import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/error/failures.dart';

abstract class NotificationLocalDataSource {
  /// Gets the cached notifications from local storage.
  /// Throws a [CacheException] if no cached data is present.
  Future<Map<String, dynamic>?> getCachedNotifications();

  /// Caches the given notifications data into local storage.
  Future<void> cacheNotifications(Map<String, dynamic> data);
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  static const String boxName = 'sync_cache';
  static const String cacheKey = 'notifications_cache';

  @override
  Future<Map<String, dynamic>?> getCachedNotifications() async {
    try {
      final box = await Hive.openBox(boxName);
      final jsonString = box.get(cacheKey);
      if (jsonString != null) {
        return jsonDecode(jsonString);
      }
      return null;
    } catch (e) {
      debugPrint('Hive Cache Read Error: $e');
      return null;
    }
  }

  @override
  Future<void> cacheNotifications(Map<String, dynamic> data) async {
    try {
      final box = await Hive.openBox(boxName);
      final jsonString = jsonEncode(data);
      await box.put(cacheKey, jsonString);
    } catch (e) {
      debugPrint('Hive Cache Write Error: $e');
    }
  }
}
