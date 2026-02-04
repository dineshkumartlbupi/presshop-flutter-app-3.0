import 'package:flutter/material.dart';
import 'package:presshop/core/core_export.dart';
import '../../domain/entities/task_detail.dart';
import '../../domain/entities/task_media.dart';

class TaskVideoModel {
  TaskVideoModel(
      {this.id = "",
      this.type = "",
      this.thumbnail = "",
      this.imageVideoUrl = "",
      this.paidStatus = false,
      this.amount = "",
      this.paidStatusToHopper = false,
      this.paidAmount = "",
      this.payableAmount = "",
      this.commitionAmount = "",
      this.address = ""});

  TaskVideoModel.fromJson(Map<String, dynamic> json) {
    id = (json["_id"] ?? json["image_id"] ?? "").toString();
    type = (json["mime"] ?? "").toString();
    thumbnail = (json["thumbnail_url"] ??
            json["watermarkimage_url"] ??
            json["thumbnail"] ??
            "")
        .toString();
    imageVideoUrl = (json["url"] ?? json["name"] ?? "").toString();
    paidStatus = json["paid_status"] ?? false;
    amount = json["amount"].toString();
    paidStatusToHopper = json["paid_status_to_hopper"] ?? false;
    paidAmount = json["amount_paid_to_hopper"].toString();
    payableAmount = json["amount_payable_to_hopper"] ?? "";
    commitionAmount = json["commition_to_payable"].toString();
    address = json["location"] ?? "";
  }
  String id = "";
  String type = "";
  String thumbnail = "";
  String imageVideoUrl = "";
  bool paidStatus = false;
  String amount = "";
  bool paidStatusToHopper = false;
  String paidAmount = "";
  String payableAmount = "";
  String commitionAmount = "";
  String address = "";
}

class TaskDetailMediaModel extends TaskMedia {
  const TaskDetailMediaModel({
    super.id = "",
    super.type = "",
    super.thumbnail = "",
    super.imageVideoUrl = "",
    super.paidStatus = false,
    super.amount = "",
    super.paidStatusToHopper = false,
    super.paidAmount = "",
    super.payableAmount = "",
    super.commitionAmount = "",
  });

  factory TaskDetailMediaModel.fromJson(Map<String, dynamic> json) {
    return TaskDetailMediaModel(
      id: (json["_id"] ?? json["image_id"] ?? "").toString(),
      type: (json["media_type"] ?? "").toString(),
      thumbnail: (json["watermark"] ?? json["thumbnail"] ?? "").toString(),
      imageVideoUrl: (json["media"] ?? "").toString(),
      paidStatus: json["paid_status"] ?? false,
      amount: json["amount_paid"].toString(),
      paidStatusToHopper: json["paid_status_to_hopper"] ?? false,
      paidAmount: json["amount_paid_to_hopper"].toString(),
      payableAmount: json["amount_payable_to_hopper"] ?? "",
      commitionAmount: json["commition_to_payable"].toString(),
    );
  }
}

class TaskDetailModel extends TaskDetail {
  const TaskDetailModel({
    super.id = "",
    super.isNeedPhoto = false,
    super.isNeedVideo = false,
    super.isNeedInterview = false,
    super.mode = "",
    super.type = "",
    super.status = "",
    super.paidStatus = "",
    required super.deadLine,
    super.mediaHouseId = "",
    super.mediaHouseImage = "",
    super.mediaHouseName = "",
    super.companyName = "",
    super.title = "",
    super.description = "",
    super.acceptedBy = const [],
    super.specialReq = "",
    super.location = "",
    super.photoPrice = "",
    super.videoPrice = "",
    super.interviewPrice = "",
    super.receivedAmount = "",
    super.latitude = 0.0,
    super.longitude = 0.0,
    super.role = "",
    super.categoryId = "",
    super.userId = "",
    super.createdAt = "",
    super.discountPercent = "",
    super.miles = "",
    super.byFeet = "",
    super.byCar = "",
    super.mediaList = const [],
    super.broadcastLocation = "",
    super.roomId = "",
    super.minimumPriceRange = "",
    super.maximumPriceRange = "",
    super.currency = "",
    super.currencySymbol = "",
  });

