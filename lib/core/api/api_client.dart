import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:presshop/core/api/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:presshop/core/api/token_refresh_manager.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/error/api_error_handler.dart';
import 'package:presshop/core/utils/app_logger.dart';

class ApiClient {
  ApiClient(this._dio, this._sharedPreferences, this._secureStorage) {
    _dio.options.baseUrl = ApiConstantsNew.config.baseUrl;
    _dio.options.connectTimeout = const Duration(minutes: 2);
    _dio.options.receiveTimeout = const Duration(minutes: 2);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );

    // if (kDebugMode) {
    //   _dio.interceptors.add(PrettyDioLogger(formatJson: true));
    // }
  }
  final Dio _dio;
  final SharedPreferences _sharedPreferences;
  final FlutterSecureStorage _secureStorage;

  SharedPreferences get sharedPreferences => _sharedPreferences;

  Future<void> _onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Check if this is a retry from _onError
    if (options.extra['is_retry'] == true) {
      debugPrint(
          "DEBUG: [RETRY] Detected retry flag for ${options.path}. Keeping existing headers.");
      handler.next(options);
      return;
    }

    // Normal flow: Read tokens from SharedPreferences or SecureStorage
    String? token =
        _sharedPreferences.getString(SharedPreferencesKeys.tokenKey);
    if (token == null || token.isEmpty) {
      token = await _secureStorage.read(key: SharedPreferencesKeys.tokenKey);
      if (token != null && token.isNotEmpty) {
        await _sharedPreferences.setString(
            SharedPreferencesKeys.tokenKey, token);
      }
    }

    final deviceId =
        _sharedPreferences.getString(SharedPreferencesKeys.deviceIdKey) ?? "";

    if (token != null && token.isNotEmpty) {
      // debugPrint("DEBUG: ApiClient Token: $token");
      options.headers[SharedPreferencesKeys.headerKey] = "Bearer $token";
      options.headers['x-access-token'] = token;
    }

    options.headers[SharedPreferencesKeys.headerDeviceIdKey] = deviceId;
    options.headers[SharedPreferencesKeys.headerDeviceTypeKey] =
        "mobile-flutter-${Platform.isIOS ? "ios" : "android"}";
    handler.next(options);
  }

  Future<void> _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    handler.next(response);
  }

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (ApiErrorHandler.isUnauthenticated(err)) {
      // 1. Avoid infinite loops if the refresh token call itself fails
      if (err.requestOptions.path.contains(ApiConstantsNew.auth.refreshToken)) {
        handler.next(err);
        return;
      }

      // 2. Check if this request has already been retried once
      if (err.requestOptions.extra['is_retry'] == true) {
        debugPrint(
            "❌ 401 Detected again on a retried request for: ${err.requestOptions.path}. Stopping to avoid infinite loop.");
        handler.next(err);
        return;
      }

      debugPrint("🔄 401 Detected - Attempting Token Refresh...");

      try {
        final newAccessToken = await TokenRefreshManager().refreshToken();

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          debugPrint("✅ Token Refresh Success - Retrying original request");

          final opts = err.requestOptions;

          // Set mandatory headers for retry
          final Map<String, dynamic> newHeaders =
              Map<String, dynamic>.from(opts.headers);
          newHeaders[SharedPreferencesKeys.headerKey] =
              "Bearer $newAccessToken";
          newHeaders['x-access-token'] = newAccessToken;

          // Mark as retry to ensure _onRequest skips it
          final Map<String, dynamic> newExtra =
              Map<String, dynamic>.from(opts.extra);
          newExtra['is_retry'] = true;

          debugPrint(
              "DEBUG: Retrying request with new token (last 4 chars): ${newAccessToken.substring(newAccessToken.length - 4)}");

          final cloneReq = await _dio.request(
            opts.path,
            options: Options(
              method: opts.method,
              headers: newHeaders,
              contentType: opts.contentType,
              responseType: opts.responseType,
              followRedirects: opts.followRedirects,
              validateStatus: opts.validateStatus,
              receiveTimeout: opts.receiveTimeout,
              sendTimeout: opts.sendTimeout,
              extra: newExtra,
            ),
            data: opts.data,
            queryParameters: opts.queryParameters,
          );
          return handler.resolve(cloneReq);
        }
      } catch (e) {
        debugPrint("❌ Token Refresh Exception in ApiClient: $e");
      }
    }

    _printCurlCommand(err.requestOptions);

    final failure = ApiErrorHandler.handle(err);

    AppLogger.error(
      "API Error [${err.requestOptions.method}] ${err.requestOptions.path}: ${failure.message}",
      trackAnalytics: true,
    );

    final sanitizedError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: failure.message,
      message: failure.message,
    );

    handler.next(sanitizedError);
  }

  void _printCurlCommand(RequestOptions options) {
    if (kDebugMode) {
      String queryParams = "";
      if (options.queryParameters.isNotEmpty) {
        queryParams =
            "?${options.queryParameters.entries.map((e) => "${e.key}=${e.value}").join("&")}";
      }

      String curl =
          "curl -X ${options.method} '${options.baseUrl}${options.path}$queryParams'";
      for (var header in options.headers.entries) {
        curl += " -H '${header.key}: ${header.value}'";
      }

      if (options.data != null) {
        if (options.data is FormData) {
          curl += " -d '[FormData]'";
        } else {
          try {
            curl += " -d '${jsonEncode(options.data)}'";
          } catch (e) {
            curl += " -d '[Unencodable Data: $e]'";
          }
        }
      }

      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      debugPrint("� CURL COMMAND:");
      debugPrint(curl);
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool showLoader = true,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool showLoader = true,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool showLoader = true,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool showLoader = true,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool showLoader = true,
  }) async {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Support for multipart/form-data
  Future<Response> multipartPost(
    String path, {
    required FormData formData,
    Options? options,
    bool showLoader = true,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.post(
      path,
      data: formData,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
