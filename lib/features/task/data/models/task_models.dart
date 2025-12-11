import 'package:flutter/material.dart';
import 'package:presshop/core/utils/common_utils.dart';
import '../../domain/entities/task_detail.dart';
import '../../domain/entities/task_media.dart';

class TaskVideoModel {
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
    id = (json["_id"] ?? "").toString();
    type = (json["mime"] ?? "").toString();
    thumbnail = json["thumbnail"] ?? "";
    imageVideoUrl = json["name"] ?? "";
    paidStatus = json["paid_status"] ?? false;
    amount = json["amount"].toString();
    paidStatusToHopper = json["paid_status_to_hopper"] ?? false;
    paidAmount = json["amount_paid_to_hopper"].toString();
    payableAmount = json["amount_payable_to_hopper"] ?? "";
    commitionAmount = json["commition_to_payable"].toString();
    address = json["location"] ?? "";
  }
}

class TaskDetailMediaModel extends TaskMedia {
  
  TaskDetailMediaModel({
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
      id: (json["_id"] ?? "").toString(),
      type: (json["media_type"] ?? "").toString(),
      thumbnail: json["thumbnail"] ?? "",
      imageVideoUrl: json["media"] ?? "",
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
  
  TaskDetailModel({
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
  });

  factory TaskDetailModel.fromJson(Map<String, dynamic> json) {
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
           latitude = (coordinator.first is num) ? (coordinator.first as num).toDouble() : double.tryParse(coordinator.first.toString()) ?? 0.0;
           longitude = (coordinator.last is num) ? (coordinator.last as num).toDouble() : double.tryParse(coordinator.last.toString()) ?? 0.0;
        }
      }
    }

    return TaskDetailModel(
      id: (json["_id"] ?? "").toString(),
      isNeedPhoto: (json["need_photos"] ?? "").toString().toLowerCase() == "true",
      isNeedVideo: (json["need_videos"] ?? "").toString().toLowerCase() == "true",
      isNeedInterview: (json["need_interview"] ?? "").toString().toLowerCase() == "true",
      mode: (json["mode"] ?? "").toString(),
      type: (json["type"] ?? "").toString(),
      status: (json["status"] ?? "").toString(),
      paidStatus: json["paid_status"].toString(),
      deadLine: DateTime.tryParse(json["deadline_date"] ?? "") ?? DateTime.now(),
      
      mediaHouseId: (json["mediahouse_id"] is Map ? (json["mediahouse_id"]["_id"] ?? "") : "").toString(),
      mediaHouseName: (json["mediahouse_id"] is Map ? (json["mediahouse_id"]["full_name"] ?? "") : "").toString(),
      companyName: (json["mediahouse_id"] is Map ? (json["mediahouse_id"]["company_name"] ?? "") : "").toString(),
      mediaHouseImage: (json["mediahouse_id"] is Map ? (json["mediahouse_id"]["profile_image"] ?? "") : "").toString(),

      title: (json["heading"] ?? "").toString(),
      description: (json["task_description"] ?? "").toString(),
      acceptedBy: json['accepted_by'] != null ? List<String>.from(json['accepted_by']) : [],
      specialReq: (json["any_spcl_req"] ?? "").toString(),
      location: (json["location"] ?? "").toString(),
      photoPrice: (json["photo_price"] ?? "").toString(),
      videoPrice: (json["videos_price"] ?? "").toString(),
      createdAt: (json["createdAt"] ?? "").toString(),
      
      interviewPrice: (json["interview_price"] ?? "").toString(),
      receivedAmount: (json["received_amount"] ?? "").toString(),
      role: (json["role"] ?? "").toString(),
      categoryId: (json["category_id"] ?? "").toString(),
      userId: (json["user_id"] ?? "").toString(),
      mediaList: mediaList,
      latitude: latitude,
      longitude: longitude
    );
  }
}
