import 'package:equatable/equatable.dart';

class Version extends Equatable {
  final String ios;
  final String android;
  final bool forceUpdate;

  const Version({
    required this.ios,
    required this.android,
    required this.forceUpdate,
  });

  @override
  List<Object?> get props => [ios, android, forceUpdate];
}
