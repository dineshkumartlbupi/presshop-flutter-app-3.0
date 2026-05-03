// hopper_feed_model.dart

class HopperFeedResponse {

  HopperFeedResponse({
    required this.code,
    required this.response,
  });

  factory HopperFeedResponse.fromJson(Map<String, dynamic> json) {
    return HopperFeedResponse(
      code: json['code'] ?? 0,
      response: (json['response'] as List<dynamic>? ?? [])
          .map((e) => HopperFeed.fromJson(e))
          .toList(),
    );
  }
  final int code;
  final List<HopperFeed> response;
}

// ---------------------------------------------------------------------------

class HopperFeed {

  HopperFeed({
    required this.id,
    this.description,
    this.location,
    this.latitude,
    this.longitude,
    this.categoryId,
    this.hopper,
    this.type,
    this.askPrice,
    this.timestamp,
    required this.isDraft,
    required this.isCharity,
    this.charity,
    required this.images,
    required this.videos,
    required this.status,
    required this.contentMetadata,
    required this.displayPrice,
    required this.displayCurrency,
    required this.isFavourite,
    required this.isLiked,
  });

  factory HopperFeed.fromJson(Map<String, dynamic> json) {
    return HopperFeed(
      id: json['id'] ?? '',
      description: json['description'],
      location: json['location'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      categoryId: json['category_id'],
      hopper: json['hopper_id'] is Map<String, dynamic>
          ? HopperUser.fromJson(json['hopper_id'])
          : null,
      type: json['type'],
      askPrice: json['ask_price'],
      timestamp: json['timestamp'],
      isDraft: json['is_draft'] == "true" || json['is_draft'] == true,
      isCharity: json['is_charity'] == "true" || json['is_charity'] == true,
      charity: json['charity'],
      images: List<String>.from(json['images'] ?? []),
      videos: List<String>.from(json['videos'] ?? []),
      status: json['status'] ?? '',
      contentMetadata: (json['content_metadata'] as List<dynamic>? ?? [])
          .map((e) => ContentMetadata.fromJson(e))
          .toList(),
      displayPrice: (json['display_price'] ?? 0).toDouble(),
      displayCurrency: json['display_currency'] ?? '',
      isFavourite: json['is_favourite'] ?? false,
      isLiked: json['is_liked'] ?? false,
    );
  }
  final String id;
  final String? description;
  final String? location;
  final String? latitude;
  final String? longitude;
  final String? categoryId;
  final HopperUser? hopper;
  final String? type;
  final String? askPrice;
  final String? timestamp;
  final bool isDraft;
  final bool isCharity;
  final String? charity;
  final List<String> images;
  final List<String> videos;
  final String status;
  final List<ContentMetadata> contentMetadata;
  final double displayPrice;
  final String displayCurrency;
  final bool isFavourite;
  final bool isLiked;
}

// ---------------------------------------------------------------------------

class HopperUser {

  HopperUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.avatar,
  });

  factory HopperUser.fromJson(Map<String, dynamic> json) {
    return HopperUser(
      id: json['_id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phone: json['phone'] ?? '',
      avatar:
          json['avatar_id'] != null ? Avatar.fromJson(json['avatar_id']) : null,
    );
  }
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final Avatar? avatar;
}

// ---------------------------------------------------------------------------

class Avatar {

  Avatar({
    required this.id,
    required this.avatar,
  });

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(
      id: json['_id'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }
  final String id;
  final String avatar;
}

// ---------------------------------------------------------------------------

class ContentMetadata {

  ContentMetadata({
    required this.media,
    required this.isNsfw,
    required this.deepFake,
    required this.mediaType,
    required this.isWatermarked,
    this.watermarkedMedia,
  });

  factory ContentMetadata.fromJson(Map<String, dynamic> json) {
    return ContentMetadata(
      media: json['media'] ?? '',
      isNsfw: json['is_nsfw'] ?? false,
      deepFake: json['deep_fake'] ?? false,
      mediaType: json['media_type'] ?? '',
      isWatermarked: json['is_watermarked'] ?? false,
      watermarkedMedia: json['watermarked_media'],
    );
  }
  final String media;
  final bool isNsfw;
  final bool deepFake;
  final String mediaType;
  final bool isWatermarked;
  final String? watermarkedMedia;
}
