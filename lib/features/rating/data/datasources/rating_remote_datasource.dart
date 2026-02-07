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
      final data = response.data; // Access .data from Response
      if (data != null && data['resp'] != null) {
        return (data['resp'] as List)
            .map((e) => RatingReviewModel.fromJson(e))
            .toList();
      } else {
        throw ServerException('No data found');
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
