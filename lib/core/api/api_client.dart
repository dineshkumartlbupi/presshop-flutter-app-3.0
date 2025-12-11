import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:presshop/core/core_export.dart'; // Ensure this path is correct
import 'package:presshop/core/utils/shared_preferences.dart';

class ApiClient {
  final Dio _dio;
  final SharedPreferences _sharedPreferences;

  ApiClient(this._dio, this._sharedPreferences) {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(minutes: 1);
    _dio.options.receiveTimeout = const Duration(minutes: 1);
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onError: _onError,
    ));
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
      error: true,
    ));
  }

  void _onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _sharedPreferences.getString(tokenKey);
    final deviceId = _sharedPreferences.getString(deviceIdKey) ?? "";

    if (token != null && token.isNotEmpty) {
      // Assuming headerKey is "Authorization" or custom key from CommonSharedPrefrence
      // If headerKey value is "Authorization", we might need to prepend "Bearer "
      // Checking CommonSharedPrefrence.dart, headerKey = "Authorization"
      // NetworkClass didn't seem to prepend Bearer, it just sent the token.
      // I will verify existing NetworkClass behavior.
      // In NetworkClass: headerToken = sharedPreferences!.getString(tokenKey)!; request.headers[headerKey] = headerToken;
      // So no "Bearer " prefix.
      options.headers[headerKey] = token; 
    }

    options.headers[headerDeviceIdKey] = deviceId;
    options.headers[headerDeviceTypeKey] = "mobile-flutter-${Platform.isIOS ? "ios" : "android"}";

    handler.next(options);
  }

  Future<void> _onError(DioException err, ErrorInterceptorHandler handler) async {
    // Basic 401 handling - for now, just pass through. 
    // Implementing robust refresh token logic within interceptor requires 
    // a separate Dio instance or careful locking to avoid loops.
    // For this step, I'll rely on the caller or a separate AuthRepository logic for refresh 
    // if simple interceptor retry isn't enough, but I will add a placeholder.
    
    if (err.response?.statusCode == 401) {
       // TODO: Implement Token Refresh Logic similar to NetworkClass
    }
    
    handler.next(err);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return _dio.put(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return _dio.patch(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return _dio.delete(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> multipartPost(String path, {required FormData formData, Map<String, dynamic>? queryParameters}) async {
    return _dio.post(path, data: formData, queryParameters: queryParameters);
  }
}
