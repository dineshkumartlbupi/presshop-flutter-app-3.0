import 'package:presshop/core/core_export.dart';
import 'package:presshop/features/task/domain/entities/broadcast_data.dart';

class BroadcastDataModel extends BroadcastData {
  const BroadcastDataModel({
    required super.broadcastedId,
    required super.headline,
    required super.taskDescription,
    required super.specialRequirements,
    required super.photoPrice,
    required super.videoPrice,
    required super.interviewPrice,
    required super.location,
    required super.deadLineDate,
    required super.deadLine,
    required super.mediaHouseName,
    required super.mediaHouseImage,
    required super.mediaHouseId,
    required super.latitude,
    required super.longitude,
    required super.showPhotoPrice,
    required super.showVideoPrice,
    required super.showInterviewPrice,
    required super.minimumPriceRange,
    required super.maximumPriceRange,
  });

  factory BroadcastDataModel.fromJson(Map<String, dynamic> json) {
    String mediaHouseName = "";
    String mediaHouseImage = "";
    String mediaHouseId = "";
    String maximumPriceRange = "";
    String minimumPriceRange = "";
    double latitude = 0;
    double longitude = 0;

    if (json["mediahouse_id"] != null &&
        json["mediahouse_id"] is Map<String, dynamic>) {
      if (json["mediahouse_id"]["admin_detail"] != null) {
        mediaHouseName =
            (json["mediahouse_id"]["company_name"] ?? "").toString();
        mediaHouseImage =
            (json["mediahouse_id"]["admin_detail"]["admin_profile"] ?? "")
                .toString();
        mediaHouseId = (json["mediahouse_id"]["_id"] ?? "").toString();
      }
      if (json['mediahouse_id']['admin_rignts'] != null) {
        if (json['mediahouse_id']['admin_rignts']['price_range'] != null) {
          maximumPriceRange = (json['mediahouse_id']['admin_rignts']
                      ['price_range']['maximum_price'] ??
                  "")
              .toString();
          minimumPriceRange = (json['mediahouse_id']['admin_rignts']
                      ['price_range']['minimum_price'] ??
                  "")
              .toString();
        }
      }
    }

    if (json["address_location"] != null &&
        json["address_location"]["coordinates"] != null) {
      var coordinatesList = json["address_location"]["coordinates"] as List;

      if (coordinatesList.isNotEmpty) {
        if (coordinatesList[0] is num) {
          latitude = (coordinatesList[0] as num).toDouble();
        }
        if (coordinatesList.length > 1 && coordinatesList[1] is num) {
          longitude = (coordinatesList[1] as num).toDouble();
        }
      }
    }

    return BroadcastDataModel(
      broadcastedId: (json["_id"] ?? "").toString(),
      headline: (json["heading"] ?? "").toString(),
      taskDescription: (json["task_description"] ?? "").toString(),
      specialRequirements: (json["any_spcl_req"] ?? "").toString(),
      location: (json["location"] ?? "").toString(),
      deadLineDate: (json["deadline_date"] ?? "").toString(),
      deadLine: DateTime.tryParse(dateTimeFormatter(
              dateTime: (json["deadline_date"] ?? "").toString(),
              format: "yyyy-MM-dd HH:mm:ss",
              time: true)) ??
          DateTime.now(),
      photoPrice: (json["photo_price"] ?? "").toString(),
      videoPrice: (json["videos_price"] ?? "").toString(),
      interviewPrice: (json["interview_price"] ?? "").toString(),
      mediaHouseName: mediaHouseName,
      mediaHouseImage: mediaHouseImage,
      mediaHouseId: mediaHouseId,
      latitude: latitude,
      longitude: longitude,
      showPhotoPrice: (json["need_photos"] ?? false),
      showVideoPrice: (json["need_videos"] ?? false),
      showInterviewPrice: (json["need_interview"] ?? false),
      minimumPriceRange: minimumPriceRange,
      maximumPriceRange: maximumPriceRange,
    );
  }
}
