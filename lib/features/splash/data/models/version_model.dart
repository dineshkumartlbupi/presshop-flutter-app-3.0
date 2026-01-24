import 'package:presshop/features/splash/domain/entities/version.dart';

class AppVersionData {
  final String ios;
  final String android;
  final bool forceUpdate;

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
    required String ios,
    required String android,
    required bool forceUpdate,
  }) : super(
          ios: ios,
          android: android,
          forceUpdate: forceUpdate,
        );

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
