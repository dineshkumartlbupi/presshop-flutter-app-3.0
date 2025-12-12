import 'package:equatable/equatable.dart';

class MediaHouse extends Equatable {
  final String id;
  final String name;
  final String icon;

  const MediaHouse({
    required this.id,
    required this.name,
    required this.icon,
  });

  @override
  List<Object?> get props => [id, name, icon];
}
