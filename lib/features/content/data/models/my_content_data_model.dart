import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:presshop/core/utils/date_time_utils.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;
import '../../domain/entities/content_item.dart';
import 'category_data_model.dart';
import 'content_metadata_model.dart';

class MyContentResponseModel {
  final int code;
  final List<MyContentItemModel> data;
  final int count;

  MyContentResponseModel({
    required this.code,
    required this.data,
    required this.count,
  });

  factory MyContentResponseModel.fromJson(Map<String, dynamic> json) {
    return MyContentResponseModel(
      code: json['code'],
      data: (json['data'] as List)
          .map((e) => MyContentItemModel.fromJson(e))
          .toList(),
      count: json['count'],
    );
  }
}

class MyContentItemModel extends ContentItem {
  const MyContentItemModel({
    required super.id,
    required super.description,
    required super.location,
    required super.latitude,
    required super.longitude,
    required super.categoryId,
    required super.hopperId,
    super.type,
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
    required super.convertedAskPrice,
    required super.currencyOriginal,
    required super.priceBase,
    required super.currencyBase,
    required super.imageCount,
    required super.videoCount,
    required super.audioCount,
    required super.otherCount,
    required super.contentUnderOffer,
    required super.paidStatus,
    required super.contentViewCount, // Mapped to viewCount from input
    required super.isFavourite,
    required super.isLiked,
    required super.isEmoji,
    required super.isClap,
    required super.updatedAt,
    required super.categoryData,
  });

  factory MyContentItemModel.fromJson(Map<String, dynamic> json) {
    return MyContentItemModel(
      id: json['id'],
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      categoryId: json['category_id'],
      hopperId: json['hopper_id'],
      type: json['type'],
      askPrice: json['ask_price'],
      isDraft: json['is_draft'] == "true",
      isCharity: json['is_charity'] == "true",
      images: List<String>.from(json['images']),
      videos: List<dynamic>.from(json['videos']),
      createdAt: json['created_at'],
      status: json['status'],
      contentMetadata: (json['content_metadata'] as List)
          .map((e) => ContentMetadataModel.fromJson(e))
          .toList(),
      productId: json['product_id'],
      priceOriginal: json['price_original'],
      convertedAskPrice: json['converted_ask_price'],
      currencyOriginal: json['currency_original'],
      priceBase: json['price_base'],
      currencyBase: json['currency_base'],
      imageCount: json['image_count'],
      videoCount: json['video_count'],
      audioCount: json['audio_count'],
      otherCount: json['other_count'],
      contentUnderOffer: json['content_under_offer'],
      paidStatus: json['paid_status'],
      contentViewCount: json['content_view_count_by_marketplace_for_app'],
      isFavourite: json['is_favourite'],
      isLiked: json['is_liked'],
      isEmoji: json['is_emoji'],
      isClap: json['is_clap'],
      updatedAt: json['updated_at'],
      categoryData: CategoryDataModel.fromJson(json['categoryData']),
    );
  }
}

class MyContentData {
  String id;
  String title;
  String textValue;
  String time;
  String location;
  String latitude;
  String longitude;
  String amount;
  String originalAmount;
  String status;
  String soldStatus;
  String paidStatus;
  String contentType;
  String dateTime;
  bool isPaidStatusToHopper;
  bool exclusive;
  bool showVideo;
  String audioDescription;
  String audioDuration;
  List<ContentMediaData> contentMediaList;
  List<dynamic> hashTagList;
  CategoryDataModel? categoryData;
  String completionPercent;
  String discountPercent;
  int leftPercent;
  int offerCount;
  String mediaHouseName;
  String categoryId;
  int contentView;
  int purchasedMediahouseCount;
  String totalEarning;

  MyContentData({
    required this.id,
    required this.title,
    required this.textValue,
    required this.time,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.amount,
    required this.originalAmount,
    required this.status,
    required this.soldStatus,
    required this.paidStatus,
    required this.contentType,
    required this.dateTime,
    required this.isPaidStatusToHopper,
    required this.exclusive,
    required this.showVideo,
    required this.audioDescription,
    required this.audioDuration,
    required this.contentMediaList,
    required this.hashTagList,
    this.categoryData,
    required this.completionPercent,
    required this.discountPercent,
    required this.leftPercent,
    required this.offerCount,
    required this.mediaHouseName,
    required this.categoryId,
    required this.contentView,
    required this.purchasedMediahouseCount,
    required this.totalEarning,
  });

