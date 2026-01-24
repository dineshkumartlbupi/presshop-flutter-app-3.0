import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/error/api_error_handler.dart';
import 'package:presshop/core/error/exceptions.dart';
import 'package:presshop/features/map/domain/entities/route_info.dart';
import 'package:presshop/features/map/domain/entities/map_marker.dart';
import 'package:presshop/features/map/data/models/marker_model.dart';
import 'package:presshop/core/api/api_constant_new.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  final ApiClient apiClient;
  final String googleApiKey;

  MapRemoteDataSourceImpl(
      {required this.apiClient, required this.googleApiKey});

  @override
  Future<RouteInfo> getRoute(LatLng start, LatLng end) async {
    // Mock Data
    return RouteInfo(
      points: [start, end],
      distanceKm: 5.0,
      durationMinutes: 15,
    );
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
  Future<List<Incident>> getIncidents() async {
    try {
      final response = await apiClient.get(
        ApiConstantsNew
            .chat.getAlertIncidents, // Use Chat class where we added it
      );

      final List<dynamic> data = response.data;
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
