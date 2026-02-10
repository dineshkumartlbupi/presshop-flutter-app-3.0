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
    super.rootParentId,
    super.replyToName,
  });
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    String? userName;
    String? userImage;

    if (json['user_id'] is Map) {
      userName = json['user_id']['full_name'] ?? json['user_id']['user_name'];
      userImage = json['user_id']['profile_image'] ?? json['user_id']['avatar'];
    } else if (json['user_details'] != null) {
      userName = json['user_details']['full_name'] ??
          json['user_details']['user_name'];
      userImage = json['user_details']['profile_image'] ??
          json['user_details']['avatar'];
    }

    return CommentModel(
      id: json['_id'] ?? json['id'] ?? '',
      contentId: json['content_id']?.toString() ?? '',
      userId: json['user_id'] is Map
          ? json['user_id']['_id']
          : (json['user_id']?.toString() ?? ''),
      comment: json['comment'] ?? json['text'] ?? '',
      createdAt: json['createdAt'] ?? '',
      userImage: userImage,
      userName: userName,
      replies: json['replies'] != null
          ? (json['replies'] as List)
              .map((e) => CommentModel.fromJson(e))
              .toList()
          : [],
      likesCount: json['likes_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      rootParentId:
          (json['root_parent_id'] ?? json['root_comment_id'])?.toString(),
      replyToName: json['reply_to_user_name'] ??
          json['reply_to_name'] ??
          json['replyTo'],
    );
  }
}
