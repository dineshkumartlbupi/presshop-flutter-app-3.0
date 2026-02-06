import 'dart:io';
import 'package:dio/dio.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/features/dashboard/presentation/pages/version_checker.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ForceUpdateRepository {
  static const String endpoint = "auth/getLatestVersion";

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstantsNew.config.baseUrl,
      connectTimeout: Duration(seconds: 20),
      receiveTimeout: Duration(seconds: 20),
    ),
  );
// sdfsd
  // ------------------------------------------
  // MAIN CALL
  // ------------------------------------------
  static Future<bool> checkForceUpdate() async {
    try {
      final headers = await _prepareHeaders();

      final response = await _dio.get(
        endpoint,
        options: Options(headers: headers),
      );

      if (response.data["code"] != 200) return false;

      final data = response.data["data"];
      print("forceupdateddata");
      print(data);

      bool updateAvailable = await VersionService.isUpdateAvailable(
        androidPackage: "com.presshop.app",
        iosAppId: "6744651614",
      );

      if (!updateAvailable) return false;

      if (Platform.isAndroid) return data["aOSshouldForceUpdate"] == true;
      if (Platform.isIOS) return data["iOSshouldForceUpdate"] == true;

      return false;
    } on DioException catch (e) {
      // ------------------------------------------
      // HANDLE 401 → ATTEMPT REFRESH TOKEN
      // ------------------------------------------
      if (e.response?.statusCode == 401) {
        bool refreshed = await _refreshToken();

        if (refreshed) {
          return await checkForceUpdate();
        } else {
          return false;
        }
      }

      return false;
    }
  }

  // ------------------------------------------
  // PREPARE HEADERS LIKE NetworkClass
  // ------------------------------------------
  static Future<Map<String, String>> _prepareHeaders() async {
    final headers = <String, String>{};

    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: tokenKey);
    String? deviceId = sharedPreferences!.getString(deviceIdKey);

    if (token != null) {
      headers[headerKey] = token;
    }
    headers[headerDeviceTypeKey] =
        "mobile-flutter-${Platform.isIOS ? "ios" : "android"}";
    headers[headerDeviceIdKey] = deviceId ?? "";

    return headers;
  }

  // ------------------------------------------
  // REFRESH TOKEN (same system as NetworkClass)
  // ------------------------------------------
  static Future<bool> _refreshToken() async {
    try {
      const storage = FlutterSecureStorage();
      String? refresh = await storage.read(key: refreshtokenKey);
      String? accessToken = await storage.read(key: tokenKey);
      String? deviceId = sharedPreferences!.getString(deviceIdKey);

      if (refresh == null) return false;

      final response = await _dio.post(
        ApiConstantsNew.auth.refreshToken,
        options: Options(headers: {
          refreshHeaderKey: refresh,
          accessHeaderKey: refresh.isEmpty ? (accessToken ?? "") : "",
          headerDeviceTypeKey:
              "mobile-flutter-${Platform.isIOS ? "ios" : "android"}",
          headerDeviceIdKey: deviceId ?? "",
        }),
      );

      if (response.statusCode == 200 &&
          response.data["data"] != null &&
          response.data["data"]["token"] != null) {
        // SAVE NEW TOKENS
        await storage.write(
            key: tokenKey, value: response.data["data"]["token"]);
        await storage.write(
            key: refreshtokenKey, value: response.data["data"]["refreshToken"]);

        // Also update shared prefs for consistency if needed by other parts
        sharedPreferences!.setString(tokenKey, response.data["data"]["token"]);
        sharedPreferences!
            .setString(refreshtokenKey, response.data["data"]["refreshToken"]);

        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}
