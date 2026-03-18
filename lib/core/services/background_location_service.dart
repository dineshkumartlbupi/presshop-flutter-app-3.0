import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/features/task/presentation/widgets/dialog_for_continuous_location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
// URL from old project to maintain API compatibility

/// =============================================================
/// ================= SERVICE ENTRY POINT ========================
/// =============================================================
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final notifications = FlutterLocalNotificationsPlugin();

  // Initialize notifications for this isolate
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_noti_logo');

  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings();
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );
  await notifications.initialize(
    initializationSettings,
    onDidReceiveBackgroundNotificationResponse:
        internalNotificationTapBackground,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {
      // Forward foreground taps to the same handler
      internalNotificationTapBackground(notificationResponse);
    },
  );

  await prefs.setBool('stop_service_flag', false);
  _pollStopFlag(service, notifications);
  _registerIsolateStopListener(service, notifications);

  if (Platform.isAndroid) {
    await _showAndroidForegroundNotification(prefs, notifications);
  }

  _registerAndroidServiceEvents(service);

  final userId = prefs.getString('_id') ?? '';
  debugPrint("BackgroundService started for user: $userId");

  final socket = _initializeSocket(userId);
  final locationSettings = await _buildLocationSettings(prefs);

  _startLocationTracking(
    service: service,
    socket: socket,
    userId: userId,
    locationSettings: locationSettings,
  );
}

/// =============================================================
/// ================= iOS BACKGROUND CALLBACK ===================
/// =============================================================
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  debugPrint('iOS background execution triggered');
  return true;
}

/// =============================================================
/// ================= INTERNAL STOP HANDLER =====================
/// =============================================================
@pragma('vm:entry-point')
void internalNotificationTapBackground(
    NotificationResponse notificationResponse) async {
  DartPluginRegistrant.ensureInitialized();
  debugPrint(
      "DEBUG: internalNotificationTapBackground called with actionId: ${notificationResponse.actionId}");

  if (notificationResponse.actionId == 'stop_service') {
    debugPrint("DEBUG: Stop Service Tapped (Internal Handler)");

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('stop_service_flag', true);
    await prefs.setBool('manually_stopped_service', true);
    await prefs.setBool('is_task_grabbing_active', false);
    debugPrint("DEBUG: Set stop_service_flag to true and cleared active flags");

    // Cancel notification
    try {
      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin.cancel(888);
      debugPrint("DEBUG: Notification 888 cancelled");
    } catch (e) {
      debugPrint("DEBUG: Error cancelling notification: $e");
    }

    // Attempt internal stop if we are in the same isolate
    try {
      final SendPort? sendPort =
          IsolateNameServer.lookupPortByName('location_service_stop_port');
      if (sendPort != null) {
        sendPort.send('stop');
        debugPrint("DEBUG: Sent 'stop' to isolate port");
      } else {
        debugPrint("DEBUG: 'location_service_stop_port' not found");
      }
    } catch (e) {
      debugPrint("DEBUG: Error sending to isolate: $e");
    }

    // Direct stop check
    try {
      FlutterBackgroundService().invoke("stopService");
    } catch (e) {
      debugPrint("DEBUG: Error invoking stopService: $e");
    }
  }
}

/// =============================================================
/// ================= STOP SERVICE HANDLING =====================
/// =============================================================

void _pollStopFlag(
  ServiceInstance service,
  FlutterLocalNotificationsPlugin notifications,
) {
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    if (prefs.getBool('stop_service_flag') == true) {
      debugPrint("Stop flag detected");
      await prefs.setBool('stop_service_flag', false);
      notifications.cancel(888);
      service.stopSelf();
      timer.cancel();
    }
  });
}

void _registerIsolateStopListener(
  ServiceInstance service,
  FlutterLocalNotificationsPlugin notifications,
) {
  final port = ReceivePort();
  IsolateNameServer.removePortNameMapping('location_service_stop_port');
  IsolateNameServer.registerPortWithName(
    port.sendPort,
    'location_service_stop_port',
  );

  port.listen((message) {
    if (message == 'stop') {
      debugPrint("Stop signal received from notification");
      notifications.cancel(888);
      service.stopSelf();
    }
  });
}

/// =============================================================
/// ================= ANDROID NOTIFICATION ======================
/// =============================================================
Future<void> _showAndroidForegroundNotification(
  SharedPreferences prefs,
  FlutterLocalNotificationsPlugin notifications,
) async {
  const channel = AndroidNotificationChannel(
    'my_foreground',
    'Tracking Location',
    description: 'Location tracking service',
    importance: Importance.low,
  );

  await notifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await notifications.show(
    888,
    prefs.getString('svc_notification_title') ?? 'Tracking Location',
    prefs.getString('svc_notification_desc') ?? 'Location service running',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'my_foreground',
        'Tracking Location',
        icon: 'ic_noti_logo',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        actions: [
          AndroidNotificationAction(
            'stop_service',
            'Stop Service',
            showsUserInterface: false,
            cancelNotification: false,
          ),
        ],
      ),
    ),
  );
}

