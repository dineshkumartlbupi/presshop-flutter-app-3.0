import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:presshop/core/api/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/error/api_error_handler.dart';
import 'package:presshop/core/utils/app_logger.dart';

class ApiClient {
  ApiClient(this._dio, this._sharedPreferences, this._secureStorage) {
    _dio.options.baseUrl = ApiConstantsNew.config.baseUrl;
    _dio.options.connectTimeout = const Duration(minutes: 2);
    _dio.options.receiveTimeout = const Duration(minutes: 2);

    /// Attach interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );

    /// Pretty logger (DEBUG ONLY)
    if (kDebugMode) {
      _dio.interceptors.add(PrettyDioLogger());
    }
  }
  final Dio _dio;
  final SharedPreferences _sharedPreferences;
  final FlutterSecureStorage _secureStorage;

  SharedPreferences get sharedPreferences => _sharedPreferences;

  Future<void> _onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Prioritize SharedPreferences for speed and stability
    String? token =
        _sharedPreferences.getString(SharedPreferencesKeys.tokenKey);
    if (token == null || token.isEmpty) {
      token = await _secureStorage.read(key: SharedPreferencesKeys.tokenKey);
      if (token != null && token.isNotEmpty) {
        // Sync back to SharedPreferences if found in SecureStorage
        await _sharedPreferences.setString(
            SharedPreferencesKeys.tokenKey, token);
      }
    }

    final deviceId =
        _sharedPreferences.getString(SharedPreferencesKeys.deviceIdKey) ?? "";

    if (token != null && token.isNotEmpty) {
      debugPrint("DEBUG: ApiClient Token: $token");

      /// Using same behavior as your existing NetworkClass
      options.headers[SharedPreferencesKeys.headerKey] = "Bearer $token";
      options.headers['x-access-token'] = token;
    } else {
      debugPrint("DEBUG: ApiClient Token is NULL or EMPTY");
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
    /*
    if (ApiErrorHandler.isUnauthenticated(err)) {
      /// Avoid infinite loops if the refresh token call itself fails
      if (err.requestOptions.path.contains(ApiConstantsNew.auth.refreshToken)) {
        handler.next(err);
        return;
      }

      debugPrint("🔄 401 Detected - Attempting Token Refresh...");

      try {
        final refreshSuccess = await TokenRefreshManager().refreshToken();

        if (refreshSuccess) {
          debugPrint("✅ Token Refresh Success - Retrying original request");
          final newAccessToken = _sharedPreferences.getString(tokenKey);

          if (newAccessToken != null && newAccessToken.isNotEmpty) {
            final opts = err.requestOptions;
            opts.headers[headerKey] = "Bearer $newAccessToken";

            final cloneReq = await _dio.request(
              opts.path,
              options: Options(
                method: opts.method,
                headers: opts.headers,
                contentType: opts.contentType,
                responseType: opts.responseType,
                followRedirects: opts.followRedirects,
                validateStatus: opts.validateStatus,
                receiveTimeout: opts.receiveTimeout,
                sendTimeout: opts.sendTimeout,
                extra: opts.extra,
              ),
              data: opts.data,
              queryParameters: opts.queryParameters,
            );
            return handler.resolve(cloneReq);
          }
        }
      } catch (e) {
        debugPrint("❌ Token Refresh Exception in ApiClient: $e");
      }

      // If refresh failed or was not possible, continue to error handling
      // TokenRefreshManager already handles logout/navigation if needed.
    }
    */
    _printCurlCommand(err.requestOptions);

    // Use ApiErrorHandler to sanitize the error before passing it up
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
    try {
      debugPrint("👇👇👇 CURL COMMAND FOR REPRODUCTION 👇👇👇");
      String curl = "curl --request ${options.method} '${options.uri}'";

      options.headers.forEach((key, value) {
        if (key != "content-length") {
          curl += " --header '$key: $value'";
        }
      });

      if (options.data != null) {
        if (options.data is FormData) {
          curl += " --data '[FormData]'";
        } else if (options.data is Map || options.data is List) {
          curl += " --data '${jsonEncode(options.data)}'";
        } else {
          curl += " --data '${options.data}'";
        }
      }

      debugPrint(curl);
      debugPrint("👆👆👆 COPY AND RUN THIS IN TERMINAL 👆👆👆");
    } catch (e) {
      debugPrint("❌ Failed to generate CURL command: $e");
    }
  }

  // Future<void> _clearSession() async {
  //   debugPrint("🧹 Clearing User Session (ApiClient)...");
  //   await _secureStorage.delete(key: tokenKey);
  //   await _secureStorage.delete(key: refreshtokenKey);
  //   await _sharedPreferences.remove(tokenKey);
  //   await _sharedPreferences.remove(refreshtokenKey);
  //   await _sharedPreferences.remove(rememberKey);
  // }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool? showLoader,
  }) async {
    options ??= Options();
    options.extra ??= {};
    if (showLoader != null) {
      options.extra!['show_loader'] = showLoader;
    }

    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool? showLoader,
  }) async {
    options ??= Options();
    options.extra ??= {};
    if (showLoader != null) {
      options.extra!['show_loader'] = showLoader;
    }

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
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool? showLoader,
  }) async {
    options ??= Options();
    options.extra ??= {};
    if (showLoader != null) {
      options.extra!['show_loader'] = showLoader;
    }

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
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool? showLoader,
  }) async {
    options ??= Options();
    options.extra ??= {};
    if (showLoader != null) {
      options.extra!['show_loader'] = showLoader;
    }

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
    bool? showLoader,
  }) async {
    options ??= Options();
    options.extra ??= {};
    if (showLoader != null) {
      options.extra!['show_loader'] = showLoader;
    }

    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> multipartPost(
    String path, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool? showLoader,
  }) async {
    options ??= Options();
    options.extra ??= {};
    if (showLoader != null) {
      options.extra!['show_loader'] = showLoader;
    }

    return _dio.post(path,
        data: formData, queryParameters: queryParameters, options: options);
  }

  Future<Response> postUri(
    Uri uri, {
    dynamic data,
    Options? options,
    bool? showLoader,
  }) async {
    options ??= Options();
    options.extra ??= {};
    if (showLoader != null) {
      options.extra!['show_loader'] = showLoader;
    }

    return _dio.postUri(uri, data: data, options: options);
  }
}
