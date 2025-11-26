import 'dart:math';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as image;
import 'package:presshop/view/mapView/models/marker_model.dart';

class MarkerService {
  final Map<String, String> markerIcons = {
    "accident": "assets/markers/carcrash.png",
    "fire": "assets/markers/fire.png",
    "medical": "assets/markers/medical.png",
    "gun": "assets/markers/gun.png",
    "protest": "assets/markers/fight.png",
    "knife": "assets/markers/knife.png",
    "fight": "assets/markers/fight.png",
    "content": "assets/markers/avatar.png",
    "hopper": "assets/markers/avatar.png",
  };

  final Random _random = Random();

  List<Map<String, dynamic>> get defaultIncidents => [
        // 1-10
        {
          "id": "incident-1",
          "markerType": "icon",
          "type": "gun",
          "position": {
            "lat": 37.794324 + (_random.nextDouble() - 0.5) * 0.01,
            "lng": -122.406192 + (_random.nextDouble() - 0.5) * 0.01,
          },
          "address": "Some Street 1",
          "time": "10:40 AM",
          "category": "Crime",
          "alertType": "Alert",
        },
        {
          "id": "incident-2",
          "markerType": "icon",
          "type": "fire",
          "position": {
            "lat": 37.788827 + (_random.nextDouble() - 0.5) * 0.01,
            "lng": -122.406829 + (_random.nextDouble() - 0.5) * 0.01,
          },
          "address": "Some Street 2",
          "time": "09:55 AM",
          "category": "Accident",
          "alertType": "Warning",
        },
        {
          "id": "incident-3",
          "markerType": "icon",
          "type": "medical",
          "position": {
            "lat": 37.788627 + (_random.nextDouble() - 0.5) * 0.01,
            "lng": -122.406829 + (_random.nextDouble() - 0.5) * 0.01,
          },
          "address": "Some Street 3",
          "time": "09:55 AM",
          "category": "Event",
          "alertType": "Info",
        },
        {
          "id": "incident-4",
          "markerType": "icon",
          "type": "protest",
          "position": {
            "lat": 37.7900 + (_random.nextDouble() - 0.5) * 0.01,
            "lng": -122.4070 + (_random.nextDouble() - 0.5) * 0.01,
          },
          "address": "Protest Street",
          "time": "12:00 PM",
        },
        {
          "id": "incident-5",
          "markerType": "icon",
          "type": "knife",
          "position": {
            "lat": 37.7920 + (_random.nextDouble() - 0.5) * 0.01,
            "lng": -122.4040 + (_random.nextDouble() - 0.5) * 0.01,
          },
          "address": "Knife Street",
          "time": "12:15 PM",
        },
        {
          "id": "incident-6",
          "markerType": "icon",
          "type": "fight",
          "position": {
            "lat": 37.7890 + (_random.nextDouble() - 0.5) * 0.01,
            "lng": -122.4020 + (_random.nextDouble() - 0.5) * 0.01,
          },
          "address": "Fight Street",
          "time": "12:30 PM",
        },
        {
          "id": "content-1",
          "markerType": "content",
          "position": {
            "lat": 37.781649 + (_random.nextDouble() - 0.5) * 0.01,
            "lng": -122.403173 + (_random.nextDouble() - 0.5) * 0.01,
          },
          "image":
              "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400",
          "title": "Beautiful Landscape",
          "description": "A stunning view of the countryside",
          "address": "Hyde Park",
          "time": "11:00 AM",
        },
        {
          "id": "content-2",
          "markerType": "content",
          "position": {
            "lat": 37.781649 + (_random.nextDouble() - 0.5) * 0.01,
            "lng": -122.403173 + (_random.nextDouble() - 0.5) * 0.01,
          },
          "image":
              "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400",
          "title": "Beautiful Landscape",
          "description": "A stunning view of the countryside",
          "address": "Hyde Park",
          "time": "11:00 AM",
        },
        {
          "id": "content-3",
          "markerType": "content",
          "position": {
            "lat": 37.781649 + (_random.nextDouble() - 0.5) * 0.01,
            "lng": -122.403173 + (_random.nextDouble() - 0.5) * 0.01,
          },
          "image":
              "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400",
          "title": "Beautiful Landscape",
          "description": "A stunning view of the countryside",
          "address": "Hyde Park",
          "time": "11:00 AM",
        },
        {
          "id": "hopper-4",
          "markerType": "hopper",
          "position": {
            "lat": 37.778527 + (_random.nextDouble() - 0.5) * 0.01,
            "lng": -122.409866 + (_random.nextDouble() - 0.5) * 0.01,
          },
          "image":
              "https://firebasestorage.googleapis.com/v0/b/perdaycoaching.appspot.com/o/Group%209.png?alt=media&token=577ffc4f-6616-442a-8336-5ea2d0998de4",
          "name": "John Doe",
          "rating": "4.8",
          "specialization": "Emergency Response",
          "distance": "0.5 miles",
          "address": "Oxford Street",
          "statusColor": "#10b981",
        },
        {
          "id": "incident-7",
          "markerType": "icon",
          "type": "gun",
          "position": {
            "lat": 37.7870 + (_random.nextDouble() - 0.5) * 0.01,
            "lng": -122.4080 + (_random.nextDouble() - 0.5) * 0.01,
          },
          "address": "Gun Street",
          "time": "12:45 PM",
        },
        {
          "id": "incident-8",
          "markerType": "icon",
          "type": "fire",
          "position": {
            "lat": 37.7865 + (_random.nextDouble() - 0.5) * 0.01,
            "lng": -122.4090 + (_random.nextDouble() - 0.5) * 0.01,
          },
          "address": "Fire Street",
          "time": "01:00 PM",
        },

        // 11-20
        {
          "id": "incident-9",
          "markerType": "icon",
          "type": "accident",
          "position": {
            "lat": 37.7850 + (_random.nextDouble() - 0.5) * 0.01,
            "lng": -122.4100 + (_random.nextDouble() - 0.5) * 0.01,
          },
          "address": "Medical Street",
          "time": "01:15 PM",
        },
        {
          "id": "incident-10",
          "markerType": "icon",
          "type": "protest",
          "position": {
            "lat": 37.7840 + (_random.nextDouble() - 0.5) * 0.01,
            "lng": -122.4110 + (_random.nextDouble() - 0.5) * 0.01,
          },
          "address": "Protest Street 2",
          "time": "01:30 PM",
        },
        {
          "id": "incident-11",
          "markerType": "icon",
          "type": "knife",
          "position": {
            "lat": 37.7830 + (_random.nextDouble() - 0.5) * 0.01,
            "lng": -122.4120 + (_random.nextDouble() - 0.5) * 0.01,
          },
          "address": "Knife Street 2",
          "time": "01:45 PM",
        },
        {
          "id": "incident-12",
          "markerType": "icon",
          "type": "fight",
          "position": {
            "lat": 37.7820 + (_random.nextDouble() - 0.5) * 0.01,
            "lng": -122.4130 + (_random.nextDouble() - 0.5) * 0.01,
          },
          "address": "Fight Street 2",
          "time": "02:00 PM",
        },
        {
          "id": "incident-13",
          "markerType": "icon",
          "type": "accident",
          "position": {
            "lat": 37.7810 + (_random.nextDouble() - 0.5) * 0.01,
            "lng": -122.4140 + (_random.nextDouble() - 0.5) * 0.01,
          },
          "address": "Gun Street 2",
          "time": "02:15 PM",
        },
        {
          "id": "incident-14",
          "markerType": "icon",
          "type": "fire",
          "position": {
            "lat": 37.7800 + (_random.nextDouble() - 0.5) * 0.01,
            "lng": -122.4150 + (_random.nextDouble() - 0.5) * 0.01,
          },
          "address": "Fire Street 3",
          "time": "02:30 PM",
        },
      ];

