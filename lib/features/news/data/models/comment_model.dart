import 'package:presshop/features/news/domain/entities/comment.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.contentId,
    required super.userId,
    required super.comment,
    required super.createdAt,
    super.userImage,
    super.userName,
    super.replies,
    super.likesCount,
    super.isLiked,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['_id'] ?? '',
      contentId: json['content_id'] ?? '',
      userId: json['user_id'] is Map
          ? json['user_id']['_id']
          : (json['user_id'] ?? ''),
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] ?? '',
      userImage:
          json['user_id'] is Map ? json['user_id']['profile_image'] : null,
      userName: json['user_id'] is Map ? json['user_id']['full_name'] : null,
      replies: json['replies'] != null
          ? (json['replies'] as List)
              .map((e) => CommentModel.fromJson(e))
              .toList()
          : [],
      likesCount: json['likes_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
    );
  }
}
