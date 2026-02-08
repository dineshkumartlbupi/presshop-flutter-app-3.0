import 'dart:convert';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/constants/api_response.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/core/error/api_error_handler.dart';
import 'package:presshop/features/splash/data/models/version_model.dart';

abstract class SplashRemoteDataSource {
  Future<VersionModel> checkAppVersion();
}

class SplashRemoteDataSourceImpl implements SplashRemoteDataSource {
  SplashRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<VersionModel> checkAppVersion() async {
    try {
      final response = await apiClient.get(
        ApiConstantsNew.auth.getLatestVersion,
        showLoader: false,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final Map<String, dynamic> responseMap =
            data is String ? jsonDecode(data) : Map<String, dynamic>.from(data);

        final appVersionResponse = ApiResponse<AppVersionData>.fromJson(
            responseMap, (json) => AppVersionData.fromJson(json));

        if (appVersionResponse.success) {
          return VersionModel(
            ios: appVersionResponse.data?.ios ?? '',
            android: appVersionResponse.data?.android ?? '',
            forceUpdate: appVersionResponse.data?.forceUpdate ?? false,
          );
        }
        throw ServerFailure(
            message: appVersionResponse.message.isNotEmpty
                ? appVersionResponse.message
                : 'Unknown error');
      } else {
        throw ServerFailure(
            message: 'Failed to check app version: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
