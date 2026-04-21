import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:presshop/core/utils/app_logger.dart';

class LocationService {
  final Location _location = Location();

  // ── Static (shared across ALL instances) permission gate ──────────────────
  // This prevents concurrent permission requests whether the caller uses
  // sl<LocationService>() or LocationService() directly.

  static Future<void> _lastRequest = Future.value();
  static bool _isRequestInProgress = false;
  // ─────────────────────────────────────────────────────────────────────────

  /// Check and request any permission safely — queued & de-duplicated.
  Future<bool> requestPermission(Permission permission) async {
    // Fast-path: already granted
    if (await permission.isGranted) return true;

    // Chain this request so concurrent callers queue up
    final completer = Completer<void>();
    final previousRequest = _lastRequest;
    _lastRequest = completer.future;

    try {
      if (_isRequestInProgress) {
        debugPrint(
            "LocationService: A permission request is already in progress, waiting in queue...");
      }
      await previousRequest;
    } catch (_) {}

    _isRequestInProgress = true;
    try {
      // Re-check after waiting
      if (await permission.isGranted) return true;
      return await _executePermissionRequest(permission);
    } finally {
      _isRequestInProgress = false;
      completer.complete();
    }
  }

  DateTime? _lastSettingsOpen;

  Future<bool> _executePermissionRequest(Permission permission) async {
    try {
      var status = await permission.request();
      if (status.isGranted) {
        AppLogger.info("Permission ${permission.toString()} granted");
        return true;
      } else if (status.isDenied) {
        AppLogger.warning("Permission ${permission.toString()} denied");
        return false;
      } else if (status.isPermanentlyDenied) {
        AppLogger.error(
            "Permission ${permission.toString()} permanently denied",
            trackAnalytics: true);
        if (_lastSettingsOpen == null ||
            DateTime.now().difference(_lastSettingsOpen!) >
                const Duration(seconds: 2)) {
          _lastSettingsOpen = DateTime.now();
          await openAppSettings();
        }
        return false;
      }
    } catch (e) {
      debugPrint("LocationService: Permission request error (ignored): $e");
    }
    return false;
  }

  // Legacy compatibility for location (internal)
  Future<bool> _requestLocationPermission(
      BuildContext context, bool shouldShowSettingPopup) async {
    return requestPermission(Permission.location);
  }

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
        return null;
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
