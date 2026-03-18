import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/core/di/injection_container.dart';

/// Service for handling deeplink callbacks to the admin API
class DeeplinkService {
  /// Send deeplink callback data to admin API
  static Future<void> sendCallback(
    String data,
    bool isAppInstallCallback,
  ) async {
    try {
      String path = isAppInstallCallback
          ? ApiConstantsNew.misc.onAppInstallCallback
          : ApiConstantsNew.misc.onDeeplinkCallback;

      Response response = await sl<ApiClient>().post(
        path,
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
