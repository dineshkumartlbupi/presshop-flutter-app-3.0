import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:presshop/utils/CommonWigdets.dart';

class LocationService {
  final Location _location = Location();

  // Check and request location permission
  Future<bool> _requestLocationPermission(BuildContext context) async {
    var status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      return false;
    } else if (status.isPermanentlyDenied) {
      await _showLocationMandatoryDialog(context);
    }
    return false;
  }

  // Show dialog if location permission is denied
  Future<void> _showLocationMandatoryDialog(BuildContext context) async {
    return commonErrorDialogDialog(
        isFromNetworkError: false,
        actionButton: "Open Settings",
        MediaQuery.of(context).size,
        "This app needs access to your location to provide its features. Please enable location permission in your app settings",
        "Location permission required", () {
      openAppSettings().then((value) => {Navigator.pop(context)});
    });
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

  // Fetch current location
  Future<LocationData?> getCurrentLocation(BuildContext context) async {
    // Request permission
    bool hasPermission = await _requestLocationPermission(context);
    if (!hasPermission) {
      return null;
    }

    // Check and request GPS
    bool gpsEnabled = await _checkAndRequestGps();
    if (!gpsEnabled) {
      return null;
    }

    // Fetch location
    try {
      LocationData? locationData = await Future.any([
        _location.getLocation(),
        Future.delayed(Duration(seconds: 6), () => null),
      ]);
      return locationData;
    } catch (e) {
      return null;
    }
  }
}
