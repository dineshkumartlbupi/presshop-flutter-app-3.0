import 'package:equatable/equatable.dart';

class Review extends Equatable {
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

  @override
  List<Object?> get props => [
        id,
        newsName,
        ratingValue,
        review,
      ];
}
