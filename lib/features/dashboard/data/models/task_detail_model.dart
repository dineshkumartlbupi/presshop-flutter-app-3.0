import 'package:presshop/features/task/domain/entities/task_detail.dart';
import 'package:presshop/features/task/data/models/task_models.dart'
    show TaskDetailMediaModel;
import 'package:presshop/features/task/domain/entities/task_media.dart';
import 'package:flutter/foundation.dart';

class TaskDetailModel extends TaskDetail {
  const TaskDetailModel({
    required super.id,
    super.isNeedPhoto,
    super.isNeedVideo,
    super.isNeedInterview,
    super.mode,
    super.type,
    super.status,
    super.paidStatus,
    required super.deadLine,
    super.mediaHouseId,
    super.mediaHouseImage,
    super.mediaHouseName,
    super.companyName,
    super.title,
    super.description,
    super.acceptedBy,
    super.specialReq,
    super.location,
    super.photoPrice,
    super.videoPrice,
    super.interviewPrice,
    super.receivedAmount,
    super.latitude,
    super.longitude,
    super.role,
    super.categoryId,
    super.userId,
    super.createdAt,
    super.discountPercent,
    super.miles,
    super.byFeet,
    super.byCar,
    super.mediaList = const [],
    super.broadcastLocation,
    super.roomId,
    super.minimumPriceRange = "",
    super.maximumPriceRange = "",
  });

  factory TaskDetailModel.fromJson(Map<String, dynamic> json,
      {String? roomId}) {
    Map<String, dynamic> mediaHouseDetailMap = json["mediahouse_id"] ?? {};

    List<TaskMedia> mediaList = [];
    if (json["content"] != null) {
      var uploadedMedia = json["content"] as List;
      mediaList =
          uploadedMedia.map((e) => TaskDetailMediaModel.fromJson(e)).toList();
    }

    double lat = 0.0;
    double lng = 0.0;

    if (json["address_location"] != null) {
      if (json["address_location"]["coordinates"] != null) {
        var coordinator = json["address_location"]["coordinates"] as List;
        if (coordinator.isNotEmpty) {
          try {
            lat = double.parse(coordinator.first.toString());
            lng = double.parse(coordinator.last.toString());
          } catch (e) {
            debugPrint("Error parsing coords: $e");
          }
        }
      }
    }

    String minPrice = "";
    String maxPrice = "";
    if (mediaHouseDetailMap['admin_rignts'] != null &&
        mediaHouseDetailMap['admin_rignts']['price_range'] != null) {
      maxPrice = mediaHouseDetailMap['admin_rignts']['price_range']
              ['maximum_price']
          .toString();
      minPrice = mediaHouseDetailMap['admin_rignts']['price_range']
              ['minimum_price']
          .toString();
    }

    return TaskDetailModel(
      id: (json["_id"] ?? "").toString(),
      isNeedPhoto:
          (json["need_photos"] ?? "").toString().toLowerCase() == "true",
      isNeedVideo:
          (json["need_videos"] ?? "").toString().toLowerCase() == "true",
      isNeedInterview:
          (json["need_interview"] ?? "").toString().toLowerCase() == "true",
      mode: (json["mode"] ?? "").toString(),
      type: (json["type"] ?? "").toString(),
      status: (json["status"] ?? "").toString(),
      paidStatus: json["paid_status"].toString(),
      deadLine:
          DateTime.tryParse(json["deadline_date"] ?? "") ?? DateTime.now(),
      mediaHouseId: (mediaHouseDetailMap["_id"] ?? "").toString(),
      mediaHouseName: (mediaHouseDetailMap["full_name"] ?? "").toString(),
      companyName: (mediaHouseDetailMap["company_name"] ?? "").toString(),
      mediaHouseImage: (mediaHouseDetailMap["profile_image"] ?? "").toString(),
      title: (json["heading"] ?? "").toString(),
      description: (json["task_description"] ?? "").toString(),
      acceptedBy: json['accepted_by'] != null
          ? List<String>.from(json['accepted_by'])
          : [],
      specialReq: (json["any_spcl_req"] ?? "").toString(),
      location: (json["location"] ?? "").toString(),
      photoPrice: (json["photo_price"] ?? "").toString(),
      videoPrice: (json["videos_price"] ?? "").toString(),
      interviewPrice: (json["interview_price"] ?? "").toString(),
      receivedAmount: (json["received_amount"] ?? "").toString(),
      latitude: lat,
      longitude: lng,
      role: (json["role"] ?? "").toString(),
      categoryId: (json["category_id"] ?? "").toString(),
      userId: (json["user_id"] ?? "").toString(),
      createdAt: (json["createdAt"] ?? "").toString(),
      mediaList: mediaList,
      roomId: roomId ?? "",
      minimumPriceRange: minPrice,
      maximumPriceRange: maxPrice,
    );
  }
}
