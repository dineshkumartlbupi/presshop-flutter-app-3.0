import 'package:presshop/features/map/data/models/incident_model.dart';
import 'package:presshop/features/map/data/models/place_suggestion_model.dart';
import 'package:presshop/features/map/data/models/route_info_model.dart';
import 'package:presshop/features/map/domain/entities/geo_point.dart';

abstract class MapRemoteDataSource {
  Future<List<IncidentModel>> getIncidents();
  Future<IncidentModel> reportIncident(String alertType, GeoPoint position);
  Future<RouteInfoModel> getRoute(GeoPoint start, GeoPoint end);
  Future<List<PlaceSuggestionModel>> searchPlaces(String query);
  Future<GeoPoint> getPlaceDetails(String placeId);
  Future<String> getAddressFromCoordinates(GeoPoint position);
  Stream<IncidentModel> getIncidentStream();
}
