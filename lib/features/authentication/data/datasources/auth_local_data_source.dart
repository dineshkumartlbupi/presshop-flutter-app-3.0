import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:presshop/core/utils/shared_preferences.dart'; // Using existing keys

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> cacheUser(Map<String, dynamic> user);
  Future<Map<String, dynamic>?> getUser();
  Future<void> clearCache();
  Future<bool> getRememberMe();
  Future<void> setRememberMe(bool value);
  Future<bool> getOnboardingSeen();
  Future<void> setOnboardingSeen();
  Future<String?> getUserId();
  Future<void> cacheRefreshToken(String token);
  Future<String?> getRefreshToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.secureStorage,
  });
  final SharedPreferences sharedPreferences;
  final FlutterSecureStorage secureStorage;

  @override
  Future<void> cacheToken(String token) async {
    debugPrint(
        "💾 AuthLocalDataSource: Caching Token: ${token.substring(0, (token.length > 10 ? 10 : token.length))}...");
    await secureStorage.write(
        key: SharedPreferencesKeys.tokenKey, value: token);
    await sharedPreferences.setString(SharedPreferencesKeys.tokenKey, token);
    debugPrint(
        "✅ AuthLocalDataSource: Token Cached in SecureStorage and SharedPreferences");
  }

  @override
  Future<String?> getToken() async {
    debugPrint("🔍 AuthLocalDataSource: Retrieving Token...");
    String? token =
        await secureStorage.read(key: SharedPreferencesKeys.tokenKey);
    if (token == null || token.isEmpty) {
      debugPrint(
          "⚠️ AuthLocalDataSource: Token not found in SecureStorage, checking SharedPreferences...");
      token = sharedPreferences.getString(SharedPreferencesKeys.tokenKey);
      if (token != null && token.isNotEmpty) {
        debugPrint("✅ AuthLocalDataSource: Token found in SharedPreferences");
      } else {
        debugPrint(
            "❌ AuthLocalDataSource: Token NOT found in SharedPreferences");
      }
    } else {
      debugPrint("✅ AuthLocalDataSource: Token found in SecureStorage");
    }
    return token;
  }

  @override
  Future<void> cacheUser(Map<String, dynamic> user) async {
    if (user.containsKey('currency_symbol') &&
        user['currency_symbol'] != null) {
      await sharedPreferences.setString(
          SharedPreferencesKeys.currencySymbolKey, user['currency_symbol']);
    }
    if (user.containsKey('referral_code') && user['referral_code'] != null) {
      await sharedPreferences.setString(
          SharedPreferencesKeys.referralCode, user['referral_code']);
    }
    if (user.containsKey('total_hopper_army') &&
        user['total_hopper_army'] != null) {
      await sharedPreferences.setString(
          SharedPreferencesKeys.totalHopperArmy, user['total_hopper_army']);
    }
    // Add logic for other fields if necessary
    if (user.containsKey('_id') && user['_id'] != null) {
      await sharedPreferences.setString(
          SharedPreferencesKeys.hopperIdKey, user['_id']);
    }
  }

  @override
  Future<Map<String, dynamic>?> getUser() async {
    // Return minimal user info if needed
    return null;
  }

  @override
  Future<void> clearCache() async {
    debugPrint("⚠️ AuthLocalDataSource: Clearing Auth Cache...");
    await secureStorage.delete(key: SharedPreferencesKeys.tokenKey);
    await secureStorage.delete(key: SharedPreferencesKeys.refreshtokenKey);
    await sharedPreferences.remove(SharedPreferencesKeys.tokenKey);
    await sharedPreferences.remove(SharedPreferencesKeys.refreshtokenKey);
    await sharedPreferences.remove(SharedPreferencesKeys.rememberKey);
    debugPrint("✅ AuthLocalDataSource: Auth Cache Cleared");
  }

  @override
  Future<bool> getRememberMe() async {
    final val =
        sharedPreferences.getBool(SharedPreferencesKeys.rememberKey) ?? false;
    debugPrint("🔍 AuthLocalDataSource: Getting RememberMe: $val");
    return val;
  }

  @override
  Future<void> setRememberMe(bool value) async {
    debugPrint("💾 AuthLocalDataSource: Setting RememberMe: $value");
    await sharedPreferences.setBool(SharedPreferencesKeys.rememberKey, value);
  }

  @override
  Future<bool> getOnboardingSeen() async {
    return sharedPreferences.getBool("onboarding_seen") ?? false;
  }

  @override
  Future<void> setOnboardingSeen() async {
    await sharedPreferences.setBool("onboarding_seen", true);
  }

  @override
  Future<String?> getUserId() async {
    return sharedPreferences.getString(SharedPreferencesKeys.hopperIdKey);
  }

  @override
  Future<void> cacheRefreshToken(String token) async {
    debugPrint(
        "💾 AuthLocalDataSource: Caching Refresh Token: ${token.substring(0, (token.length > 10 ? 10 : token.length))}...");
    await secureStorage.write(
        key: SharedPreferencesKeys.refreshtokenKey, value: token);
    await sharedPreferences.setString(
        SharedPreferencesKeys.refreshtokenKey, token);
    debugPrint(
        "✅ AuthLocalDataSource: Refresh Token Cached in SecureStorage and SharedPreferences");
  }

  @override
  Future<String?> getRefreshToken() async {
    String? token =
        await secureStorage.read(key: SharedPreferencesKeys.refreshtokenKey);
    if (token == null || token.isEmpty) {
      token =
          sharedPreferences.getString(SharedPreferencesKeys.refreshtokenKey);
    }
    return token;
  }
}
