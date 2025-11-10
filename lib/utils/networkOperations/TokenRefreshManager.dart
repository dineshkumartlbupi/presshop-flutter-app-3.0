import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Common.dart';
import '../CommonSharedPrefrence.dart';
import '../../main.dart';

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
  static const int _maxRetries = 5; // Increased retries to prevent logout
  static const Duration _initialRetryDelay = Duration(seconds: 2);

  /// Check if token refresh is in progress
  bool get isRefreshing => _isRefreshing;

  /// Refresh the access token using refresh token
  /// Returns true if refresh was successful, false otherwise
  /// Retries on network errors, only logs out if refresh token is invalid (401)
  Future<bool> refreshToken({int retryAttempt = 0}) async {
    // If already refreshing, wait for the existing refresh to complete
    if (_isRefreshing && _refreshCompleter != null && retryAttempt == 0) {
      debugPrint("Token refresh already in progress, waiting...");
      return await _refreshCompleter!.future;
    }

    // Check if refresh token exists
    if (sharedPreferences?.getString(refreshtokenKey) == null ||
        sharedPreferences!.getString(refreshtokenKey)!.isEmpty) {
      debugPrint("No refresh token available");
      // Keep retrying - token might be saved by another process or will be available later
      if (retryAttempt < _maxRetries) {
        debugPrint(
            "No refresh token on retry attempt $retryAttempt, waiting and retrying...");
        await Future.delayed(_initialRetryDelay * (retryAttempt + 1));
        return await refreshToken(retryAttempt: retryAttempt + 1);
      }
      // Max retries reached, but NEVER logout - keep user logged in
      debugPrint(
          "Max retries reached without refresh token, but keeping user logged in");
      if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
        _refreshCompleter!.complete(false);
      }
      _processPendingRequests(false);
      _isRefreshing = false;
      _refreshCompleter = null;
      _retryCount = 0;
      return false;
    }

    if (retryAttempt == 0) {
      _isRefreshing = true;
      _refreshCompleter = Completer<bool>();
    }

    try {
      final refreshTokenValue = sharedPreferences!.getString(refreshtokenKey)!;
      final deviceID = sharedPreferences!.getString(deviceIdKey) ?? "";

      final uri = Uri.parse(baseUrl + appRefreshTokenUrl);
      debugPrint(
          "Refreshing token: $uri (Attempt ${retryAttempt + 1}/${_maxRetries + 1})");

      final request = http.Request("GET", uri);
      request.headers.addAll({
        refreshHeaderKey: refreshTokenValue,
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

      // Even if refresh token returns 401, don't logout - keep retrying
      // The token might be valid but server had a temporary issue
      if (isUnauthorizedResponse(response.statusCode, response.body)) {
        debugPrint(
            "Refresh token API returned 401, but keeping user logged in and retrying...");
        // Retry even on 401 - might be temporary server issue
        if (retryAttempt < _maxRetries) {
          debugPrint("Retrying token refresh after 401 response...");
          await Future.delayed(_initialRetryDelay * (retryAttempt + 1));
          return await refreshToken(retryAttempt: retryAttempt + 1);
        }
        // Max retries reached, but NEVER logout - keep user logged in
        debugPrint("Max retries reached after 401, but keeping user logged in");
        if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
          _refreshCompleter!.complete(false);
        }
        _processPendingRequests(false);
        _isRefreshing = false;
        _refreshCompleter = null;
        _retryCount = 0;
        return false;
      }

      if (response.statusCode <= 201) {
        try {
          final map = jsonDecode(response.body);
          if (map["token"] != null && map["refreshToken"] != null) {
            // Save new tokens
            sharedPreferences!.setString(tokenKey, map["token"]);
            sharedPreferences!.setString(refreshtokenKey, map["refreshToken"]);
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
            // Max retries reached, but don't logout - keep user logged in
            debugPrint(
                "Max retries reached after invalid response format, but keeping user logged in");
            if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
              _refreshCompleter!.complete(false);
            }
            _processPendingRequests(false);
            _isRefreshing = false;
            _refreshCompleter = null;
            _retryCount = 0;
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
          // Max retries reached, but don't logout - keep user logged in
          debugPrint(
              "Max retries reached after parse error, but keeping user logged in");
          if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
            _refreshCompleter!.complete(false);
          }
          _processPendingRequests(false);
          _isRefreshing = false;
          _refreshCompleter = null;
          _retryCount = 0;
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
        // Max retries reached, but don't logout - keep user logged in
        debugPrint(
            "Max retries reached after status error, but keeping user logged in");
        if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
          _refreshCompleter!.complete(false);
        }
        _processPendingRequests(false);
        _isRefreshing = false;
        _refreshCompleter = null;
        _retryCount = 0;
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
      // Max retries reached, but don't logout - keep user logged in
      debugPrint(
          "Max retries reached after exception, but keeping user logged in");
      if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
        _refreshCompleter!.complete(false);
      }
      _processPendingRequests(false);
      _isRefreshing = false;
      _refreshCompleter = null;
      _retryCount = 0;
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
          "Token refresh failed, but keeping ${_pendingRequests.length} pending requests for next attempt");
      // Don't clear pending requests - they will be retried when user makes next API call
      // The tokens might be refreshed by then or on next 401 error
    }
    _pendingRequests.clear();
  }

  /// NOTE: This method is kept for reference but should NEVER be called automatically
  /// Users should only be logged out through explicit user action (logout button)
  /// This method is intentionally not used to prevent automatic logouts
  void _logoutUser() {
    debugPrint(
        "WARNING: _logoutUser() called - this should only happen on manual logout");
    // This method is kept but should not be called automatically
    // Only manual logout should clear tokens
  }

  /// Check if user should be logged out
  /// Always returns false to prevent automatic logouts
  static bool shouldLogout() {
    // NEVER return true automatically - only manual logout should work
    return false;
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
