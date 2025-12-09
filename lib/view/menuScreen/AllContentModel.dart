class AllContentData {
  String id = "";
  String type = "";
  String status = "";
  List<AllContentMediaModel> content = [];
  String heading = "";
  String description = "";
  String location = "";
  String categoryId = "";
  String categoryName = "";
  int totalView = 0;
  int totalSold = 0;
  int totalOffer = 0;
  String displayPrice = "";
  String time = "";

  /// 🔥 Added New Field
  String hopperId = "";

  AllContentData({
    this.id = "",
    this.type = "",
    this.status = "",
    this.content = const [],
    this.heading = "",
    this.description = "",
    this.location = "",
    this.categoryId = "",
    this.categoryName = "",
    this.totalView = 0,
    this.totalSold = 0,
    this.totalOffer = 0,
    this.displayPrice = "",
    this.time = "",
    this.hopperId = "", // added
  });

  AllContentData.fromJson(Map<String, dynamic> json) {
    id = (json['_id'] ?? "").toString();
    type = (json['type'] ?? "").toString();
    status = (json['status'] ?? "").toString();

    /// 🔥 hopperId from API
    hopperId = (json['hopper_id'] ?? "").toString();

    if (json['content'] != null) {
      content = <AllContentMediaModel>[];
      for (var v in json['content']) {
        content.add(AllContentMediaModel.fromJson(v));
      }
    }

    heading = (json['heading'] ?? "").toString();
    description = (json['description'] ?? "").toString();
    location = (json['location'] ?? "").toString();

    if (json['category_id'] != null && json['category_id'] is Map) {
      categoryId = (json['category_id']['_id'] ?? "").toString();
      categoryName = (json['category_id']['name'] ?? "").toString();
    }

    totalView = json['totalView'] ?? 0;
    totalSold = json['totalSold'] ?? 0;
    totalOffer = json['offer_content_size'] ?? 0;
    displayPrice = (json['display_price'] ?? "").toString();
    time = (json['createdAt'] ?? "").toString();
  }
}

class AllContentMediaModel {
  String media = "";
  String mediaType = "";
  String thumbnail = "";

  AllContentMediaModel({
    this.media = "",
    this.mediaType = "",
    this.thumbnail = "",
  });

  AllContentMediaModel.fromJson(Map<String, dynamic> json) {
    media = (json['media'] ?? "").toString();
    mediaType = (json['media_type'] ?? "").toString();
    thumbnail = (json['thumbnail'] ?? "").toString();
  }
}

class AllContentMedia {
  String mediaType = "";
  bool isWatermarked = false;
  bool isNsfw = false;
  bool deepFake = false;
  bool isAdult = false;
  bool wasConverted = false;
  String id = "";
  String media = "";
  String originalFileName = "";

  AllContentMedia({
    required this.mediaType,
    required this.isWatermarked,
    required this.isNsfw,
    required this.deepFake,
    required this.isAdult,
    required this.wasConverted,
    required this.id,
    required this.media,
    required this.originalFileName,
  });

  AllContentMedia.fromJson(Map<String, dynamic> json) {
    mediaType = json['media_type'] ?? "";
    isWatermarked = json['is_watermarked'] ?? false;
    isNsfw = json['is_nsfw'] ?? false;
    deepFake = json['deep_fake'] ?? false;
    isAdult = json['isAdult'] ?? false;
    wasConverted = json['wasConverted'] ?? false;
    id = json['_id'] ?? "";
    media = json['media'] ?? "";
    originalFileName = json['originalFileName'] ?? "";
  }
}
