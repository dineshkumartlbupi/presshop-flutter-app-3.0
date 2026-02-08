import 'package:presshop/core/api/api_constant.dart';
import '../../../../core/api/api_client.dart';
import 'package:presshop/core/error/api_error_handler.dart';

abstract class FeedRemoteDataSource {
  Future<Map<String, dynamic>> getFeeds(Map<String, dynamic> params);
  Future<bool> toggleInteraction(Map<String, dynamic> params);
}

class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  FeedRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<Map<String, dynamic>> getFeeds(Map<String, dynamic> params) async {
    try {
      final response = await apiClient.get(
        ApiConstantsNew.content.feedList,
        queryParameters: params,
      );
      return response.data;
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<bool> toggleInteraction(Map<String, dynamic> params) async {
    try {
      final response = await apiClient.patch(
        ApiConstantsNew.content.likeFeed,
        data: params,
      );
      return response.statusCode == 200;
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
