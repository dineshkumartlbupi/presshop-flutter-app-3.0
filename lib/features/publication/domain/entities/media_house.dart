import 'package:equatable/equatable.dart';

class MediaHouse extends Equatable {
  const MediaHouse({
    required this.id,
    required this.name,
    required this.icon,
  });
  final String id;
  final String name;
  final String icon;

  @override
  List<Object?> get props => [id, name, icon];
}
