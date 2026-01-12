import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/features/rating/data/models/rating_review_model.dart';
import 'package:presshop/core/models/publication_model.dart';
import 'package:presshop/core/error/exceptions.dart';

abstract class RatingRemoteDataSource {
  Future<List<RatingReviewModel>> getReviews(Map<String, dynamic> params);
  Future<List<PublicationDataModel>> getMediaHouses();
}

class RatingRemoteDataSourceImpl implements RatingRemoteDataSource {
  final ApiClient apiClient;

  RatingRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<RatingReviewModel>> getReviews(
      Map<String, dynamic> params) async {
    final response = await apiClient.get(
      getAllRatingAPI,
      queryParameters: params,
    );
    try {
      final data = response.data; // Access .data from Response
      if (data != null && data['resp'] != null) {
        return (data['resp'] as List)
            .map((e) => RatingReviewModel.fromJson(e))
            .toList();
      } else {
        throw ServerException('No data found');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<PublicationDataModel>> getMediaHouses() async {
    final response = await apiClient.get(
      getMediaHouseDetailAPI,
    );
    try {
      final data = response.data; // Access .data from Response
      if (data != null && data['response'] != null) {
        return (data['response'] as List)
            .map((e) => PublicationDataModel.fromJson(e))
            .toList();
      } else {
        throw ServerException('No data found');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
