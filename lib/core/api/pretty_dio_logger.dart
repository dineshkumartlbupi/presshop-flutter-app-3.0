import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:presshop/core/utils/shared_preferences.dart';

class PrettyDioLogger extends Interceptor {

  PrettyDioLogger({this.formatJson = true});
  /// Set this to true to print formatted JSON (with indentation).
  /// Set to false to print unformatted raw JSON (compact).
  final bool formatJson;

  void _printLong(String text) {
    if (text.isEmpty) return;
    final pattern = RegExp('.{1,800}');
    for (var line in text.split('\n')) {
      for (var match in pattern.allMatches(line)) {
        debugPrint(match.group(0));
      }
    }
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    _printLong(
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
    _printLong(
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
    _printLong(
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

  /// Mask sensitive headers and truncate excessively long values
  Map<String, dynamic> _maskHeaders(Map<String, dynamic> headers) {
    final masked = <String, dynamic>{};

    headers.forEach((key, value) {
      if (key == SharedPreferencesKeys.headerKey ||
          key.toLowerCase() == "authorization" ||
          key.toLowerCase() == "x-access-token") {
        masked[key] = "****TOKEN****";
      } else {
        // Safeguard: Truncate any extremely long header values (e.g. JWTs, cookies)
        final stringValue = value.toString();
        if (stringValue.length > 500) {
          masked[key] =
              "${stringValue.substring(0, 500)}... [TRUNCATED ${stringValue.length - 500} chars]";
        } else {
          masked[key] = value;
        }
      }
    });

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
      // Avoid processing large datasets synchronously on the main thread
      if (data is List && data.length > 5000) {
        return "[LIST of ${data.length} items] (Formatting skipped for performance)";
      }
      if (data is Map && data.length > 5000) {
        return "[MAP with ${data.length} keys] (Formatting skipped for performance)";
      }

      String result = "";
      if (data is String) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is List && decoded.length > 5000) {
            return "[DECODED LIST of ${decoded.length} items]";
          }
          if (decoded is Map && decoded.length > 5000) {
            return "[DECODED MAP with ${decoded.length} keys]";
          }
          if (!formatJson) {
            result = jsonEncode(decoded);
          } else {
            result = const JsonEncoder.withIndent('  ').convert(decoded);
          }
        } catch (_) {
          result = data;
        }
      } else {
        if (!formatJson) {
          result = jsonEncode(data);
        } else {
          result = const JsonEncoder.withIndent('  ').convert(data);
        }
      }

      // Safeguard: Limit total output length to prevent terminal buffer saturation
      const int maxLogLength = 1000000;
      if (result.length > maxLogLength) {
        return "${result.substring(0, maxLogLength)}\n... [TRUNCATED ${result.length - maxLogLength} characters to prevent IDE freeze]";
      }
      return result;
    } catch (e) {
      final fallback = data.toString();
      const int maxFallbackLength = 1000;
      if (fallback.length > maxFallbackLength) {
        return "${fallback.substring(0, maxFallbackLength)}\n... [TRUNCATED ${fallback.length - maxFallbackLength} characters]";
      }
      return fallback;
    }
  }
}
