import 'package:http/http.dart' as http;
import 'package:presshop/features/news/data/models/comment_model.dart';
import 'package:presshop/features/news/data/models/news_model.dart';

abstract class NewsRemoteDataSource {
  Future<List<NewsModel>> getAggregatedNews({
    required double lat,
    required double lng,
    required double km,
    String category = "all",
  });

  Future<NewsModel> getNewsDetail(String id);

  Future<List<CommentModel>> getComments(String contentId, {int limit = 15});
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final http.Client client;
  final String baseUrl =
      "https://dev-api.presshop.news:5019"; // Should ideally be in config

  NewsRemoteDataSourceImpl({required this.client});

  @override
  Future<List<NewsModel>> getAggregatedNews({
    required double lat,
    required double lng,
    required double km,
    String category = "all",
  }) async {
    /*
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

    debugPrint(":::fetchAggregatedNews token: $token params: $body");

    final response = await client.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    debugPrint(":::fetchAggregatedNews statusCode: ${response.statusCode}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['data'] != null && data['data']['news'] != null) {
        final List<dynamic> newsList = data['data']['news'];
        return newsList.map((item) => NewsModel.fromJson(item)).toList();
      }
      return [];
    } else {
      throw ServerException();
    }
    */
    // Mock Data
    return [
      NewsModel(
        id: '1',
        title: 'Mock News Title 1',
        description: 'This is a mock description for news item 1.',
        mediaUrl: 'https://via.placeholder.com/150',
        mediaType: 'image',
        userName: 'Mock Author',
        createdAt: DateTime.now().toIso8601String(),
        location: 'Mock Location',
        likesCount: 10,
        viewCount: 100,
        sharesCount: 5,
        commentsCount: 2,
        isLiked: false,
      ),
      NewsModel(
        id: '2',
        title: 'Mock News Title 2',
        description: 'This is a mock description for news item 2.',
        mediaUrl: 'https://via.placeholder.com/150',
        mediaType: 'image',
        userName: 'Mock Author',
        createdAt: DateTime.now().toIso8601String(),
        location: 'Mock Location 2',
        likesCount: 20,
        viewCount: 200,
        sharesCount: 10,
        commentsCount: 5,
        isLiked: true,
      ),
    ];
  }

  @override
  Future<NewsModel> getNewsDetail(String id) async {
    /*
    final url = Uri.parse('$baseUrl/hopper/getAggregatedNewsDetail');
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString(tokenKey) ?? "";
    String deviceID = prefs.getString(deviceIdKey) ?? "";

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': token,
      headerDeviceTypeKey: "mobile-flutter-ios",
      headerDeviceIdKey: deviceID,
    };

    final body = jsonEncode({"id": id});

    final response = await client.post(
      url,
      headers: headers,
      body: body,
    );

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
        return NewsModel.fromJson(incidentData);
      }
      throw ServerException();
    } else {
      throw ServerException();
    }
    */
    // Mock Data
    return NewsModel(
      id: id,
      title: 'Mock News Detail Title',
      description: 'This is a detailed mock description for the news item.',
      mediaUrl: 'https://via.placeholder.com/150',
      mediaType: 'image',
      userName: 'Mock Author',
      createdAt: DateTime.now().toIso8601String(),
      location: 'Mock Location',
      likesCount: 10,
      viewCount: 100,
      sharesCount: 5,
      commentsCount: 2,
      isLiked: false,
    );
  }

  @override
  Future<List<CommentModel>> getComments(String contentId,
      {int limit = 15}) async {
    /*
    final url = Uri.parse('$baseUrl/hopper/getAggregatedNewsComments');
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString(tokenKey) ?? "";
    String deviceID = prefs.getString(deviceIdKey) ?? "";

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': token,
      headerDeviceTypeKey: "mobile-flutter-ios",
      headerDeviceIdKey: deviceID,
    };

    final body = jsonEncode({
      "content_id": contentId,
      "limit": limit,
    });

    final response = await client.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data.containsKey('data')) {
        return (data['data'] as List)
            .map((e) => CommentModel.fromJson(e))
            .toList();
      }
      return [];
    } else {
      throw ServerException();
    }
    */
    // Mock Data
    return [
      CommentModel(
        id: '1',
        contentId: contentId,
        userId: 'user1',
        comment: 'This is a mock comment.',
        createdAt: DateTime.now().toIso8601String(),
        userName: 'Mock User',
        userImage: 'https://via.placeholder.com/50',
      ),
    ];
  }
}
