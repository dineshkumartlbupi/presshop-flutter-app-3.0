// lib/services/api_service.dart
import 'package:dio/dio.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://dev-api.presshop.news:5019/",
      connectTimeout: Duration(seconds: 20),
      receiveTimeout: Duration(seconds: 20),
    ),
  );

  static Future<Response> get(String url,
      {Map<String, dynamic>? headers}) async {
    return _dio.get(url, options: Options(headers: headers));
  }

  static Future<Response> post(String url, dynamic body,
      {Map<String, dynamic>? headers}) async {
    return _dio.post(url, data: body, options: Options(headers: headers));
  }
}
