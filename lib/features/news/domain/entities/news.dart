import 'package:equatable/equatable.dart';

class News extends Equatable {

  const News({
    required this.id,
    required this.title,
    required this.description,
    this.mediaUrl,
    this.mediaType,
    this.location,
    this.createdAt,
    this.likesCount,
    this.commentsCount,
    this.sharesCount,
    this.viewCount,
    this.isLiked,
    this.isMostViewed,
    this.userImage,
    this.userName,
    this.latitude,
    this.longitude,
    this.type,
    this.markerType,
  });
  final String id;
  final String title;
  final String description;
  final String? mediaUrl;
  final String? mediaType;
  final String? location;
  final String? createdAt;
  final int? likesCount;
  final int? commentsCount;
  final int? sharesCount;
  final int? viewCount;
  final bool? isLiked;
  final bool? isMostViewed;
  final String? userImage;
  final String? userName;
  final double? latitude;
  final double? longitude;
  final String? type;
  final String? markerType;

  News copyWith({
    String? id,
    String? title,
    String? description,
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
    String? type,
    String? markerType,
  }) {
    return News(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      viewCount: viewCount ?? this.viewCount,
      isLiked: isLiked ?? this.isLiked,
      isMostViewed: isMostViewed ?? this.isMostViewed,
      userImage: userImage ?? this.userImage,
      userName: userName ?? this.userName,
      type: type ?? this.type,
      markerType: markerType ?? this.markerType,
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        mediaUrl,
        mediaType,
        location,
        createdAt,
        likesCount,
        commentsCount,
        sharesCount,
        viewCount,
        isLiked,
        isMostViewed,
        userImage,
        userName,
        type,
        markerType,
        latitude,
        longitude,
      ];
}
