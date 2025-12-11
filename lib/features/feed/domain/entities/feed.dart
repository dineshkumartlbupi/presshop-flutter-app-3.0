import 'package:equatable/equatable.dart';

class Feed extends Equatable {
  final String id;
  final String heading;
  final String description;
  final String location;
  final String categoryName;
  final String askPrice;
  final String displayPrice;
  final String displayCurrency;
  final int viewCount;
  final int offerCount;
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

  const Feed({
    required this.id,
    required this.heading,
    required this.description,
    required this.location,
    required this.categoryName,
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
  });

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
        createdAt,
        status,
        isFavourite,
        isLiked,
        isEmoji,
        isClap,
        contentList,
      ];
}

class FeedContent extends Equatable {
  final String id;
  final String mediaType;
  final String mediaUrl;
  final String thumbnail;

  const FeedContent({
    required this.id,
    required this.mediaType,
    required this.mediaUrl,
    required this.thumbnail,
  });

  @override
  List<Object?> get props => [id, mediaType, mediaUrl, thumbnail];
}
