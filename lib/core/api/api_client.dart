import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/utils/shared_preferences.dart';

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
    final token = await _secureStorage.read(key: tokenKey);
    final deviceId = _sharedPreferences.getString(deviceIdKey) ?? "";

    if (token != null && token.isNotEmpty) {
      debugPrint("DEBUG: ApiClient Token: $token");

      /// Using same behavior as your existing NetworkClass
      options.headers[headerKey] = token;
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
    if (err.response?.statusCode == 401) {
      /// TODO: Token refresh logic if needed
    }
    handler.next(err);
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
  }) async {
    return _dio.post(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.put(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.patch(path, data: data, queryParameters: queryParameters);
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
URL    : ${options.baseUrl}${options.path}
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
URL    : ${response.requestOptions.baseUrl}${response.requestOptions.path}
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
URL    : ${err.requestOptions.baseUrl}${err.requestOptions.path}
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
