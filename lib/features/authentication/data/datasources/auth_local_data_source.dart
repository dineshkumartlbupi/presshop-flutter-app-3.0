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
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheToken(String token) async {
    await sharedPreferences.setString(tokenKey, token);
  }

  @override
  Future<String?> getToken() async {
    return sharedPreferences.getString(tokenKey);
  }

  @override
  Future<void> cacheUser(Map<String, dynamic> user) async {
    if (user.containsKey('currency_symbol') && user['currency_symbol'] != null) {
      await sharedPreferences.setString(currencySymbolKey, user['currency_symbol']);
    }
    if (user.containsKey('referral_code') && user['referral_code'] != null) {
      await sharedPreferences.setString(referralCode, user['referral_code']);
    }
    if (user.containsKey('total_hopper_army') && user['total_hopper_army'] != null) {
      await sharedPreferences.setString(totalHopperArmy, user['total_hopper_army']);
    }
    // Add logic for other fields if necessary
  }

  @override
  Future<Map<String, dynamic>?> getUser() async {
    // Return minimal user info if needed
    return null; 
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.clear();
  }

  @override
  Future<bool> getRememberMe() async {
    return sharedPreferences.getBool(rememberKey) ?? false;
  }

  @override
  Future<void> setRememberMe(bool value) async {
    await sharedPreferences.setBool(rememberKey, value);
  }

  @override
  Future<bool> getOnboardingSeen() async {
    return sharedPreferences.getBool("onboarding_seen") ?? false;
  }

  @override
  Future<void> setOnboardingSeen() async {
    await sharedPreferences.setBool("onboarding_seen", true);
  }
}
