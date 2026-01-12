import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:presshop/core/error/api_error_handler.dart';
import 'package:presshop/core/error/exceptions.dart';
import 'package:presshop/features/map/domain/entities/route_info.dart';
import 'package:presshop/features/map/domain/entities/map_marker.dart';

abstract class MapRemoteDataSource {
  Future<RouteInfo> getRoute(LatLng start, LatLng end);
  Future<List<Map<String, dynamic>>> getPlaceSuggestions(String input);
  Future<LatLng> getPlaceDetails(String placeId);
  Future<LatLng> getCurrentLocation();
  Future<List<MapMarker>> getIncidents();
  Future<void> reportIncident(Map<String, dynamic> data);
}

class MapRemoteDataSourceImpl implements MapRemoteDataSource {
  final http.Client client;
  final String googleApiKey;

  MapRemoteDataSourceImpl({required this.client, required this.googleApiKey});

  @override
  Future<RouteInfo> getRoute(LatLng start, LatLng end) async {
    /*
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&mode=driving&key=$googleApiKey';

    final response = await client.get(Uri.parse(url));
    if (response.statusCode != 200) throw ServerException();

    final data = json.decode(response.body);
    if (data['status'] != 'OK') throw ServerException();

    final route = data['routes'][0];
    final leg = route['legs'][0];

    final distanceMeters = leg['distance']['value'] as int;
    final distanceKm = distanceMeters / 1000.0;

    final durationSeconds = leg['duration']['value'] as int;
    final durationMinutes = (durationSeconds / 60).round();

    final encodedPolyline = route['overview_polyline']['points'];
    final resultPoints = PolylinePoints.decodePolyline(encodedPolyline);
    final points =
        resultPoints.map((p) => LatLng(p.latitude, p.longitude)).toList();

    return RouteInfo(
      points: points,
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
    );
    */
    // Mock Data
    return RouteInfo(
      points: [start, end],
      distanceKm: 5.0,
      durationMinutes: 15,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getPlaceSuggestions(String input) async {
    /*
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$googleApiKey';
    final response = await client.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      return (data['predictions'] as List)
          .map((p) =>
              {'description': p['description'], 'place_id': p['place_id']})
          .toList();
    }
    return [];
    */
    // Mock Data
    return [
      {'description': 'Mock Place 1', 'place_id': '1'},
      {'description': 'Mock Place 2', 'place_id': '2'},
    ];
  }

  @override
  Future<LatLng> getPlaceDetails(String placeId) async {
    /*
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleApiKey';
    final response = await client.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      final location = data['result']['geometry']['location'];
      return LatLng(location['lat'], location['lng']);
    }
    throw ServerException();
    */
    // Mock Data
    return const LatLng(51.5074, -0.1278); // London
  }

  @override
  Future<LatLng> getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationException('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw LocationException('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationException(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(pos.latitude, pos.longitude);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<List<MapMarker>> getIncidents() async {
    // Mock implementation
    return [];
  }

  @override
  Future<void> reportIncident(Map<String, dynamic> data) async {
    // Mock implementation
  }
}
