import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presshop/features/map/domain/entities/map_marker.dart';

class MapMarkerModel extends MapMarker {
  const MapMarkerModel({
    required super.id,
    required super.position,
    required super.title,
    required super.description,
    required super.type,
  });

  factory MapMarkerModel.fromJson(Map<String, dynamic> json) {
    return MapMarkerModel(
      id: json['id'] ?? '',
      position: LatLng(
        (json['lat'] as num).toDouble(),
        (json['lng'] as num).toDouble(),
      ),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'news',
    );
  }
}
