import 'package:presshop/features/splash/domain/entities/version.dart';

class AppVersionData {

  AppVersionData({
    required this.ios,
    required this.android,
    required this.forceUpdate,
  });

  factory AppVersionData.fromJson(Map<String, dynamic> json) {
    return AppVersionData(
      ios: json['ios'] ?? '',
      android: json['android'] ?? '',
      forceUpdate: json['force_update'] ?? false,
    );
  }
  final String ios;
  final String android;
  final bool forceUpdate;

  Map<String, dynamic> toJson() {
    return {
      'ios': ios,
      'android': android,
      'force_update': forceUpdate,
    };
  }
}

class VersionModel extends Version {
  const VersionModel({
    required super.ios,
    required super.android,
    required super.forceUpdate,
  });

  factory VersionModel.fromJson(Map<String, dynamic> json) {
    return VersionModel(
      ios: json['ios'] ?? '',
      android: json['android'] ?? '',
      forceUpdate: json['force_update'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ios': ios,
      'android': android,
      'force_update': forceUpdate,
    };
  }
}
