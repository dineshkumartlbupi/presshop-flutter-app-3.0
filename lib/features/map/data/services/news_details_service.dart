import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:presshop/features/map/data/models/marker_model.dart';
import 'package:presshop/features/news/data/models/comment_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewsDetailsService {
  final String baseUrl = "https://dev-api.presshop.news:5019";

  Future<Incident?> getAggregatedNewsDetail(String id) async {
    try {
      final url = Uri.parse('$baseUrl/hopper/getAggregatedNewsDetail');

      // Get token from SharedPreferences if available
      final prefs = await SharedPreferences.getInstance();
      String token = prefs.getString(tokenKey) ?? "";
      String deviceID = prefs.getString(deviceIdKey) ?? "";

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': token,
        headerDeviceTypeKey:
            "mobile-flutter-ios", // Should detect or hardcode for now
        headerDeviceIdKey: deviceID,
      };

      print("News Headers: $headers");

      final body = jsonEncode({
        "id": id,
      });

      print("Fetching news details for ID: $id");
      print("URL: $url");

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print("News Details Response Status: ${response.statusCode}");
      print("News Details Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('data')) {
          final incidentData = data['data'];
          if (data.containsKey('stats')) {
            incidentData['sharesCount'] = data['stats']['shares'];
            incidentData['likesCount'] = data['stats']['likes'];
            incidentData['commentsCount'] = data['stats']['comments'];
            incidentData['viewCount'] = data['stats']['views'];
            incidentData['isLiked'] =
                data['stats']['is_liked'] ?? data['data']['is_liked'];
          } else {
            incidentData['isLiked'] = data['data']['is_liked'];
          }
          return Incident.fromJson(incidentData);
        }
      }

      throw Exception(
          "Failed to load news: ${response.statusCode}, Body: ${response.body}");
    } catch (e) {
      print("Error fetching news details: $e");
      rethrow;
    }
  }

  Future<List<CommentData>> getComments(String contentId,
      {int limit = 15}) async {
    try {
      final url = Uri.parse('$baseUrl/hopper/getAggregatedNewsComments');
      final prefs = await SharedPreferences.getInstance();
      String token = prefs.getString(tokenKey) ?? "";
      String deviceID = prefs.getString(deviceIdKey) ?? "";

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': token, // As per previous fix, it was just the token
        headerDeviceTypeKey: "mobile-flutter-ios", // Fallback or detect
        headerDeviceIdKey: deviceID,
      };

      // Helper for platform type if needed, but for now hardcoded or basic check
      // Ideally inject or use Platform
      // But standard service might not import dart:io directly if web supported?
      // Assuming mobile app.

      final body = jsonEncode({
        "content_id": contentId,
        "limit": limit,
      });

      debugPrint("Fetching comments for ID: $contentId");
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('data')) {
          return (data['data'] as List)
              .map((e) => CommentData.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching comments: $e");
      return [];
    }
  }

  Future<List<Incident>?> getAggregatedNews({
    required double lat,
    required double lng,
    required double km,
    String category = "all",
  }) async {
    try {
      final url = Uri.parse('$baseUrl/hopper/getAggregatedNews');
      final prefs = await SharedPreferences.getInstance();
      String token = prefs.getString(tokenKey) ?? "";

      final body = {
        "category": category,
        "endpoint": "search-news",
        "search": "",
        "locationFilter": "",
        "coordinates": "$lat,$lng",
        "km": km,
        "limit": 100
      };

      print(":::fetchAggregatedNews token: $token params: $body");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      print(":::fetchAggregatedNews statusCode: ${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data']['news'] != null) {
          final List<dynamic> newsList = data['data']['news'];
          return newsList.map((item) => Incident.fromJson(item)).toList();
        }
      } else {
        debugPrint(
            "Failed to fetch news: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      debugPrint("Error fetching aggregated news: $e");
    }
    return null;
  }
}
