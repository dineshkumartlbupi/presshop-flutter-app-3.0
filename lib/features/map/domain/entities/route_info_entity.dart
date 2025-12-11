import 'package:equatable/equatable.dart';
import 'package:presshop/features/map/domain/entities/geo_point.dart';

class RouteInfoEntity extends Equatable {
  final List<GeoPoint> points;
  final double distanceKm;
  final int durationMinutes;

  const RouteInfoEntity({
    required this.points,
    required this.distanceKm,
    required this.durationMinutes,
  });

  String get formattedDistance => '${distanceKm.toStringAsFixed(1)} km';
  String get formattedDuration => '$durationMinutes min';
  String get formattedInfo => '$formattedDistance • $formattedDuration';

  @override
  List<Object?> get props => [points, distanceKm, durationMinutes];
}
