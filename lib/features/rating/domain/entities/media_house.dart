import 'package:equatable/equatable.dart';

class MediaHouse extends Equatable {
  const MediaHouse({
    required this.id,
    required this.name,
    required this.profileImage,
  });
  final String id;
  final String name;
  final String profileImage;

  @override
  List<Object?> get props => [id, name, profileImage];
}
