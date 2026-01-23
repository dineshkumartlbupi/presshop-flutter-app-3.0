import 'package:equatable/equatable.dart';

class Version extends Equatable {
  const Version({
    required this.ios,
    required this.android,
    required this.forceUpdate,
  });
  final String ios;
  final String android;
  final bool forceUpdate;

  @override
  List<Object?> get props => [ios, android, forceUpdate];
}
