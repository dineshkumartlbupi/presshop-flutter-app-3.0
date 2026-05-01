import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:presshop/core/utils/app_logger.dart';
import 'package:presshop/core/utils/permission_handler.dart';

class LocationService {
  final Location _location = Location();

  // ── Production-Grade Permission Management ────────────────────────────────
  // Map to track active requests per permission to prevent race conditions
  static final Map<Permission, Completer<bool>> _activeRequests = {};

  // Track last request time to avoid spamming the OS (cooldown)
  static final Map<Permission, DateTime> _lastRequestTime = {};
  static const Duration _requestCooldown = Duration(seconds: 1);

  /// Check and request any permission safely — production level de-duplication.
  Future<bool> requestPermission(Permission permission,
      {bool showUI = true}) async {
    // 1. Fast-path: already granted
    if (await permission.isGranted) return true;

    // 2. Check if a request for THIS permission is already in progress
    if (_activeRequests.containsKey(permission)) {
      debugPrint(
          "🚀 PermissionService: Request for $permission already in progress, joining...");
      return _activeRequests[permission]!.future;
    }

    // 3. Cooldown check: prevent rapid-fire requests that the OS might ignore
    final now = DateTime.now();
    if (_lastRequestTime.containsKey(permission)) {
      final difference = now.difference(_lastRequestTime[permission]!);
      if (difference < _requestCooldown) {
        debugPrint(
            "🚀 PermissionService: Cooldown active for $permission. Waiting ${_requestCooldown.inMilliseconds - difference.inMilliseconds}ms");
        await Future.delayed(_requestCooldown - difference);
      }
    }

    // 4. Create a new completer and mark as active
    final completer = Completer<bool>();
    _activeRequests[permission] = completer;
    _lastRequestTime[permission] = DateTime.now();

    try {
      // Final check before requesting
      if (await permission.isGranted) {
        completer.complete(true);
        return true;
      }

      final result =
          await _executePermissionRequest(permission, showUI: showUI);
      completer.complete(result);
      return result;
    } catch (e) {
      debugPrint("🚀 PermissionService: Error requesting $permission: $e");
      completer.complete(false);
      return false;
    } finally {
      // Remove from active requests
      _activeRequests.remove(permission);
    }
  }

  DateTime? _lastSettingsOpen;
  Future<bool> _executePermissionRequest(Permission permission,
      {bool showUI = true}) async {
    try {
      // Small delay to allow the OS to clean up previous dialogs/transitions
      await Future.delayed(const Duration(milliseconds: 300));

      final status = await permission.request();
      if (status.isGranted) {
        AppLogger.info("Permission $permission granted");
        return true;
      }

      if (status.isDenied) {
        // ❗ User tapped "Don't Allow"
        if (showUI) {
          PermissionUI.show(
            message: "Permission denied. Please allow to continue.",
            isPermanent: false,
          );
        }
        return false;
      }

      if (status.isPermanentlyDenied) {
        // ❗ User tapped "Don't ask again"
        if (showUI) {
          PermissionUI.show(
            message: "Permission permanently denied. Enable from settings.",
            isPermanent: true,
          );
        }
        return false;
      }
    } catch (e) {
      debugPrint("Permission error: $e");
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
