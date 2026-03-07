import 'dart:io';
import 'package:dio/dio.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/features/dashboard/presentation/pages/version_checker.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:presshop/core/utils/current_user.dart';

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

      bool shouldForce = false;
      if (Platform.isAndroid) {
        shouldForce = data["aOSshouldForceUpdate"] == true;
      }
      if (Platform.isIOS) {
        shouldForce = data["iOSshouldForceUpdate"] == true;
      }

      if (!shouldForce) return false;

      // Extract country list from API data
      List<String> requiredCountries = [];
      if (data["country"] != null) {
        requiredCountries = List<String>.from(data["country"]);
      }

      // If country is specified, check if user falls into that bucket
      if (requiredCountries.isNotEmpty) {
        String? userCountryCode = CurrentUser.user?.countryCode ??
            sharedPreferences!.getString(SharedPreferencesKeys.countryCodeKey);
        String? userCountryName =
            sharedPreferences!.getString(SharedPreferencesKeys.countryKey);

        bool matchFound = false;
        for (var country in requiredCountries) {
          String target = country.toLowerCase();
          if ((userCountryCode != null &&
                  userCountryCode.toLowerCase().contains(target)) ||
              (userCountryName != null &&
                  userCountryName.toLowerCase().contains(target))) {
            matchFound = true;
            break;
          }
        }
        return matchFound;
      }

      // If no targeted countries, apply forced update globally
      return true;
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
    String? token = await storage.read(key: SharedPreferencesKeys.tokenKey);
    String? deviceId =
        sharedPreferences!.getString(SharedPreferencesKeys.deviceIdKey);

    if (token != null) {
      headers[SharedPreferencesKeys.headerKey] = token;
    }
    headers[SharedPreferencesKeys.headerDeviceTypeKey] =
        "mobile-flutter-${Platform.isIOS ? "ios" : "android"}";
    headers[SharedPreferencesKeys.headerDeviceIdKey] = deviceId ?? "";

    return headers;
  }

  // ------------------------------------------
  // REFRESH TOKEN (same system as NetworkClass)
  // ------------------------------------------
  static Future<bool> _refreshToken() async {
    try {
      const storage = FlutterSecureStorage();
      String? refresh =
          await storage.read(key: SharedPreferencesKeys.refreshtokenKey);
      String? accessToken =
          await storage.read(key: SharedPreferencesKeys.tokenKey);
      String? deviceId =
          sharedPreferences!.getString(SharedPreferencesKeys.deviceIdKey);

      if (refresh == null) return false;

      final response = await _dio.post(
        ApiConstantsNew.auth.refreshToken,
        options: Options(headers: {
          SharedPreferencesKeys.refreshHeaderKey: refresh,
          SharedPreferencesKeys.accessHeaderKey:
              refresh.isEmpty ? (accessToken ?? "") : "",
          SharedPreferencesKeys.headerDeviceTypeKey:
              "mobile-flutter-${Platform.isIOS ? "ios" : "android"}",
          SharedPreferencesKeys.headerDeviceIdKey: deviceId ?? "",
        }),
      );

      if (response.statusCode == 200 &&
          response.data["data"] != null &&
          response.data["data"]["token"] != null) {
        // SAVE NEW TOKENS
        await storage.write(
            key: SharedPreferencesKeys.tokenKey,
            value: response.data["data"]["token"]);
        await storage.write(
            key: SharedPreferencesKeys.refreshtokenKey,
            value: response.data["data"]["refreshToken"]);

        // Also update shared prefs for consistency if needed by other parts
        sharedPreferences!.setString(
            SharedPreferencesKeys.tokenKey, response.data["data"]["token"]);
        sharedPreferences!.setString(SharedPreferencesKeys.refreshtokenKey,
            response.data["data"]["refreshToken"]);

        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}
