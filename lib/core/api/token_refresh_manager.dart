import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:presshop/core/api/api_constant.dart';

import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:presshop/main.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:presshop/features/authentication/presentation/pages/LoginScreen.dart';

/// Singleton class to manage token refresh operations
/// Handles automatic token refresh when 401 errors occur
class TokenRefreshManager {
  static final TokenRefreshManager _instance = TokenRefreshManager._internal();
  factory TokenRefreshManager() => _instance;
  TokenRefreshManager._internal();

  bool _isRefreshing = false;
  final List<Future<void> Function()> _pendingRequests = [];
  Completer<bool>? _refreshCompleter;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  static const Duration _initialRetryDelay = Duration(seconds: 2);

  /// Check if token refresh is in progress
  bool get isRefreshing => _isRefreshing;

  /// Refresh the access token using refresh token
  /// Returns true if refresh was successful, false otherwise
  /// Retries on network errors, logs out if refresh token is invalid (401)
  Future<bool> refreshToken({int retryAttempt = 0}) async {
    // If already refreshing, wait for the existing refresh to complete
    if (_isRefreshing && _refreshCompleter != null && retryAttempt == 0) {
      debugPrint("Token refresh already in progress, waiting...");
      return await _refreshCompleter!.future;
    }

    const storage = FlutterSecureStorage();
    String? refreshTokenValue = await storage.read(key: refreshtokenKey);

    // Check if refresh token exists
    if (refreshTokenValue == null || refreshTokenValue.isEmpty) {
      debugPrint(
          "No refresh token available in storage (TokenRefreshManager) - Logging out");
      _logoutUser();
      return false;
    }

    if (retryAttempt == 0) {
      _isRefreshing = true;
      _refreshCompleter = Completer<bool>();
    }

    try {
      final token = await storage.read(key: tokenKey) ?? "";
      final deviceID = sharedPreferences!.getString(deviceIdKey) ?? "";

      final uri = Uri.parse(baseUrl + appRefreshTokenUrl);
      debugPrint(
          "Refreshing token: $uri (Attempt ${retryAttempt + 1}/${_maxRetries + 1})");

      String tokenforAccess = refreshTokenValue == "" ? token : "";

      final request = http.Request("GET", uri);
      request.headers.addAll({
        refreshHeaderKey: refreshTokenValue,
        accessHeaderKey: tokenforAccess,
        headerDeviceTypeKey:
            "mobile-flutter-${Platform.isIOS ? "ios" : "android"}",
        headerDeviceIdKey: deviceID,
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse)
          .timeout(const Duration(seconds: 20), onTimeout: () {
        debugPrint("Token refresh timeout");
        return http.Response("Error", 408);
      });

      debugPrint("Token refresh response: ${response.statusCode}");
      debugPrint("Token refresh body: ${response.body}");

      // If refresh token is invalid (401), logout immediately
      if (isUnauthorizedResponse(response.statusCode, response.body)) {
        debugPrint(
            "Refresh token API returned 401 - Session expired - Logging out");
        _logoutUser();
        if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
          _refreshCompleter!.complete(false);
        }
        _processPendingRequests(false);
        _isRefreshing = false;
        _refreshCompleter = null;
        return false;
      }

      if (response.statusCode <= 201) {
        try {
          final map = jsonDecode(response.body);

          // Check for nested data object and snake_case keys as per new API response
          if (map["success"] == true &&
              map["data"] != null &&
              map["data"]["access_token"] != null &&
              map["data"]["refresh_token"] != null) {
            // 1. Delete old access token
            // 2. Delete old refresh token
            await storage.delete(key: tokenKey);
            await storage.delete(key: refreshtokenKey);

            // 3. Save NEW access token
            // 4. Save NEW refresh token
            final newAccessToken = map["data"]["access_token"];
            final newRefreshToken = map["data"]["refresh_token"];

            await storage.write(key: tokenKey, value: newAccessToken);
            await storage.write(key: refreshtokenKey, value: newRefreshToken);

            sharedPreferences!.setString(tokenKey, newAccessToken);
            sharedPreferences!.setString(refreshtokenKey, newRefreshToken);

            debugPrint("Token refreshed successfully");
            _retryCount = 0; // Reset retry count on success
            if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
              _refreshCompleter!.complete(true);
            }
            _processPendingRequests(true);
            _isRefreshing = false;
            _refreshCompleter = null;
            return true;
          } else {
            debugPrint("Invalid token refresh response format");
            // Retry on invalid response format (might be server issue)
            if (retryAttempt < _maxRetries) {
              debugPrint(
                  "Retrying token refresh after invalid response format...");
              await Future.delayed(_initialRetryDelay * (retryAttempt + 1));
              return await refreshToken(retryAttempt: retryAttempt + 1);
            }
            _logoutUser();
            return false;
          }
        } catch (e) {
          debugPrint("Error parsing token refresh response: $e");
          // Retry on parse errors (might be network issue)
          if (retryAttempt < _maxRetries) {
            debugPrint("Retrying token refresh after parse error...");
            await Future.delayed(_initialRetryDelay * (retryAttempt + 1));
            return await refreshToken(retryAttempt: retryAttempt + 1);
          }
          _logoutUser();
          return false;
        }
      } else {
        // Non-401 error - retry (might be server error, network issue, etc.)
        debugPrint("Token refresh failed with status: ${response.statusCode}");
        if (retryAttempt < _maxRetries) {
          debugPrint(
              "Retrying token refresh after status error (${response.statusCode})...");
          await Future.delayed(_initialRetryDelay * (retryAttempt + 1));
          return await refreshToken(retryAttempt: retryAttempt + 1);
        }
        // If max retries reached for non-401 error, we might not want to logout immediately
        // but we return false so the original request fails.
        // However, if it's a persistent issue, user might be stuck.
        // For now, let's NOT logout on 500s, just return false.
        if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
          _refreshCompleter!.complete(false);
        }
        _processPendingRequests(false);
        _isRefreshing = false;
        _refreshCompleter = null;
        return false;
      }
    } catch (e) {
      debugPrint("Token refresh exception: $e");
      // Retry on exceptions (network errors, etc.)
      if (retryAttempt < _maxRetries) {
        debugPrint("Retrying token refresh after exception...");
        await Future.delayed(_initialRetryDelay * (retryAttempt + 1));
        return await refreshToken(retryAttempt: retryAttempt + 1);
      }

      if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
        _refreshCompleter!.complete(false);
      }
      _processPendingRequests(false);
      _isRefreshing = false;
      _refreshCompleter = null;
      return false;
    }
  }

  /// Add a pending request to be retried after token refresh
  void addPendingRequest(Future<void> Function() retryFunction) {
    _pendingRequests.add(retryFunction);
    debugPrint(
        "Added pending request. Total pending: ${_pendingRequests.length}");
  }

  /// Process all pending requests after token refresh
  void _processPendingRequests(bool success) {
    if (success) {
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

  /// Logout user and navigate to login screen
  void _logoutUser() async {
    debugPrint("Logging out user due to expired session");
    const storage = FlutterSecureStorage();
    await storage.deleteAll();
    sharedPreferences?.clear();

    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false);
    }
  }

  /// Check if user should be logged out
  static bool shouldLogout() {
    return true;
  }

  /// Clear logout flag
  static void clearLogoutFlag() {
    sharedPreferences?.remove("force_logout");
  }

  /// Check if response indicates unauthorized (401)
  static bool isUnauthorizedResponse(int statusCode, String? responseBody) {
    if (statusCode == 401) {
      return true;
    }

    // Also check response body for unauthorized messages
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
        // If parsing fails, just check status code
      }
    }

    return false;
  }
}
