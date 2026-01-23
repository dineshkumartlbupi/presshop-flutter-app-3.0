import 'package:presshop/core/api/api_constant_new.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/error/api_error_handler.dart';
import 'package:presshop/core/error/exceptions.dart';
import 'package:presshop/features/news/data/models/comment_model.dart';
import 'package:presshop/features/news/data/models/news_model.dart';

abstract class NewsRemoteDataSource {
  Future<List<NewsModel>> getAggregatedNews({
    required double lat,
    required double lng,
    required double km,
    String category = "all",
    String? alertType,
    int limit = 10,
    int offset = 0,
  });

  Future<NewsModel> getNewsDetail(String id);

  Future<List<CommentModel>> getComments(String contentId, {int limit = 15});
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final ApiClient client;

  NewsRemoteDataSourceImpl({required this.client});

  @override
  Future<List<NewsModel>> getAggregatedNews({
    required double lat,
    required double lng,
    required double km,
    String category = "all",
    String? alertType,
    int limit = 10,
    int offset = 0,
  }) async {
    final body = {
      "category": category,
      "endpoint": "search-news",
      "search": "",
      "locationFilter": "",
      "coordinates": "$lat,$lng",
      "km": km,
      "limit": limit,
      "offset": offset,
      "alert_type": alertType,
    };

    try {
      final response = await client.post(
        ApiConstantsNew.content.aggregatedNews,
        data: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['data'] != null && data['data']['news'] != null) {
          final List<dynamic> newsList = data['data']['news'];
          if (newsList.isNotEmpty) {
            print("DEBUG: Raw News Item [0]: ${newsList[0]}");
          }
          return newsList.map((item) => NewsModel.fromJson(item)).toList();
        }
        return [];
      } else {
        throw ServerException("Failed to fetch aggregated news");
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<NewsModel> getNewsDetail(String id) async {
    final body = {"id": id};

    try {
      final response = await client.post(
        ApiConstantsNew.content.aggregatedNewsDetail,
        data: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = response.data;
        if (data.containsKey('data')) {
          final incidentData = data['data'];
          if (data.containsKey('stats')) {
            incidentData['sharesCount'] = data['stats']['shares'];
            incidentData['likesCount'] = data['stats']['likes'];
            incidentData['commentsCount'] = data['stats']['comments'];
            incidentData['viewCount'] = data['stats']['views'];
            incidentData['isLiked'] =
                data['stats']['is_liked'] ?? data['data']['is_liked'];
          } else {
            incidentData['isLiked'] = data['data']['is_liked'];
          }
          return NewsModel.fromJson(incidentData);
        }
        throw ServerException("Failed to fetch news detail");
      } else {
        throw ServerException("Failed to fetch news detail");
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<List<CommentModel>> getComments(String contentId,
      {int limit = 15}) async {
    final body = {
      "content_id": contentId,
      "limit": limit,
    };

    try {
      final response = await client.post(
        ApiConstantsNew.content.aggregatedNewsComments,
        data: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = response.data;
        if (data.containsKey('data')) {
          return (data['data'] as List)
              .map((e) => CommentModel.fromJson(e))
              .toList();
        }
        return [];
      } else {
        throw ServerException("Failed to fetch comments");
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
