import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapUtils {
  static double calculateDistance(List<LatLng> points) {
    double total = 0;
    for (int i = 0; i < points.length - 1; i++) {
      total += _coordinateDistance(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
    }
    return total;
  }

  static String calculateDuration(double distanceKm, {double speedKmh = 40}) {
    double hours = distanceKm / speedKmh;
    int mins = (hours * 60).round();
    return '$mins min';
  }

  static double _coordinateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295; // pi/180
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2*R*asin...
  }
}
