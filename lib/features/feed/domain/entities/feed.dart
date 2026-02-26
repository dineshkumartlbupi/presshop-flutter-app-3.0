import 'package:equatable/equatable.dart';

class Feed extends Equatable {
  const Feed({
    required this.id,
    required this.heading,
    required this.description,
    required this.location,
    required this.categoryName,
    this.categoryImage = "",
    required this.askPrice,
    required this.displayPrice,
    required this.displayCurrency,
    required this.viewCount,
    required this.offerCount,
    required this.createdAt,
    required this.timeAgo,
    required this.feedImage,
    required this.status,
    required this.isFavourite,
    required this.isLiked,
    required this.isEmoji,
    required this.isClap,
    required this.contentList,
    required this.type,
    required this.isDraft,
    required this.userId,
    required this.saleStatus,
    required this.paidStatus,
    this.likesCount = 0,
  });
  final String id;
  final String heading;
  final String description;
  final String location;
  final String categoryName;
  final String categoryImage;
  final String askPrice;
  final String displayPrice;
  final String displayCurrency;
  final int viewCount;
  final int offerCount;
  final int likesCount;
  final String createdAt;
  final String timeAgo; // timestamp?
  final String feedImage; // Avatar?
  final String status;
  final bool isFavourite;
  final bool isLiked;
  final bool isEmoji;
  final bool isClap;
  final List<FeedContent> contentList;
  final String type;
  final bool isDraft;
  final String userId;
  final String saleStatus;
  final String paidStatus;

  @override
  List<Object?> get props => [
        id,
        heading,
        description,
        location,
        categoryName,
        askPrice,
        displayPrice,
        viewCount,
        offerCount,
        likesCount,
        createdAt,
        status,
        isFavourite,
        isLiked,
        isEmoji,
        isClap,
        isClap,
        contentList,
        paidStatus,
      ];

  Feed copyWith({
    String? id,
    String? heading,
    String? description,
    String? location,
    String? categoryName,
    String? categoryImage,
    String? askPrice,
    String? displayPrice,
    String? displayCurrency,
    int? viewCount,
    int? offerCount,
    String? createdAt,
    String? timeAgo,
    String? feedImage,
    String? status,
    bool? isFavourite,
    bool? isLiked,
    bool? isEmoji,
    bool? isClap,
    List<FeedContent>? contentList,
    String? type,
    bool? isDraft,
    String? userId,
    String? saleStatus,
    String? paidStatus,
    int? likesCount,
  }) {
    return Feed(
      id: id ?? this.id,
      heading: heading ?? this.heading,
      description: description ?? this.description,
      location: location ?? this.location,
      categoryName: categoryName ?? this.categoryName,
      categoryImage: categoryImage ?? this.categoryImage,
      askPrice: askPrice ?? this.askPrice,
      displayPrice: displayPrice ?? this.displayPrice,
      displayCurrency: displayCurrency ?? this.displayCurrency,
      viewCount: viewCount ?? this.viewCount,
      offerCount: offerCount ?? this.offerCount,
      likesCount: likesCount ?? this.likesCount,
      createdAt: createdAt ?? this.createdAt,
      timeAgo: timeAgo ?? this.timeAgo,
      feedImage: feedImage ?? this.feedImage,
      status: status ?? this.status,
      isFavourite: isFavourite ?? this.isFavourite,
      isLiked: isLiked ?? this.isLiked,
      isEmoji: isEmoji ?? this.isEmoji,
      isClap: isClap ?? this.isClap,
      contentList: contentList ?? this.contentList,
      type: type ?? this.type,
      isDraft: isDraft ?? this.isDraft,
      userId: userId ?? this.userId,
      saleStatus: saleStatus ?? this.saleStatus,
      paidStatus: paidStatus ?? this.paidStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'heading': heading,
      'description': description,
      'location': location,
      'category_name': categoryName,
      'category_image': categoryImage,
      'ask_price': askPrice,
      'display_price': displayPrice,
      'display_currency': displayCurrency,
      'view_count': viewCount,
      'offer_count': offerCount,
      'likes_count': likesCount,
      'created_at': createdAt,
      'time_ago': timeAgo,
      'feed_image': feedImage,
      'status': status,
      'is_favourite': isFavourite,
      'is_liked': isLiked,
      'is_emoji': isEmoji,
      'is_clap': isClap,
      'content_list': contentList.map((e) => e.toJson()).toList(),
      'type': type,
      'is_draft': isDraft,
      'user_id': userId,
      'sale_status': saleStatus,
      'paid_status': paidStatus,
    };
  }
}

class FeedContent extends Equatable {
  const FeedContent({
    required this.id,
    required this.mediaType,
    required this.mediaUrl,
    required this.thumbnail,
  });
  final String id;
  final String mediaType;
  final String mediaUrl;
  final String thumbnail;

  @override
  List<Object?> get props => [id, mediaType, mediaUrl, thumbnail];

  FeedContent copyWith({
    String? id,
    String? mediaType,
    String? mediaUrl,
    String? thumbnail,
  }) {
    return FeedContent(
      id: id ?? this.id,
      mediaType: mediaType ?? this.mediaType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'media_type': mediaType,
      'media_url': mediaUrl,
      'thumbnail': thumbnail,
    };
  }
}
