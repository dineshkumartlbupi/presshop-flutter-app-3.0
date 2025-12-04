import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  static bool _isRequestingPermission = false;

  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  static Future<LatLng> getCurrentLatLng() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled. Using fallback coordinates.');
        return const LatLng(51.5074, -0.1278); // fallback
      }

      LocationPermission permission = await Geolocator.checkPermission();
      print('Location permission status: $permission');

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        print('Requested permission, new status: $permission');
      }

      if (permission == LocationPermission.deniedForever) {
        print(
          'Location permission denied forever. Using fallback coordinates.',
        );
        return const LatLng(51.5074, -0.1278); // fallback
      }

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print(
        'Current Position obtained: Lat=${pos.latitude}, Lng=${pos.longitude}',
      );
      return LatLng(pos.latitude, pos.longitude);
    } catch (e) {
      print('Error obtaining location: $e. Using fallback coordinates.');
      return const LatLng(51.5074, -0.1278); // fallback
    }
  }

  // Get current location safely
  static Future<LatLng?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    // prevent duplicate permission requests
    if (permission == LocationPermission.denied && !_isRequestingPermission) {
      _isRequestingPermission = true;
      permission = await Geolocator.requestPermission();
      _isRequestingPermission = false;

      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    return LatLng(position.latitude, position.longitude);
  }

  static Stream<LatLng> locationStream({int distanceFilter = 5}) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: distanceFilter,
      ),
    ).map((pos) => LatLng(pos.latitude, pos.longitude));
  }

  static double calculateDistance(LatLng a, LatLng b) {
    return Geolocator.distanceBetween(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );
  }
}
