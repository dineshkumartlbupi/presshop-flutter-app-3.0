import 'package:equatable/equatable.dart';
import 'category_data.dart';
import 'content_metadata.dart';

class ContentItem extends Equatable {
  final String id;
  final String description;
  final String location;
  final String latitude;
  final String longitude;
  final String categoryId;
  final String hopperId;
  final String? type; // Added
  final String askPrice;
  final bool isDraft;
  final bool isCharity;
  final List<String> images;
  final List<dynamic> videos;
  final String createdAt;
  final String status;
  final List<ContentMetadata> contentMetadata;
  final String productId;
  final String priceOriginal;
  final String convertedAskPrice; // Added
  final String currencyOriginal;
  final String? priceBase; // Added
  final String? currencyBase; // Added
  final int imageCount;
  final int videoCount;
  final int? audioCount; // Added
  final int? otherCount; // Added
  final bool contentUnderOffer;
  final bool paidStatus;
  final int contentViewCount; // mapped to viewCount
  final bool isFavourite;
  final bool isLiked;
  final bool? isEmoji; // Added
  final bool? isClap; // Added
  final String? updatedAt; // Added
  final CategoryData categoryData;
  final int purchasedMediahouseCount;
  final int totalOffer;
  final bool? isExclusive;
  final bool isPaidStatusToHopper;

  const ContentItem({
    required this.id,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.categoryId,
    required this.hopperId,
    this.type,
    required this.askPrice,
    required this.isDraft,
    required this.isCharity,
    required this.images,
    required this.videos,
    required this.createdAt,
    required this.status,
    required this.contentMetadata,
    required this.productId,
    required this.priceOriginal,
    this.convertedAskPrice = "",
    required this.currencyOriginal,
    this.priceBase,
    this.currencyBase,
    required this.imageCount,
    required this.videoCount,
    this.audioCount,
    this.otherCount,
    required this.contentUnderOffer,
    required this.paidStatus,
    required this.contentViewCount,
    required this.isFavourite,
    required this.isLiked,
    this.isEmoji,
    this.isClap,
    this.updatedAt,
    required this.categoryData,
    this.purchasedMediahouseCount = 0,
    this.totalOffer = 0,
    this.isExclusive,
    this.isPaidStatusToHopper = false,
  });

  // Getters for UI compatibility
  int get totalView => contentViewCount;
  List<ContentMetadata> get mediaList => contentMetadata;
  String? get mediaType => type;
  List<String> get mediaUrls => images.isNotEmpty
      ? images
      : (videos.isNotEmpty ? videos.map((e) => e.toString()).toList() : []);
  String get totalSold => "0";
  String get title => description.isNotEmpty ? description : "No Title";
  String? get price => askPrice.isNotEmpty ? askPrice : priceOriginal;

  @override
  List<Object?> get props => [
        id,
        description,
        location,
        latitude,
        longitude,
        categoryId,
        hopperId,
        type,
        askPrice,
        isDraft,
        isCharity,
        images,
        videos,
        createdAt,
        status,
        contentMetadata,
        productId,
        priceOriginal,
        convertedAskPrice,
        currencyOriginal,
        priceBase,
        currencyBase,
        imageCount,
        videoCount,
        audioCount,
        otherCount,
        contentUnderOffer,
        paidStatus,
        contentViewCount,
        isFavourite,
        isLiked,
        isEmoji,
        isClap,
        updatedAt,
        categoryData,
        purchasedMediahouseCount,
        totalOffer,
        isExclusive,
        isPaidStatusToHopper,
      ];
}
