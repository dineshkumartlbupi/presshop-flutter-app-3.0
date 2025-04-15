import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_service/flutter_foreground_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonSharedPrefrence.dart';
import 'package:presshop/utils/LocalNotificationService.dart';
import 'package:presshop/view/cameraScreen/PreviewScreen.dart';
import 'package:presshop/view/splash/SplashScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();
GoogleSignIn googleSignIn = GoogleSignIn();
bool rememberMe = false;
SharedPreferences? sharedPreferences;

const iOSLocalizedLabels = false;

List<CameraDescription> cameras = <CameraDescription>[];
LocalNotificationService localNotificationService = LocalNotificationService();

List<MediaData> contentMediaList = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  await localNotificationService.setup();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint("CameraException: $e");
  }

  getSharedPreferences().then((value) {
    sharedPreferences = value;
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
    setCrashlyticsIdentity();
    debugPrint("IsItRemember:::: $rememberMe");
    runApp(MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: "AirbnbCereal",
          scaffoldBackgroundColor: Colors.white,
          useMaterial3: false),
      // home: const SplashScreen(),
      home: const SplashScreen(),
    ));
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'image_watermark',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

Future<void> uploadMediaUsingDio(
  String endUrl,
  Map<String, String>? jsonBody,
  List filePathList,
  String imageParams,
) async {
  ForegroundService().start();
  Dio dio = Dio();
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
    Response response = await dio.post(
      baseUrl + endUrl,
      data: formData,
      onSendProgress: (int sent, int total) {
        int progress = ((sent / total) * 100).toInt();
        bool isUploadStarted = false;
        bool isUploadCompleted = false;
        debugPrint("progress:::::$progress");

        if (progress == 2 && !isUploadStarted) {
          isUploadStarted = true; // Track that the upload has started
          _showProgressNotification(
              localNotificationService.flutterLocalNotificationsPlugin,
              progress);
        }

        if (progress > 2 && progress < 100 && progress % 2 == 0) {
          //  _showCompletionNotification(localNotificationService.flutterLocalNotificationsPlugin);
        }

        if (progress == 100 && !isUploadCompleted) {
          isUploadCompleted = true;
          _showProgressNotification(
              localNotificationService.flutterLocalNotificationsPlugin,
              progress);
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
          localNotificationService.flutterLocalNotificationsPlugin);
    } else {
      debugPrint("Upload failed with status code: ${response.statusCode}");
      debugPrint("add content error:::: ${jsonDecode(response.data)}");
    }

    ForegroundService().stop();
  } catch (e) {
    debugPrint("Error: $e");
    ForegroundService().stop();
  }
}

void _showProgressNotification(
    FlutterLocalNotificationsPlugin notificationPlugin, int progress) {
  notificationPlugin.show(
    0,
    'Uploading Content',
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

void _showCompletionNotification(
    FlutterLocalNotificationsPlugin notificationPlugin) {
  notificationPlugin.show(
    0,
    'Upload Complete',
    'Your Media has been uploaded successfully.',
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

void _showErrorNotification(
    FlutterLocalNotificationsPlugin notificationPlugin) {
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
