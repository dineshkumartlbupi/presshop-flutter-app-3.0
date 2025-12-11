import 'package:dio/dio.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/core_export.dart';
import '../models/content_item_model.dart';
import '../models/hashtag_model.dart';
import 'package:presshop/core/api/api_client.dart';

abstract class ContentRemoteDataSource {
  Future<List<ContentItemModel>> getMyContent({int page = 1, int limit = 20, Map<String, dynamic> params = const {}});
  Future<ContentItemModel> publishContent(Map<String, dynamic> data);
  Future<ContentItemModel> saveDraft(Map<String, dynamic> data);
  Future<ContentItemModel> updateContent(String contentId, Map<String, dynamic> data);
  Future<void> deleteContent(String contentId);
  Future<List<String>> uploadMedia(List<String> filePaths);
  Future<List<HashtagModel>> searchHashtags(String query);
  Future<List<HashtagModel>> getTrendingHashtags();
  Future<ContentItemModel> getContentDetail(String contentId);
}

class ContentRemoteDataSourceImpl implements ContentRemoteDataSource {
  final ApiClient apiClient;

  ContentRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<ContentItemModel>> getMyContent({int page = 1, int limit = 20, Map<String, dynamic> params = const {}}) async {
    try {
      final queryParams = {'page': page, 'limit': limit, ...params};
      final response = await apiClient.get(
        myContentUrl,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 200) {
          final List contentList = data['content'] ?? data['data'] ?? [];
          return contentList.map((e) => ContentItemModel.fromJson(e)).toList();
        }
        throw ServerFailure(message: data['message'] ?? 'Failed to load content');
      }
      throw ServerFailure(message: 'Failed to load content');
    } catch (e) {
      throw ServerFailure(message: e.toString());
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
        response = await apiClient.multipartPost(publishContentUrl, formData: formData);
      } else {
        response = await apiClient.post(publishContentUrl, data: data);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        if (resData['code'] == 200) {
          return ContentItemModel.fromJson(resData['content'] ?? resData['data']);
        }
        throw ServerFailure(message: resData['message'] ?? 'Publish failed');
      }
      throw ServerFailure(message: 'Publish failed');
    } catch (e) {
      throw ServerFailure(message: e.toString());
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
        response = await apiClient.multipartPost(saveDraftUrl, formData: formData);
      } else {
        response = await apiClient.post(saveDraftUrl, data: data);
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
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<ContentItemModel> updateContent(String contentId, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.put('$updateContentUrl/$contentId', data: data);

      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData['code'] == 200) {
          return ContentItemModel.fromJson(resData['content'] ?? resData['data']);
        }
        throw ServerFailure(message: resData['message'] ?? 'Update failed');
      }
      throw ServerFailure(message: 'Update failed');
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<void> deleteContent(String contentId) async {
    try {
      final response = await apiClient.delete('$deleteContentUrl/$contentId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 200) {
          return;
        }
        throw ServerFailure(message: data['message'] ?? 'Delete failed');
      }
      throw ServerFailure(message: 'Delete failed');
    } catch (e) {
      throw ServerFailure(message: e.toString());
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

      final response = await apiClient.multipartPost(uploadMediaUrl, formData: formData);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 200) {
          return List<String>.from(data['urls'] ?? data['media_urls'] ?? []);
        }
        throw ServerFailure(message: data['message'] ?? 'Upload failed');
      }
      throw ServerFailure(message: 'Upload failed');
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<List<HashtagModel>> searchHashtags(String query) async {
    try {
      final response = await apiClient.get(
        searchHashtagsUrl,
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
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<List<HashtagModel>> getTrendingHashtags() async {
    try {
      final response = await apiClient.get(trendingHashtagsUrl);

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
      throw ServerFailure(message: e.toString());
    }
  }

  @override
  Future<ContentItemModel> getContentDetail(String contentId) async {
    try {
      final response = await apiClient.get('$contentDetailUrl/$contentId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 200) {
          return ContentItemModel.fromJson(data['content'] ?? data['data']);
        }
        throw ServerFailure(message: data['message'] ?? 'Failed to load content');
      }
      throw ServerFailure(message: 'Failed to load content');
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }
}
