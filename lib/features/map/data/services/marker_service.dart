import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as image;
import 'package:presshop/features/map/data/models/marker_model.dart';
import 'package:http/http.dart' as http;

class MarkerService {
  final Map<String, String> markerIcons = {
    "accident": "assets/markers/carcrash.png",
    "fire": "assets/markers/fire.png",
    "medical": "assets/markers/medical.png",
    "gun": "assets/markers/gun.png",
    "protest": "assets/markers/protest.png",
    "knife": "assets/markers/knife.png",
    "fight": "assets/markers/fight.png",
    "content": "assets/markers/bg-removed-content.png",
    "hopper": "assets/markers/avatar.png",
  };

  List<Incident> getIncidents() => [];
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

  Future<BitmapDescriptor> bitmapFromIncidentAsset(
    String assetPath,
    int width,
  ) async {
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();

    final img = image.decodeImage(bytes)!;
    final resized = image.copyResize(img, width: width);

    return BitmapDescriptor.fromBytes(
      Uint8List.fromList(image.encodePng(resized)),
    );
  }

  Future<BitmapDescriptor> bitmapFromUrl(
    String url, {
    int width = 120,
    String defaultAsset = "assets/markers/bg-removed-content.png",
  }) async {
    try {
      if (url.isEmpty) {
        return bitmapResize(defaultAsset, width: width);
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final img = image.decodeImage(bytes);
        if (img == null) return bitmapResize(defaultAsset, width: width);

        // Circular crop (optional but looks better for news/users)
        // For now, just resizing to keep it simple and safe
        final resized = image.copyResize(img, width: width);
        final rounded =
            image.copyCropCircle(resized); // Make it round if possible

        return BitmapDescriptor.fromBytes(
          Uint8List.fromList(image.encodePng(rounded)),
        );
      }
      return bitmapResize(defaultAsset, width: width);
    } catch (e) {
      print("Error loading marker from URL: $e");
      return bitmapResize(defaultAsset, width: width);
    }
  }
}
