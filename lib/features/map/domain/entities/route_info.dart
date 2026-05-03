import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteInfo extends Equatable {

  const RouteInfo({
    required this.points,
    required this.distanceKm,
    required this.durationMinutes,
  });
  final List<LatLng> points;
  final double distanceKm;
  final int durationMinutes;

  String get formattedDistance => '${distanceKm.toStringAsFixed(1)} km';
  String get formattedDuration => '$durationMinutes min';
  String get formattedInfo => '$formattedDistance • $formattedDuration';

  @override
  List<Object?> get props => [points, distanceKm, durationMinutes];
}
