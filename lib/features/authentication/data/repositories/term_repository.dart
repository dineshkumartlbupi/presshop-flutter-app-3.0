import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:presshop/core/api/api_constant_new.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/features/authentication/data/models/term_model.dart';

class TermsRepository {

  TermsRepository(this.apiClient);
  final ApiClient apiClient;

  Future<TermsResponse> fetchTerms(String type) async {
    try {
      debugPrint("Fetching terms with type: $type");
      final response = await apiClient.get(
        ApiConstantsNew.misc.cms,
        queryParameters: {
          "type": type,
        },
      );
      debugPrint("Terms API Response: ${response.data}");

      if (response.statusCode == 200) {
        return TermsResponse.fromJson(response.data);
      } else {
        throw Exception(
          "Failed to load terms: ${response.statusCode}",
        );
      }
    } on DioException catch (e) {
      String errorMessage = "Network error while loading Terms";
      if (e.response?.data is Map<String, dynamic>) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else if (e.message != null && e.message!.isNotEmpty) {
        // Use the custom message set by ApiClient for 502/404
        errorMessage = e.message!;
      }
      throw Exception(errorMessage);
    }
  }
}
