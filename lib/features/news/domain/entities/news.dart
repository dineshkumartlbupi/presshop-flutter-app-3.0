import 'package:equatable/equatable.dart';

class News extends Equatable {
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
  final String? userImage;
  final String? userName;
  final double? latitude;
  final double? longitude;

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
    this.userImage,
    this.userName,
    this.latitude,
    this.longitude,
  });

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
    String? userImage,
    String? userName,
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
      userImage: userImage ?? this.userImage,
      userName: userName ?? this.userName,
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
        userImage,
        userName,
      ];
}
