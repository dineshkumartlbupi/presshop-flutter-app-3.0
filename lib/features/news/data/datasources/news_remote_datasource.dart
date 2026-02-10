import 'package:flutter/foundation.dart';
import 'package:presshop/core/api/api_constant.dart';
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

  Future<List<CommentModel>> getComments(String contentId,
      {int limit = 15, int offset = 0});
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  NewsRemoteDataSourceImpl({required this.client});
  final ApiClient client;

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
      debugPrint("DEBUG: getAggregatedNews body: $body");
      final response = await client.post(
        ApiConstantsNew.content.aggregatedNews,
        data: body,
      );
      debugPrint(
          "DEBUG: getAggregatedNews response keys: ${response.data is Map ? (response.data as Map).keys.toList() : 'Not a Map'}");
      // debugPrint("DEBUG: getAggregatedNews response data: ${response.data}");

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 202) {
        if (response.statusCode == 202) {
          debugPrint(
              "DEBUG: getAggregatedNews status is 202 (Accepted/Processing)");
          throw ProcessingException("News aggregation in progress");
        }
        final data = response.data;
        if (data['data'] != null && data['data']['news'] != null) {
          final List<dynamic> newsList = data['data']['news'];
          if (newsList.isNotEmpty) {
            // debugPrint("DEBUG: getAggregatedNews first news item: ${newsList[0]}");
            if (newsList[0] is Map) {
              debugPrint(
                  "DEBUG: first news item keys: ${(newsList[0] as Map).keys.toList()}");
            }
          } else {
            debugPrint("DEBUG: getAggregatedNews news list is EMPTY");
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
      {int limit = 15, int offset = 0}) async {
    final body = {
      "content_id": contentId,
      "limit": limit,
      "offset": offset,
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
