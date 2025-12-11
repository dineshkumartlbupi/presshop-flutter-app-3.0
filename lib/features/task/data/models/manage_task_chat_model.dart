
import 'package:flutter/material.dart';
import 'package:presshop/core/utils/common_utils.dart';
import 'package:presshop/features/task/data/models/task_models.dart';

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
