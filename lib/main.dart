import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:presshop/features/camera/presentation/pages/PreviewScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core imports
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/services/app_initialization_service.dart';
import 'package:presshop/core/services/deeplink_service.dart';
import 'package:presshop/core/services/media_upload_service.dart';

// App widget
import 'package:presshop/app.dart';

// ============================================================================
// GLOBAL VARIABLES
// ============================================================================

final navigatorKey = GlobalKey<NavigatorState>();
GoogleSignIn googleSignIn = GoogleSignIn();
bool rememberMe = false;
FacebookAppEvents facebookAppEvents = FacebookAppEvents();
SharedPreferences? sharedPreferences;
final player = AudioPlayer();
const iOSLocalizedLabels = false;
String currencySymbol = "";

List<CameraDescription> cameras = <CameraDescription>[];
LocalNotificationService localNotificationService = LocalNotificationService();
List<MediaData> contentMediaList = [];

// ============================================================================
// MAIN ENTRY POINT
// ============================================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Load environment variables
  await AppInitializationService.loadEnvironment();
  
  // 2. Initialize dependency injection
  await AppInitializationService.initializeDI();
  
  // 3. Log app open event
  AppInitializationService.logAppOpenEvent();

  // 4. Set system UI preferences
  AppInitializationService.setSystemUIPreferences();

  // 5. Initialize Firebase
  await AppInitializationService.initializeFirebase();

  // 6. Get device information
  final deviceInfo = await AppInitializationService.getDeviceInfo();

  // 7. Initialize cameras
  await AppInitializationService.initializeCameras();

  // 8. Initialize SharedPreferences and setup app
  await AppInitializationService.initializeSharedPreferences(deviceInfo);
  
  // 9. Setup error handlers
  AppInitializationService.setupErrorHandlers();
  
  // 10. Initialize AppsFlyer if needed
  await AppInitializationService.initializeAppsFlyerIfNeeded();
  
  // 11. Set Crashlytics identity
  AppInitializationService.setCrashlyticsIdentity();
  
  // 12. Setup audio player
  AppInitializationService.setupAudioPlayer();

  // 13. Run the app
  runApp(const MyApp());
}

// ============================================================================
// GLOBAL UTILITY FUNCTIONS
// ============================================================================

/// Callback function for deeplink API
Future<void> onDeeplinkCallbackApi(
  String data,
  bool isAppInstallCallback,
) async {
  await DeeplinkService.sendCallback(data, isAppInstallCallback);
}

/// Upload media using Dio with progress tracking
Future<void> uploadMediaUsingDio(
  String endUrl,
  Map<String, String>? jsonBody,
  List filePathList,
  String imageParams,
) async {
  await MediaUploadService.uploadMedia(
    endUrl: endUrl,
    jsonBody: jsonBody,
    filePathList: filePathList,
    imageParams: imageParams,
  );
}
