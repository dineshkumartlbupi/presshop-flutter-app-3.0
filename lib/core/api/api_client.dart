import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:presshop/core/error/api_error_handler.dart';

class ApiClient {
  final Dio _dio;
  final SharedPreferences _sharedPreferences;
  final FlutterSecureStorage _secureStorage;

  ApiClient(this._dio, this._sharedPreferences, this._secureStorage) {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(minutes: 2);
    _dio.options.receiveTimeout = const Duration(minutes: 2);

    /// Attach interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );

    /// Pretty logger (DEBUG ONLY)
    if (kDebugMode) {
      _dio.interceptors.add(PrettyDioLogger());
    }
  }

  SharedPreferences get sharedPreferences => _sharedPreferences;

  Future<void> _onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    String? token = await _secureStorage.read(key: tokenKey);

    /// Fallback to SharedPreferences if SecureStorage fails (common on some Android versions)
    if (token == null || token.isEmpty) {
      token = _sharedPreferences.getString(tokenKey);
      if (token != null && token.isNotEmpty) {
        debugPrint("DEBUG: ApiClient Token retrieved from SharedPreferences");
        // Sync back to SecureStorage if it was empty
        await _secureStorage.write(key: tokenKey, value: token);
      }
    }

    final deviceId = _sharedPreferences.getString(deviceIdKey) ?? "";

    if (token != null && token.isNotEmpty) {
      debugPrint("DEBUG: ApiClient Token: $token");

      /// Using same behavior as your existing NetworkClass
      options.headers[headerKey] = "Bearer $token";
    } else {
      debugPrint("DEBUG: ApiClient Token is NULL or EMPTY");
    }

    options.headers[headerDeviceIdKey] = deviceId;
    options.headers[headerDeviceTypeKey] =
        "mobile-flutter-${Platform.isIOS ? "ios" : "android"}";

    handler.next(options);
  }

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (ApiErrorHandler.isUnauthenticated(err)) {
      /// Token refresh logic
      if (err.requestOptions.path.contains(appRefreshTokenUrl)) {
        final failure = ApiErrorHandler.handle(err);
        final sanitized = DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: err.type,
          error: failure.message,
          message: failure.message,
        );
        handler.next(sanitized);
        return;
      }

      String? refreshToken = await _secureStorage.read(key: refreshtokenKey);

      /// Fallback for Refresh Token
      if (refreshToken == null || refreshToken.isEmpty) {
        refreshToken = _sharedPreferences.getString(refreshtokenKey);
        if (refreshToken != null && refreshToken.isNotEmpty) {
          debugPrint(
              "DEBUG: ApiClient Refresh Token retrieved from SharedPreferences");
          await _secureStorage.write(key: refreshtokenKey, value: refreshToken);
        }
      }

      String? accessToken = await _secureStorage.read(key: tokenKey);
      if (accessToken == null || accessToken.isEmpty) {
        accessToken = _sharedPreferences.getString(tokenKey) ?? "";
      }

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          final refreshDio = Dio();
          refreshDio.options.baseUrl = baseUrl;

          // Match TokenRefreshManager headers
          refreshDio.options.headers[headerDeviceIdKey] =
              _sharedPreferences.getString(deviceIdKey) ?? "";
          refreshDio.options.headers[headerDeviceTypeKey] =
              "mobile-flutter-${Platform.isIOS ? "ios" : "android"}";

          // Logic from TokenRefreshManager: if refresh token exists, access token header is empty
          String tokenForAccess = refreshToken.isEmpty ? accessToken : "";

          refreshDio.options.headers[refreshHeaderKey] = refreshToken;
          refreshDio.options.headers[accessHeaderKey] = tokenForAccess;

          debugPrint("🔄 Attempting Token Refresh (ApiClient)...");
          // Send empty body as per TokenRefreshManager
          final response = await refreshDio.get(appRefreshTokenUrl);

          if (response.statusCode == 200) {
            final data = response.data;
            debugPrint("✅ Token Refresh Success: $data");

            if (data["success"] == true &&
                data["data"] != null &&
                data["data"]["access_token"] != null &&
                data["data"]["refresh_token"] != null) {
              // 1. Delete old tokens
              await _secureStorage.delete(key: tokenKey);
              await _secureStorage.delete(key: refreshtokenKey);

              // 2. Save NEW tokens
              final newAccessToken = data["data"]["access_token"];
              final newRefreshToken = data["data"]["refresh_token"];

              await _secureStorage.write(key: tokenKey, value: newAccessToken);
              await _secureStorage.write(
                  key: refreshtokenKey, value: newRefreshToken);

              // 3. Update SharedPreferences to stay in sync
              await _sharedPreferences.setString(tokenKey, newAccessToken);
              await _sharedPreferences.setString(
                  refreshtokenKey, newRefreshToken);

              debugPrint("🔄 Retrying original request with new token");
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
          } else {
            debugPrint(
                "❌ Token Refresh Failed with status: ${response.statusCode}");
            await _clearSession();
          }
        } catch (e) {
          debugPrint("❌ Token Refresh Failed: $e");
          await _clearSession();
        }
      } else {
        debugPrint("❌ Refresh Token is NULL or EMPTY - Clearing Session");
        await _clearSession();
      }
    }
    _printCurlCommand(err.requestOptions);
    
    // Use ApiErrorHandler to sanitize the error before passing it up
    final failure = ApiErrorHandler.handle(err);
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

  Future<void> _clearSession() async {
    debugPrint("🧹 Clearing User Session (ApiClient)...");
    await _secureStorage.delete(key: tokenKey);
    await _secureStorage.delete(key: refreshtokenKey);
    await _sharedPreferences.remove(tokenKey);
    await _sharedPreferences.remove(refreshtokenKey);
    await _sharedPreferences.remove(rememberKey);
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
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
  }) async {
    return _dio.delete(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> multipartPost(
    String path, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post(path,
        data: formData, queryParameters: queryParameters, options: options);
  }

  Future<Response> postUri(
    Uri uri, {
    dynamic data,
    Options? options,
  }) async {
    return _dio.postUri(uri, data: data, options: options);
  }
}

class PrettyDioLogger extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    debugPrint(
      '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
➡️ API REQUEST
METHOD : ${options.method}
URL    : ${options.uri}
HEADERS: ${_maskHeaders(options.headers)}
QUERY  : ${options.queryParameters}
BODY   : ${options.data}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''',
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    debugPrint(
      '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ API RESPONSE
STATUS : ${response.statusCode}
URL    : ${response.realUri}
DATA   : ${response.data}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    debugPrint(
      '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ API ERROR
STATUS : ${err.response?.statusCode}
URL    : ${err.requestOptions.uri}
ERROR  : ${err.message}
DATA   : ${err.response?.data}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''',
    );
    super.onError(err, handler);
  }

  /// Mask sensitive headers
  Map<String, dynamic> _maskHeaders(Map<String, dynamic> headers) {
    final masked = Map<String, dynamic>.from(headers);
    if (masked.containsKey(headerKey)) {
      debugPrint("Token coming in headers: ${masked[headerKey]}");
      masked[headerKey] = "****TOKEN****";
      print("Token masked final: ${masked[headerKey]}");
    }
    return masked;
  }
}
