class CommentData {
  String id;
  String name;
  String date;
  String comment;
  String avatarUrl;
  int likes;
  List<CommentData> replies;
  bool isExpanded;
  bool isLiked; // Added for persistence

  CommentData({
    required this.id,
    required this.name,
    required this.date,
    required this.comment,
    required this.avatarUrl,
    required this.likes,
    this.replies = const [],
    this.isExpanded = false,
    this.isLiked = false,
  });

  factory CommentData.fromJson(Map<String, dynamic> json) {
    String name = "Unknown";
    String avatar = "";
    if (json['user_details'] != null) {
      name =
          "${json['user_details']['first_name']} ${json['user_details']['last_name']}";
      avatar = json['user_details']['avatar'] ?? "";
    }

    List<CommentData> replies = [];
    if (json['replies'] != null) {
      replies = (json['replies'] as List)
          .map((e) => CommentData.fromJson(e))
          .toList();
    }

    return CommentData(
      id: json['_id'] ?? "",
      name: name,
      date: json['createdAt'] ?? "", // You might want to format this
      comment: json['text'] ?? "",
      avatarUrl: (avatar.trim().isEmpty) ? "" : avatar,
      likes: json['likes_count'] ?? 0,
      replies: replies,
      isLiked: json['is_liked'] ?? false, // Check API response key
    );
  }
}
