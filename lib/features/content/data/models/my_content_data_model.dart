import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:presshop/core/utils/date_time_utils.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;
import 'package:presshop/features/task/data/models/manage_task_chat_model.dart';
import '../../domain/entities/content_item.dart';
import 'category_data_model.dart';
import 'content_metadata_model.dart';
import 'package:presshop/core/utils/common_utils.dart';

class MyContentResponseModel {
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
  final int code;
  final List<MyContentItemModel> data;
  final int count;
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
    super.currency = "",
    super.currencySymbol = "",
  });

  factory MyContentItemModel.fromJson(Map<String, dynamic> json) {
    return MyContentItemModel(
      id: (json['id'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      latitude: (json['latitude'] ?? '').toString(),
      longitude: (json['longitude'] ?? '').toString(),
      categoryId: (json['category_id'] ?? '').toString(),
      hopperId: (json['hopper_id'] ?? '').toString(),
      type: json['type']?.toString(),
      askPrice: (json['ask_price'] ?? '').toString(),
      isDraft: (json['is_draft'] ?? "false").toString() == "true",
      isCharity: (json['is_charity'] ?? "false").toString() == "true",
      images: List<String>.from(json['images'] ?? []),
      videos: List<dynamic>.from(json['videos'] ?? []),
      createdAt: (json['created_at'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      contentMetadata: (json['content_metadata'] as List? ?? [])
          .map((e) => ContentMetadataModel.fromJson(e))
          .toList(),
      productId: (json['product_id'] ?? '').toString(),
      priceOriginal: (json['price_original'] ?? '').toString(),
      convertedAskPrice: (json['converted_ask_price'] ?? '').toString(),
      currencyOriginal: (json['currency_original'] ?? '').toString(),
      priceBase: json['price_base']?.toString(),
      currencyBase: json['currency_base']?.toString(),
      imageCount: int.tryParse((json['image_count'] ??
                  json['imageCount'] ??
                  json['images_count'] ??
                  '0')
              .toString()) ??
          0,
      videoCount: int.tryParse((json['video_count'] ??
                  json['videoCount'] ??
                  json['videos_count'] ??
                  '0')
              .toString()) ??
          0,
      audioCount: int.tryParse((json['audio_count'] ??
                  json['audioCount'] ??
                  json['audios_count'] ??
                  '0')
              .toString()) ??
          0,
      otherCount: int.tryParse((json['other_count'] ??
                  json['otherCount'] ??
                  json['others_count'] ??
                  '0')
              .toString()) ??
          0,
      contentUnderOffer: json['content_under_offer'] == true,
      paidStatus: json['paid_status'] == true,
      contentViewCount: int.tryParse((json['content_view_count_by_marketplace_for_app'] ??
                  json['view_count'] ??
                  json['viewCount'] ??
                  json['totalViews'] ??
                  '0')
              .toString()) ??
          0,
      isFavourite: json['is_favourite'] == true,
      isLiked: json['is_liked'] == true,
      isEmoji: json['is_emoji'] == true,
      isClap: json['is_clap'] == true,
      updatedAt: json['updated_at']?.toString(),
      categoryData: CategoryDataModel.fromJson(json['categoryData'] ?? {}),
      currency: (json['currency'] ?? '').toString(),
      currencySymbol: (json['currency_symbol'] != null &&
              json['currency_symbol'].toString().isNotEmpty)
          ? json['currency_symbol'].toString()
          : getCurrencySymbol(
              (json['currency'] ?? json['currency_original'] ?? '').toString()),
    );
  }
}

class MyContentData {
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
    this.chatList = const [],
    this.currency = "",
    this.currencySymbol = "",
  });

  factory MyContentData.fromJson(Map<String, dynamic> json) {
    bool exclusive = json["type"] == "shared" ? false : true;
    String time = dateTimeFormatter(
        dateTime: (json["timestamp"] ?? "").toString(),
        format: "HH:mm, dd MMM, yyyy",
        utc: true);
    String textValue = (json["description"] ?? "").toString();
    String location = (json["location"] ?? "").toString();
    String latitude = (json["latitude"] ?? "0.0").toString();
    String longitude = (json["longitude"] ?? "0.0").toString();
    String amount = (json["original_ask_price"] ??
            json["ask_price"] ??
            json["display_price"] ??
            "0")
        .toString();

    List<ContentMediaData> contentMediaList = [];
    if (json["content"] != null) {
      var contentList = json["content"] as List;
      contentMediaList =
          contentList.map((e) => ContentMediaData.fromJson(e)).toList();
    } else if (json["images"] != null || json["videos"] != null) {
      // Fallback for direct images/videos lists if 'content' is missing
      if (json["images"] is List) {
        for (var img in json["images"]) {
          contentMediaList.add(ContentMediaData(
              "", img.toString(), "image", img.toString(), ""));
        }
      }
      if (json["videos"] is List) {
        for (var vid in json["videos"]) {
          contentMediaList.add(ContentMediaData(
              "", vid.toString(), "video", vid.toString(), ""));
        }
      }
    }

    List<dynamic> hashTagList = [];
    if (json["tagData"] != null) {
      hashTagList = json["tagData"] as List;
    } else if (json["tag_ids"] != null) {
      // Handle tag_ids string/list if present
    }

    CategoryDataModel? categoryData;
    if (json["categoryData"] != null) {
      categoryData = CategoryDataModel.fromJson(json["categoryData"]);
    } else if (json["category_id"] != null) {
      categoryData = CategoryDataModel(
          id: json["category_id"].toString(),
          name: "Unknown",
          percentage: "0",
          type: "content");
    }

    int count = 0;
    if (textValue.trim().isNotEmpty) count += 1;
    if (time.trim().isNotEmpty) count += 1;
    if (location.trim().isNotEmpty) count += 1;
    if (amount.trim().isNotEmpty && amount != "0") count += 1;
    if (contentMediaList.isNotEmpty) count += 1;
    if (hashTagList.isNotEmpty) count += 1;
    if (categoryData != null && categoryData.name != "Unknown") count += 1;

    String completionPercent = ((count * 14.286) / 100).round().toString();
    int leftPercent = ((7 - count) * 14.286).round();

    return MyContentData(
      id: (json["id"] ?? json["_id"] ?? json["mongo_id"] ?? "").toString(),
      title: (json["title"] ?? json["heading"] ?? "").toString(),
      textValue: textValue,
      time: time,
      location: location,
      latitude: latitude,
      longitude: longitude,
      amount: amount,
      originalAmount: amount,
      status: (json["status"] ?? "").toString(),
      soldStatus: (json["sale_status"] ?? "").toString(),
      paidStatus: (json["paid_status"] ?? "").toString(),
      contentType: (json["media_type"] ?? "").toString(),
      dateTime: (json["created_at"] ?? json["timestamp"] ?? "").toString(),
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
      offerCount: int.tryParse((json["total_offer"] ??
                  json["offer_count"] ??
                  json["offer_content_size"] ??
                  "0")
              .toString()) ??
          0,
      mediaHouseName: "",
      categoryId: categoryData?.id ?? "",
      contentView: int.tryParse((json["view_count"] ??
                  json["viewCount"] ??
                  json["content_view_count"] ??
                  json["content_view_count_by_marketplace_for_app"] ??
                  "0")
              .toString()) ??
          0,
      purchasedMediahouseCount: int.tryParse((json["purchased_mediahouse_count"] ??
                  json["purchasedMediahouseCount"] ??
                  json["sale_count"] ??
                  json["sold_count"] ??
                  "0")
              .toString()) ??
          0,
      totalEarning: (json["total_earnings"] ??
              json["totalEarnings"] ??
              json["total_earning"] ??
              "0")
          .toString(),
      chatList: json["chat"] != null && json["chat"] is List
          ? (json["chat"] as List)
              .map((e) => ManageTaskChatModel.fromJson(e))
              .toList()
          : [],
      currency: (json['currency'] ?? '').toString(),
      currencySymbol: (json['currency_symbol'] != null &&
              json['currency_symbol'].toString().isNotEmpty)
          ? json['currency_symbol'].toString()
          : getCurrencySymbol(
              (json['currency'] ?? json['currency_original'] ?? '').toString()),
    );
  }
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
  List<ManageTaskChatModel> chatList;
  String currency;
  String currencySymbol;

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': textValue,
      'timestamp': dateTime,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'original_ask_price': amount,
      'status': status,
      'sale_status': soldStatus,
      'paid_status': paidStatus,
      'media_type': contentType,
      'created_at': dateTime,
      'type': exclusive ? 'exclusive' : 'shared',
      'content': contentMediaList.map((e) => e.toJson()).toList(),
      'tagData': hashTagList,
      'categoryData': categoryData?.toJson(),
      'total_offer': offerCount,
    };
  }
}

class ContentMediaData {
  ContentMediaData(
      this.id, this.media, this.mediaType, this.thumbNail, this.waterMark);

  ContentMediaData.fromJson(json) {
    id = (json["_id"] ?? json["id"] ?? "").toString();
    media = (json["media"] ?? "").toString();
    mediaType = (json["media_type"] ?? "").toString();
    thumbNail = (json["thumbnail"] ?? json["media"] ?? "").toString();
    waterMark =
        (json["watermark"] ?? json["watermarked_media"] ?? "").toString();
  }
  String id = "";
  String media = "";
  String mediaType = "";
  String thumbNail = "";
  String waterMark = "";

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'media': media,
      'media_type': mediaType,
      'thumbnail': thumbNail,
      'watermark': waterMark,
    };
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
