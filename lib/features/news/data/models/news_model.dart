import 'package:presshop/core/utils/common_utils.dart';
import 'package:presshop/core/api/api_constant_new.dart';
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
    bool? isMostViewed,
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
          isMostViewed: isMostViewed,
          userImage: userImage,
          userName: userName,
          latitude: latitude,
          longitude: longitude,
        );

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    dynamic mediaRaw = json['media_url'] ?? json['media'] ?? json['content'];
    String? mediaUrlRaw;
    String? mediaType = json['media_type'];

    if (mediaRaw is List && mediaRaw.isNotEmpty) {
      var firstMedia = mediaRaw[0];
      if (firstMedia is Map) {
        mediaUrlRaw = firstMedia['media'] ??
            firstMedia['media_url'] ??
            firstMedia['url'] ??
            firstMedia['thumbnail'] ??
            firstMedia['thumb'];
        mediaType = firstMedia['media_type'] ?? mediaType;
      } else if (firstMedia is String) {
        mediaUrlRaw = firstMedia;
      }
    } else if (mediaRaw is String) {
      mediaUrlRaw = mediaRaw;
    }

    if (mediaUrlRaw == null || mediaUrlRaw.isEmpty) {
      mediaUrlRaw = json['thumbnail'] ?? json['thumb'] ?? json['image'];
    }

    String? mediaUrl = getMediaImageUrl(
      mediaUrlRaw,
      isVideo: mediaType == 'video',
    );

    var userRaw = json['user_id'] ?? json['hopper_id'] ?? json['hopper'];

    String? userImageRaw;
    String? userName;

    if (userRaw != null && userRaw is Map) {
      userImageRaw = userRaw['profile_image'] ?? userRaw['avatar'];
      userName =
          userRaw['full_name'] ?? userRaw['user_name'] ?? userRaw['userName'];
    } else {
      userImageRaw = json['profile_image'] ?? json['avatar'];
      userName = json['full_name'] ?? json['user_name'] ?? json['userName'];
    }

    String? userImage = userImageRaw != null && userImageRaw.isNotEmpty
        ? (userImageRaw.startsWith('http')
            ? fixS3Url(userImageRaw)
            : "${ApiConstantsNew.config.profileImageUrl}$userImageRaw")
        : null;

    return NewsModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      location: json['location'],
      createdAt: json['createdAt'],
      likesCount: json['likesCount'] ?? json['likes_count'],
      commentsCount: json['commentsCount'] ?? json['comments_count'],
      sharesCount: json['sharesCount'] ?? json['shares_count'],
      viewCount: json['viewCount'] ?? json['view_count'],
      isLiked: json['isLiked'] ?? json['is_liked'],
      isMostViewed: json['isMostViewed'] ?? json['is_most_viewed'],
      userImage: userImage,
      userName: userName,
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
      'isMostViewed': isMostViewed,
    };
  }
}
