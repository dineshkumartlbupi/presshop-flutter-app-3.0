import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presshop/core/api/global_socket_client.dart';
import 'package:presshop/core/api/socket_constants.dart';

class IncidentSocketDataSource {
  final GlobalSocketClient _client;

  IncidentSocketDataSource({required GlobalSocketClient client})
      : _client = client;

  Function(dynamic)? onIncidentNew;
  Function(dynamic)? onIncidentUpdated;
  Function(dynamic)? onIncidentCreated;

  bool get isInitialized => _client.isInitialized;

  void initSocket({required String userId, required String userType}) {
    _client.initSocket(userId: userId, userType: userType);
  }

  void initializeListeners() {
    _client.on(SocketEvents.incidentNew, (data) {
      debugPrint(
          "IncidentSocketDataSource: incident:new received (data length: ${data?.toString().length})");
      onIncidentNew?.call(data);
    });

    _client.on(SocketEvents.incidentUpdated, (data) {
      debugPrint(
          "IncidentSocketDataSource: incident:updated received (data length: ${data?.toString().length})");
      onIncidentUpdated?.call(data);
    });

    _client.on(SocketEvents.incidentCreated, (data) {
      debugPrint(
          "IncidentSocketDataSource: incident:created received (data length: ${data?.toString().length})");
      onIncidentCreated?.call(data);
    });
  }

  void emitAlert({
    required String alertType,
    required LatLng position,
    String message = "",
    String address = "",
    required String userId,
  }) {
    debugPrint(":::: Inside IncidentSocketDataSource Emit Alert :::::");
    final Map<String, dynamic> data = {
      "userId": userId,
      "message": message,
      "type": alertType,
      "lat": position.latitude,
      "lng": position.longitude,
      "severity": "low",
      "address": address,
    };

    debugPrint("Emit Socket Alert : $data");
    _client.emit(SocketEvents.incidentCreate, data);
  }

  void dispose() {
    _client.off(SocketEvents.incidentNew);
    _client.off(SocketEvents.incidentUpdated);
    _client.off(SocketEvents.incidentCreated);
  }
}
