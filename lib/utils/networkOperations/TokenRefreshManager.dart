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

  /// Check if token refresh is in progress
  bool get isRefreshing => _isRefreshing;

  /// Refresh the access token using refresh token
  /// Returns true if refresh was successful, false otherwise
  Future<bool> refreshToken() async {
    // If already refreshing, wait for the existing refresh to complete
    if (_isRefreshing && _refreshCompleter != null) {
      debugPrint("Token refresh already in progress, waiting...");
      return await _refreshCompleter!.future;
    }

    // Check if refresh token exists
    if (sharedPreferences?.getString(refreshtokenKey) == null ||
        sharedPreferences!.getString(refreshtokenKey)!.isEmpty) {
      debugPrint("No refresh token available");
      _logoutUser();
      return false;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final refreshTokenValue = sharedPreferences!.getString(refreshtokenKey)!;
      final deviceID = sharedPreferences!.getString(deviceIdKey) ?? "";

      final uri = Uri.parse(baseUrl + appRefreshTokenUrl);
      debugPrint("Refreshing token: $uri");

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

      if (response.statusCode <= 201) {
        try {
          final map = jsonDecode(response.body);
          if (map["token"] != null && map["refreshToken"] != null) {
            // Save new tokens
            sharedPreferences!.setString(tokenKey, map["token"]);
            sharedPreferences!.setString(refreshtokenKey, map["refreshToken"]);
            debugPrint("Token refreshed successfully");
            _refreshCompleter!.complete(true);
            _processPendingRequests(true);
            return true;
          } else {
            debugPrint("Invalid token refresh response format");
            _logoutUser();
            _refreshCompleter!.complete(false);
            _processPendingRequests(false);
            return false;
          }
        } catch (e) {
          debugPrint("Error parsing token refresh response: $e");
          _logoutUser();
          _refreshCompleter!.complete(false);
          _processPendingRequests(false);
          return false;
        }
      } else {
        // Refresh token is also invalid, logout user
        debugPrint("Token refresh failed with status: ${response.statusCode}");
        _logoutUser();
        _refreshCompleter!.complete(false);
        _processPendingRequests(false);
        return false;
      }
    } catch (e) {
      debugPrint("Token refresh exception: $e");
      _logoutUser();
      _refreshCompleter!.complete(false);
      _processPendingRequests(false);
      return false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  /// Add a pending request to be retried after token refresh
  void addPendingRequest(Future<void> Function() retryFunction) {
    _pendingRequests.add(retryFunction);
    debugPrint("Added pending request. Total pending: ${_pendingRequests.length}");
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
      debugPrint("Token refresh failed, cancelling ${_pendingRequests.length} pending requests");
    }
    _pendingRequests.clear();
  }

  /// Logout user when refresh token fails
  void _logoutUser() {
    debugPrint("Logging out user due to token refresh failure");
    // Clear tokens
    sharedPreferences?.remove(tokenKey);
    sharedPreferences?.remove(refreshtokenKey);
    rememberMe = false;
    
    // Set a flag that logout is needed - NetworkClass will handle navigation
    sharedPreferences?.setBool("force_logout", true);
  }
  
  /// Check if user should be logged out
  static bool shouldLogout() {
    return sharedPreferences?.getBool("force_logout") ?? false;
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
            (map['message'] != null && map['message'].toString().toLowerCase().contains('unauthorized'))) {
          return true;
        }
      } catch (e) {
        // If parsing fails, just check status code
      }
    }
    
    return false;
  }
}


