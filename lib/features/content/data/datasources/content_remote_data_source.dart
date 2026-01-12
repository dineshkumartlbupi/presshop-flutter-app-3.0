import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/core_export.dart';
import '../models/content_item_model.dart';
import '../models/hashtag_model.dart';
import 'package:presshop/features/task/data/models/manage_task_chat_model.dart';
import 'package:presshop/features/earning/data/models/earning_model.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/error/api_error_handler.dart';

abstract class ContentRemoteDataSource {
  Future<List<ContentItemModel>> getMyContent(
      {int page = 1, int limit = 20, Map<String, dynamic> params = const {}});
  Future<ContentItemModel> publishContent(Map<String, dynamic> data);
  Future<ContentItemModel> saveDraft(Map<String, dynamic> data);
  Future<ContentItemModel> updateContent(
      String contentId, Map<String, dynamic> data);
  Future<void> deleteContent(String contentId);
  Future<List<String>> uploadMedia(List<String> filePaths);
  Future<List<HashtagModel>> searchHashtags(String query);
  Future<List<HashtagModel>> getTrendingHashtags();
  Future<ContentItemModel> getContentDetail(String contentId);
  Future<List<ManageTaskChatModel>> getMediaHouseOffers(String contentId);
  Future<List<EarningTransactionDetail>> getContentTransactions(
      String contentId, int limit, int offset);
}

class ContentRemoteDataSourceImpl implements ContentRemoteDataSource {
  final ApiClient apiClient;

  ContentRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<ContentItemModel>> getMyContent(
      {int page = 1,
      int limit = 20,
      Map<String, dynamic> params = const {}}) async {
    try {
      final queryParams = {'page': page, 'limit': limit, ...params};
      final response = await apiClient.get(
        myContentUrl,
        queryParameters: queryParams,
      );

      debugPrint("DEBUG: getMyContent response: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 200) {
          final List contentList =
              data['contentList'] ?? data['content'] ?? data['data'] ?? [];
          debugPrint("DEBUG: getMyContent list length: ${contentList.length}");
          return contentList.map((e) => ContentItemModel.fromJson(e)).toList();
        }
        debugPrint("DEBUG: getMyContent failed code: ${data['code']}");
        throw ServerFailure(
            message: data['message'] ?? 'Failed to load content');
      }
      throw ServerFailure(message: 'Failed to load content');
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<ContentItemModel> publishContent(Map<String, dynamic> data) async {
    try {
      List<String>? mediaPaths;
      if (data.containsKey('_mediaPaths')) {
        mediaPaths = List<String>.from(data['_mediaPaths']);
        data.remove('_mediaPaths');
      }

      Response response;
      if (mediaPaths != null && mediaPaths.isNotEmpty) {
        FormData formData = FormData.fromMap(data);
        for (int i = 0; i < mediaPaths.length; i++) {
          formData.files.add(MapEntry(
            "media[$i]",
            await MultipartFile.fromFile(mediaPaths[i]),
          ));
        }
        response =
            await apiClient.multipartPost(uploadContentUrl, formData: formData);
      } else {
        response = await apiClient.post(uploadContentUrl, data: data);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        if (resData['code'] == 200) {
          return ContentItemModel.fromJson(
              resData['content'] ?? resData['data']);
        }
        throw ServerFailure(message: resData['message'] ?? 'Publish failed');
      }
      throw ServerFailure(message: 'Publish failed');
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<ContentItemModel> saveDraft(Map<String, dynamic> data) async {
    try {
      List<String>? mediaPaths;
      if (data.containsKey('_mediaPaths')) {
        mediaPaths = List<String>.from(data['_mediaPaths']);
        data.remove('_mediaPaths');
      }

      data['status'] = 'draft';

      Response response;
      if (mediaPaths != null && mediaPaths.isNotEmpty) {
        FormData formData = FormData.fromMap(data);
        for (int i = 0; i < mediaPaths.length; i++) {
          formData.files.add(MapEntry(
            "media[$i]",
            await MultipartFile.fromFile(mediaPaths[i]),
          ));
        }
        response =
            await apiClient.multipartPost(uploadContentUrl, formData: formData);
      } else {
        response = await apiClient.post(uploadContentUrl, data: data);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        if (resData['code'] == 200) {
          return ContentItemModel.fromJson(resData['draft'] ?? resData['data']);
        }
        throw ServerFailure(message: resData['message'] ?? 'Save draft failed');
      }
      throw ServerFailure(message: 'Save draft failed');
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<ContentItemModel> updateContent(
      String contentId, Map<String, dynamic> data) async {
    try {
      final response =
          await apiClient.put('$uploadContentUrl/$contentId', data: data);

      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData['code'] == 200) {
          return ContentItemModel.fromJson(
              resData['content'] ?? resData['data']);
        }
        throw ServerFailure(message: resData['message'] ?? 'Update failed');
      }
      throw ServerFailure(message: 'Update failed');
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<void> deleteContent(String contentId) async {
    try {
      final response = await apiClient.delete('$uploadContentUrl/$contentId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 200) {
          return;
        }
        throw ServerFailure(message: data['message'] ?? 'Delete failed');
      }
      throw ServerFailure(message: 'Delete failed');
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<List<String>> uploadMedia(List<String> filePaths) async {
    try {
      FormData formData = FormData();
      for (int i = 0; i < filePaths.length; i++) {
        formData.files.add(MapEntry(
          "media[$i]",
          await MultipartFile.fromFile(filePaths[i]),
        ));
      }

      final response =
          await apiClient.multipartPost(uploadContentUrl, formData: formData);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 200) {
          return List<String>.from(data['urls'] ?? data['media_urls'] ?? []);
        }
        throw ServerFailure(message: data['message'] ?? 'Upload failed');
      }
      throw ServerFailure(message: 'Upload failed');
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<List<HashtagModel>> searchHashtags(String query) async {
    try {
      final response = await apiClient.get(
        getHashTagsUrl,
        queryParameters: {'query': query},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 200) {
          final List hashtags = data['hashtags'] ?? data['data'] ?? [];
          return hashtags.map((e) => HashtagModel.fromJson(e)).toList();
        }
        return [];
      }
      return [];
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<List<HashtagModel>> getTrendingHashtags() async {
    try {
      final response = await apiClient.get(getHashTagsUrl);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 200) {
          final List hashtags = data['hashtags'] ?? data['data'] ?? [];
          return hashtags.map((e) => HashtagModel.fromJson(e)).toList();
        }
        return [];
      }
      return [];
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<ContentItemModel> getContentDetail(String contentId) async {
    try {
      final response = await apiClient.get('$myContentDetailUrl$contentId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 200) {
          return ContentItemModel.fromJson(
              data['contentDetail'] ?? data['content'] ?? data['data']);
        }
        throw ServerFailure(
            message: data['message'] ?? 'Failed to load content');
      }
      throw ServerFailure(message: 'Failed to load content');
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<List<ManageTaskChatModel>> getMediaHouseOffers(
      String contentId) async {
    try {
      final response = await apiClient.get(
        getContentMediaHouseOfferUrl,
        queryParameters: {'image_id': contentId},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 200) {
          final List offers = data['response'] ?? [];
          return offers
              .map((e) => ManageTaskChatModel.fromJson(e ?? {}))
              .toList();
        }
        throw ServerFailure(
            message: data['message'] ?? 'Failed to load offers');
      }
      throw ServerFailure(message: 'Failed to load offers');
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<List<EarningTransactionDetail>> getContentTransactions(
      String contentId, int limit, int offset) async {
    try {
      final response = await apiClient.post(
        getDetailsById,
        data: {
          'content_id': contentId,
          // 'limit': limit, // Endpoint might not support limit/offset or handles it differently
          // 'offset': offset, 
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // TaskRemoteDataSource uses 'response' key for this endpoint
        final List transactions = data['response'] ?? [];
        return transactions
            .map((e) => EarningTransactionDetail.fromJson(e))
            .toList();
      }
      throw ServerFailure(message: 'Failed to load transactions');
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
