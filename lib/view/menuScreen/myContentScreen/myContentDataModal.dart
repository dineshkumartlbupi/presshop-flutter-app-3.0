import 'package:presshop/view/menuScreen/MyDraftScreen.dart';
import 'package:presshop/view/publishContentScreen/HashTagSearchScreen.dart';
import 'package:presshop/view/publishContentScreen/TutorialsScreen.dart';

class MyContentData {
  String id = "";
  String title = "";
  String textValue = "";
  String time = "";
  String location = "";
  String latitude = "";
  String longitude = "";
  String amount = "";
  String originalAmount = "";
  String totalEarning = "";
  String status = "";
  String soldStatus = "";
  String paidStatus = "";
  String contentType = "";
  String dateTime = "";
  bool isPaidStatusToHopper = false;
  bool exclusive = false;
  bool showVideo = false;
  String audioDescription = '';
  List<ContentMediaData> contentMediaList = [];
  List<HashTagData> hashTagList = [];
  CategoryDataModel? categoryData;
  String completionPercent = "";
  String discountPercent = "";
  int leftPercent = 0;
  int offerCount = 0;
  String mediaHouseName = '';
  String categoryId = '';
  int contentView = 0;
  int purchasedMediahouseCount = 0;
  String userId = "";

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
    required this.contentMediaList,
    required this.hashTagList,
    required this.categoryData,
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

  MyContentData.fromJson(json) {
    id = json["_id"];
    exclusive = json["type"] == "shared" ? false : true;
    dateTime = json["timestamp"].toString();
    purchasedMediahouseCount = (json["purchased_mediahouse"] as List).length;
    time = json["timestamp"].toString();
    title = json["heading"] ?? "";
    textValue = json["description"] ?? "";
    location = json["location"] ?? "";
    latitude = json["latitude"].toString();
    longitude = json["longitude"].toString();
    amount = json["original_ask_price"] != null
        ? json["original_ask_price"].toString()
        : "0";
    originalAmount = json["original_ask_price"] != null
        ? json["original_ask_price"].toString()
        : "0";

    totalEarning = json["total_earnings"] != null
        ? json["total_earnings"].toString()
        : "0";
    contentView = json["content_view_count_by_marketplace_for_app"];
    status = json["status"].toString();
    discountPercent = json["discount_percent"] ?? "";
    soldStatus = json["sale_status"] ?? '';

    paidStatus = json["paid_status"].toString();

    isPaidStatusToHopper = json["paid_status_to_hopper"] ?? false;
    contentType = json['type'] ?? '';
    offerCount = json['offer_content_size'] ?? 0;

    mediaHouseName = json['purchased_publication_details'] != null
        ? json['purchased_publication_details']['company_name'] ?? ""
        : "";
    audioDescription = json['audio_description'] ?? '';
    categoryId = json['category_id'] ?? '';
    if (json["content"] != null) {
      var contentList = json["content"] as List;
      contentMediaList =
          contentList.map((e) => ContentMediaData.fromJson(e)).toList();
    }
    if (json["tagData"] != null) {
      var tagList = json["tagData"] as List;
      hashTagList = tagList.map((e) => HashTagData.fromJson(e)).toList();
    }
    if (json["categoryData"] != null) {
      categoryData = CategoryDataModel.fromJson(json["categoryData"]);
    }

    int count = 0;

    if (textValue.trim().isNotEmpty) {
      count += 1;
    }
    if (time.trim().isNotEmpty) {
      count += 1;
    }

    if (location.trim().isNotEmpty) {
      count += 1;
    }

    if (amount.trim().isNotEmpty) {
      count += 1;
    }

    if (contentMediaList.isNotEmpty) {
      count += 1;
    }

    if (hashTagList.isNotEmpty) {
      count += 1;
    }

    if (categoryData != null) {
      count += 1;
    }

    completionPercent = ((count * 14.286) / 100).round().toString();
    leftPercent = ((7 - count) * 14.286).round();
  }

  MyContentData copyWith({
    String? id,
    String? title,
    String? textValue,
    String? time,
    String? location,
    String? latitude,
    String? longitude,
    String? amount,
    String? originalAmount,
    String? totalEarning,
    String? status,
    String? soldStatus,
    String? paidStatus,
    String? contentType,
    String? dateTime,
    bool? isPaidStatusToHopper,
    bool? exclusive,
    bool? showVideo,
    String? audioDescription,
    List<ContentMediaData>? contentMediaList,
    List<HashTagData>? hashTagList,
    CategoryDataModel? categoryData,
    String? completionPercent,
    String? discountPercent,
    int? leftPercent,
    int? offerCount,
    String? mediaHouseName,
    String? categoryId,
    int? contentView,
  }) {
    return MyContentData(
        id: id ?? this.id,
        title: title ?? this.title,
        textValue: textValue ?? this.textValue,
        time: time ?? this.time,
        location: location ?? this.location,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        amount: amount ?? this.amount,
        originalAmount: originalAmount ?? this.originalAmount,
        status: status ?? this.status,
        soldStatus: soldStatus ?? this.soldStatus,
        paidStatus: paidStatus ?? this.paidStatus,
        contentType: contentType ?? this.contentType,
        dateTime: dateTime ?? this.dateTime,
        isPaidStatusToHopper: isPaidStatusToHopper ?? this.isPaidStatusToHopper,
        exclusive: exclusive ?? this.exclusive,
        showVideo: showVideo ?? this.showVideo,
        audioDescription: audioDescription ?? this.audioDescription,
        contentMediaList: contentMediaList ?? List.from(this.contentMediaList),
        hashTagList: hashTagList ?? List.from(this.hashTagList),
        categoryData: categoryData ?? this.categoryData,
        completionPercent: completionPercent ?? this.completionPercent,
        discountPercent: discountPercent ?? this.discountPercent,
        leftPercent: leftPercent ?? this.leftPercent,
        offerCount: offerCount ?? this.offerCount,
        mediaHouseName: mediaHouseName ?? this.mediaHouseName,
        categoryId: categoryId ?? this.categoryId,
        contentView: contentView ?? this.contentView,
        purchasedMediahouseCount:
            purchasedMediahouseCount ?? this.purchasedMediahouseCount,
        totalEarning: totalEarning ?? this.totalEarning);
  }
}
