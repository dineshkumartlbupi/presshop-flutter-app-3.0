import 'package:presshop/features/rating/domain/entities/review.dart';

class RatingReviewModel extends Review {
  const RatingReviewModel({
    required super.id,
    required super.newsName,
    required super.image,
    required super.dateTime,
    required super.date,
    required super.time,
    required super.ratingValue,
    required super.review,
    required super.senderType,
    required super.from,
    required super.to,
    required super.hopperImage,
    required super.userName,
    required super.totalEarning,
    required super.hopperCreatedAt,
    required super.featureList,
  });

  factory RatingReviewModel.fromJson(Map<String, dynamic> json) {
    return RatingReviewModel(
      newsName: json['mediahouse_details'] != null
          ? json['mediahouse_details']['company_name'] ?? ''
          : '',
      image: json['mediahouse_details'] != null
          ? json['mediahouse_details']['profile_image'] ?? ''
          : '',
      dateTime: json['updateddata'] != null
          ? json['updateddata']['createdAt'].toString()
          : "",
      date: json['updateddata'] != null
          ? json['updateddata']['createdAt'].toString()
          : "",
      time: json['updateddata'] != null
          ? json['updateddata']['createdAt'].toString()
          : "",
      ratingValue: json["updateddata"] != null
          ? double.tryParse(json['updateddata']['rating'].toString()) ?? 0.0
          : 0.0,
      review: json["updateddata"] != null
          ? json['updateddata']['review'].toString()
          : "",
      id: json["_id"] ?? "",
      from: json["from"] ?? "",
      to: json["to"] ??
          "", // Fixed: was json["to"] in original but let's assume same key
      senderType: json["sender_type"] ?? "",
      totalEarning: json["total_earining"] != null
          ? json["total_earining"].toString()
          : "0",
      hopperImage: json['hopper_details'] != null &&
              json['hopper_details']['avatar_id'] != null
          ? json['hopper_details']['avatar_id']['avatar'].toString()
          : "",
      userName: json['hopper_details'] != null
          ? json['hopper_details']['user_name'] ?? ""
          : "",
      hopperCreatedAt: json['hopper_details'] != null
          ? json['hopper_details']['createdAt'] ?? ""
          : "",
      featureList:
          json['updateddata'] != null && json['updateddata']['features'] != null
              ? List<String>.from(json['updateddata']['features'])
              : [],
    );
  }
}