  factory TaskDetailModel.fromJson(Map<String, dynamic> json,
      {String roomId = ""}) {
    debugPrint("json aditya::::$json");

    List<TaskMedia> mediaList = [];
    if (json["content"] != null) {
      var uploadedMedia = json["content"] as List;
      mediaList =
          uploadedMedia.map((e) => TaskDetailMediaModel.fromJson(e)).toList();
      debugPrint("mediaList Length : ${mediaList.length}");
    }

    double latitude = 0.0;
    double longitude = 0.0;

    if (json["address_location"] != null) {
      if (json["address_location"]["coordinates"] != null) {
        var coordinator = json["address_location"]["coordinates"] as List;

        if (coordinator.isNotEmpty) {
          // Assuming numberFormatting returns a number or string
          // Just parsing safely
          latitude = (coordinator.first is num)
              ? (coordinator.first as num).toDouble()
              : double.tryParse(coordinator.first.toString()) ?? 0.0;
          longitude = (coordinator.last is num)
              ? (coordinator.last as num).toDouble()
              : double.tryParse(coordinator.last.toString()) ?? 0.0;
        }
      }
    }

    String minimumPriceRange = "";
    String maximumPriceRange = "";

    if (json['mediahouse_id'] != null &&
        json['mediahouse_id'] is Map &&
        json['mediahouse_id']['admin_rignts'] != null) {
      if (json['mediahouse_id']['admin_rignts']['price_range'] != null) {
        maximumPriceRange = json['mediahouse_id']['admin_rignts']['price_range']
                ['maximum_price']
            .toString();
        minimumPriceRange = json['mediahouse_id']['admin_rignts']['price_range']
                ['minimum_price']
            .toString();
      }
    }

    final bool isSuccess = json["code"] == 200 ||
        json["success"] == true ||
        (json["status"]?.toString().toLowerCase() == "success");

    if (!isSuccess) {
      debugPrint(
          "🚀 TaskDetailModel: Attempting to parse despite missing success/code flag");
    }

    return TaskDetailModel(
      id: (json["_id"] ?? "").toString(),
      isNeedPhoto:
          (json["need_photos"] ?? "").toString().toLowerCase() == "true" ||
              (json["hopper_photo_price"] != null &&
                  json["hopper_photo_price"].toString() != "0"),
      isNeedVideo:
          (json["need_videos"] ?? "").toString().toLowerCase() == "true" ||
              (json["hopper_videos_price"] != null &&
                  json["hopper_videos_price"].toString() != "0"),
      isNeedInterview:
          (json["need_interview"] ?? "").toString().toLowerCase() == "true" ||
              (json["hopper_interview_price"] != null &&
                  json["hopper_interview_price"].toString() != "0"),
      mode: (json["mode"] ?? "").toString(),
      type: (json["type"] ?? "").toString(),
      status: (json["status"] ?? "").toString(),
      paidStatus: json["paid_status"].toString(),
      deadLine:
          DateTime.tryParse(json["deadline_date"] ?? "") ?? DateTime.now(),
      mediaHouseId: (json["mediahouse_id"] is Map
              ? (json["mediahouse_id"]["_id"] ?? "")
              : "")
          .toString(),
      mediaHouseName: (json["mediahouse_id"] is Map
              ? (json["mediahouse_id"]["full_name"] ?? "")
              : "")
          .toString(),
      companyName: (json["mediahouse_id"] is Map
              ? (json["mediahouse_id"]["company_name"] ?? "")
              : "")
          .toString(),
      mediaHouseImage: (json["mediahouse_id"] is Map
              ? (json["mediahouse_id"]["profile_image"] ?? "")
              : "")
          .toString(),
      title: (json["heading"] ?? "").toString(),
      description: (json["task_description"] ?? "").toString(),
      acceptedBy: json['accepted_by'] != null
          ? List<String>.from(json['accepted_by'])
          : [],
      specialReq: (json["any_spcl_req"] ?? "").toString(),
      location: (json["location"] ?? "").toString(),
      photoPrice:
          (json["hopper_photo_price"] ?? json["photo_price"] ?? "").toString(),
      videoPrice: (json["hopper_videos_price"] ?? json["videos_price"] ?? "")
          .toString(),
      createdAt: (json["createdAt"] ?? "").toString(),
      interviewPrice:
          (json["hopper_interview_price"] ?? json["interview_price"] ?? "")
              .toString(),
      receivedAmount: (json["received_amount"] ?? "").toString(),
      role: (json["role"] ?? "").toString(),
      categoryId: (json["category_id"] ?? "").toString(),
      userId: (json["user_id"] ?? "").toString(),
      mediaList: mediaList,
      latitude: latitude,
      longitude: longitude,
      minimumPriceRange: minimumPriceRange,
      maximumPriceRange: maximumPriceRange,
      currency: (json["currency"] ?? "").toString(),
      currencySymbol: (json["currency_symbol"] != null &&
              json["currency_symbol"].toString().isNotEmpty)
          ? json["currency_symbol"].toString()
          : getCurrencySymbol(json["currency"]?.toString()),
      roomId: roomId,
    );
  }

  factory TaskDetailModel.fromEntity(TaskDetail entity) {
    return TaskDetailModel(
      id: entity.id,
      isNeedPhoto: entity.isNeedPhoto,
      isNeedVideo: entity.isNeedVideo,
      isNeedInterview: entity.isNeedInterview,
      mode: entity.mode,
      type: entity.type,
      status: entity.status,
      paidStatus: entity.paidStatus,
      deadLine: entity.deadLine,
      mediaHouseId: entity.mediaHouseId,
      mediaHouseImage: entity.mediaHouseImage,
      mediaHouseName: entity.mediaHouseName,
      companyName: entity.companyName,
      title: entity.title,
      description: entity.description,
      acceptedBy: entity.acceptedBy,
      specialReq: entity.specialReq,
      location: entity.location,
      photoPrice: entity.photoPrice,
      videoPrice: entity.videoPrice,
      interviewPrice: entity.interviewPrice,
      receivedAmount: entity.receivedAmount,
      latitude: entity.latitude,
      longitude: entity.longitude,
      role: entity.role,
      categoryId: entity.categoryId,
      userId: entity.userId,
      createdAt: entity.createdAt,
      discountPercent: entity.discountPercent,
      miles: entity.miles,
      byFeet: entity.byFeet,
      byCar: entity.byCar,
      mediaList: entity.mediaList,
      broadcastLocation: entity.broadcastLocation,
      roomId: entity.roomId,
      minimumPriceRange: entity.minimumPriceRange,
      maximumPriceRange: entity.maximumPriceRange,
      currency: entity.currency,
      currencySymbol: entity.currencySymbol,
    );
  }
}
