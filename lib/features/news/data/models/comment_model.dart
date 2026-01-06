import 'package:presshop/features/news/domain/entities/comment.dart';

class CommentModel extends Comment {
  const CommentModel({
    required String id,
    required String contentId,
    required String userId,
    required String comment,
    required String createdAt,
    String? userImage,
    String? userName,
    List<Comment> replies = const [],
    int likesCount = 0,
    bool isLiked = false,
  }) : super(
          id: id,
          contentId: contentId,
          userId: userId,
          comment: comment,
          createdAt: createdAt,
          userImage: userImage,
          userName: userName,
          replies: replies,
          likesCount: likesCount,
          isLiked: isLiked,
        );

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
