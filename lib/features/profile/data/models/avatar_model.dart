import '../../domain/entities/avatar.dart';

class AvatarModel extends Avatar {
  const AvatarModel({required super.id, required super.avatar});

  factory AvatarModel.fromJson(Map<String, dynamic> json) {
    return AvatarModel(
      id: json['_id'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'avatar': avatar,
    };
  }
}
