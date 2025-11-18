import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/view/splash/repository/force_update_repository.dart';
// import 'package:flutter_foreground_service/flutter_foreground_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:presshop/utils/AnalyticsHelper.dart';
import 'package:presshop/utils/AnalyticsMixin.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonSharedPrefrence.dart';
import 'package:presshop/utils/LocalNotificationService.dart';
import 'package:presshop/view/cameraScreen/PreviewScreen.dart';
import 'package:presshop/view/splash/SplashScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:force_update_helper/force_update_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

final navigatorKey = GlobalKey<NavigatorState>();
GoogleSignIn googleSignIn = GoogleSignIn();
bool rememberMe = false;
FacebookAppEvents facebookAppEvents = FacebookAppEvents();
SharedPreferences? sharedPreferences;
final player = AudioPlayer();
const iOSLocalizedLabels = false;
String currencySymbol = "";
// AppsFlyer SDK instance
late AppsflyerSdk _appsflyerSdk;

List<CameraDescription> cameras = <CameraDescription>[];
LocalNotificationService localNotificationService = LocalNotificationService();

List<MediaData> contentMediaList = [];

Future<void> initializeAppsFlyer() async {
  final AppsFlyerOptions appsFlyerOptions = AppsFlyerOptions(
    appId: "6744651614",
    afDevKey: "bxvwnv53n3J7eKMAiDmX7J",
    showDebug: false,
    timeToWaitForATTUserAuthorization: 40,
  );
  _appsflyerSdk = AppsflyerSdk(appsFlyerOptions);
  // Listen to install conversion data
  _appsflyerSdk.onInstallConversionData((data) {
    // Print each key-value pair for better readability
    if (data is Map) {
      data.forEach((key, value) {
        debugPrint("$key: $value");
      });
    }
    // Convert data to string
    String dataString = data.toString();
    debugPrint("Data as string: $dataString");
    onDeeplinkCallbackApi(dataString, true);
  });

  // Listen to app open attribution
  _appsflyerSdk.onAppOpenAttribution((data) {
    if (data is Map) {
      data.forEach((key, value) {
        debugPrint("$key: $value");
      });
    }
    // Convert data to string
    String dataString = data.toString();
    onDeeplinkCallbackApi(dataString, false);
  });

  // Initialize the SDK
  await _appsflyerSdk.initSdk(
    registerConversionDataCallback: true,
    registerOnAppOpenAttributionCallback: true,
  );

  debugPrint("AppsFlyer SDK initialized successfully");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  facebookAppEvents.logEvent(
    name: "app_open",
    parameters: {
      "app_name": "Presshop",
      "platform": Platform.operatingSystem,
      "version": Platform.version,
    },
  );

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark));

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  late IosDeviceInfo? info;
  if (Platform.isIOS) {
    info = await deviceInfo.iosInfo;
  }

  await localNotificationService.setup();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint("CameraException: $e");
  }

  getSharedPreferences().then((value) async {
    sharedPreferences = value;
    sharedPreferences!.setBool(
        "isIpad",
        Platform.isAndroid
            ? false
            : info!.model.toLowerCase().contains("ipad"));

    if (sharedPreferences!.getBool(rememberKey) != null) {
      rememberMe = sharedPreferences!.getBool(rememberKey)!;
    }
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    if (!rememberMe) {
      // Initialize AppsFlyer SDK
      await initializeAppsFlyer();
    }
    setCrashlyticsIdentity();
    currencySymbol = sharedPreferences!.getString(currencySymbolKey) ?? "£";
    player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        player.play(
          AssetSource('audio/task_sound.mp3'),
          volume: 1,
        );
      }
    });

    runApp(
      MaterialApp(
        navigatorKey: navigatorKey,
        builder: (context, child) {
          return ForceUpdateWidget(
            navigatorKey: navigatorKey,
            forceUpdateClient: ForceUpdateClient(
              fetchRequiredVersion: () async {
                try {
                  final force = await ForceUpdateRepository.checkForceUpdate();
                  print("forceupdateddata $force");

                  if (force) return "999.0.0";

                  final info = await PackageInfo.fromPlatform();
                  return info.version;
                } catch (e) {
                  print("Force update check failed: $e");

                  // Use global navigator key to show snackbar
                  if (context != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Failed to check updates."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }

                  // Fallback: let app continue normally
                  final info = await PackageInfo.fromPlatform();
                  return info.version;
                }
              },
              iosAppStoreId: '6744651614',
            ),
            allowCancel: false,
            showForceUpdateAlert: (context, allowCancel) {
              final size = MediaQuery.of(context).size;
              return showDialog(
                context: context,
                barrierDismissible: allowCancel,
                builder: (context) {
                  return AlertDialog(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      contentPadding: EdgeInsets.zero,
                      insetPadding:
                          EdgeInsets.symmetric(horizontal: size.width * numD04),
                      content: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    size.width * numD045)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: size.width * numD04,
                                      top: size.width * numD02),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Update Required",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: size.width * numD04,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size.width * numD04),
                                  child: const Divider(
                                    color: Colors.black,
                                    thickness: 0.5,
                                  ),
                                ),
                                SizedBox(
                                  height: size.width * numD02,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size.width * numD04),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              size.width * numD04),
                                        ),
                                        child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                size.width * numD04),
                                            child: Image.asset(
                                              "${commonImagePath}dog.png",
                                              height: size.width * numD25,
                                              width: size.width * numD35,
                                              fit: BoxFit.cover,
                                            )),
                                      ),
                                      SizedBox(
                                        width: size.width * numD04,
                                      ),
                                      Expanded(
                                        child: Text(
                                          "A newer version of PressHop is available. Please update the app to continue using all features smoothly.",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: size.width * numD035,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: size.width * numD08,
                                ),
                                SizedBox(
                                  height: size.width * numD12,
                                  width: size.width * numD35,
                                  child: commonElevatedButton(
                                    "Update Now",
                                    size,
                                    commonButtonTextStyle(size),
                                    commonButtonStyle(size, colorThemePink),
                                    _openStore,
                                  ),
                                ),
                                SizedBox(
                                  height: size.width * numD05,
                                ),
                              ],
                            ),
                          );
                        },
                      ));
                },
              );
            },
            showStoreListing: (Uri storeUrl) async {},
            child: child ?? const SizedBox(),
          );
        },
        debugShowCheckedModeBanner: false,
        navigatorObservers: [
          AnalyticsHelper.observer,
          AnalyticsRouteObserver(),
        ],
        theme: ThemeData(
          fontFamily: "AirbnbCereal",
          scaffoldBackgroundColor: Colors.white,
          useMaterial3: false,
        ),
        home: const SplashScreen(),
      ),
    );
  });
}

