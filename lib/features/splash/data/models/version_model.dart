import 'dart:io';
import 'package:presshop/features/splash/domain/entities/version.dart';

class AppVersionData {
  AppVersionData({
    required this.ios,
    required this.android,
    required this.forceUpdate,
    required this.countries,
  });

  factory AppVersionData.fromJson(Map<String, dynamic> json) {
    return AppVersionData(
      ios: json['live_Version']?.toString() ?? '',
      android: json['live_Version']?.toString() ?? '',
      forceUpdate: Platform.isAndroid
          ? (json['aOSshouldForceUpdate'] ?? false)
          : (json['iOSshouldForceUpdate'] ?? false),
      countries:
          json['country'] != null ? List<String>.from(json['country']) : [],
    );
  }
  final String ios;
  final String android;
  final bool forceUpdate;
  final List<String> countries;

  Map<String, dynamic> toJson() {
    return {
      'ios': ios,
      'android': android,
      'force_update': forceUpdate,
      'country': countries,
    };
  }
}

class VersionModel extends Version {
  const VersionModel({
    required super.ios,
    required super.android,
    required super.forceUpdate,
    required super.countries,
  });

  factory VersionModel.fromJson(Map<String, dynamic> json) {
    return VersionModel(
      ios: json['live_Version']?.toString() ?? '',
      android: json['live_Version']?.toString() ?? '',
      forceUpdate: Platform.isAndroid
          ? (json['aOSshouldForceUpdate'] ?? false)
          : (json['iOSshouldForceUpdate'] ?? false),
      countries:
          json['country'] != null ? List<String>.from(json['country']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ios': ios,
      'android': android,
      'force_update': forceUpdate,
      'country': countries,
    };
  }
}
