import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:presshop/main.dart';

import '../view/dashboard/Dashboard.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {

 // debugPrint('Handling a background message ${message.datalocalNotificationService}');
  debugPrint('notification_type::::::: ${message.data["notification_type"].toString()}');
  debugPrint('message.data::::::${message.data}');

  if(message.data.isNotEmpty && message.data["notification_type"].toString() == "media_house_tasks"){
    localNotificationService.flutterLocalNotificationsPlugin.cancelAll();
    debugPrint("Inside Background notification");
    localNotificationService.showFlutterNotificationWithSound(message);
  }

  debugPrint('Handling a background message ${message.messageId}');
}

final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

const MethodChannel platform = MethodChannel('presshop');

const String portName = 'notification_send_port';

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

String? selectedNotificationPayload;

/// A notification action which triggers a url launch event
const String urlLaunchActionId = 'id_1';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print('notification action tapped with input: ${notificationResponse.input}');
  }
}

@pragma('vm:entry-point')
void onDidReceiveNotificationResponse(
    NotificationResponse? notificationResponse) async {
  debugPrint("onDidReceiveNotificationResponse local: ${notificationResponse.toString()} ");

}


class LocalNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> setup() async {

    /// Notification Permission For Android 12 or Android 13 Versions
    if (Platform.isAndroid) {
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    }else{
       flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('ic_noti_logo');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      // onDidReceiveLocalNotification:
      //     (int id, String? title, String? body, String? payload) async {
      //   didReceiveLocalNotificationStream.add(
      //     ReceivedNotification(
      //       id: id,
      //       title: title,
      //       body: body,
      //       payload: payload,
      //     ),
      //   );
      // },
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );


    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        debugPrint(":::: Inside Local Notification When App Background ::::");
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:

            if (notificationResponse.payload != null &&
                notificationResponse.payload!.isNotEmpty) {
              var taskDetail =
              jsonDecode(notificationResponse.payload!);
              if (taskDetail["notification_type"].toString() == "media_house_tasks") {
                Navigator.pushAndRemoveUntil(navigatorKey.currentContext!, MaterialPageRoute(builder: (context)=>Dashboard(initialPosition: 2,)), (route) => false);
              }
            }

            selectNotificationStream.add(notificationResponse.payload);
            break;
          case NotificationResponseType.selectedNotificationAction:
            if (notificationResponse.actionId == navigationActionId) {
              selectNotificationStream.add(notificationResponse.payload);
            }
            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      debugPrint("android is not null------>");
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            "presshop",
            "presshop",
            channelDescription: "Android_Channel",
            importance: Importance.high,
            priority: Priority.high,
            color: Colors.black,
            playSound: true,
            category: AndroidNotificationCategory.message,
            styleInformation: BigTextStyleInformation(notification.body ?? "")
          ),
            iOS: const DarwinNotificationDetails(
              presentSound: true,
              presentBadge: true,
              presentAlert: true,
            )
        ),
      );
    }
  }


  void showFlutterNotificationWithSound(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails("presshop_custom_sound", "presshop_custom_sound",
              channelDescription: "Android_Channel_custom_sound",
              importance: Importance.high,
              priority: Priority.high,
              color: Colors.black,
              sound: const RawResourceAndroidNotificationSound('bell2'),
              playSound: true,
              enableVibration: true,
              audioAttributesUsage: AudioAttributesUsage.alarm,
              category: AndroidNotificationCategory.message,
              styleInformation: BigTextStyleInformation(notification.body ?? "")),
          iOS: const DarwinNotificationDetails(
            presentSound: true,
            presentBadge: true,
            presentAlert: true,

          )

        ),
        payload: jsonEncode(message.data)
      );
    }
  }
}