Future<void> onDeeplinkCallbackApi(
    String data, bool isAppInstallCallback) async {
  try {
    Dio dio = Dio(
      BaseOptions(
        baseUrl: adminBaseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    Response response = await dio.post(
      isAppInstallCallback ? onAppInstallCallback : onDeeplinkCallback,
      data: {"data": data},
    );

    if (response.statusCode! <= 201) {
      debugPrint("Deeplink callback success: ${response.data}");
      // Handle success response
      // onDeeplinkCallback(response.data);
    } else {
      debugPrint(
          "Deeplink callback failed with status code: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("Deeplink callback error: $e");
  }
}

Future<void> uploadMediaUsingDio(
  String endUrl,
  Map<String, String>? jsonBody,
  List filePathList,
  String imageParams,
) async {
  // ForegroundService().start();
  await WakelockPlus.enable();
  Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 120),
    ),
  );
  FormData formData = FormData();
  if (filePathList.isNotEmpty) {
    for (var element in filePathList) {
      var mimeType = lookupMimeType(element.path);
      debugPrint("MediaMime: $mimeType");
      mimeType ??= "video/mp4";
      if (mimeType != null) {
        // var mArray = mimeType.split("/");
        // formData.files.add(MapEntry(
        //   imageParams,
        //   await MultipartFile.fromFile(element.path, contentType: MediaType(mArray.first, mArray.last)),
        // ));

        var mArray = mimeType.split("/");
        var file = await MultipartFile.fromFile(
          element.path,
          contentType: MediaType(mArray.first, mArray.last),
        );
        formData.files.add(MapEntry(imageParams, file));

        // **Print file details**
        // debugPrint("Adding File:");
        // debugPrint("Path: ${element.path}");
        debugPrint("MimeType: $mimeType");
        // debugPrint("Size: ${await element.length()} bytes");
      }
    }
  }

  if (sharedPreferences!.getString(tokenKey) != null) {
    dio.options.headers = {
      "Authorization": "Bearer ${sharedPreferences!.getString(tokenKey)!}",
    };
  }

  if (jsonBody != null && jsonBody.isNotEmpty) {
    jsonBody.forEach((key, value) {
      formData.fields.add(MapEntry(key, value.toString()));
    });
  }

  try {
    log("callAddContentApi finished" + DateTime.now().toString());
    Response response = await dio.post(
      baseUrl + endUrl,
      data: formData,
      onSendProgress: (int sent, int total) {
        int progress = ((sent / total) * 100).toInt();
        debugPrint("progress:::::$progress");

        if ((progress >= 1 &&
                progress <= 10 &&
                (sharedPreferences!.getBool('notify_10') ?? true)) ||
            (progress >= 30 &&
                progress <= 40 &&
                (sharedPreferences!.getBool('notify_40') ?? true)) ||
            (progress >= 80 &&
                progress <= 90 &&
                (sharedPreferences!.getBool('notify_90') ?? true))) {
          _showProgressNotification(
              localNotificationService.flutterLocalNotificationsPlugin,
              progress,
              isDraft: jsonBody?['is_draft'] == 'true');

          if (progress <= 10) sharedPreferences!.setBool('notify_10', false);
          if (progress <= 40) sharedPreferences!.setBool('notify_40', false);
          if (progress <= 90) sharedPreferences!.setBool('notify_90', false);
        } else if (progress == 100) {
          // Reset notification flags for next upload
          sharedPreferences!.remove('notify_10');
          sharedPreferences!.remove('notify_40');
          sharedPreferences!.remove('notify_90');
          _showProgressNotification(
              localNotificationService.flutterLocalNotificationsPlugin,
              progress,
              isDraft: jsonBody?['is_draft'] == 'true');
        }
      },
    );
    debugPrint("add content success::: ${response.data}");
    if (response.statusCode! <= 201) {
      debugPrint("Upload successful: ${response.data}");
      /* var map = jsonDecode(response.data);
      MyContentData detail = MyContentData.fromJson(map["data"] ?? {});*/
      localNotificationService.flutterLocalNotificationsPlugin.cancel(0);
      _showCompletionNotification(
          localNotificationService.flutterLocalNotificationsPlugin,
          isDraft: jsonBody?['is_draft'] == 'true');
    } else {
      _failedNotification(
          localNotificationService.flutterLocalNotificationsPlugin);
      debugPrint("Upload failed with status code: ${response.statusCode}");
      debugPrint("add content error:::: ${jsonDecode(response.data)}");
    }
    // ForegroundService().stop();
  } catch (e) {
    debugPrint("Error: $e");
    _failedNotification(
        localNotificationService.flutterLocalNotificationsPlugin);
    await WakelockPlus.disable();
  } finally {
    await WakelockPlus.disable();
  }
}

void _showProgressNotification(
    FlutterLocalNotificationsPlugin notificationPlugin, int progress,
    {bool isDraft = false}) {
  notificationPlugin.show(
    0,
    isDraft ? "Saving draft" : 'Uploading Content',
    'Progress: $progress%',
    NotificationDetails(
      android: AndroidNotificationDetails(
        'upload_channel',
        'Video Upload',
        importance: Importance.max,
        priority: Priority.high,
        showProgress: true,
        maxProgress: 100,
        progress: progress,
      ),
    ),
  );
}

void _failedNotification(FlutterLocalNotificationsPlugin notificationPlugin) {
  notificationPlugin.show(
    0,
    'Upload Failed',
    'There was an error uploading the video.',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'upload_channel',
        'Video Upload',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
  );
}

void _showCompletionNotification(
    FlutterLocalNotificationsPlugin notificationPlugin,
    {bool isDraft = false}) {
  notificationPlugin.show(
    0,
    'Upload Complete',
    isDraft
        ? "Draft saved successfully"
        : 'Your Media has been uploaded successfully.',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'upload_channel',
        'Video Upload',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
  );
}

void setCrashlyticsIdentity() {
  try {
    final name = sharedPreferences?.getString(adminNameKey);
    final email = sharedPreferences?.getString(emailKey);
    if (email != null) {
      FirebaseCrashlytics.instance.setUserIdentifier(email);
    }
    if (name != null) {
      FirebaseCrashlytics.instance.setCustomKey("name", name.toString());
    }
  } on Exception catch (_, ex) {
    debugPrint("Exception $ex");
  }
}

void _openStore() async {
  FirebaseCrashlytics.instance.log("User clicked Update Now");
  FirebaseAnalytics.instance.logEvent(name: "user_update_now_click");

  final url = Platform.isAndroid
      ? 'https://play.google.com/store/apps/details?id=com.presshop.app'
      : 'https://apps.apple.com/app/id6744651614';

  try {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    FirebaseAnalytics.instance.logEvent(
      name: "store_launch_error",
      parameters: {"error": e.toString()},
    );
    showSnackBar("Error", "Could not open store", Colors.red);
  }
}
