import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_constant.dart';
import '../../../../core/utils/shared_preferences.dart';

abstract class NotificationRemoteDataSource {
  Future<Map<String, dynamic>> getNotifications(int limit, int offset);
  Future<void> markNotificationsAsRead();
  Future<void> clearAllNotifications();
  Future<Map<String, dynamic>> checkStudentBeans();
  Future<String> activateStudentBeans();
  Future<void> markStudentBeansVisited();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio dio;
  final SharedPreferences sharedPreferences;

  NotificationRemoteDataSourceImpl({required this.dio, required this.sharedPreferences});

  Options _getOptions() {
    String token = sharedPreferences.getString(tokenKey) ?? "";
    return Options(headers: {
      "Authorization": "Bearer $token",
    });
  }

  @override
  Future<Map<String, dynamic>> getNotifications(int limit, int offset) async {
    try {
      var response = await dio.get(
        "$baseUrl$notificationListAPI",
        queryParameters: {'limit': limit, 'offset': offset},
        options: _getOptions(),
      );

      if (response.statusCode == 200) {
        var data = response.data;
        if (data is String) data = jsonDecode(data);
        return data;
      } else {
        throw Exception("Failed to fetch notifications: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching notifications: $e");
    }
  }

  @override
  Future<void> markNotificationsAsRead() async {
    try {
      await dio.patch(
        "$baseUrl$notificationReadAPI",
        options: _getOptions(),
      );
    } catch (e) {
      debugPrint("Error marking notifications as read: $e");
      throw Exception("Error marking notifications as read");
    }
  }

  @override
  Future<void> clearAllNotifications() async {
    try {
      await dio.patch(
        "$baseUrl$clearNotification",
        options: _getOptions(),
      );
    } catch (e) {
      throw Exception("Error clearing notifications: $e");
    }
  }

  @override
  Future<Map<String, dynamic>> checkStudentBeans() async {
    try {
      var response = await dio.get(
        "$baseUrl$myProfileUrl",
        options: _getOptions(),
      );

      if (response.statusCode == 200) {
        var data = response.data;
        if (data is String) data = jsonDecode(data);
        return data;
      } else {
        throw Exception("Failed to check student beans");
      }
    } catch (e) {
      throw Exception("Error checking student beans: $e");
    }
  }

  @override
  Future<String> activateStudentBeans() async {
    try {
      var response = await dio.post(
        "$baseUrl$studentBeansActivationUrl",
        options: _getOptions(),
      );
      if (response.statusCode == 200) {
        var map = response.data;
        if (map is String) map = jsonDecode(map);
        return map["url"] ?? "";
      } else {
        throw Exception("Failed to activate student beans");
      }
    } catch (e) {
      throw Exception("Error activating student beans: $e");
    }
  }

  @override
  Future<void> markStudentBeansVisited() async {
    try {
      await sharedPreferences.setBool(sourceDataIsClickKey, true);
      await sharedPreferences.setBool(sourceDataIsOpenedKey, true);
    } catch (e) {
      throw Exception("Error marking student beans as visited: $e");
    }
  }
}
