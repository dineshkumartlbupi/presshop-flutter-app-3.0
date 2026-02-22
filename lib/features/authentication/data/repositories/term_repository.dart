import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/features/authentication/data/models/term_model.dart';

class TermsRepository {
  TermsRepository(this.apiClient);
  final ApiClient apiClient;

  Future<TermsResponse> fetchTerms(String type) async {
    try {
      debugPrint("Fetching terms with type: $type");
      if (type == 'legal') {
        final response = await apiClient.get(ApiConstantsNew.misc.signupLegal);
        debugPrint("Terms API Response (Legal): ${response.data}");

        if (response.statusCode == 200) {
          var legalData = response.data['data'] ??
              response.data['response'] ??
              response.data['status'] ??
              response.data;

          if (legalData is List && legalData.isNotEmpty) {
            legalData = legalData[0];
          }

          if (legalData != null) {
            final String desc = (legalData['description'] ??
                    legalData['content'] ??
                    legalData['terms'] ??
                    "")
                .toString();
            final cmsItem = CmsItem(
                id: legalData['id'] ?? legalData['_id'] ?? '',
                description: desc);
            return TermsResponse(
              data: TermsData(
                privacyPolicy: CmsItem(id: '', description: ''),
                termAndCond: cmsItem,
              ),
            );
          } else {
            return TermsResponse(
              data: TermsData(
                privacyPolicy: CmsItem(id: '', description: ''),
                termAndCond: CmsItem(id: '', description: ''),
              ),
            );
          }
        } else {
          throw Exception("Failed to load terms: ${response.statusCode}");
        }
      }

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
        errorMessage = e.message!;
      }
      throw Exception(errorMessage);
    }
  }
}
