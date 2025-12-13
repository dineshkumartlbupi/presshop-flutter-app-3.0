import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/core/error/exceptions.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:presshop/features/map/data/datasources/map_remote_datasource.dart';
import 'package:presshop/features/map/data/models/incident_model.dart';
import 'package:presshop/features/map/data/models/place_suggestion_model.dart';
import 'package:presshop/features/map/data/models/route_info_model.dart';
import 'package:presshop/features/map/domain/entities/geo_point.dart';
import 'package:presshop/main.dart';
import 'package:presshop/features/map/presentation/pages/services/socket_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapRemoteDataSourceImpl implements MapRemoteDataSource {
  final Dio dio;
  final SocketService socketService;
  // Using the key found in existing code. Ideally should be in secure config.
  // Key is loaded from env via api_constant
  String get googleApiKey => googleMapAPiKey; 

  final _incidentStreamController = StreamController<IncidentModel>.broadcast();

  MapRemoteDataSourceImpl({required this.dio, required this.socketService}) {
    _initSocketListeners();
  }

  void _initSocketListeners() {
    final String userId = sharedPreferences!.getString(hopperIdKey).toString();
    socketService.initSocket(userId: userId, joinAs: "hopper");

    socketService.onIncidentNew = (data) {
      try {
        _incidentStreamController.add(IncidentModel.fromJson(data));
      } catch (e) {
        print('Error parsing socket incident: $e');
      }
    };
    
    // Also listen to 'updated' and 'created' if needed, mapping them to the same stream
    socketService.onIncidentUpdated = (data) {
       try {
        _incidentStreamController.add(IncidentModel.fromJson(data));
      } catch (e) {
        print('Error parsing socket incident update: $e');
      }
    };

    socketService.onIncidentCreated = (data) {
       try {
        _incidentStreamController.add(IncidentModel.fromJson(data));
      } catch (e) {
        print('Error parsing socket incident created: $e');
      }
    };
  }

  @override
  Future<List<IncidentModel>> getIncidents() async {
    try {
      final String token = sharedPreferences!.getString(tokenKey).toString();
      // Using direct full URL because of unknown config for ApiClient
      final response = await dio.get(
        "https://dev-api.presshop.news:5019/hopper/getAlertIncidents",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is String ? jsonDecode(response.data) : response.data;
        return data.map((json) => IncidentModel.fromJson(json)).toList();
      } else {
        throw ServerException("Failed to fetch incidents");
      }
    } catch (e) {
       throw ServerException(e.toString());
    }
  }

  @override
  Future<IncidentModel> reportIncident(String alertType, GeoPoint position) async {
    final String userId = sharedPreferences!.getString(hopperIdKey).toString();
    
    // Emit via socket as per existing implementation
    socketService.emitAlert(
      alertType: alertType,
      position: LatLng(position.latitude, position.longitude), // Convert to Google Maps LatLng as expected by existing SocketService
      userId: userId,
    );

    // Return a local temporary model, as socket is fire-and-forget mostly
    // or wait for socket reaction. Existing code just emits.
    return IncidentModel(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      markerType: 'icon',
      type: alertType,
      position: position,
      time: DateTime.now().toIso8601String(),
      alertType: 'Alert',
      category: 'User Alert',
      address: 'User reported alert',
    );
  }

  @override
  Future<RouteInfoModel> getRoute(GeoPoint start, GeoPoint end) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&mode=driving&key=$googleApiKey';

    final response = await http.get(Uri.parse(url)); // Keep using http for Google API to avoid auth header injection of Dio client
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        return RouteInfoModel.fromJson(data);
      } else {
        throw ServerException("Failed to get route");
      }
    } else {
      throw ServerException("Failed to get route");
    }
  }

  @override
  Future<List<PlaceSuggestionModel>> searchPlaces(String query) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$googleApiKey&types=geocode';
    
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        return (data['predictions'] as List)
            .map((p) => PlaceSuggestionModel.fromJson(p))
            .toList();
      }
      return [];
    } else {
      throw ServerException("Failed to search places");
    }
  }

  @override
  Future<GeoPoint> getPlaceDetails(String placeId) async {
     final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleApiKey';
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        final location = data['result']['geometry']['location'];
        return GeoPoint(location['lat'], location['lng']);
      }
      throw ServerException("Place not found");
    } else {
      throw ServerException("Failed to get place details");
    }
  }

  @override
  Future<String> getAddressFromCoordinates(GeoPoint position) async {
    final url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleApiKey';
    final response = await http.get(Uri.parse(url));
    
     if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'] as String;
        }
      }
      return '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
  }

  @override
  Stream<IncidentModel> getIncidentStream() {
    return _incidentStreamController.stream;
  }
}
