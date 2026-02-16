import 'package:equatable/equatable.dart';

class Review extends Equatable {
  const Review({
    required this.id,
    required this.newsName,
    required this.image,
    required this.dateTime,
    required this.date,
    required this.time,
    required this.ratingValue,
    required this.review,
    required this.senderType,
    required this.from,
    required this.to,
    required this.hopperImage,
    required this.userName,
    required this.totalEarning,
    required this.hopperCreatedAt,
    required this.featureList,
  });
  final String id;
  final String newsName;
  final String image; // MediaHouse image or Hopper image depending on flow?
  final String dateTime;
  final String date;
  final String time;
  final double ratingValue;
  final String review;
  final String senderType;
  final String from;
  final String to;
  final String hopperImage;
  final String userName;
  final String totalEarning;
  final String hopperCreatedAt;
  final List<String> featureList;

  @override
  List<Object?> get props => [
        id,
        newsName,
        ratingValue,
        review,
      ];

  Review copyWith({
    String? id,
    String? newsName,
    String? image,
    String? dateTime,
    String? date,
    String? time,
    double? ratingValue,
    String? review,
    String? senderType,
    String? from,
    String? to,
    String? hopperImage,
    String? userName,
    String? totalEarning,
    String? hopperCreatedAt,
    List<String>? featureList,
  }) {
    return Review(
      id: id ?? this.id,
      newsName: newsName ?? this.newsName,
      image: image ?? this.image,
      dateTime: dateTime ?? this.dateTime,
      date: date ?? this.date,
      time: time ?? this.time,
      ratingValue: ratingValue ?? this.ratingValue,
      review: review ?? this.review,
      senderType: senderType ?? this.senderType,
      from: from ?? this.from,
      to: to ?? this.to,
      hopperImage: hopperImage ?? this.hopperImage,
      userName: userName ?? this.userName,
      totalEarning: totalEarning ?? this.totalEarning,
      hopperCreatedAt: hopperCreatedAt ?? this.hopperCreatedAt,
      featureList: featureList ?? this.featureList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'newsName': newsName,
      'image': image,
      'dateTime': dateTime,
      'date': date,
      'time': time,
      'ratingValue': ratingValue,
      'review': review,
      'senderType': senderType,
      'from': from,
      'to': to,
      'hopperImage': hopperImage,
      'userName': userName,
      'totalEarning': totalEarning,
      'hopperCreatedAt': hopperCreatedAt,
      'featureList': featureList,
    };
  }
}
