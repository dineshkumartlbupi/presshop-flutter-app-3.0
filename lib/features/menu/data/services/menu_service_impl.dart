import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:presshop/features/menu/domain/services/menu_service.dart';
import 'package:presshop/main.dart';

class MenuServiceImpl implements MenuService {
  final GoogleSignIn googleSignIn;

  MenuServiceImpl({required this.googleSignIn});

  @override
  Future<String> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId = "";
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? "";
      }
    } catch (e) {
      // Ignore
    }
    return deviceId;
  }

  @override
  Future<void> clearSession() async {
    try {
      // Updating global variable from main.dart
      rememberMe = false;

      await FirebaseAnalytics.instance.logEvent(
        name: 'device_token_removed',
        parameters: {
          'message': 'Device token removed successfully',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Ignore
    }
  }

  @override
  Future<void> googleSignOut() async {
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }
  }
}
