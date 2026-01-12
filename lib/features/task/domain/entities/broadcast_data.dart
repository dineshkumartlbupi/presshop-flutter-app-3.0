import 'package:equatable/equatable.dart';

class BroadcastData extends Equatable {
  final String broadcastedId;
  final String headline;
  final String taskDescription;
  final String specialRequirements;
  final String photoPrice;
  final String videoPrice;
  final String interviewPrice;
  final String location;
  final String deadLineDate;
  final DateTime deadLine;
  final String mediaHouseName;
  final String mediaHouseImage;
  final String mediaHouseId;
  final double latitude;
  final double longitude;
  final bool showPhotoPrice;
  final bool showVideoPrice;
  final bool showInterviewPrice;
  final String minimumPriceRange;
  final String maximumPriceRange;

  const BroadcastData({
    required this.broadcastedId,
    required this.headline,
    required this.taskDescription,
    required this.specialRequirements,
    required this.photoPrice,
    required this.videoPrice,
    required this.interviewPrice,
    required this.location,
    required this.deadLineDate,
    required this.deadLine,
    required this.mediaHouseName,
    required this.mediaHouseImage,
    required this.mediaHouseId,
    required this.latitude,
    required this.longitude,
    required this.showPhotoPrice,
    required this.showVideoPrice,
    required this.showInterviewPrice,
    required this.minimumPriceRange,
    required this.maximumPriceRange,
  });

  @override
  List<Object?> get props => [
        broadcastedId,
        headline,
        taskDescription,
        specialRequirements,
        photoPrice,
        videoPrice,
        interviewPrice,
        location,
        deadLineDate,
        deadLine,
        mediaHouseName,
        mediaHouseImage,
        mediaHouseId,
        latitude,
        longitude,
        showPhotoPrice,
        showVideoPrice,
        showInterviewPrice,
        minimumPriceRange,
        maximumPriceRange,
      ];
}
