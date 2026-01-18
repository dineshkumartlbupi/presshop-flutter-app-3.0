class FeedsDataModel {
  bool firstLevelCheckNudity = false;
  bool firstLevelCheckAdult = false;
  bool firstLevelCheckGDPR = false;
  String saleStatus = "";
  String paymentPending = "";
  String feedImage = "";
  String pressshop = "";
  bool checkAndApprove = false;
  String mode = "";
  List<dynamic> tagIds = [];
  String type = "";
  String status = "";
  String favouriteStatus = "";
  bool isDraft = false;
  String paidStatus = "";
  bool paidStatusToHopper = false;
  String id = "";
  String description = "";
  String location = "";
  double latitude = 0.0;
  double longitude = 0.0;
  String categoryPercentage = "";
  String categoryName = "";
  String categoryId = "";
  String categoryType = "";
  String askPrice = "";
  String total_earnings = "";
  String displayPrice = "";
  String displayCurrency = "";
  String timestamp;
  int viewCount = 0;
  int offerCount = 0;

  List<ContentDataModel> contentDataList = [];
  String createdAt;
  String updatedAt;
  String heading = "";
  String remarks = "";
  String userId;
  String amountPaid = '';
  String feedsDataModelId;
  bool showVideo = false;
  bool mostViewed = false;

  bool isFavourite = false;
  bool isLiked = false;
  bool isEmoji = false;
  bool isClap = false;

  FeedsDataModel({
    required this.firstLevelCheckNudity,
    required this.firstLevelCheckAdult,
    required this.firstLevelCheckGDPR,
    required this.saleStatus,
    required this.paymentPending,
    required this.pressshop,
    required this.checkAndApprove,
    required this.mode,
    required this.tagIds,
    required this.type,
    required this.status,
    required this.favouriteStatus,
    required this.isDraft,
    required this.paidStatus,
    required this.paidStatusToHopper,
    required this.id,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.categoryId,
    required this.categoryPercentage,
    required this.categoryName,
    required this.categoryType,
    required this.askPrice,
    required this.timestamp,
    required this.contentDataList,
    required this.createdAt,
    required this.updatedAt,
    required this.heading,
    required this.remarks,
    required this.userId,
    required this.amountPaid,
    required this.feedsDataModelId,
    required this.showVideo,
    required this.mostViewed,
    required this.isFavourite,
    required this.isLiked,
    required this.isEmoji,
    required this.isClap,
    required this.viewCount,
    required this.offerCount,
    required this.total_earnings,
    required this.displayPrice,
    required this.displayCurrency,
    required this.feedImage,
  });

  factory FeedsDataModel.fromJson(Map<String, dynamic> json) {
    List<ContentDataModel> contentData = [];
    if (json["content"] != null) {
      var data = json["content"] as List;
      contentData = data.map((e) => ContentDataModel.fromJson(e)).toList();
    }

    return FeedsDataModel(
        saleStatus: json["sale_status"] ?? "",
        paymentPending: json["payment_pending"] ?? "",
        pressshop: json["pressshop"] ?? "",
        checkAndApprove: json["checkAndApprove"] ?? "",
        mode: json["mode"] ?? "",
        tagIds: json["tag_ids"] ?? [],
        type: json["type"] ?? "",
        status: json["status"] ?? "",
        favouriteStatus: json["favourite_status"] ?? "",
        isDraft: json["is_draft"] ?? "",
        paidStatus: json["paid_status"] ?? "",
        paidStatusToHopper: json["paid_status_to_hopper"] ?? "",
        id: json["_id"] ?? "",
        description: json["description"] ?? "",
        location: json["location"] ?? "",
        latitude: json["latitude"]?.toDouble() ?? 0.0,
        longitude: json["longitude"]?.toDouble() ?? 0.0,
        categoryId: json['category_id']['_id'] ?? "",
        categoryName: json['category_id']['name'] ?? "",
        categoryPercentage: json['category_id']['percentage'] ?? "",
        categoryType: json['category_id']['type'] ?? "",
        askPrice: json["original_ask_price"].toString(),
        timestamp: json["timestamp"] ?? "",
        total_earnings: json["total_earnings"]?.toString() ?? "0",
        displayPrice: json["display_price"]?.toString() ?? "0",
        displayCurrency: json["display_currency"]?.toString() ?? "",
        contentDataList: contentData,
        createdAt: json['createdAt'].toString(),
        updatedAt: json['updatedAt'] ?? "",
        heading: json["heading"] ?? "",
        remarks: json["remarks"] ?? "",
        userId: json["user_id"] ?? "",
        amountPaid: json["amount_paid"].toString() ?? '',
        feedsDataModelId: json["id"] ?? "",
        firstLevelCheckNudity: json['firstLevelCheck']['nudity'] ?? false,
        firstLevelCheckAdult: json['firstLevelCheck']['isAdult'] ?? false,
        firstLevelCheckGDPR: json['firstLevelCheck']['isGDPR'] ?? false,
        showVideo: false,
        mostViewed: false,
        isFavourite: json['is_favourite'] ?? false,
        isLiked: json['is_liked'] ?? false,
        isEmoji: json['is_emoji'] ?? false,
        isClap: json['is_clap'] ?? false,
        feedImage: (json['purchased_mediahouse_user'] != null &&
                (json['purchased_mediahouse_user'] as List).isNotEmpty)
            ? json['purchased_mediahouse_user'][0]['profile_image'] ?? ""
            : "",
        // viewCount: json['count_for_hopper'] ?? 0,
        viewCount: json['content_view_count_by_marketplace_for_app'] ?? 0,
        offerCount: json["purchased_mediahouse"] != null
            ? (json["purchased_mediahouse"] as List).length
            : 0);
  }
}

class ContentDataModel {
  String mediaType = "";
  String id = "";
  String media = "";
  String thumbnail = "";

  ContentDataModel({
    required this.mediaType,
    required this.id,
    required this.media,
    required this.thumbnail,
  });

  factory ContentDataModel.fromJson(Map<String, dynamic> json) =>
      ContentDataModel(
        mediaType: json["media_type"] ?? json["type"] ?? "",
        id: json["_id"] ?? "",
        media: json["media"] ?? "",
        thumbnail: json["imageAndVideo"] ?? json["media"] ?? "",
      );
}
