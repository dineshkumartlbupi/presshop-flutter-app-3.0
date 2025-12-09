import 'package:flutter/material.dart';
import 'package:presshop/utils/Common.dart';

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
    amount = json["amount"].toString() ?? "";
    paidStatusToHopper = json["paid_status_to_hopper"] ?? false;
    paidAmount = json["amount_paid_to_hopper"].toString() ?? "";
    payableAmount = json["amount_payable_to_hopper"] ?? "";
    commitionAmount = json["commition_to_payable"].toString() ?? "";
    address = json["location"] ?? "";
  }
}

class TaskDetailMediaModel {
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

  TaskDetailMediaModel({
    this.id = "",
    this.type = "",
    this.thumbnail = "",
    this.imageVideoUrl = "",
    this.paidStatus = false,
    this.amount = "",
    this.paidStatusToHopper = false,
    this.paidAmount = "",
    this.payableAmount = "",
    this.commitionAmount = "",
  });

  TaskDetailMediaModel.fromJson(Map<String, dynamic> json) {
    id = (json["_id"] ?? "").toString();
    type = (json["media_type"] ?? "").toString();
    thumbnail = json["thumbnail"] ?? "";
    imageVideoUrl = json["media"] ?? "";
    paidStatus = json["paid_status"] ?? false;
    amount = json["amount_paid"].toString() ?? "";
    paidStatusToHopper = json["paid_status_to_hopper"] ?? false;
    paidAmount = json["amount_paid_to_hopper"].toString() ?? "";
    payableAmount = json["amount_payable_to_hopper"] ?? "";
    commitionAmount = json["commition_to_payable"].toString() ?? "";
  }
}

class TaskDetailModel {
  String id = "";
  bool isNeedPhoto = false;
  bool isNeedVideo = false;
  bool isNeedInterview = false;
  String mode = "";
  String type = "";
  String status = "";
  String paidStatus = "";
  DateTime deadLine = DateTime.now();
  String mediaHouseId = "";
  String mediaHouseImage = "";
  String mediaHouseName = "";
  String companyName = "";
  String title = "";
  String description = "";
  List<String> acceptedBy = [];
  String specialReq = "";
  String location = "";
  String photoPrice = "";
  String videoPrice = "";
  String interviewPrice = "";
  String receivedAmount = "";
  double latitude = 0.0;
  double longitude = 0.0;
  String role = "";
  String categoryId = "";
  String userId = "";
  String createdAt = "";
  String discountPercent = "";
  String miles = "";
  String byFeet = "";
  String byCar = "";
  List<TaskDetailMediaModel> mediaList = [];
  String broadcastLocation = "";

  TaskDetailModel({
    this.id = "",
    this.isNeedPhoto = false,
    this.isNeedVideo = false,
    this.isNeedInterview = false,
    this.mode = "",
    this.type = "",
    this.status = "",
    this.paidStatus = "",
    required this.deadLine,
    this.mediaHouseId = "",
    this.mediaHouseImage = "",
    this.mediaHouseName = "",
    this.companyName = "",
    this.title = "",
    this.description = "",
    this.acceptedBy = const [],
    this.specialReq = "",
    this.location = "",
    this.photoPrice = "",
    this.videoPrice = "",
    this.interviewPrice = "",
    this.receivedAmount = "",
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.role = "",
    this.categoryId = "",
    this.userId = "",
    this.createdAt = "",
    this.discountPercent = "",
    this.miles = "",
    this.byFeet = "",
    this.byCar = "",
    this.mediaList = const [],
    this.broadcastLocation = "",
  });

