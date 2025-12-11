import '../../domain/entities/content_item.dart';
import '../../domain/entities/content_media.dart';

class ContentItemModel extends ContentItem {
  const ContentItemModel({
    required super.id,
    required super.title,
    required super.description,
    super.mediaType,
    required super.mediaUrls,
    super.mediaList,
    required super.hashtags,
    super.location,
    super.latitude,
    super.longitude,
    super.price,
    required super.status,
    super.categoryId,
    super.createdAt,
    super.publishedAt,
    super.isExclusive,
    super.watermark,
    super.totalSold,
    super.totalOffer,
    super.totalView,
    super.paidStatus,
    super.purchasedMediahouseCount,
    super.saleStatus,
    super.discountPercent,
    super.mediaHouseName,
    super.isPaidStatusToHopper,
    super.userId,
  });

  factory ContentItemModel.fromJson(Map<String, dynamic> json) {
    return ContentItemModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? json['caption'] ?? '',
      mediaType: json['media_type'] ?? json['type'],
      mediaUrls: json['media_urls'] != null
          ? List<String>.from(json['media_urls'])
          : json['media'] != null
              ? List<String>.from(json['media'])
              : [],
      mediaList: json['content'] != null
          ? (json['content'] as List).map((e) => ContentMedia(
              mediaUrl: e['media'] ?? '',
              mediaType: e['mediaType'] ?? e['media_type'] ?? 'image',
              thumbnailUrl: e['thumbNail'] ?? e['thumbnail'] ?? e['thumb_nail'],
              watermarkUrl: e['waterMark'] ?? e['water_mark'],
              mimeType: e['mimeType'] ?? e['mime_type'],
              fileName: e['fileName'] ?? e['file_name'],
            )).toList()
          : [],
      hashtags: json['hashtags'] != null
          ? List<String>.from(json['hashtags'])
          : [],
      location: json['location'] ?? json['address'],
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      price: json['price']?.toString(),
      status: json['status'] ?? 'draft',
      categoryId: json['category_id'] ?? json['categoryId'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'])
          : null,
      isExclusive: json['is_exclusive'] ?? json['isExclusive'],
      watermark: json['watermark'],
      totalSold: json['totalSold'] ?? json['total_earnings'] ?? 0,
      totalOffer: json['offer_content_size'] ?? 0,
      totalView: json['content_view_count_by_marketplace_for_app'] ?? 0,
      paidStatus: json['paid_status']?.toString(),
      purchasedMediahouseCount: json['purchased_mediahouse'] != null ? (json['purchased_mediahouse'] as List).length : 0,
      saleStatus: json['sale_status'],
      discountPercent: json['discount_percent'],
      mediaHouseName: json['purchased_publication_details'] != null ? json['purchased_publication_details']['company_name'] : null,
      isPaidStatusToHopper: json['paid_status_to_hopper'] ?? false,
      userId: json['hopper_id'] ?? json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'media_type': mediaType,
      'media_urls': mediaUrls,
      'hashtags': hashtags,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'price': price,
      'status': status,
      'category_id': categoryId,
      'is_exclusive': isExclusive,
      'watermark': watermark,
    };
  }
}
