import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:presshop/core/constants/api_response.dart';
import 'package:presshop/features/splash/data/models/version_model.dart';

void main() {
  const jsonResponse = '''
  {
    "success": true,
    "message": "Latest version details",
    "data": {
      "ios": "1.0.5",
      "android": "1.0.6",
      "force_update": true
    }
  }
  ''';

  test('should parse AppVersionResponse from JSON correctly', () {
    final Map<String, dynamic> jsonMap = json.decode(jsonResponse);
    final result = ApiResponse<AppVersionData>.fromJson(
        jsonMap, (json) => AppVersionData.fromJson(json));
    expect(result.success, true);
    expect(result.message, "Latest version details");
    expect(result.data?.ios, "1.0.5");
    expect(result.data?.android, "1.0.6");
    expect(result.data?.forceUpdate, true);
  });

  test('should parse AppVersionData from JSON correctly', () {
    final Map<String, dynamic> jsonMap = json.decode(jsonResponse)['data'];
    final result = AppVersionData.fromJson(jsonMap);
    expect(result.ios, "1.0.5");
    expect(result.android, "1.0.6");
    expect(result.forceUpdate, true);
  });
}
