import 'package:google_maps_flutter/google_maps_flutter.dart';

class Incident {
  final String id;
  final String markerType; // "icon", "content", "hopper"
  final String? type; // e.g. accident, fire (only for icon)
  final LatLng position;
  final String? address;
  final String? time;
  final String? image; // For content/hopper markers
  final String? title;
  final String? description;
  final String? name;
  final String? rating;
  final String? specialization;
  final String? distance;
  final String? statusColor;
  final String? category; // e.g. "Accident", "Crime", "Event"
  final String? alertType; // e.g. "Alert", "Info", "Warning"

  Incident({
    required this.id,
    required this.markerType,
    required this.position,
    this.type,
    this.address,
    this.time,
    this.image,
    this.title,
    this.description,
    this.name,
    this.rating,
    this.specialization,
    this.distance,
    this.statusColor,
    this.category,
    this.alertType,
  });

  factory Incident.fromMap(Map<String, dynamic> map) {
    final pos = map['position'] as Map<String, dynamic>;
    return Incident(
      id: map['id'],
      markerType: map['markerType'],
      type: map['type'],
      position: LatLng(pos['lat'], pos['lng']),
      address: map['address'],
      time: map['time'],
      image: map['image'],
      title: map['title'],
      description: map['description'],
      name: map['name'],
      rating: map['rating'],
      specialization: map['specialization'],
      distance: map['distance'],
      statusColor: map['statusColor'],
      category: map['category'],
      alertType: map['alertType'],
    );
  }

  factory Incident.fromJson(Map<String, dynamic> json) {
    double lat = 0.0;
    double lng = 0.0;

    if (json['position'] != null) {
      lat = (json['position']['lat'] ?? 0.0).toDouble();
      lng = (json['position']['lng'] ?? 0.0).toDouble();
    } else {
      lat = (json['lat'] ?? json['latitude'] ?? 0.0).toDouble();
      lng = (json['lng'] ?? json['longitude'] ?? 0.0).toDouble();
    }

    return Incident(
      id:
          json['_id'] ??
          json['id'] ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      markerType: json['markerType'] ?? 'icon',
      type: json['type'] ?? 'accident',
      position: LatLng(lat, lng),
      address: json['address'],
      time: json['createdAt'] ?? json['time'],
      image: json['image'],
      title: json['title'],
      description: json['description'] ?? json['message'],
      name: json['name'],
      rating: json['rating'],
      specialization: json['specialization'],
      distance: json['distance'],
      statusColor: json['statusColor'],
      category: json['category'],
      alertType: json['alertType'],
    );
  }
}

class DangerZone {
  final String id;
  final String name;
  final String description;
  final List<LatLng> points;
  final String? icon;

  DangerZone({
    required this.id,
    required this.name,
    required this.description,
    required this.points,
    this.icon,
  });
}

class Listing {
  final String id;
  final String title;
  final String subtitle;
  final LatLng location;
  final String imageUrl;

  Listing({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.imageUrl,
  });
}

class LocationModel {
  LatLng? currentPosition;
  LatLng? targetPosition;
  double? distance;

  LocationModel({this.currentPosition, this.targetPosition, this.distance});
}
