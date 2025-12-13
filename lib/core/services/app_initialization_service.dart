import 'dart:io';
import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:presshop/core/di/injection_container.dart' as di;
import 'package:presshop/core/services/appsflyer_service.dart';
import 'package:presshop/core/services/local_notification_service.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:presshop/firebase_options.dart';
import 'package:presshop/main.dart';

/// Service for handling app initialization tasks
class AppInitializationService {
  /// Load environment variables
  static Future<void> loadEnvironment() async {
    try {
      await dotenv.load(fileName: ".env");
      debugPrint("✅ Environment variables loaded");
    } catch (e) {
      debugPrint("⚠️ .env file not found. Using fallback values for API keys.");
    }
  }

  /// Initialize dependency injection
  static Future<void> initializeDI() async {
    try {
      await di.init();
      debugPrint("✅ Dependency Injection initialized");
    } catch (e) {
      debugPrint("❌ DI initialization error: $e");
    }
  }

  /// Set system UI preferences
  static void setSystemUIPreferences() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
      ),
    );

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    debugPrint("✅ System UI preferences set");
  }

  /// Initialize Firebase services
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      await localNotificationService.setup();
      
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      
      debugPrint("✅ Firebase initialized");
    } catch (e) {
      debugPrint("❌ Firebase initialization error: $e");
    }
  }

  /// Get device information
  static Future<IosDeviceInfo?> getDeviceInfo() async {
    if (Platform.isIOS) {
      try {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        final info = await deviceInfo.iosInfo;
        debugPrint("✅ Device info retrieved: ${info.model}");
        return info;
      } catch (e) {
        debugPrint("❌ Device info error: $e");
      }
    }
    return null;
  }

  /// Initialize cameras
  static Future<void> initializeCameras() async {
    try {
      cameras = await availableCameras();
      debugPrint("✅ Cameras initialized: ${cameras.length} found");
    } on CameraException catch (e) {
      debugPrint("❌ Camera initialization error: $e");
    }
  }

  /// Initialize SharedPreferences and related services
  static Future<void> initializeSharedPreferences(IosDeviceInfo? deviceInfo) async {
    try {
      sharedPreferences = await getSharedPreferences();
      
      // Set iPad flag
      sharedPreferences!.setBool(
        "isIpad",
        Platform.isAndroid
            ? false
            : deviceInfo?.model.toLowerCase().contains("ipad") ?? false,
      );

      // Get remember me preference
      if (sharedPreferences!.getBool(rememberKey) != null) {
        rememberMe = sharedPreferences!.getBool(rememberKey)!;
      }

      // Set currency symbol
      currencySymbol = sharedPreferences!.getString(currencySymbolKey) ?? "£";
      
      debugPrint("✅ SharedPreferences initialized");
    } catch (e) {
      debugPrint("❌ SharedPreferences initialization error: $e");
    }
  }

  /// Setup error handlers for Crashlytics
  static void setupErrorHandlers() {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    
    debugPrint("✅ Error handlers configured");
  }

  /// Set Crashlytics user identity
  static void setCrashlyticsIdentity() {
    try {
      final name = sharedPreferences?.getString(adminNameKey);
      final email = sharedPreferences?.getString(emailKey);
      
      if (email != null) {
        FirebaseCrashlytics.instance.setUserIdentifier(email);
      }
      if (name != null) {
        FirebaseCrashlytics.instance.setCustomKey("name", name.toString());
      }
      
      debugPrint("✅ Crashlytics identity set");
    } on Exception catch (e) {
      debugPrint("❌ Crashlytics identity error: $e");
    }
  }

  /// Initialize AppsFlyer if needed
  static Future<void> initializeAppsFlyerIfNeeded() async {
    if (!rememberMe) {
      try {
        await AppsFlyerService.initialize();
      } catch (e) {
        debugPrint("❌ AppsFlyer initialization error: $e");
      }
    }
  }

  /// Setup audio player
  static void setupAudioPlayer() {
    player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        player.play(
          AssetSource('audio/task_sound.mp3'),
          volume: 1,
        );
      }
    });
    
    debugPrint("✅ Audio player configured");
  }

  /// Log app open event to Facebook
  static void logAppOpenEvent() {
    try {
      facebookAppEvents.logEvent(
        name: "app_open",
        parameters: {
          "app_name": "Presshop",
          "platform": Platform.operatingSystem,
          "version": Platform.version,
        },
      );
      debugPrint("✅ App open event logged");
    } catch (e) {
      debugPrint("❌ Facebook event logging error: $e");
    }
  }
}