  List<Incident> getIncidents() =>
      defaultIncidents.map((e) => Incident.fromMap(e)).toList();
  Future<BitmapDescriptor> bitmapResize(
    String assetPath, {
    int width = 160,
  }) async {
    final byteData = await rootBundle.load(assetPath);
    final uint8list = byteData.buffer.asUint8List();

    final img = image.decodeImage(uint8list);
    if (img == null) return BitmapDescriptor.defaultMarker;
    final resized = image.copyResize(img, width: width);
    final resizedBytes = image.encodePng(resized);
    return BitmapDescriptor.bytes(resizedBytes);
  }

  // Future<BitmapDescriptor> bitmapFromIncidentAsset(
  //   String assetPath, {
  //   int width = 60,
  // }) async {
  //   final byteData = await rootBundle.load(assetPath);
  //   final bytes = byteData.buffer.asUint8List();
  //   final decoded = image.decodeImage(bytes);
  //   if (decoded == null) return BitmapDescriptor.defaultMarker;

  //   final resized = image.copyResize(
  //     decoded,
  //     width: width,
  //     interpolation: image.Interpolation.cubic,
  //   );
  //   final pngBytes = image.encodePng(resized);
  //   return BitmapDescriptor.bytes(pngBytes);
  // }
  Future<BitmapDescriptor> bitmapFromIncidentAsset(
    String assetPath,
    int width,
  ) async {
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();

    final img = image.decodeImage(bytes)!;
    final resized = image.copyResize(img, width: width); // 👈 control size

    return BitmapDescriptor.fromBytes(
      Uint8List.fromList(image.encodePng(resized)),
    );
  }
}