  TaskDetailModel.fromJson(Map<String, dynamic> json) {
    debugPrint("json aditya::::$json");
    /*double dis =0.0;
    String miles ="";
    String byFeet ="";
    String byCar ="";
    calculateTravelDetails(double distanceInMeters) {
      double distanceInMiles = distanceInMeters / 1609.34;
      double distanceInFeet = distanceInMeters * 3.28084;
      double averageSpeedKmh = 60.0;
      double averageSpeedFeetPerMinute = (averageSpeedKmh * 1000 * 3.28084) / 60.0;
      double timeByCarInMinutes = (distanceInMeters / 1000) / averageSpeedKmh * 60;
      double timeByFeetInMinutes = distanceInFeet / averageSpeedFeetPerMinute;
      String formattedTime;
      String formattedCarTime;
      if (timeByFeetInMinutes >= 60) {
        int hours = timeByFeetInMinutes ~/ 60;
        int hour = timeByCarInMinutes ~/ 60;
        double minutes = timeByFeetInMinutes.round() % 60;
        double minute = timeByCarInMinutes.round() % 60;
        formattedTime = "$hours h ";
        formattedCarTime = "$hour h";
      } else {
        formattedTime = "${timeByFeetInMinutes.round().toString()} min";
        formattedCarTime = "${timeByCarInMinutes.round().toString()} min";
      }
      miles = "${distanceInMiles.round().toString()} mi";
      byFeet =formattedTime.toString();
      byCar =formattedCarTime.toString();

      debugPrint("Distance in Miles: ${distanceInMiles.toStringAsFixed(2)} miles");
      debugPrint("Estimated Travel Time by Car (using meters): $formattedCarTime minutes");
      debugPrint("Total Time Taken (using feet): $formattedTime to cover the distance in feet");
    }
    if(json['distance'].toString().isNotEmpty){
      dis = json['distance'];
      calculateTravelDetails(dis);
    }

*/

    id = (json["_id"] ?? "").toString();
    isNeedPhoto =
        (json["need_photos"] ?? "").toString().toLowerCase() == "true";
    isNeedVideo =
        (json["need_videos"] ?? "").toString().toLowerCase() == "true";
    isNeedInterview =
        (json["need_interview"] ?? "").toString().toLowerCase() == "true";
    mode = (json["mode"] ?? "").toString();
    type = (json["type"] ?? "").toString();
    status = (json["status"] ?? "").toString();
    paidStatus = json["paid_status"].toString();
    deadLine = DateTime.parse(json["deadline_date"] ?? "");
    Map<String, dynamic> mediaHouseDetailMap = json["mediahouse_id"] ?? {};
    mediaHouseId = (mediaHouseDetailMap["_id"] ?? "").toString();
    mediaHouseName = (mediaHouseDetailMap["full_name"] ?? "").toString();
    companyName = (mediaHouseDetailMap["company_name"] ?? "").toString();
    mediaHouseImage = (mediaHouseDetailMap["profile_image"] ?? "").toString();

    title = (json["heading"] ?? "").toString();
    description = (json["task_description"] ?? "").toString();
    if (json['accepted_by'] != null) {
      acceptedBy = List<String>.from(json['accepted_by']);
    }
    specialReq = (json["any_spcl_req"] ?? "").toString();
    location = (json["location"] ?? "").toString();
    photoPrice = (json["photo_price"] ?? "").toString();
    videoPrice = (json["videos_price"] ?? "").toString();
    createdAt = (json["createdAt"] ?? "").toString();
    miles = miles;
    byFeet = byFeet;
    byCar = byCar;
    interviewPrice = (json["interview_price"] ?? "").toString();
    receivedAmount = (json["received_amount"] ?? "").toString();
    role = (json["role"] ?? "").toString();
    categoryId = (json["category_id"] ?? "").toString();
    userId = (json["user_id"] ?? "").toString();

    if (json["content"] != null) {
      var uploadedMedia = json["content"] as List;
      mediaList =
          uploadedMedia.map((e) => TaskDetailMediaModel.fromJson(e)).toList();
      debugPrint("mediaList Length : ${mediaList.length}");
    }

    if (json["address_location"] != null) {
      if (json["address_location"]["coordinates"] != null) {
        var coordinator = json["address_location"]["coordinates"] as List;

        if (coordinator.isNotEmpty) {
          latitude =
              double.parse(numberFormatting(coordinator.first).toString());
          longitude =
              double.parse(numberFormatting(coordinator.last).toString());
        }
      }
    }
  }
}

class AdminDetailModel {
  String id = "";
  String name = "";
  String profilePic = "";
  String lastMessageTime = "";
  String lastMessage = "";
  String roomId = "";
  String senderId = "";
  String receiverId = "";
  String roomType = "";

  AdminDetailModel({
    required this.id,
    required this.name,
    required this.profilePic,
    required this.lastMessageTime,
    required this.lastMessage,
    required this.roomId,
    required this.senderId,
    required this.receiverId,
    required this.roomType,
  });

  AdminDetailModel.fromJson(Map<String, dynamic> json) {
    id = (json["_id"] ?? "").toString();
    name = (json["name"] ?? "").toString();
    profilePic = (json["profile_image"] ?? "").toString();
    lastMessageTime = '';
    lastMessage = '';
    roomId =
        json["room_details"] != null ? json["room_details"]['room_id'] : '';
    senderId =
        json["room_details"] != null ? json["room_details"]['sender_id'] : '';
    receiverId =
        json["room_details"] != null ? json["room_details"]['receiver_id'] : '';
    roomType =
        json["room_details"] != null ? json["room_details"]['room_type'] : '';
  }

/* AdminDetailModel.copyWith({
    String? id,
    String? name,
    String? profilePic,
    String? lastMessageTime,
    String? lastMessage,
    String? roomId,
    String? senderId,
    String? receiverId,
  }) {
    AdminDetailModel(
        id: id ?? this.id,
        name: name ?? this.name,
        profilePic: profilePic ?? this.profilePic,
        lastMessageTime: lastMessageTime ?? this.lastMessageTime,
        lastMessage: lastMessage ?? this.lastMessage,
        roomId:roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.senderId


    );
  }*/
}

