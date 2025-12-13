import 'dart:convert';
import 'package:presshop/core/api/api_constant.dart';
import '../../../../core/api/api_client.dart';
import 'package:presshop/core/error/exceptions.dart';

abstract class FeedRemoteDataSource {
  Future<Map<String, dynamic>> getFeeds(Map<String, dynamic> params);
  Future<bool> toggleInteraction(Map<String, dynamic> params);
}

class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  final ApiClient apiClient;

  FeedRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getFeeds(Map<String, dynamic> params) async {
    final response = await apiClient.get(
      getFeedListAPI, 
      queryParameters: params,
    );

    if (response.statusCode == 200) {
      if (response.data is String) {
        return jsonDecode(response.data) as Map<String, dynamic>;
      }
      return response.data as Map<String, dynamic>;
    } else {
      throw ServerException("Failed to get feeds");
    }
  }

  @override
  Future<bool> toggleInteraction(Map<String, dynamic> params) async {
    final response = await apiClient.patch(
      likeFavFeedAPI,
      data: params,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw ServerException("Failed to toggle interaction");
    }
  }
}
