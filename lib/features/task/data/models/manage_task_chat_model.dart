import 'package:flutter/material.dart';
import 'package:presshop/core/utils/common_utils.dart';
import 'package:presshop/features/task/data/models/task_models.dart';

class ManageTaskChatModel {
  ManageTaskChatModel.fromJsonNew(Map<String, dynamic> json) {
    id = (json["_id"] ?? "").toString();
    String mType = (json["message_type"] ?? "").toString();
    if (mType == "image" || mType == "video" || mType == "audio") {
      messageType = "media";
    } else {
      messageType = mType;
    }
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

    // Extract parent-level address (may be used as fallback for media items)
    String parentAddress = (json["address"] ??
            json["location"] ??
            json["place"] ??
            json["place_name"] ??
            "")
        .toString();
    debugPrint(
        "📍 ManageTaskChatModel parent address: '$parentAddress', keys: ${json.keys.toList()}");

    if (json["media"] != null) {
      var data = json["media"] as List;
      mediaListTem = data.map((e) => TaskVideoModel.fromJson(e)).toList();
      debugPrint("mediaListTem Length::::: ${mediaListTem.length}");

      // If media items don't have their own address, use parent's address
      if (parentAddress.isNotEmpty) {
        for (var m in mediaListTem) {
          if (m.address.isEmpty) {
            m.address = parentAddress;
          }
        }
      }
    }

    id = (json["_id"] ?? "").toString();
    String mType = (json["message_type"] ?? "").toString();
    if (mType == "image" || mType == "video" || mType == "audio") {
      messageType = "media";
    } else {
      messageType = mType;
    }
    senderType = (json["sender_type"] ?? "").toString();
    amount = numberFormatting((json["amount"] ?? "")).toString();
    hopperPrice = numberFormatting((json["hopper_price"] ?? "")).toString();
    payableHopperPrice = numberFormatting(
      (json["payable_to_hopper"] ?? ""),
    ).toString();
    requestStatus = (json["request_status"] ?? "").toString();
    finalCounterAmount = (json["finaloffer_price"] ?? "").toString();
    initialOfferAmount = (json["initial_offer_price"] ?? "").toString();
    createdAtTime = (json["createdAt"] ?? "").toString();
    roomId = (json["room_id"] ?? "").toString();
    isMakeCounterOffer = (json["is_hide"] ?? "").toString() == "true";
    // Map<String, dynamic> mediaMap = json["media"] ?? {};
    rating = double.parse(numberFormatting((json["rating"] ?? "")).toString());
    priceController = TextEditingController(
      text: (json["finaloffer_price"] ?? "").toString(),
    );
    ratingReviewController = TextEditingController(
      text: (json["review"] ?? "").toString(),
    );
    paidStatus = json['paid_status'] ?? false;
    isRatingGiven = json["review"] != null;
    mediaList = mediaListTem;
    if (mediaList.isNotEmpty) {
      media = mediaList.first;
    }

    // Handle media counts if not provided by API
    if (json["imageCount"] != null) {
      imageCount = json["imageCount"].toString();
      videoCount = json["videoCount"].toString();
      audioCount = json["audioCount"].toString();
    } else if (mediaList.isNotEmpty) {
      int imgC = 0, vidC = 0, audC = 0;
      for (var m in mediaList) {
        if (m.type.contains("video")) {
          vidC++;
        } else if (m.type.contains("audio")) {
          audC++;
        } else {
          imgC++;
        }
      }
      imageCount = imgC.toString();
      videoCount = vidC.toString();
      audioCount = audC.toString();
    } else {
      imageCount = "0";
      videoCount = "0";
      audioCount = "0";
    }

    // Handle receiver_id: can be String or Map
    var receiverData = json["receiver_id"] ?? json["sender_id"];
    if (receiverData is Map) {
      mediaHouseId = (receiverData["_id"] ?? "").toString();
      mediaHouseName = json["message_type"] == "PaymentIntent"
          ? json["user_info"] != null
              ? json["user_info"]["company_name"]
              : ""
          : (receiverData["company_name"] ?? "").toString();
      mediaHouseImage = (receiverData["profile_image"] ?? "").toString();
    } else {
      mediaHouseId = receiverData.toString();
      mediaHouseName = "";
      mediaHouseImage = "";
    }
    transactionId = json["transaction_id"] ?? "";
    message = (json["message"] ?? "").toString();
    if (json["options"] != null) {
      options = List<String>.from(json["options"]);
    }
  }
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
  String message = "";
  List<String> options = [];
  TextEditingController priceController = TextEditingController();
  TextEditingController ratingReviewController = TextEditingController();

  // Local upload tracking fields
  bool isLocalUpload = false;
  int uploadProgress = 0;
  String uploadStatus = ""; // 'uploading', 'processing', 'completed', 'failed'

  // Constructor for local uploads
  ManageTaskChatModel.forLocalUpload({
    required this.id,
    required this.roomId,
    required this.mediaList,
    required this.messageType,
    this.uploadStatus = 'starting',
    this.uploadProgress = 0,
  }) {
    isLocalUpload = true;
    createdAtTime = DateTime.now().toIso8601String();
    // Initialize counts from mediaList
    int imgC = 0, vidC = 0, audC = 0;
    for (var m in mediaList) {
      if (m.type.contains("video")) {
        vidC++;
      } else if (m.type.contains("audio")) {
        audC++;
      } else {
        imgC++;
      }
    }
    imageCount = imgC.toString();
    videoCount = vidC.toString();
    audioCount = audC.toString();
    if (mediaList.isNotEmpty) {
      media = mediaList.first;
    }
  }

  // Serialize to local JSON for DB storage
  Map<String, dynamic> toLocalJson() {
    return {
      'id': id,
      'roomId': roomId,
      'messageType': messageType,
      'isLocalUpload': isLocalUpload,
      'uploadProgress': uploadProgress,
      'uploadStatus': uploadStatus,
      'createdAtTime': createdAtTime,
      'imageCount': imageCount,
      'videoCount': videoCount,
      'audioCount': audioCount,
      'mediaList': mediaList
          .map(
            (m) => {
              'type': m.type,
              'media': m.imageVideoUrl,
              'thumbnail': m.thumbnail,
            },
          )
          .toList(),
    };
  }

  // Deserialize from local JSON
  ManageTaskChatModel.fromLocalJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    roomId = json['roomId'] ?? '';
    messageType = json['messageType'] ?? '';
    isLocalUpload = json['isLocalUpload'] ?? false;
    uploadProgress = json['uploadProgress'] ?? 0;
    uploadStatus = json['uploadStatus'] ?? '';
    createdAtTime = json['createdAtTime'] ?? '';
    imageCount = json['imageCount'] ?? '0';
    videoCount = json['videoCount'] ?? '0';
    audioCount = json['audioCount'] ?? '0';

    if (json['mediaList'] != null) {
      var data = json['mediaList'] as List;
      mediaList = data
          .map(
            (e) => TaskVideoModel(
              type: e['type'] ?? '',
              imageVideoUrl: e['media'] ?? '',
              thumbnail: e['thumbnail'] ?? '',
            ),
          )
          .toList();
      if (mediaList.isNotEmpty) {
        media = mediaList.first;
      }
    }
  }
}
