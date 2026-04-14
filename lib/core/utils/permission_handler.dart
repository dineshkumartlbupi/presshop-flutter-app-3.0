import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import 'package:location/location.dart';

import 'package:presshop/main.dart';
import 'package:go_router/go_router.dart';

Future<bool> checkGps() async {
  var status = await permission.Permission.location.serviceStatus;

  switch (status) {
    case permission.ServiceStatus.disabled:
      {
        var service = await Location.instance.requestService();
        return service;
      }

    case permission.ServiceStatus.enabled:
      return true;

    default:
      return false;
  }
}

Future<bool> locationPermission() async {
  var status = await permission.Permission.location.status;
  switch (status) {
    case permission.PermissionStatus.denied:
      {
        if (Platform.isAndroid) {
          var service = await permission.Permission.location.request();
          return service.isGranted ? true : false;
        } else {
          var per = await Location().requestPermission();
          return PermissionStatus.granted == per ? true : false;
        }
      }

    case permission.PermissionStatus.granted:
      return true;

    case permission.PermissionStatus.restricted:
      //Navigator.pop(navigatorKey.currentContext!);
      const SnackBar(content: Text("Please Enable Location"));
      return false;
    case permission.PermissionStatus.permanentlyDenied:
      // Navigator.pop(navigatorKey.currentContext!);
      const SnackBar(content: Text("Please Enable Location"));
      return false;

    case permission.PermissionStatus.limited:
      // Navigator.pop(navigatorKey.currentContext!);
      const SnackBar(content: Text("Please Enable Location"));
      return false;
    default:
      return false;
  }
}

/*Future<bool> storagePermission() async {
  var status = await permission.Permission.storage.status;

  switch (status) {
    case permission.PermissionStatus.denied:
      {
        var requestValue = await permission.Permission.storage.request();
        return requestValue.isDenied ? false : true;
      }

    case permission.PermissionStatus.granted:
      return true;

    case permission.PermissionStatus.restricted:
      */ /*showToast(
          message: "Please Enable Storage Permission",
          context: navigatorKey.currentContext!);*/ /*
      return false;
    case permission.PermissionStatus.permanentlyDenied:
      */ /*showToast(
          message: "Please Enable Storage Permission",
          context: navigatorKey.currentContext!);*/ /*
      return false;

    case permission.PermissionStatus.limited:
      */ /*showToast(
          message: "Please Enable Storage Permission",
          context: navigatorKey.currentContext!);*/ /*
      return false;

    default:
      return false;
  }
}*/

Future<bool> storagePermission() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    if (androidInfo.version.sdkInt >= 33) {
      // For Android 13 and above, we need to request media permissions
      var photoStatus = await permission.Permission.photos.status;
      var videoStatus = await permission.Permission.videos.status;

      if (photoStatus.isGranted && videoStatus.isGranted) {
        return true;
      }

      Map<permission.Permission, permission.PermissionStatus> statuses = await [
        permission.Permission.photos,
        permission.Permission.videos,
      ].request();

      if (statuses[permission.Permission.photos]!.isGranted ||
          statuses[permission.Permission.videos]!.isGranted) {
        return true;
      }

      if (statuses[permission.Permission.photos]!.isPermanentlyDenied ||
          statuses[permission.Permission.videos]!.isPermanentlyDenied) {
        permission.openAppSettings();
      }
      return false;
    } else {
      // For Android 12 and below, we use standard storage permission
      var status = await permission.Permission.storage.status;

      if (status.isGranted) {
        return true;
      }

      switch (status) {
        case permission.PermissionStatus.denied:
          var requestValue = await permission.Permission.storage.request();
          return requestValue.isGranted;

        case permission.PermissionStatus.permanentlyDenied:
          permission.openAppSettings();
          return false;

        case permission.PermissionStatus.restricted:
        case permission.PermissionStatus.limited:
          if (navigatorKey.currentContext != null) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
              const SnackBar(content: Text("Please Enable Storage Permission in Settings")),
            );
          }
          return false;

        default:
          return false;
      }
    }
  } else {
    // iOS Handling
    var status = await permission.Permission.photos.status;

    if (status.isGranted || status.isLimited) {
      return true;
    }

    switch (status) {
      case permission.PermissionStatus.denied:
        var requestValue = await permission.Permission.photos.request();
        return requestValue.isGranted || requestValue.isLimited;

      case permission.PermissionStatus.permanentlyDenied:
        permission.openAppSettings();
        return false;

      default:
        return false;
    }
  }
}

Future<bool> cameraPermission() async {
  var status = await permission.Permission.camera.status;

  switch (status) {
    case permission.PermissionStatus.denied:
      {
        var requestValue = await permission.Permission.camera.request();
        return requestValue.isDenied ? false : true;
      }

    case permission.PermissionStatus.granted:
      return true;

    case permission.PermissionStatus.restricted:
      return false;
    case permission.PermissionStatus.permanentlyDenied:
      return false;

    case permission.PermissionStatus.limited:
      return false;

    default:
      return false;
  }
}

class Uuid {
  final Random _random = Random();

  String generateV4() {
    // Generate xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx / 8-4-4-4-12.
    final int special = 8 + _random.nextInt(4);

    return '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}-'
        '${_bitsDigits(16, 4)}-'
        '4${_bitsDigits(12, 3)}-'
        '${_printDigits(special, 1)}${_bitsDigits(12, 3)}-'
        '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}';
  }

  String _bitsDigits(int bitCount, int digitCount) =>
      _printDigits(_generateBits(bitCount), digitCount);

  int _generateBits(int bitCount) => _random.nextInt(1 << bitCount);

  String _printDigits(int value, int count) =>
      value.toRadixString(16).padLeft(count, '0');
}
