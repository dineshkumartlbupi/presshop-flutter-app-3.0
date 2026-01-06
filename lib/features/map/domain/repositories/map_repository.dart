import 'package:dartz/dartz.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presshop/core/error/failures.dart';

import 'package:presshop/features/map/domain/entities/route_info.dart';
import 'package:presshop/features/map/domain/entities/map_marker.dart';

abstract class MapRepository {
  Future<Either<Failure, RouteInfo>> getRoute(LatLng start, LatLng end);
  Future<Either<Failure, List<Map<String, dynamic>>>> getPlaceSuggestions(
      String input);
  Future<Either<Failure, LatLng>> getPlaceDetails(String placeId);
  Future<Either<Failure, LatLng>> getCurrentLocation();
  Future<Either<Failure, List<MapMarker>>> getIncidents();
  Future<Either<Failure, void>> reportIncident(Map<String, dynamic> data);
}
