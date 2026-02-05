import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarker extends Equatable { // e.g., 'news', 'event', 'user'

  const MapMarker({
    required this.id,
    required this.position,
    required this.title,
    required this.description,
    required this.type,
  });
  final String id;
  final LatLng position;
  final String title;
  final String description;
  final String type;

  @override
  List<Object?> get props => [id, position, title, description, type];
}
