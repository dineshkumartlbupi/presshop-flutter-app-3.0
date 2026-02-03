import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:presshop/core/utils/shared_preferences.dart';

class PrettyDioLogger extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    debugPrint(
      '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
➡️ ➡️ ➡️ ➡️ ➡️ ➡️ ➡️ ➡️ ➡️ ➡️ ➡️ ➡️ ➡️ ➡️ API REQUEST ➡️ ➡️ ➡️ ➡️ ➡️ ➡️ ➡️ ➡️ ➡️ ➡️ ➡️ ➡️ ➡️ ➡️
METHOD : ${options.method}
URL    : ${options.uri}
TIME   : ${_getFormattedTime()}
HEADERS: ${_maskHeaders(options.headers)}
QUERY  : ${options.queryParameters}
BODY   : ${_prettyJson(options.data)}
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
✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ API RESPONSE ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅
STATUS : ${response.statusCode}
URL    : ${response.realUri}
TIME   : ${_getFormattedTime()}
DATA   : ${_prettyJson(response.data)}
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
❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ API ERROR ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌ ❌
STATUS : ${err.response?.statusCode}
URL    : ${err.requestOptions.uri}
TIME   : ${_getFormattedTime()}
ERROR  : ${err.message}
DATA   : ${_prettyJson(err.response?.data)}
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

  String _getFormattedTime() {
    final now = DateTime.now();
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String amPm = now.hour >= 12 ? "PM" : "AM";
    int hour12 =
        now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);

    return "${twoDigits(now.day)}${months[now.month - 1]} ${now.year} ${twoDigits(hour12)}:${twoDigits(now.minute)}:${twoDigits(now.second)} $amPm";
  }

  String _prettyJson(dynamic data) {
    if (data == null) return "null";
    try {
      const encoder = JsonEncoder.withIndent('  ');
      if (data is String) {
        try {
          final decoded = jsonDecode(data);
          return encoder.convert(decoded);
        } catch (_) {
          return data;
        }
      }
      return encoder.convert(data);
    } catch (e) {
      return data.toString();
    }
  }
}
