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

  MediaHouse copyWith({
    String? id,
    String? name,
    String? profileImage,
  }) {
    return MediaHouse(
      id: id ?? this.id,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_image': profileImage,
    };
  }
}