/// =============================================================
/// ================= ANDROID SERVICE EVENTS ====================
/// =============================================================
void _registerAndroidServiceEvents(ServiceInstance service) {
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((_) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((_) {
      service.setAsBackgroundService();
    });

    service.on('stopService').listen((_) {
      debugPrint("stopService event received");
      service.stopSelf();
    });
  }
}

/// =============================================================
/// ================= SOCKET INITIALIZATION =====================
/// =============================================================
IO.Socket _initializeSocket(String userId) {
  final socket = IO.io(
    ApiConstantsNew.config.socketUrl2,
    IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build(),
  );

  socket.connect();

  socket.onConnect((_) {
    debugPrint("Socket connected: ${socket.id}");
    if (userId.isNotEmpty) {
      socket.emit("joinHopper", userId);
    }
  });

  return socket;
}

/// =============================================================
/// ================= LOCATION SETTINGS =========================
/// =============================================================
Future<LocationSettings> _buildLocationSettings(SharedPreferences prefs) async {
  final distanceFilter = prefs.getDouble('distance_filter') ?? 0.0;

  if (Platform.isAndroid) {
    return AndroidSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: distanceFilter.toInt(),
      intervalDuration: const Duration(seconds: 1),
      forceLocationManager: true,
    );
  }

  if (Platform.isIOS) {
    return AppleSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      activityType: ActivityType.other,
      distanceFilter: distanceFilter.toInt(),
      pauseLocationUpdatesAutomatically: false,
      showBackgroundLocationIndicator: true,
    );
  }

  return LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: distanceFilter.toInt(),
  );
}

/// =============================================================
/// ================= LOCATION STREAM ===========================
/// =============================================================
void _startLocationTracking({
  required ServiceInstance service,
  required IO.Socket socket,
  required String userId,
  required LocationSettings locationSettings,
}) {
  Position? lastPosition;

  Geolocator.getPositionStream(
    locationSettings: locationSettings,
  ).listen((position) {
    double distance = 0;
    if (lastPosition != null) {
      distance = Geolocator.distanceBetween(
        lastPosition!.latitude,
        lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );
    }

    lastPosition = position;

    debugPrint("📍 ${position.latitude}, ${position.longitude}");
    debugPrint("Moved: ${distance.toStringAsFixed(2)} meters");

    if (socket.connected) {
      socket.emit("getLocation", {
        "userId": userId,
        "lat": position.latitude,
        "lng": position.longitude,
      });
    }

    service.invoke('update', {
      "latitude": position.latitude,
      "longitude": position.longitude,
      "timestamp": DateTime.now().toIso8601String(),
    });
  }, onError: (e) {
    debugPrint("Location error: $e");
  });
}

/// =============================================================
/// ================= PUBLIC CONTROLLER =========================
/// =============================================================
class BackgroundLocationService {
  static final FlutterBackgroundService service = FlutterBackgroundService();

  static Future<bool> initService({
    String? notificationTitle,
    String? notificationContent,
    double? distanceFilter,
    BuildContext? context,
    bool showPrePermissionDialog = false,
    String? dialogTitle,
    String? dialogContent,
    String? dialogImage,
    String? dialogButtonText,
    String? dialogCancelText,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (notificationTitle != null) {
      await prefs.setString('svc_notification_title', notificationTitle);
    }

    if (notificationContent != null) {
      await prefs.setString('svc_notification_desc', notificationContent);
    }

    if (distanceFilter != null) {
      await prefs.setDouble('distance_filter', distanceFilter);
    }

    if (showPrePermissionDialog && context != null) {
      final size = MediaQuery.of(context).size;
      final confirmed = await showLocationPermissionDialogWithImage(
        context: context,
        size: size,
        heading: dialogTitle,
        description: dialogContent,
        imagePath: dialogImage ?? "assets/location/location_permission.png",
        buttonText: dialogButtonText,
        cancelText: dialogCancelText,
      );

      if (confirmed != true) {
        return false; // User cancelled the custom dialog
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // permission = await Geolocator.requestPermission();
    }

    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'my_foreground',
        'Tracking Location',
        description: 'Location tracking service',
        importance: Importance.low,
      );

      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      debugPrint(
          "Debugging: Notification channel 'my_foreground' created explicitly.");
    }

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: false,
        notificationChannelId: 'my_foreground',
        initialNotificationTitle: 'Tracking Location',
        initialNotificationContent: 'Location service running',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    await service.startService();
    return true;
  }

  static Future<void> stopService() async {
    if (await service.isRunning()) {
      service.invoke("stopService");
    }
  }
}
