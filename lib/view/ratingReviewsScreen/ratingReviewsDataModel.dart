import 'package:flutter/cupertino.dart';

class RatingReviewData {
  String newsName = "";
  String image = "";
  String dateTime = "";
  String date = "";
  String time = "";
  String ratingValue = '0.0';
  String id;
  String from;
  String to;
  String rating = "";
  String senderType;
  String review="";
  String hopperImage="";
  String userName="";
  String totalEarning="";
  String hopperCreatedAt="";
  List<String> featureList=[];


  // DateTime createdAt;
  // DateTime updatedAt;

  RatingReviewData({
    required this.newsName,
    required this.image,
    required this.dateTime,
    required this.date,
    required this.time,
    required this.ratingValue,
    required this.senderType,
    //  required this.createdAt,
    // required this.updatedAt,
    required this.id,
    required this.from,
    required this.to,
    required this.rating,
    required this.review,
    required this.featureList,
    required this.hopperImage,
    required this.userName,
    required this.totalEarning,
    required this.hopperCreatedAt,

  });

  factory RatingReviewData.fromJson(Map<String, dynamic> json) {
    return RatingReviewData(
      newsName: json['mediahouse_details'] != null
          ? json['mediahouse_details']['company_name']
          : '',
      image: json['mediahouse_details'] != null
          ? json['mediahouse_details']['profile_image']
          : '',
      dateTime: json['updateddata']!=null?json['updateddata']['createdAt'].toString():"",
      date: json['updateddata']!=null?json['updateddata']['createdAt'].toString():"",
      time: json['updateddata']!=null?json['updateddata']['createdAt'].toString():"",
      ratingValue: json["updateddata"] != null? json['updateddata']['rating'].toString() : "0.0",
      review: json["updateddata"] != null? json['updateddata']['review'].toString() : "",
      id: json["_id"] ?? "",
      from: json["from"] ?? "",
      to: json["to"] ?? "",
      rating: json["rating"].toString(),
      senderType: json["sender_type"] ?? "",
      totalEarning: json["total_earining"].toString(),

      hopperImage:json['hopper_details']['avatar_id']['avatar'].toString(),
      userName:json['hopper_details']!=null?json['hopper_details']['user_name']:"",
      hopperCreatedAt:json['hopper_details']!=null?json['hopper_details']['createdAt']:"",
        featureList :List<String>.from(json['updateddata']['features'] ?? []),

    //  updatedAT: dateTimeFormatter(dateTime: json['updatedAt']),
    );
  }
}

class FilterRatingData {
  double ratingValue = 0;
  bool selected = false;

  FilterRatingData({required this.ratingValue, required this.selected});
}


