import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:presshop/features/camera/presentation/pages/preview_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/services/app_initialization_service.dart';
import 'package:presshop/core/services/deeplink_service.dart';
import 'package:presshop/core/services/media_upload_service.dart';
import 'package:presshop/app.dart';
import 'dart:io';
import 'package:presshop/core/utils/http_overrides.dart';

final navigatorKey = GlobalKey<NavigatorState>();
GoogleSignIn googleSignIn = GoogleSignIn();
bool rememberMe = false;

SharedPreferences? sharedPreferences;
final player = AudioPlayer();
const iOSLocalizedLabels = false;
String currencySymbol = "";

List<CameraDescription> cameras = <CameraDescription>[];
LocalNotificationService localNotificationService = LocalNotificationService();
List<MediaData> contentMediaList = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  await AppInitializationService.loadEnvironment();
  await AppInitializationService.initializeDI();
  await AppInitializationService.initializeHive();
  AppInitializationService.logAppOpenEvent();
  AppInitializationService.setSystemUIPreferences();
  await AppInitializationService.initializeFirebase();
  final deviceInfo = await AppInitializationService.getDeviceInfo();
  await AppInitializationService.initializeCameras();
  await AppInitializationService.initializeSharedPreferences(deviceInfo);
  AppInitializationService.setupErrorHandlers();
  AppInitializationService.setupAudioPlayer();

  final storage = FlutterSecureStorage();
  String? token = await storage.read(key: SharedPreferencesKeys.tokenKey);
  if (token == null || token.isEmpty) {
    token = sharedPreferences?.getString(SharedPreferencesKeys.tokenKey);
    debugPrint("🔍 CHECKING TOKEN (SharedPreferences Fallback): $token");
  } else {
    debugPrint("🔍 CHECKING TOKEN (SecureStorage): $token");
  }

  runApp(const MyApp());
}

Future<void> onDeeplinkCallbackApi(
  String data,
  bool isAppInstallCallback,
) async {
  await DeeplinkService.sendCallback(data, isAppInstallCallback);
}

Future<bool> uploadMediaUsingDio(
  String endUrl,
  Map<String, String>? jsonBody,
  List filePathList,
  String imageParams, {
  Map<String, String>? additionalFiles,
}) async {
  return await MediaUploadService.uploadMedia(
    endUrl: endUrl,
    jsonBody: jsonBody,
    filePathList: filePathList,
    imageParams: imageParams,
    additionalFiles: additionalFiles,
  );
}
