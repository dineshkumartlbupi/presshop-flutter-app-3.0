import 'package:presshop/features/map/domain/entities/geo_point.dart';
import 'package:presshop/features/map/domain/entities/incident_entity.dart';

class IncidentModel extends IncidentEntity {
  const IncidentModel({
    required super.id,
    required super.markerType,
    required super.type,
    required super.position,
    super.address,
    super.time,
    super.image,
    super.title,
    super.description,
    super.name,
    super.rating,
    super.specialization,
    super.distance,
    super.statusColor,
    super.category,
    super.alertType,
  });

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    double lat = 0.0;
    double lng = 0.0;

    if (json['position'] != null) {
      if (json['position'] is Map) {
        lat = (json['position']['lat'] ?? 0.0).toDouble();
        lng = (json['position']['lng'] ?? 0.0).toDouble();
      } else if (json['position'] is List && json['position'].length >= 2) {
          // Sometimes GeoJSON is [lng, lat] or [lat, lng], usually [lng, lat] in Mongo
          // But looking at existing code:
          // lat = (json['position']['lat'] ?? 0.0).toDouble();
          // It seems strictly object structure. Keeping as is.
      }
    } else {
      lat = (json['lat'] ?? json['latitude'] ?? 0.0).toDouble();
      lng = (json['lng'] ?? json['longitude'] ?? 0.0).toDouble();
    }

    return IncidentModel(
      id: json['_id'] ??
          json['id'] ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      markerType: json['markerType'] ?? 'icon',
      type: json['type'] ?? 'accident',
      position: GeoPoint(lat, lng),
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'markerType': markerType,
      'type': type,
      'position': {
        'lat': position.latitude,
        'lng': position.longitude,
      },
      'address': address,
      'time': time,
      'image': image,
      'title': title,
      'description': description,
      'name': name,
      'rating': rating,
      'specialization': specialization,
      'distance': distance,
      'statusColor': statusColor,
      'category': category,
      'alertType': alertType,
    };
  }
}
