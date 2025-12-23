import 'package:dio/dio.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/features/authentication/data/models/term_model.dart';

class TermsRepository {
  final Dio dio;

  TermsRepository(this.dio);

  Future<TermsResponse> fetchTerms(String type) async {
    try {
      final response = await dio.get(
        "$baseUrl$termConditionUrl",
        queryParameters: {
          "type": type,
        },
      );

      if (response.statusCode == 200) {
        return TermsResponse.fromJson(response.data);
      } else {
        throw Exception(
          "Failed to load terms: ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? "Network error while loading Terms",
      );
    }
  }
}
