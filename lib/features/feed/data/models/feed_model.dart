import '../../domain/entities/feed.dart';
import 'package:presshop/core/core_export.dart';

class FeedModel extends Feed {
  const FeedModel({
    required super.id,
    required super.heading,
    required super.description,
    required super.location,
    required super.categoryName,
    super.categoryImage = "",
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
    required super.paidStatus,
    super.likesCount = 0,
  });

  factory FeedModel.fromJson(Map<String, dynamic> json) {
    List<FeedContent> contentList = [];
    if (json['content_metadata'] != null) {
      json['content_metadata'].forEach((v) {
        contentList.add(FeedContentModel.fromJson(v));
      });
    } else if (json['content'] != null) {
      json['content'].forEach((v) {
        contentList.add(FeedContentModel.fromJson(v));
      });
    }

    if (contentList.isEmpty) {
      if (json['images'] != null && json['images'] is List) {
        for (var img in json['images']) {
          contentList.add(FeedContentModel(
            id: "",
            mediaType: "image",
            mediaUrl: img,
            thumbnail: "",
          ));
        }
      }
      if (json['videos'] != null && json['videos'] is List) {
        for (var vid in json['videos']) {
          contentList.add(FeedContentModel(
            id: "",
            mediaType: "video",
            mediaUrl: vid,
            thumbnail: "", // Fallback or generate?
          ));
        }
      }
    }

    String avatarUrl = "";
    if (json['hopper_id'] != null && json['hopper_id'] is Map) {
      var hopper = json['hopper_id'];
      if (hopper['avatar_id'] != null &&
          hopper['avatar_id'] is Map &&
          hopper['avatar_id']['avatar'] != null) {
        avatarUrl =
            "${"https://dev-presshope.s3.eu-west-2.amazonaws.com/public/"}${hopper['avatar_id']['avatar']}";
      } else if (hopper['avatarData'] != null &&
          hopper['avatarData'] is Map &&
          hopper['avatarData']['avatar'] != null) {
        avatarUrl =
            "${"https://dev-presshope.s3.eu-west-2.amazonaws.com/public/"}${hopper['avatarData']['avatar']}";
      }
    }
    if (avatarUrl.isEmpty) {
      avatarUrl = json['feed_image'] ?? "";
    }

    return FeedModel(
      id: json['id'] ?? json['_id'] ?? "",
      heading: json['heading'] ?? json['description'] ?? "",
      description: json['description'] ?? "",
      location: json['location'] ?? "",
      categoryName: json['category_id'] is Map
          ? (json['category_id']['name'] ?? "")
          : "General", // Fallback for ID string
      categoryImage: json['category_id'] is Map
          ? getMediaImageUrl(json['category_id']['icon']?.toString() ?? "")
          : "",
      askPrice: json['ask_price']?.toString() ??
          json['original_ask_price']?.toString() ??
          "",
      displayPrice: json['display_price']?.toString() ?? "",
      displayCurrency: (json['currency_symbol'] != null &&
              json['currency_symbol'].toString().isNotEmpty)
          ? json['currency_symbol'].toString()
          : getCurrencySymbol(
              (json['display_currency'] ?? json['currency'] ?? '').toString()),
      viewCount: json['content_view_count_by_marketplace_for_app'] ??
          json['view_count'] ??
          0,
      offerCount: json['offer_count'] ?? 0,
      likesCount: json['likes_count'] ?? 0,
      createdAt: json['created_at'] ?? json['createdAt'] ?? "",
      timeAgo: "",
      feedImage: avatarUrl,
      status: json['status'] ?? "",
      isFavourite: json['is_favourite'] ?? false,
      isLiked: json['is_liked'] ?? false,
      isEmoji: json['is_emoji'] ?? false,
      isClap: json['is_clap'] ?? false,
      contentList: contentList,
      type: json['type'] ?? "",
      isDraft: json['is_draft'] == "true" || json['is_draft'] == true,
      userId: json['hopper_id'] is Map
          ? (json['hopper_id']['_id'] is Map
              ? "" // Buffer object?
              : json['hopper_id']['_id']?.toString() ?? "")
          : json['user_id'] ?? "",
      saleStatus: json['sale_status'] ?? "",
      paidStatus: json['paid_status'] == true ? "Paid" : "Unpaid",
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
