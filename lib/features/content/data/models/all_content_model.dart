import '../../domain/entities/content_item.dart';
import 'category_data_model.dart';
import 'content_metadata_model.dart';
import 'package:presshop/core/core_export.dart';

class ContentListResponseModel {
  ContentListResponseModel({
    required this.code,
    required this.data,
    required this.count,
  });

  factory ContentListResponseModel.fromJson(Map<String, dynamic> json) {
    return ContentListResponseModel(
      code: json['code'],
      data: (json['data'] as List)
          .map((e) => ContentItemModel.fromJson(e))
          .toList(),
      count: json['count'],
    );
  }
  final int code;
  final List<ContentItemModel> data;
  final int count;

  Map<String, dynamic> toJson() => {
        'code': code,
        'data': data.map((e) => e.toJson()).toList(),
        'count': count,
      };
}

class ContentItemModel extends ContentItem {
  const ContentItemModel({
    required super.id,
    required super.description,
    required super.location,
    required super.latitude,
    required super.longitude,
    required super.categoryId,
    required super.hopperId,
    required super.askPrice,
    required super.isDraft,
    required super.isCharity,
    required super.images,
    required super.videos,
    required super.createdAt,
    required super.status,
    required super.contentMetadata,
    required super.productId,
    required super.priceOriginal,
    required super.currencyOriginal,
    required super.imageCount,
    required super.videoCount,
    required super.contentUnderOffer,
    required super.paidStatus,
    required super.contentViewCount,
    required super.isFavourite,
    required super.isLiked,
    required super.categoryData,
    super.purchasedMediahouseCount = 0,
    super.totalOffer = 0,
    super.isExclusive,
    super.isPaidStatusToHopper = false,
    super.currency = "",
    super.currencySymbol = "",
  });

  factory ContentItemModel.fromJson(Map<String, dynamic> json) {
    return ContentItemModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      description: json['description'] ?? json['heading'] ?? '',
      location: json['location'] ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ??
          json['category_ids']?.toString() ??
          '',
      hopperId: json['hopper_id'] ?? '',
      askPrice: json['ask_price']?.toString() ?? '0',
      isDraft: json['is_draft'] == "true" || json['is_draft'] == true,
      isCharity: json['is_charity'] == "true" || json['is_charity'] == true,
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      videos: json['videos'] != null ? List<dynamic>.from(json['videos']) : [],
      createdAt: json['created_at'] ?? '',
      status: json['status'] ?? '',
      contentMetadata: json['content_metadata'] != null
          ? (json['content_metadata'] as List)
              .map((e) => ContentMetadataModel.fromJson(e))
              .toList()
          : [],
      productId: json['product_id'] ?? '',
      priceOriginal: json['price_original']?.toString() ?? '0',
      currencyOriginal: json['currency_original'] ?? '',
      imageCount: json['image_count'] ?? 0,
      videoCount: json['video_count'] ?? 0,
      contentUnderOffer: json['content_under_offer'] == true,
      paidStatus: json['paid_status'] == true || json['paid_status'] == "paid",
      contentViewCount: json['content_view_count_by_marketplace_for_app'] ?? 0,
      isFavourite: json['is_favourite'] == true,
      isLiked: json['is_liked'] == true,
      categoryData: (json['categoryData'] ?? json['category']) != null
          ? CategoryDataModel.fromJson(json['categoryData'] ?? json['category'])
          : const CategoryDataModel(id: '', name: '', percentage: '', type: ''),
      purchasedMediahouseCount: json['purchased_mediahouse'] != null
          ? (json['purchased_mediahouse'] as List).length
          : 0,
      totalOffer: json['offer_content_size'] ?? 0,
      isExclusive: json['is_exclusive'] ?? (json['type'] != 'shared'),
      isPaidStatusToHopper: json['paid_status_to_hopper'] == true ||
          json['paid_status_to_hopper'] == "paid",
      currency: (json['currency'] ?? '').toString(),
      currencySymbol: (json['currency_symbol'] != null &&
              json['currency_symbol'].toString().isNotEmpty)
          ? json['currency_symbol'].toString()
          : getCurrencySymbol(
              (json['currency'] ?? json['currency_original'] ?? '').toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'category_id': categoryId,
        'hopper_id': hopperId,
        'ask_price': askPrice,
        'is_draft': isDraft,
        'is_charity': isCharity,
        'images': images,
        'videos': videos,
        'created_at': createdAt,
        'status': status,
        'content_metadata': contentMetadata
            .map((e) => (e as ContentMetadataModel).toJson())
            .toList(),
        'product_id': productId,
        'price_original': priceOriginal,
        'currency_original': currencyOriginal,
        'image_count': imageCount,
        'video_count': videoCount,
        'content_under_offer': contentUnderOffer,
        'paid_status': paidStatus,
        'content_view_count_by_marketplace_for_app': contentViewCount,
        'is_favourite': isFavourite,
        'is_liked': isLiked,
        'categoryData': (categoryData as CategoryDataModel).toJson(),
        'purchased_mediahouse':
            [], // Placeholder for toJson as we only store count
        'offer_content_size': totalOffer,
        'is_exclusive': isExclusive,
        'paid_status_to_hopper': isPaidStatusToHopper,
        'currency': currency,
        'currency_symbol': currencySymbol,
      };
}
