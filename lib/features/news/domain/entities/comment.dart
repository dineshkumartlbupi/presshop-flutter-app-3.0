import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  const Comment({
    required this.id,
    required this.contentId,
    required this.userId,
    required this.comment,
    required this.createdAt,
    this.userImage,
    this.userName,
    this.replies = const [],
    this.likesCount = 0,
    this.isLiked = false,
    this.parentId,
    this.rootParentId,
    this.replyToName,
  });
  final String id;
  final String contentId;
  final String userId;
  final String comment;
  final String createdAt;
  final String? userImage;
  final String? userName;

  final List<Comment> replies;
  final int likesCount;
  final bool isLiked;
  final String? parentId;
  final String? rootParentId;
  final String? replyToName;

  Comment copyWith({
    String? id,
    String? contentId,
    String? userId,
    String? comment,
    String? createdAt,
    String? userImage,
    String? userName,
    List<Comment>? replies,
    int? likesCount,
    bool? isLiked,
    String? parentId,
    String? rootParentId,
    String? replyToName,
  }) {
    return Comment(
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      userId: userId ?? this.userId,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      userImage: userImage ?? this.userImage,
      userName: userName ?? this.userName,
      replies: replies ?? this.replies,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      parentId: parentId ?? this.parentId,
      rootParentId: rootParentId ?? this.rootParentId,
      replyToName: replyToName ?? this.replyToName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        contentId,
        userId,
        comment,
        createdAt,
        userImage,
        userName,
        replies,
        likesCount,
        isLiked,
        parentId,
        rootParentId,
        replyToName,
      ];
}
