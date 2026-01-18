import 'package:presshop/features/news/domain/entities/news.dart';

class NewsModel extends News {
  const NewsModel({
    required String id,
    required String title,
    required String description,
    String? mediaUrl,
    String? mediaType,
    String? location,
    String? createdAt,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    int? viewCount,
    bool? isLiked,
    String? userImage,
    String? userName,
    double? latitude,
    double? longitude,
  }) : super(
          id: id,
          title: title,
          description: description,
          mediaUrl: mediaUrl,
          mediaType: mediaType,
          location: location,
          createdAt: createdAt,
          likesCount: likesCount,
          commentsCount: commentsCount,
          sharesCount: sharesCount,
          viewCount: viewCount,
          isLiked: isLiked,
          userImage: userImage,
          userName: userName,
          latitude: latitude,
          longitude: longitude,
        );

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      mediaUrl: json['media_url'],
      mediaType: json['media_type'],
      location: json['location'],
      createdAt: json['createdAt'],
      likesCount: json['likesCount'] ?? json['likes_count'],
      commentsCount: json['commentsCount'] ?? json['comments_count'],
      sharesCount: json['sharesCount'] ?? json['shares_count'],
      viewCount: json['viewCount'] ?? json['view_count'],
      isLiked: json['isLiked'] ?? json['is_liked'],
      userImage: json['user_id'] != null && json['user_id'] is Map
          ? json['user_id']['profile_image']
          : null,
      userName: json['user_id'] != null && json['user_id'] is Map
          ? json['user_id']['full_name']
          : null,
      latitude: json['position'] != null && json['position'] is Map
          ? (json['position']['lat'] is double
              ? json['position']['lat']
              : double.tryParse(json['position']['lat'].toString()))
          : null,
      longitude: json['position'] != null && json['position'] is Map
          ? (json['position']['lng'] is double
              ? json['position']['lng']
              : double.tryParse(json['position']['lng'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'location': location,
      'createdAt': createdAt,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'viewCount': viewCount,
      'isLiked': isLiked,
    };
  }
}
