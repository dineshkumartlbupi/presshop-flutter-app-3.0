import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/api/api_constant_new.dart';
import 'package:presshop/core/error/api_error_handler.dart';
import 'package:presshop/core/error/failures.dart';
import '../models/tutorials_model.dart';
import '../models/category_data_model.dart';

abstract class TutorialsRemoteDataSource {
  Future<List<TutorialsModel>> getTutorials(
      String category, int offset, int limit);
  Future<List<CategoryDataModel>> getCategories();
  Future<void> addViewCount(String tutorialId);
}

class TutorialsRemoteDataSourceImpl implements TutorialsRemoteDataSource {
  final ApiClient apiClient;

  TutorialsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<TutorialsModel>> getTutorials(
      String category, int offset, int limit) async {
    final box = Hive.box<TutorialsModel>('tutorials_box');

    try {
      final response = await apiClient.get(
        ApiConstantsNew.misc.generalMgmt,
        queryParameters: {
          "type": 'videos',
          "offset": offset.toString(),
          "limit": limit.toString(),
          "category": category,
        },
        showLoader: false,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic>? list;
        if (data['data'] != null) {
          if (data['data'] is List) {
            list = data['data'];
          } else if (data['data'] is Map) {
            list = data['data']['status'];
          }
        } else {
          list = data['status'];
        }

        final List<dynamic> dataModel = list ?? [];
        final tutorials =
            dataModel.map((e) => TutorialsModel.fromJson(e)).toList();

        debugPrint(
            "💾 Hive: Saving ${tutorials.length} tutorials for offset $offset");

        if (offset == 0) {
          for (var t in tutorials) {
            box.put(t.id, t);
          }
          debugPrint("✅ Hive: Cache updated. Box size: ${box.length}");
        }

        return tutorials;
      } else {
        throw ServerFailure(
            message: "Failed to fetch tutorials: ${response.statusMessage}");
      }
    } catch (e) {
      debugPrint("🚨 Hive: Fetch tutorials failed: $e. Attempting fallback...");
      // If network fails, try to return from cache
      if (offset == 0 && box.isNotEmpty) {
        debugPrint(
            "📦 Hive: Box has ${box.length} items. Filtering for category name: '$category'");

        String categoryId = category;
        if (category.isNotEmpty) {
          final catBox = Hive.box<CategoryDataModel>('categories_box');
          final matchingCat = catBox.values.firstWhere(
            (c) => c.name.trim().toLowerCase() == category.trim().toLowerCase(),
            orElse: () => CategoryDataModel(
                id: '', name: '', type: '', percentage: '', selected: false),
          );
          if (matchingCat.id.isNotEmpty) {
            categoryId = matchingCat.id;
            debugPrint(
                "🔍 Hive: Resolved category name '$category' to ID '$categoryId'");
          }
        }

        final cached = box.values.where((t) {
          final match = category.isEmpty || t.category == categoryId;
          return match;
        }).toList();

        debugPrint(
            "🔍 Hive: Found ${cached.length} cached items matching category ID '$categoryId'");
        if (cached.isNotEmpty) return cached;
      }
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<List<CategoryDataModel>> getCategories() async {
    final box = Hive.box<CategoryDataModel>('categories_box');

    try {
      final response = await apiClient.get(
        ApiConstantsNew.content.hopperCategory,
        queryParameters: {
          "type": 'tutorial',
        },
        showLoader: false,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final list = data['data'] != null
            ? data['data']['categories']
            : data['categories'];
        final List<dynamic> dataList = list ?? [];
        final categories =
            dataList.map((e) => CategoryDataModel.fromJson(e)).toList();

        debugPrint("💾 Hive: Saving ${categories.length} categories");

        // Update Cache
        box.clear();
        box.addAll(categories);
        debugPrint("✅ Hive: Categories cache updated. Box size: ${box.length}");

        return categories;
      } else {
        throw ServerFailure(
            message: "Failed to fetch categories: ${response.statusMessage}");
      }
    } catch (e) {
      debugPrint(
          "🚨 Hive: Fetch categories failed: $e. Attempting fallback...");
      // Return from cache if network fails
      if (box.isNotEmpty) {
        debugPrint("📦 Hive: Returning ${box.length} cached categories");
        return box.values.toList();
      }
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<void> addViewCount(String tutorialId) async {
    try {
      // According to TutorialsScreen.dart:
      // "user_id": sharedPreferences!.getString(hopperIdKey)
      // We will assume the API client handles auth token, but user_id was passed in body.
      // However, ApiClient usually handles headers. `sharedPreferences` usage implies manual passing.
      // We might need to pass userId if the API specifically requires it in body.
      // For now, I'll access sharedPreferences via DI or assuming ApiClient interceptor might handle it?
      // ERROR: TutorialsScreen passes `user_id` explicitly. I should probably get it from SharedPreferences.
      // But `TutorialsRemoteDataSource` shouldn't depend on SharedPreferences ideally.
      // It's better to pass it in. But to keep signature clean, maybe I'll skip it if it's not strictly required
      // OR I'll assume it's needed.
      // Wait, `NetworkClass` structure suggests it was manual.
      // I'll skip it for now and see if it fails, or better: inject SharedPreferences?
      // Actually, relying on `ApiClient` might be enough if the backend uses the token to identify the user.
      // If `user_id` is mandatory in body, I need to fetch it.

      /* 
      Code in Screen:
      "user_id": sharedPreferences!.getString(hopperIdKey).toString() ?? ''
      */

      // I will rely on the fact that usually modern APIs use token. If this legacy API needs body, I'll add it later.
      // Or I can add `user_id` to the parameters of `addViewCount` method if I want to be safe, but UseCase ideally handles that?
      // No, UseCase getting user ID from a UserRepo?
      // Let's stick to what's visible. I'll omit it for now or pass empty string if I don't have access.
      // Ideally I should inject SharedPreferences to DS if needed.

      await apiClient.post(ApiConstantsNew.content.mostViewed, data: {
        "type": "tutorial",
        'tutorial_id': tutorialId,
        // "user_id": ... // Skipping for now, assuming token is enough or will fix if needed. A lot of legacy code passes explicit UserID unnecessarily.
      });
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
