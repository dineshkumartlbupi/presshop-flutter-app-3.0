import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:presshop/core/router/router_constants.dart';
import 'package:presshop/core/api/api_constant.dart';

import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:presshop/main.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenRefreshManager {
  factory TokenRefreshManager() => _instance;
  TokenRefreshManager._internal();
  static final TokenRefreshManager _instance = TokenRefreshManager._internal();

  bool _isRefreshing = false;
  final List<Future<void> Function()> _pendingRequests = [];
  Completer<String?>? _refreshCompleter;
  static const int _maxRetries = 3;
  static const Duration _initialRetryDelay = Duration(seconds: 2);

  bool get isRefreshing => _isRefreshing;
  Future<String?> refreshToken({int retryAttempt = 0}) async {
    if (_isRefreshing && _refreshCompleter != null && retryAttempt == 0) {
      debugPrint("Token refresh already in progress, waiting...");
      return await _refreshCompleter!.future;
    }

    const storage = FlutterSecureStorage();
    String? refreshTokenValue =
        await storage.read(key: SharedPreferencesKeys.refreshtokenKey);

    if (refreshTokenValue == null || refreshTokenValue.isEmpty) {
      debugPrint(
          "No refresh token available in storage (TokenRefreshManager) - Logging out");
      _logoutUser();
      return null;
    }

    if (retryAttempt == 0) {
      _isRefreshing = true;
      _refreshCompleter = Completer<String?>();
    }

    try {
      final token =
          await storage.read(key: SharedPreferencesKeys.tokenKey) ?? "";
      final deviceID =
          sharedPreferences!.getString(SharedPreferencesKeys.deviceIdKey) ?? "";

      final uri = Uri.parse(
          ApiConstantsNew.config.baseUrl + ApiConstantsNew.auth.refreshToken);
      debugPrint(
          "Refreshing token: $uri (Attempt ${retryAttempt + 1}/${_maxRetries + 1})");

      final request = http.Request("GET", uri);
      request.headers.addAll({
        SharedPreferencesKeys.refreshHeaderKey: refreshTokenValue,
        SharedPreferencesKeys.accessHeaderKey: token,
        SharedPreferencesKeys.headerDeviceTypeKey:
            "mobile-flutter-${Platform.isIOS ? "ios" : "android"}",
        SharedPreferencesKeys.headerDeviceIdKey: deviceID,
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse)
          .timeout(const Duration(seconds: 20), onTimeout: () {
        debugPrint("Token refresh timeout");
        return http.Response("Error", 408);
      });

      debugPrint("Token refresh response: ${response.statusCode}");
      debugPrint("Token refresh body: ${response.body}");

      if (isUnauthorizedResponse(response.statusCode, response.body)) {
        debugPrint(
            "Refresh token API returned 401 - Session expired - Logging out");
        _logoutUser();
        if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
          _refreshCompleter!.complete(null);
        }
        _processPendingRequests(null);
        _isRefreshing = false;
        _refreshCompleter = null;
        return null;
      }

      if (response.statusCode <= 201) {
        try {
          final map = jsonDecode(response.body);
          final data = map["data"] ?? map;

          final newAccessToken = data["access_token"] ??
              data["token"] ??
              (data["user"] != null ? data["user"]["token"] : null);
          final newRefreshToken = data["refresh_token"] ??
              data["refreshToken"] ??
              (data["user"] != null ? data["user"]["refreshToken"] : null);

          if ((map["success"] == true || map["code"] == 200) &&
              newAccessToken != null &&
              newRefreshToken != null) {
            await storage.delete(key: SharedPreferencesKeys.tokenKey);
            await storage.delete(key: SharedPreferencesKeys.refreshtokenKey);

            await storage.write(
                key: SharedPreferencesKeys.tokenKey, value: newAccessToken);
            await storage.write(
                key: SharedPreferencesKeys.refreshtokenKey,
                value: newRefreshToken);

            await sharedPreferences!
                .setString(SharedPreferencesKeys.tokenKey, newAccessToken);
            await sharedPreferences!.setString(
                SharedPreferencesKeys.refreshtokenKey, newRefreshToken);

            debugPrint("Token refreshed successfully");
            if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
              _refreshCompleter!.complete(newAccessToken);
            }
            _processPendingRequests(newAccessToken);
            _isRefreshing = false;
            _refreshCompleter = null;
            return newAccessToken;
          } else {
            debugPrint("Invalid token refresh response format or data missing");
            if (retryAttempt < _maxRetries) {
              debugPrint(
                  "Retrying token refresh after invalid response format...");
              await Future.delayed(_initialRetryDelay * (retryAttempt + 1));
              return await refreshToken(retryAttempt: retryAttempt + 1);
            }
            _logoutUser();
            return null;
          }
        } catch (e) {
          debugPrint("Error parsing token refresh response: $e");
          if (retryAttempt < _maxRetries) {
            debugPrint("Retrying token refresh after parse error...");
            await Future.delayed(_initialRetryDelay * (retryAttempt + 1));
            return await refreshToken(retryAttempt: retryAttempt + 1);
          }
          _logoutUser();
          return null;
        }
      } else {
        debugPrint("Token refresh failed with status: ${response.statusCode}");
        if (retryAttempt < _maxRetries) {
          debugPrint(
              "Retrying token refresh after status error (${response.statusCode})...");
          await Future.delayed(_initialRetryDelay * (retryAttempt + 1));
          return await refreshToken(retryAttempt: retryAttempt + 1);
        }
        if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
          _refreshCompleter!.complete(null);
        }
        _processPendingRequests(null);
        _isRefreshing = false;
        _refreshCompleter = null;
        return null;
      }
    } catch (e) {
      debugPrint("Token refresh exception: $e");
      if (retryAttempt < _maxRetries) {
        debugPrint("Retrying token refresh after exception...");
        await Future.delayed(_initialRetryDelay * (retryAttempt + 1));
        return await refreshToken(retryAttempt: retryAttempt + 1);
      }

      if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
        _refreshCompleter!.complete(null);
      }
      _processPendingRequests(null);
      _isRefreshing = false;
      _refreshCompleter = null;
      return null;
    }
  }

  void addPendingRequest(Future<void> Function() retryFunction) {
    _pendingRequests.add(retryFunction);
    debugPrint(
        "Added pending request. Total pending: ${_pendingRequests.length}");
  }

  void _processPendingRequests(String? newToken) {
    if (newToken != null) {
      debugPrint("Processing ${_pendingRequests.length} pending requests");
      for (var retryFunction in _pendingRequests) {
        try {
          retryFunction();
        } catch (e) {
          debugPrint("Error processing pending request: $e");
        }
      }
    } else {
      debugPrint(
          "Token refresh failed, clearing ${_pendingRequests.length} pending requests");
    }
    _pendingRequests.clear();
  }

  void _logoutUser() async {
    debugPrint("🧹 Logging out user (Selective Wipe)...");
    const storage = FlutterSecureStorage();
    await storage.delete(key: SharedPreferencesKeys.tokenKey);
    await storage.delete(key: SharedPreferencesKeys.refreshtokenKey);
    await sharedPreferences?.remove(SharedPreferencesKeys.tokenKey);
    await sharedPreferences?.remove(SharedPreferencesKeys.refreshtokenKey);
    await sharedPreferences?.remove(SharedPreferencesKeys.rememberKey);

    if (navigatorKey.currentContext != null) {
      GoRouter.of(navigatorKey.currentContext!).goNamed(AppRoutes.loginName);
    }
  }

  static bool shouldLogout() {
    return true;
  }

  static void clearLogoutFlag() {
    sharedPreferences?.remove("force_logout");
  }

  static bool isUnauthorizedResponse(int statusCode, String? responseBody) {
    if (statusCode == 401) {
      return true;
    }

    if (responseBody != null) {
      try {
        final map = jsonDecode(responseBody);
        if (map['code'] == 401 ||
            map['body'] == "Unauthorized" ||
            (map['message'] != null &&
                map['message']
                    .toString()
                    .toLowerCase()
                    .contains('unauthorized'))) {
          return true;
        }
      } catch (e) {
        debugPrint("Error parsing response body: $e");
      }
    }

    return false;
  }
}
