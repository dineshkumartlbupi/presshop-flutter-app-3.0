import 'dart:convert';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/core/error/api_error_handler.dart';

abstract class SplashRemoteDataSource {
  Future<Map<String, dynamic>> checkAppVersion();
}

class SplashRemoteDataSourceImpl implements SplashRemoteDataSource {
  final ApiClient apiClient;

  SplashRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> checkAppVersion() async {
    try {
      final response = await apiClient.get(getLatestVersionUrl);
      if (response.statusCode == 200) {
        final data = response.data;
        final Map<String, dynamic> responseMap =
            data is String ? jsonDecode(data) : Map<String, dynamic>.from(data);

        if (responseMap['success'] == true && responseMap['data'] != null) {
          return responseMap['data'];
        }
        return responseMap;
      } else {
        throw ServerFailure(
            message: 'Failed to check app version: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
