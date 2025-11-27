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
