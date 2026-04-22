import 'package:equatable/equatable.dart';
import 'category_data.dart';
import 'content_metadata.dart';

class ContentItem extends Equatable {
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
    this.currency = "",
    this.currencySymbol = "",
    this.totalEarnings = "0",
  });
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
  final String currency;
  final String currencySymbol;
  final String totalEarnings;

  // Getters for UI compatibility
  int get totalView => contentViewCount;
  List<ContentMetadata> get mediaList => contentMetadata;
  String? get mediaType => type;
  int get totalMediaCount =>
      imageCount + videoCount + (audioCount ?? 0) + (otherCount ?? 0);
  List<String> get mediaUrls {
    List<String> urls = [...images];
    urls.addAll(videos.map((e) => e.toString()));
    for (var meta in contentMetadata) {
      if (meta.media.isNotEmpty && !urls.contains(meta.media)) {
        urls.add(meta.media);
      }
    }
    return urls;
  }

  String get totalSold => totalEarnings;
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
        currency,
        currencySymbol,
        totalEarnings,
      ];

  ContentItem copyWith({
    String? id,
    String? description,
    String? location,
    String? latitude,
    String? longitude,
    String? categoryId,
    String? hopperId,
    String? type,
    String? askPrice,
    bool? isDraft,
    bool? isCharity,
    List<String>? images,
    List<dynamic>? videos,
    String? createdAt,
    String? status,
    List<ContentMetadata>? contentMetadata,
    String? productId,
    String? priceOriginal,
    String? convertedAskPrice,
    String? currencyOriginal,
    String? priceBase,
    String? currencyBase,
    int? imageCount,
    int? videoCount,
    int? audioCount,
    int? otherCount,
    bool? contentUnderOffer,
    bool? paidStatus,
    int? contentViewCount,
    bool? isFavourite,
    bool? isLiked,
    bool? isEmoji,
    bool? isClap,
    String? updatedAt,
    CategoryData? categoryData,
    int? purchasedMediahouseCount,
    int? totalOffer,
    bool? isExclusive,
    bool? isPaidStatusToHopper,
    String? currency,
    String? currencySymbol,
    String? totalEarnings,
  }) {
    return ContentItem(
      id: id ?? this.id,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      categoryId: categoryId ?? this.categoryId,
      hopperId: hopperId ?? this.hopperId,
      type: type ?? this.type,
      askPrice: askPrice ?? this.askPrice,
      isDraft: isDraft ?? this.isDraft,
      isCharity: isCharity ?? this.isCharity,
      images: images ?? this.images,
      videos: videos ?? this.videos,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      contentMetadata: contentMetadata ?? this.contentMetadata,
      productId: productId ?? this.productId,
      priceOriginal: priceOriginal ?? this.priceOriginal,
      convertedAskPrice: convertedAskPrice ?? this.convertedAskPrice,
      currencyOriginal: currencyOriginal ?? this.currencyOriginal,
      priceBase: priceBase ?? this.priceBase,
      currencyBase: currencyBase ?? this.currencyBase,
      imageCount: imageCount ?? this.imageCount,
      videoCount: videoCount ?? this.videoCount,
      audioCount: audioCount ?? this.audioCount,
      otherCount: otherCount ?? this.otherCount,
      contentUnderOffer: contentUnderOffer ?? this.contentUnderOffer,
      paidStatus: paidStatus ?? this.paidStatus,
      contentViewCount: contentViewCount ?? this.contentViewCount,
      isFavourite: isFavourite ?? this.isFavourite,
      isLiked: isLiked ?? this.isLiked,
      isEmoji: isEmoji ?? this.isEmoji,
      isClap: isClap ?? this.isClap,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryData: categoryData ?? this.categoryData,
      purchasedMediahouseCount:
          purchasedMediahouseCount ?? this.purchasedMediahouseCount,
      totalOffer: totalOffer ?? this.totalOffer,
      isExclusive: isExclusive ?? this.isExclusive,
      isPaidStatusToHopper: isPaidStatusToHopper ?? this.isPaidStatusToHopper,
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      totalEarnings: totalEarnings ?? this.totalEarnings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'category_id': categoryId,
      'hopper_id': hopperId,
      'type': type,
      'ask_price': askPrice,
      'is_draft': isDraft,
      'is_charity': isCharity,
      'images': images,
      'videos': videos,
      'created_at': createdAt,
      'status': status,
      'content_metadata': contentMetadata.map((e) => e.toJson()).toList(),
      'product_id': productId,
      'price_original': priceOriginal,
      'converted_ask_price': convertedAskPrice,
      'currency_original': currencyOriginal,
      'price_base': priceBase,
      'currency_base': currencyBase,
      'image_count': imageCount,
      'video_count': videoCount,
      'audio_count': 4,
      'other_count': otherCount,
      'content_under_offer': contentUnderOffer,
      'paid_status': paidStatus,
      'content_view_count': contentViewCount,
      'is_favourite': isFavourite,
      'is_liked': isLiked,
      'is_emoji': isEmoji,
      'is_clap': isClap,
      'updated_at': updatedAt,
      'categoryData': categoryData.toJson(),
      'purchased_mediahouse_count': purchasedMediahouseCount,
      'total_offer': totalOffer,
      'is_exclusive': isExclusive,
      'is_paid_status_to_hopper': isPaidStatusToHopper,
      'currency': currency,
      'currency_symbol': currencySymbol,
      'total_earnings': totalEarnings,
    };
  }
}
