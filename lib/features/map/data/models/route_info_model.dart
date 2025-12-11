import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:presshop/features/map/domain/entities/geo_point.dart';
import 'package:presshop/features/map/domain/entities/route_info_entity.dart';

class RouteInfoModel extends RouteInfoEntity {
  const RouteInfoModel({
    required super.points,
    required super.distanceKm,
    required super.durationMinutes,
  });

  factory RouteInfoModel.fromJson(Map<String, dynamic> json) {
    // This expects Google Directions API response structure for a LEG (or part of it)
    // Actually, MapService parses it before creating object.
    // Ideally, Model should parse raw JSON.
    // Let's assume this factory takes the parsed 'leg' AND 'overview_polyline' or similar.
    // However, keeping it simple to align with existing MapService logic which might be refactored into DataSource.

    // Let's assume raw Directions API "route" object is passed, but extracting points is tricky without logic.
    // We will handle specific parsing in DataSource for Google API, or defined rigid structure here.

    // For cleanliness, let's look at how MapService does it:
    // It gets `data['routes'][0]` -> `route`.
    // `leg = route['legs'][0]`
    // `overview_polyline` = route['overview_polyline']['points']

    final route = json['routes'][0];
    final leg = route['legs'][0];
    final distanceMeters = leg['distance']['value'] as int;
    final durationSeconds = leg['duration']['value'] as int;

    final encodedPolyline = route['overview_polyline']['points'];
    final resultPoints = PolylinePoints().decodePolyline(encodedPolyline);
    final points = resultPoints
        .map((p) => GeoPoint(p.latitude, p.longitude))
        .toList();

    return RouteInfoModel(
      points: points,
      distanceKm: distanceMeters / 1000.0,
      durationMinutes: (durationSeconds / 60).round(),
    );
  }
}
