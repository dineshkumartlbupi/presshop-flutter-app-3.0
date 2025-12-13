import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:presshop/core/api/api_constant.dart';

/// Service for handling deeplink callbacks to the admin API
class DeeplinkService {
  /// Send deeplink callback data to admin API
  static Future<void> sendCallback(
    String data,
    bool isAppInstallCallback,
  ) async {
    try {
      Dio dio = Dio(
        BaseOptions(
          baseUrl: adminBaseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      Response response = await dio.post(
        isAppInstallCallback ? onAppInstallCallback : onDeeplinkCallback,
        data: {"data": data},
      );

      if (response.statusCode! <= 201) {
        debugPrint("✅ Deeplink callback success: ${response.data}");
      } else {
        debugPrint(
          "❌ Deeplink callback failed with status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      debugPrint("❌ Deeplink callback error: $e");
    }
  }
}
