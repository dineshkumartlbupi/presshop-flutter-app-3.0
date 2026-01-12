import 'package:flutter/foundation.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/error/api_error_handler.dart';
import '../models/category_model.dart';
import '../models/charity_model.dart';
import '../models/tutorial_model.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';

abstract class PublishRemoteDataSource {
  Future<List<CategoryModel>> getContentCategories();
  Future<List<CategoryModel>> getTutorialCategories();
  Future<List<CharityModel>> getCharities(int offset, int limit);
  Future<List<TutorialModel>> getTutorials(
      String category, int offset, int limit);
  Future<void> addViewCount(String tutorialId);
  Future<Map<String, String>> getShareExclusivePrice();
  Future<void> submitContent(
      Map<String, dynamic> params, List<String> filePaths);
}

class PublishRemoteDataSourceImpl implements PublishRemoteDataSource {
  final ApiClient apiClient;

  PublishRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<CategoryModel>> getContentCategories() async {
    try {
      final response = await apiClient.get(categoryUrl);
      debugPrint("DEBUG: getContentCategories response: ${response.data}");

      if (response.data is List) {
        final data = response.data as List;
        debugPrint(
            "DEBUG: getContentCategories parsed list length: ${data.length}");
        return data.map((e) => CategoryModel.fromJson(e)).toList();
      } else if (response.data is Map<String, dynamic>) {
        if (response.data['categories'] != null) {
          final data = response.data['categories'] as List;
          return data.map((e) => CategoryModel.fromJson(e)).toList();
        }
      }

      debugPrint(
          "DEBUG: getContentCategories response format unknown: ${response.data.runtimeType}");
      throw ServerException(response.data.toString());
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<List<CategoryModel>> getTutorialCategories() async {
    try {
      final response = await apiClient
          .get(getHopperCategory, queryParameters: {"type": "tutorial"});
      if (response.data is! Map<String, dynamic>) {
        throw ServerException(response.data.toString());
      }
      final data = response.data['categories'] as List;
      return data.map((e) => CategoryModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<List<CharityModel>> getCharities(int offset, int limit) async {
    try {
      final Map<String, dynamic> params = {
        "offset": offset,
        "limit": limit,
      };
      final response =
          await apiClient.get(allCharityUrl, queryParameters: params);
      if (response.data is! Map<String, dynamic>) {
        throw ServerException(response.data.toString());
      }

      if (response.data['data'] is Map &&
          (response.data['data'] as Map).isEmpty) {
        return [];
      }

      final data = response.data['data'] as List;
      return data.map((e) => CharityModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<List<TutorialModel>> getTutorials(
      String category, int offset, int limit) async {
    try {
      final Map<String, dynamic> params = {
        "type": "videos",
        "offset": offset,
        "limit": limit,
        "category": category,
      };
      final response = await apiClient.get(getAllCmsUrl, queryParameters: params);
      if (response.data is! Map<String, dynamic>) {
        throw ServerException(response.data.toString());
      }
      final data = response.data['status'] as List;
      return data.map((e) => TutorialModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<void> addViewCount(String tutorialId) async {
    try {
      final Map<String, dynamic> data = {
        "type": "tutorial",
        "tutorial_id": tutorialId,
      };
      await apiClient.post(addViewCountAPI, data: data);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<Map<String, String>> getShareExclusivePrice() async {
    try {
      final Map<String, dynamic> params = {
        "type": "price",
      };
      final response = await apiClient.get(getAllCmsUrl, queryParameters: params);
      if (response.data is! Map<String, dynamic>) {
        throw ServerException(response.data.toString());
      }

      final data = response.data['status'] ?? response.data['data'];

      if (data == null || (data is Map && data.isEmpty)) {
        return {"shared": "", "exclusive": ""};
      }

      return {
        "shared": data['shared']?.toString() ?? "",
        "exclusive": data['exclusive']?.toString() ?? "",
      };
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<void> submitContent(
      Map<String, dynamic> params, List<String> filePaths) async {
    try {
      final formData = FormData.fromMap(params);

      for (var path in filePaths) {
        if (path.isNotEmpty) {
          String fileName = path.split('/').last;
          formData.files.add(MapEntry(
            'content',
            await MultipartFile.fromFile(path, filename: fileName),
          ));
        }
      }

      await apiClient.multipartPost(addContentUrl, formData: formData);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
