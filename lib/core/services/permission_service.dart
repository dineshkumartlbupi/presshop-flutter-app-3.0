import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

enum PermissionResult { granted, denied, permanentlyDenied }

class PermissionService {
  /// Returns the status of Camera and Gallery permissions.
  /// On Android 13+, Gallery is handled via Photos/Videos permissions.
  Future<PermissionResult> checkCameraAndGalleryPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;
    final galleryStatus = await _getGalleryPermissionStatus();

    if (cameraStatus.isGranted && micStatus.isGranted && galleryStatus.isGranted) {
      return PermissionResult.granted;
    }

    if (cameraStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied || galleryStatus.isPermanentlyDenied) {
      return PermissionResult.permanentlyDenied;
    }

    return PermissionResult.denied;
  }

  /// Requests Camera and Gallery permissions.
  Future<PermissionResult> requestCameraAndGalleryPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
      ...await _getGalleryPermissionsList(),
    ].request();

    final cameraStatus = statuses[Permission.camera] ?? PermissionStatus.denied;
    final micStatus = statuses[Permission.microphone] ?? PermissionStatus.denied;
    final galleryStatus = await _getGalleryPermissionStatus();

    if (cameraStatus.isGranted && micStatus.isGranted && galleryStatus.isGranted) {
      return PermissionResult.granted;
    }

    if (cameraStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied || galleryStatus.isPermanentlyDenied) {
      return PermissionResult.permanentlyDenied;
    }

    return PermissionResult.denied;
  }

  /// Helper to get the correct Gallery permission status based on Platform/SDK.
  Future<PermissionStatus> _getGalleryPermissionStatus() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        final photos = await Permission.photos.status;
        final videos = await Permission.videos.status;
        if (photos.isGranted || videos.isGranted) return PermissionStatus.granted;
        if (photos.isLimited || videos.isLimited) return PermissionStatus.granted; // Treat limited as granted for gallery access
        if (photos.isPermanentlyDenied || videos.isPermanentlyDenied) return PermissionStatus.permanentlyDenied;
        return PermissionStatus.denied;
      } else {
        return await Permission.storage.status;
      }
    } else {
      final status = await Permission.photos.status;
      if (status.isGranted || status.isLimited) return PermissionStatus.granted;
      return status;
    }
  }

  /// Helper to get the list of permissions required for Gallery.
  Future<List<Permission>> _getGalleryPermissionsList() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        return [Permission.photos, Permission.videos];
      } else {
        return [Permission.storage];
      }
    } else {
      return [Permission.photos];
    }
  }

  /// Opens the app settings.
  Future<void> openSettings() async {
    await openAppSettings();
  }

  /// Requests App Tracking Transparency permission (iOS only).
  Future<void> requestATT() async {
    if (Platform.isIOS) {
      await Permission.appTrackingTransparency.request();
    }
  }
}
