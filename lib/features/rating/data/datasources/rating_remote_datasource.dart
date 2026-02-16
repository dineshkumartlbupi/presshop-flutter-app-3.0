import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/features/rating/data/models/rating_review_model.dart';
import 'package:presshop/core/models/publication_model.dart';
import 'package:presshop/core/error/api_error_handler.dart';
import 'package:presshop/core/error/exceptions.dart';

abstract class RatingRemoteDataSource {
  Future<List<RatingReviewModel>> getReviews(Map<String, dynamic> params);
  Future<List<PublicationDataModel>> getMediaHouses();
}

class RatingRemoteDataSourceImpl implements RatingRemoteDataSource {
  RatingRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<List<RatingReviewModel>> getReviews(
      Map<String, dynamic> params) async {
    try {
      final response = await apiClient.get(
        ApiConstantsNew.content.getAllRating,
        queryParameters: params,
      );
      final responseData = response.data;
      if (responseData != null &&
          responseData['data'] != null &&
          responseData['data']['resp'] != null) {
        final List dataList = responseData['data']['resp'] as List;
        return dataList.map((e) => RatingReviewModel.fromJson(e)).toList();
      } else if (responseData != null && responseData['resp'] != null) {
        // Fallback for different API structure if applicable
        final List dataList = responseData['resp'] as List;
        return dataList.map((e) => RatingReviewModel.fromJson(e)).toList();
      } else {
        return []; // Return empty list instead of throwing to avoid failure state when no reviews found
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<List<PublicationDataModel>> getMediaHouses() async {
    try {
      final response = await apiClient.get(
        ApiConstantsNew.tasks.mediaHouseList,
      );
      final data = response.data; // Access .data from Response
      if (data != null && data['response'] != null) {
        return (data['response'] as List)
            .map((e) => PublicationDataModel.fromJson(e))
            .toList();
      } else {
        throw ServerException('No data found');
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
