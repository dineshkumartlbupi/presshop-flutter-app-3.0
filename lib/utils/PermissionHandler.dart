import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import 'package:location/location.dart';

import '../main.dart';

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
      Navigator.pop(navigatorKey.currentContext!);
      const SnackBar(content: Text("Please Enable Location"));
      return false;
    case permission.PermissionStatus.permanentlyDenied:
      Navigator.pop(navigatorKey.currentContext!);
      const SnackBar(content: Text("Please Enable Location"));
      return false;

    case permission.PermissionStatus.limited:
      Navigator.pop(navigatorKey.currentContext!);
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
  AndroidDeviceInfo androidInfo;
  if (Platform.isAndroid) {
    androidInfo = await deviceInfo.androidInfo;

    if (androidInfo.version.sdkInt >= 33) {
      return true;
    } else {
      var status = await permission.Permission.storage.status;

      switch (status) {
        case permission.PermissionStatus.denied:
          var requestValue = await permission.Permission.storage.request();

          return requestValue.isDenied ? false : true;

        case permission.PermissionStatus.granted:
          return true;

        case permission.PermissionStatus.restricted:
          Navigator.pop(navigatorKey.currentContext!);
          const SnackBar(content: Text("Please Enable Storage Permission"));

          return false;
        case permission.PermissionStatus.permanentlyDenied:
          Navigator.pop(navigatorKey.currentContext!);
          const SnackBar(content: Text("Please Enable Storage Permission"));

          return false;

        case permission.PermissionStatus.limited:
          Navigator.pop(navigatorKey.currentContext!);
          const SnackBar(content: Text("Please Enable Storage Permission"));

          return false;

        default:
          return false;
      }
    }
  } else {
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
        Navigator.pop(navigatorKey.currentContext!);
        const SnackBar(content: Text("Please Enable Storage Permission"));

        return false;
      case permission.PermissionStatus.permanentlyDenied:
        Navigator.pop(navigatorKey.currentContext!);
        const SnackBar(content: Text("Please Enable Storage Permission"));

        return false;

      case permission.PermissionStatus.limited:
        Navigator.pop(navigatorKey.currentContext!);
        const SnackBar(content: Text("Please Enable Storage Permission"));
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
      /* showToast(
          message: "Please Enable Camera Permission",
          context: navigatorKey.currentContext!);*/
      return false;
    case permission.PermissionStatus.permanentlyDenied:
      /*showToast(
          message: "Please Enable Camera Permission",
          context: navigatorKey.currentContext!);*/
      return false;

    case permission.PermissionStatus.limited:
      /* showToast(
          message: "Please Enable Camera Permission",
          context: navigatorKey.currentContext!);*/
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
