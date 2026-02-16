import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/error/api_error_handler.dart';
import 'package:presshop/core/error/exceptions.dart';
import 'package:presshop/features/map/domain/entities/route_info.dart';
import 'package:presshop/features/map/data/models/marker_model.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:presshop/core/services/location_service.dart';
import 'package:presshop/main.dart';

abstract class MapRemoteDataSource {
  Future<RouteInfo> getRoute(LatLng start, LatLng end);
  Future<List<Map<String, dynamic>>> getPlaceSuggestions(String input);
  Future<LatLng> getPlaceDetails(String placeId);
  Future<LatLng> getCurrentLocation();
  Future<List<Incident>> getIncidents();
  Future<void> reportIncident(Map<String, dynamic> data);
  Future<String> getAddressFromCoordinates(LatLng position);
}

class MapRemoteDataSourceImpl implements MapRemoteDataSource {
  MapRemoteDataSourceImpl({
    required this.apiClient,
    required this.googleApiKey,
    required this.locationService,
  });
  final ApiClient apiClient;
  final String googleApiKey;
  final LocationService locationService;

  @override
  Future<RouteInfo> getRoute(LatLng start, LatLng end) async {
    try {
      final url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&mode=driving&key=$googleApiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw ServerException('HTTP Error: ${response.statusCode}');
      }

      final data = json.decode(response.body);

      if (data['status'] != 'OK') {
        throw ServerException('Google Directions Error: ${data['status']}');
      }

      final route = data['routes'][0];
      final leg = route['legs'][0];

      // Get distance in meters and convert to km
      final distanceMeters = leg['distance']['value'] as int;
      final distanceKm = distanceMeters / 1000.0;

      // Get duration in seconds and convert to minutes
      final durationSeconds = leg['duration']['value'] as int;
      final durationMinutes = (durationSeconds / 60).round();

      // Decode polyline to get actual route points
      final encodedPolyline = route['overview_polyline']['points'];
      final points = _decodePolyline(encodedPolyline);

      return RouteInfo(
        points: points,
        distanceKm: distanceKm,
        durationMinutes: durationMinutes,
      );
    } catch (e) {
      throw ServerException('Failed to get route: $e');
    }
  }

  // Decode Google's encoded polyline format
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  @override
  Future<List<Map<String, dynamic>>> getPlaceSuggestions(String input) async {
    // Mock Data
    return [
      {'description': 'Mock Place 1', 'place_id': '1'},
      {'description': 'Mock Place 2', 'place_id': '2'},
    ];
  }

  @override
  Future<LatLng> getPlaceDetails(String placeId) async {
    // Mock Data
    return const LatLng(51.5074, -0.1278); // London
  }

  @override
  Future<LatLng> getCurrentLocation() async {
    try {
      final context = navigatorKey.currentContext;
      if (context == null) {
        throw LocationException('Navigator context not available');
      }

      final locationData = await locationService.getCurrentLocation(
        context,
        shouldShowSettingPopup: false,
      );

      if (locationData == null) {
        throw LocationException('Failed to get current location');
      }

      if (locationData.latitude == null || locationData.longitude == null) {
        throw LocationException('Location data is incomplete');
      }

      return LatLng(locationData.latitude!, locationData.longitude!);
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<List<Incident>> getIncidents() async {
    try {
      final response = await apiClient.get(
        ApiConstantsNew
            .chat.getAlertIncidents, // Use Chat class where we added it
      );

      List<dynamic> data = [];
      if (response.data is Map<String, dynamic> &&
          response.data.containsKey('data')) {
        data = response.data['data'];
      } else if (response.data is List) {
        data = response.data;
      }

      return data.map((json) => Incident.fromJson(json)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  @override
  Future<void> reportIncident(Map<String, dynamic> data) async {
    // Mock implementation
  }

  @override
  Future<String> getAddressFromCoordinates(LatLng position) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleApiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        return data['results'][0]['formatted_address'] as String;
      }
    }
    return "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
  }
}
