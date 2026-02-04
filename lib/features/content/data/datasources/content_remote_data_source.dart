import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/core_export.dart';
import '../models/all_content_model.dart';
import '../models/hashtag_model.dart';
import 'package:presshop/features/task/data/models/manage_task_chat_model.dart';
import 'package:presshop/features/earning/data/models/earning_model.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/error/api_error_handler.dart';
import 'package:presshop/core/api/api_constant.dart';

abstract class ContentRemoteDataSource {
  Future<List<ContentItemModel>> getMyContent({
    int page = 1,
    int limit = 20,
    Map<String, dynamic> params = const {},
    bool showLoader = true,
    String type = 'my',
  });
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

  ContentRemoteDataSourceImpl(this.apiClient);
  final ApiClient apiClient;

  @override
  Future<List<ContentItemModel>> getMyContent({
    int page = 1,
    int limit = 20,
    Map<String, dynamic> params = const {},
    bool showLoader = true,
    String type = 'my',
  }) async {
    try {
      final queryParams = {'page': page, 'limit': limit, ...params};
      final url = type == 'my' ? myContentUrl : allContentUrl;
      final response = await apiClient.get(
        url,
        queryParameters: queryParams,
        showLoader: showLoader,
      );

      debugPrint("DEBUG: getMyContent response: ${response.data}");

      if (response.statusCode == 200) {
        var data = response.data;
        debugPrint("DEBUG: getMyContent data: $data");

        // Handle "success": true case or "code": 200 case
        if (data['code'] == 200 || data['success'] == true) {
          var contentList = [];

          // Handle nested structure: data -> data -> list
          if (data['data'] != null) {
            if (data['data'] is Map) {
              // data['data']['data'] (from latest logs)
              if (data['data']['data'] is List) {
                contentList = data['data']['data'];
              }
              // data['data']['contentList'] (legacy)
              else if (data['data']['contentList'] is List) {
                contentList = data['data']['contentList'];
              }
              // data['data']['content'] (legacy)
              else if (data['data']['content'] is List) {
                contentList = data['data']['content'];
              }
            } else if (data['data'] is List) {
              // data['data'] is directly the list
              contentList = data['data'];
            }
          }

          // Fallback check on root level if not found in nested 'data'
          if (contentList.isEmpty) {
            if (data['contentList'] is List) {
              contentList = data['contentList'];
            } else if (data['content'] is List) {
              contentList = data['content'];
            }
          }

          debugPrint("DEBUG: getMyContent list length: ${contentList.length}");

          if (contentList.isNotEmpty) {
            try {
              return contentList
                  .map((e) {
                    try {
                      return ContentItemModel.fromJson(e);
                    } catch (err) {
                      debugPrint(
                          "DEBUG: Error parsing individual content item: $err");
                      return null;
                    }
                  })
                  .whereType<ContentItemModel>()
                  .toList(); // Filter out nulls
            } catch (e) {
              debugPrint("DEBUG: Error in list mapping: $e");
              rethrow;
            }
          }

          // If we got success/200 but list is empty, return empty list
          return [];
        }
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
        var data = response.data;

        // Handle nested structure from logs
        if (data['data'] != null && data['data'] is Map) {
          final innerData = data['data'];
          if (innerData['code'] == 200) {
            return ContentItemModel.fromJson(innerData['contentDetail'] ??
                innerData['content'] ??
                innerData['data']);
          }
        }

        // Fallback
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
      try {
        final response = await apiClient.get(
          getDetailsById,
          queryParameters: {
            'content_id': contentId,
            // 'limit': limit,
            // 'offset': offset,
          },
        );

        if (response.statusCode == 200) {
          final data = response.data;
          final List transactions = data['response'] ?? [];
          return transactions
              .map((e) => EarningTransactionDetail.fromJson(e))
              .toList();
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          debugPrint(
              "WARNING: getContentTransactions endpoint 404s. Returning empty list.");
          return [];
        }
        rethrow;
      }

      throw ServerFailure(message: 'Failed to load transactions');
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
