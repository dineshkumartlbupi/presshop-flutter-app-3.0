import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;
  final String _socketUrl = 'https://dev-api.presshop.news:3005';

  // Callbacks for events
  Function(dynamic)? onIncidentNew;
  Function(dynamic)? onIncidentUpdated;
  Function(dynamic)? onIncidentCreated;

  void initSocket({
    required String userId,
    required String joinAs, // "website" | "admin" | "hopper" | "user"
  }) {
    debugPrint(":::: Inside Socket Func :::::");
    debugPrint("socketUrl:::::$_socketUrl");

    socket = IO.io(
      _socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    debugPrint("Socket Disconnect : ${socket.disconnected}");

    socket.connect();

    socket.onConnect((_) {
      debugPrint('Connected to socket: ${socket.id}');

      if (joinAs == "website") socket.emit("joinWebsite");
      if (joinAs == "admin") socket.emit("joinAdmin", userId);
      if (joinAs == "hopper") socket.emit("joinHopper", userId);
      if (joinAs == "user") socket.emit("joinUser", userId);
    });

    socket.onDisconnect((_) => debugPrint('Disconnected from socket'));
    socket.onError((data) => debugPrint("Error Socket ::: $data"));

    // Listen for incident events
    socket.on("incident:new", (data) {
      debugPrint("Socket: incident:new received");
      onIncidentNew?.call(data);
    });

    socket.on("incident:updated", (data) {
      debugPrint("Socket: incident:updated received");
      onIncidentUpdated?.call(data);
    });

    socket.on("incident:created", (data) {
      debugPrint("Socket: incident:created received");
      onIncidentCreated?.call(data);
    });
  }

  void emitAlert({
    required String alertType,
    required LatLng position,
    String message = "",
    required String userId,
  }) {
    debugPrint(":::: Inside Socket Emit Alert :::::");
    final Map<String, dynamic> data = {
      "userId": userId,
      "message": message,
      "type": alertType,
      "lat": position.latitude,
      "lng": position.longitude,
      "severity": "low",
    };

    debugPrint("Emit Socket Alert : $data");
    print("Emit Socket Alert : $data");

    socket.emit("incident:create", data);
  }

  void dispose() {
    socket.dispose();
  }
}
