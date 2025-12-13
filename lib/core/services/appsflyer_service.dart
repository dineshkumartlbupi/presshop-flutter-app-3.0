import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:presshop/main.dart';

/// Service for handling AppsFlyer SDK initialization and callbacks
class AppsFlyerService {
  static late AppsflyerSdk _appsflyerSdk;

  /// Initialize AppsFlyer SDK with app configuration
  static Future<void> initialize() async {
    final AppsFlyerOptions appsFlyerOptions = AppsFlyerOptions(
      appId: "6744651614",
      afDevKey: "bxvwnv53n3J7eKMAiDmX7J",
      showDebug: false,
      timeToWaitForATTUserAuthorization: 40,
    );
    
    _appsflyerSdk = AppsflyerSdk(appsFlyerOptions);
    
    // Listen to install conversion data
    _appsflyerSdk.onInstallConversionData((data) {
      if (data is Map) {
        data.forEach((key, value) {
          debugPrint("AppsFlyer Install Data - $key: $value");
        });
      }
      String dataString = data.toString();
      debugPrint("AppsFlyer Install Data String: $dataString");
      onDeeplinkCallbackApi(dataString, true);
    });

    // Listen to app open attribution
    _appsflyerSdk.onAppOpenAttribution((data) {
      if (data is Map) {
        data.forEach((key, value) {
          debugPrint("AppsFlyer Attribution - $key: $value");
        });
      }
      String dataString = data.toString();
      onDeeplinkCallbackApi(dataString, false);
    });

    // Initialize the SDK
    await _appsflyerSdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
    );

    debugPrint("✅ AppsFlyer SDK initialized successfully");
  }

  /// Get the AppsFlyer SDK instance
  static AppsflyerSdk get instance => _appsflyerSdk;
}