  factory MyContentData.fromJson(Map<String, dynamic> json) {
    bool exclusive = json["type"] == "shared" ? false : true;
    String time = dateTimeFormatter(
        dateTime: (json["timestamp"] ?? "").toString(),
        format: "HH:mm, dd MMM, yyyy",
        utc: true);
    String textValue = json["description"] ?? "";
    String location = json["location"] ?? "";
    String latitude = (json["latitude"] ?? "0.0").toString();
    String longitude = (json["longitude"] ?? "0.0").toString();
    String amount = (json["original_ask_price"] ?? "0").toString();

    List<ContentMediaData> contentMediaList = [];
    if (json["content"] != null) {
      var contentList = json["content"] as List;
      contentMediaList =
          contentList.map((e) => ContentMediaData.fromJson(e)).toList();
    }

    List<dynamic> hashTagList = [];
    if (json["tagData"] != null) {
      hashTagList = json["tagData"] as List;
    }

    CategoryDataModel? categoryData;
    if (json["categoryData"] != null) {
      categoryData = CategoryDataModel.fromJson(json["categoryData"]);
    }

    int count = 0;
    if (textValue.trim().isNotEmpty) count += 1;
    if (time.trim().isNotEmpty) count += 1;
    if (location.trim().isNotEmpty) count += 1;
    if (amount.trim().isNotEmpty) count += 1;
    if (contentMediaList.isNotEmpty) count += 1;
    if (hashTagList.isNotEmpty) count += 1;
    if (categoryData != null) count += 1;

    String completionPercent = ((count * 14.286) / 100).round().toString();
    int leftPercent = ((7 - count) * 14.286).round();

    return MyContentData(
      id: (json["_id"] ?? json["id"] ?? "").toString(),
      title: json["title"] ?? "",
      textValue: textValue,
      time: time,
      location: location,
      latitude: latitude,
      longitude: longitude,
      amount: amount,
      originalAmount: amount,
      status: json["status"] ?? "",
      soldStatus: json["sale_status"] ?? "",
      paidStatus: json["paid_status"] ?? "",
      contentType: json["media_type"] ?? "",
      dateTime: (json["created_at"] ?? "").toString(),
      isPaidStatusToHopper: false,
      exclusive: exclusive,
      showVideo: false,
      audioDescription: "",
      audioDuration: "",
      contentMediaList: contentMediaList,
      hashTagList: hashTagList,
      categoryData: categoryData,
      completionPercent: completionPercent,
      discountPercent: "0",
      leftPercent: leftPercent,
      offerCount: json["total_offer"] ?? 0,
      mediaHouseName: "",
      categoryId: categoryData?.id ?? "",
      contentView: 0,
      purchasedMediahouseCount: 0,
      totalEarning: "0",
    );
  }
}

class ContentMediaData {
  String id = "";
  String media = "";
  String mediaType = "";
  String thumbNail = "";
  String waterMark = "";

  ContentMediaData(
      this.id, this.media, this.mediaType, this.thumbNail, this.waterMark);

  ContentMediaData.fromJson(json) {
    id = (json["_id"] ?? json["id"] ?? "").toString();
    media = json["media"];
    mediaType = json["media_type"] ?? "";
    thumbNail = (json["thumbnail"] ?? json["media"]).toString();
    waterMark =
        (json["watermark"] ?? json["watermarked_media"] ?? "").toString();
  }

  Future<String> getVideoThumbNail(String path) async {
    debugPrint("MediaIs:::::: $path");
    final thumbnail = await vt.VideoThumbnail.thumbnailFile(
      video: path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: vt.ImageFormat.PNG,
      maxHeight: 500,
      quality: 100,
    );
    return thumbnail ?? "";
  }
}
