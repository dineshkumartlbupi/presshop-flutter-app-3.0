import '../../../../utils/common.dart';
import '../../domain/entities/feed.dart';

class FeedModel extends Feed {
  const FeedModel({
    required super.id,
    required super.heading,
    required super.description,
    required super.location,
    required super.categoryName,
    required super.askPrice,
    required super.displayPrice,
    required super.displayCurrency,
    required super.viewCount,
    required super.offerCount,
    required super.createdAt,
    required super.timeAgo,
    required super.feedImage,
    required super.status,
    required super.isFavourite,
    required super.isLiked,
    required super.isEmoji,
    required super.isClap,
    required super.contentList,
    required super.type,
    required super.isDraft,
    required super.userId,
    required super.saleStatus,
  });

  factory FeedModel.fromJson(Map<String, dynamic> json) {
    List<FeedContent> contentList = [];
    if (json['content'] != null) {
      json['content'].forEach((v) {
        contentList.add(FeedContentModel.fromJson(v));
      });
    }

    return FeedModel(
      id: json['_id'] ?? "",
      heading: json['heading'] ?? "",
      description: json['description'] ?? "",
      location: json['location'] ?? "",
      categoryName: json['category_id'] is Map ? (json['category_id']['name'] ?? "") : "",
      askPrice: json['original_ask_price']?.toString() ?? "",
      displayPrice: json['display_price']?.toString() ?? "",
      displayCurrency: json['currency_symbol'] ?? "£", // Default or fetch
      viewCount: json['view_count'] ?? 0,
      offerCount: json['offer_count'] ?? 0,
      createdAt: json['createdAt'] ?? "",
      timeAgo: "", // Calculate if needed or use createdAt
      feedImage: json['feed_image'] ?? "", // Verify field name from previous model
      status: json['status'] ?? "",
      isFavourite: json['is_favourite'] ?? false,
      isLiked: json['is_liked'] ?? false,
      isEmoji: json['is_emoji'] ?? false,
      isClap: json['is_clap'] ?? false,
      contentList: contentList,
      type: json['type'] ?? "",
      isDraft: json['is_draft'] ?? false,
      userId: json['user_id'] ?? "",
      saleStatus: json['sale_status'] ?? "",
    );
  }
}

class FeedContentModel extends FeedContent {
  const FeedContentModel({
    required super.id,
    required super.mediaType,
    required super.mediaUrl,
    required super.thumbnail,
  });

  factory FeedContentModel.fromJson(Map<String, dynamic> json) {
    return FeedContentModel(
      id: json['_id'] ?? "",
      mediaType: json['media_type'] ?? "",
      mediaUrl: json['media'] ?? "",
      thumbnail: json['thumbnail'] ?? "",
    );
  }
}
