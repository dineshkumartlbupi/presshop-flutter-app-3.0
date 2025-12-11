import 'package:flutter/foundation.dart';

class AlertModel {
  String id = "";
  String description = "";
  String location = "";
  String image = "";
  String distance = "";
  String createdAt = "";
  String miles = "";
  String byFeet = "";
  String byCar = "";
  bool isEmergency = false;
  String minEarning = "";
  String maxEarning = "";
  LocationModel? locationData;

  AlertModel({
    required this.id,
    required this.description,
    required this.location,
    required this.image,
    required this.distance,
    required this.createdAt,
    required this.miles,
    required this.byFeet,
    required this.byCar,
    required this.isEmergency,
    required this.minEarning,
    required this.maxEarning,
    required this.locationData,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    double dis = 0.0;
    String miles = "";
    String byFeet = "";
    String byCar = "";
    calculateTravelDetails(double distanceInMeters) {
      double distanceInMiles = distanceInMeters / 1609.34;
      double distanceInFeet = distanceInMeters * 3.28084;
      double averageSpeedKmh = 60.0;
      double averageSpeedFeetPerMinute =
          (averageSpeedKmh * 1000 * 3.28084) / 60.0;
      double timeByCarInMinutes =
          (distanceInMeters / 1000) / averageSpeedKmh * 60;
      double timeByFeetInMinutes = distanceInFeet / averageSpeedFeetPerMinute;
      String formattedTime;
      String formattedCarTime;
      if (timeByFeetInMinutes >= 60) {
        int hours = timeByFeetInMinutes ~/ 60;
        int hour = timeByCarInMinutes ~/ 60;
        double minutes = timeByFeetInMinutes.round() % 60;
        double minute = timeByCarInMinutes.round() % 60;
        // The original code calculated minutes but didn't use them in the formatted string, preserving behavior.
        formattedTime = "$hours h ";
        formattedCarTime = "$hour h";
      } else {
        formattedTime = "${timeByFeetInMinutes.round().toString()} min";
        formattedCarTime = "${timeByCarInMinutes.round().toString()} min";
      }
      miles = "${distanceInMiles.round().toString()} mi";
      byFeet = formattedTime.toString();
      byCar = formattedCarTime.toString();

      debugPrint(
          "Distance in Miles: ${distanceInMiles.toStringAsFixed(2)} miles");
      debugPrint(
          "Estimated Travel Time by Car (using meters): $formattedCarTime minutes");
      debugPrint(
          "Total Time Taken (using feet): $formattedTime to cover the distance in feet");
    }

    if (json['distance'] != null && json['distance'].toString().isNotEmpty) {
      if (json['distance'] is num) {
        dis = (json['distance'] as num).toDouble();
      } else {
         dis = double.tryParse(json['distance'].toString()) ?? 0.0;
      }
      calculateTravelDetails(dis);
    }
    return AlertModel(
        id: json['_id'] ?? "",
        description: json['title'] ?? "",
        location: json['address'] ?? "",
        image: json['image'] ?? "",
        distance: dis.toString(),
        createdAt: json['createdAt'] ?? "",
        miles: miles,
        byFeet: byFeet,
        byCar: byCar,
        isEmergency: json['is_emergency'] ?? false,
        minEarning: json['min_earning'].toString(),
        maxEarning: json['max_earning'].toString(),
        locationData: json['location'] != null
            ? LocationModel.fromJson(json['location'])
            : LocationModel());
  }
}

class LocationModel {
  String? type;
  List<double>? coordinates;

  LocationModel({
    this.type,
    this.coordinates,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      type: json['type'] ?? '',
      coordinates: (json['coordinates'] != null)
          ? json['coordinates'].cast<double>()
          : [],
    );
  }
}
