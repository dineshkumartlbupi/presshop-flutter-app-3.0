import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:presshop/core/utils/app_logger.dart';
import 'package:presshop/core/analytics/analytics_constants.dart';

class LocationService {
  final Location _location = Location();
  Future<bool>? _currentRequest;

  // Check and request any permission safely
  Future<bool> requestPermission(Permission permission) async {
    if (_currentRequest != null) {
      debugPrint(
          "🚀 LocationService: Another Permission request already in progress, waiting...");
      return _currentRequest!;
    }

    _currentRequest = _executePermissionRequest(permission);
    try {
      return await _currentRequest!;
    } finally {
      _currentRequest = null;
    }
  }

  Future<bool> _executePermissionRequest(Permission permission) async {
    var status = await permission.request();
    if (status.isGranted) {
      AppLogger.info("Permission ${permission.toString()} granted");
      return true;
    } else if (status.isDenied) {
      AppLogger.warning("Permission ${permission.toString()} denied");
      return false;
    } else if (status.isPermanentlyDenied) {
      AppLogger.error("Permission ${permission.toString()} permanently denied",
          trackAnalytics: true);
      await openAppSettings();
      return false;
    }
    return false;
  }

  // Legacy compatibility for location (internal)
  Future<bool> _requestLocationPermission(
      BuildContext context, bool shouldShowSettingPopup) async {
    return requestPermission(Permission.location);
  }

  // Show dialog if location permission is denied
  // Future<void> _showLocationMandatoryDialog(BuildContext context) async {
  //   return commonErrorDialogDialog(
  //       isFromNetworkError: false,
  //       actionButton: "Open Settings",
  //       MediaQuery.of(context).size,
  //       "This app needs access to your location to provide its features. Please enable location permission in your app settings",
  //       "Location permission required", () {
  //     Navigator.pop(context);
  //     openAppSettings();
  //   });
  // }

  // Check if GPS is enabled
  Future<bool> _checkAndRequestGps() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }
    return true;
  }

  Future<LocationData?> getCurrentLocation(BuildContext context,
      {bool shouldShowSettingPopup = true}) async {
    bool hasPermission =
        await _requestLocationPermission(context, shouldShowSettingPopup);
    if (!hasPermission) {
      return null;
    }

    bool gpsEnabled = await _checkAndRequestGps();
    if (!gpsEnabled) {
      return null;
    }

    // Fetch location
    try {
      geolocator.Position? position = await Future.any([
        geolocator.Geolocator.getCurrentPosition(
            desiredAccuracy: geolocator.LocationAccuracy.high),
        Future.delayed(Duration(seconds: 20), () => null),
      ]);

      // Fallback to last known position if current position fetch fails
      if (position == null) {
        debugPrint(
            "🚀 LocationService: Current position timed out, trying last known position.");
        position = await geolocator.Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        debugPrint("🚀 LocationService: Failed to get location.");
        return null; // Timeout or no position available
      } else {
        debugPrint(
            "🚀 LocationService: Location fetched: ${position.latitude}, ${position.longitude}");

        return LocationData.fromMap({
          'latitude': position.latitude,
          'longitude': position.longitude,
        });
      }
    } catch (e) {
      AppLogger.error("LocationService: Error fetching location: $e",
          trackAnalytics: true);
      debugPrint("🚀 LocationService: Error fetching location: $e");
      return null;
    }
  }
}
