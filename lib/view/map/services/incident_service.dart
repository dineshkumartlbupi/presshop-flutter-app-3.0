import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:presshop/view/map/models/marker_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

const SOCKET_URL = 'https://dev-api.presshop.news:3005';
const BASE_URL = "https://dev-api.presshop.news:5019/";

class IncidentService extends ChangeNotifier {
  List<Incident> incidents = [];
  IO.Socket? socket;

  final String userId;
  final String joinAs; // "website" | "admin" | "hopper" | "user"

  IncidentService({required this.userId, required this.joinAs}) {
    fetchInitialIncidents();
    connectSocket();
  }

  // ========= Fetch initial data =========
  Future<void> fetchInitialIncidents() async {
    try {
      final res = await http.get(
        Uri.parse("${BASE_URL}mediahouse/getAlertIncidents"),
      );

      final List<dynamic> data = jsonDecode(res.body);

      incidents = data.map((j) => Incident.fromJson(j)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching incidents: $e");
    }
  }

  // ========= SOCKET CONNECTION =========
  void connectSocket() {
    socket = IO.io(
      SOCKET_URL,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      debugPrint("Socket connected: ${socket!.id}");

      if (joinAs == "website") socket!.emit("joinWebsite");
      if (joinAs == "admin") socket!.emit("joinAdmin", userId);
      if (joinAs == "hopper") socket!.emit("joinHopper", userId);
      if (joinAs == "user") socket!.emit("joinUser", userId);
    });

    socket!.on("incident:new", (data) {
      final incident = Incident.fromJson(data);

      // avoid duplicates
      if (!incidents.any((i) => i.id == incident.id)) {
        incidents.insert(0, incident);
        notifyListeners();
      }
    });

    socket!.on("incident:updated", (data) {
      final updated = Incident.fromJson(data);

      incidents = incidents.map((i) {
        return i.id == updated.id ? updated : i;
      }).toList();

      notifyListeners();
    });

    socket!.on("incident:created", (data) {
      final inc = Incident.fromJson(data);
      incidents.insert(0, inc);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    socket?.disconnect();
    super.dispose();
  }
}