class ManageTaskChatModel {
  String id = "";
  bool paidStatus = false;
  TaskVideoModel? media;
  List<TaskVideoModel> mediaList = [];
  String messageType = "";
  String initialOfferAmount = "";
  String senderType = "";
  String hopperPrice = "";
  String payableHopperPrice = "";
  String finalCounterAmount = "";
  String amount = "";
  String requestStatus = "";
  bool isMakeCounterOffer = false;
  String mediaHouseImage = "";
  String mediaHouseName = "";
  String mediaHouseId = "";
  String createdAtTime = "";
  String imageCount = "";
  String videoCount = "";
  String audioCount = "";
  double rating = 0;
  String roomId = "";
  bool isRatingGiven = false;
  String transactionId = "";
  TextEditingController priceController = TextEditingController();
  TextEditingController ratingReviewController = TextEditingController();

  ManageTaskChatModel.fromJsonNew(Map<String, dynamic> json) {
    id = (json["_id"] ?? "").toString();
    messageType = (json["message_type"] ?? "").toString();
    amount = json["amount"] ?? "";
    hopperPrice = json["hopper_price"] ?? "";
    Map<String, dynamic> mediaHouseDetailMap =
        json["publication_details"] ?? {};
    // Map<String, dynamic> mediaHouseDetailMap = json["sender_id"] ?? {};
    mediaHouseId = (mediaHouseDetailMap["_id"] ?? "").toString();
    mediaHouseName = (mediaHouseDetailMap["company_name"] ?? "").toString();
    mediaHouseImage = (mediaHouseDetailMap["profile_image"] ?? "").toString();
    payableHopperPrice = numberFormatting((json["earning"] ?? "")).toString();
  }

  ManageTaskChatModel.fromJson(Map<String, dynamic> json) {
    List<TaskVideoModel> mediaListTem = [];

    if (json["media"] != null) {
      var data = json["media"] as List;
      mediaListTem = data.map((e) => TaskVideoModel.fromJson(e)).toList();
      debugPrint("mediaListTem Length::::: ${mediaList.length}");
    }

    id = (json["_id"] ?? "").toString();
    messageType = (json["message_type"] ?? "").toString();
    senderType = (json["sender_type"] ?? "").toString();
    amount = numberFormatting((json["amount"] ?? "")).toString();
    hopperPrice = numberFormatting((json["hopper_price"] ?? "")).toString();
    payableHopperPrice =
        numberFormatting((json["payable_to_hopper"] ?? "")).toString();
    requestStatus = (json["request_status"] ?? "").toString();
    finalCounterAmount = (json["finaloffer_price"] ?? "").toString();
    initialOfferAmount = (json["initial_offer_price"] ?? "").toString();
    createdAtTime = (json["createdAt"] ?? "").toString();
    roomId = (json["room_id"] ?? "").toString();
    isMakeCounterOffer = (json["is_hide"] ?? "").toString() == "true";
    // Map<String, dynamic> mediaMap = json["media"] ?? {};
    rating = double.parse(numberFormatting((json["rating"] ?? "")).toString());
    priceController = TextEditingController(
        text: (json["finaloffer_price"] ?? "").toString());
    ratingReviewController =
        TextEditingController(text: (json["review"] ?? "").toString());
    paidStatus = json['paid_status'] ?? false;
    isRatingGiven = json["review"] != null;
    mediaList = mediaListTem;
    imageCount = json["imageCount"] ?? "0";
    videoCount = json["videoCount"] ?? "0";
    audioCount = json["audioCount"] ?? "0";
    Map<String, dynamic> mediaHouseDetailMap = json["receiver_id"] ?? {};
    mediaHouseId = (mediaHouseDetailMap["_id"] ?? "").toString();
    mediaHouseName = json["message_type"] == "PaymentIntent"
        ? json["user_info"] != null
            ? json["user_info"]["company_name"]
            : ""
        : (mediaHouseDetailMap["company_name"] ?? "").toString();
    mediaHouseImage = (mediaHouseDetailMap["profile_image"] ?? "").toString();
    transactionId = json["transaction_id"] ?? "";
    // }
  }
}

/// Publication List
class PublicationDataModel {
  String id = "";
  String publicationName = "";
  String companyName = "";
  String role = "";
  String companyProfile = "";
  String status = "";

  PublicationDataModel.fromJson(Map<String, dynamic> json) {
    id = json["_id"] ?? "";
    companyName = json['company_name'] ?? '';
    publicationName = json["full_name"] ?? "";
    role = json["role"] ?? "";
    status = json["status"] ?? "";
    companyProfile = json['profile_image'] ?? '';
  }
}

class AllBankNameModel {
  String id = "";
  String bankName = "";
  String bankImage = "";
  String bankLocation = "";
  bool isSelected = false;

  AllBankNameModel({
    required this.id,
    required this.bankName,
    required this.bankImage,
    required this.isSelected,
  });
}
