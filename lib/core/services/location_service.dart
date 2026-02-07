import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:presshop/core/utils/app_logger.dart';

class LocationService {
  final Location _location = Location();
  Future<void> _lastRequest = Future.value();

  // Check and request any permission safely
  Future<bool> requestPermission(Permission permission) async {
    // If already granted, return immediately to avoid blocking initialization
    if (await permission.isGranted) {
      return true;
    }

    // Chain this request to the end of the queue
    final previousRequest = _lastRequest;
    final completer = Completer<void>();
    _lastRequest = completer.future;

    // Wait for the previous request to complete
    try {
      await previousRequest;
    } catch (e) {
      // Ignore errors from previous requests
    }

    try {
      // Re-check status after waiting (incase user granted it externally or previous req covered it)
      if (await permission.isGranted) {
        return true;
      }
      return await _executePermissionRequest(permission);
    } finally {
      completer.complete();
    }
  }

  DateTime? _lastSettingsOpen;

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
      // Avoid spamming settings if multiple permissions are denied at once
      if (_lastSettingsOpen == null ||
          DateTime.now().difference(_lastSettingsOpen!) >
              const Duration(seconds: 2)) {
        _lastSettingsOpen = DateTime.now();
        await openAppSettings();
      }
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
