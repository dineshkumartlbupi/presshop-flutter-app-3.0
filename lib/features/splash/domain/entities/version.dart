import 'package:equatable/equatable.dart';

class Version extends Equatable {
  const Version({
    required this.ios,
    required this.android,
    required this.forceUpdate,
    required this.countries,
    required this.isLocationPopupEnabled,
  });
  final String ios;
  final String android;
  final bool forceUpdate;
  final List<String> countries;
  final bool isLocationPopupEnabled;

  @override
  List<Object?> get props =>
      [ios, android, forceUpdate, countries, isLocationPopupEnabled];
}
