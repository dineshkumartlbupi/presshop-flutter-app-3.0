import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/map/domain/entities/geo_point.dart';
import 'package:presshop/features/map/domain/entities/incident_entity.dart';
import 'package:presshop/features/map/domain/entities/route_info_entity.dart';
import 'package:presshop/features/map/domain/entities/place_suggestion_entity.dart';

abstract class MapRepository {
  Future<Either<Failure, GeoPoint>> getCurrentLocation();
  Future<Either<Failure, List<IncidentEntity>>> getIncidents();
  Future<Either<Failure, IncidentEntity>> reportIncident(String alertType, GeoPoint position);
  Future<Either<Failure, RouteInfoEntity>> getRoute(GeoPoint start, GeoPoint end);
  Future<Either<Failure, List<PlaceSuggestionEntity>>> searchPlaces(String query);
  Future<Either<Failure, GeoPoint>> getPlaceDetails(String placeId);
  Future<Either<Failure, String>> getAddressFromCoordinates(GeoPoint position);
  Stream<IncidentEntity> getIncidentStream();
}
