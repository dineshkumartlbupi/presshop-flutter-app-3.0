import '../../domain/entities/avatar.dart';

class AvatarModel extends Avatar {
  const AvatarModel({
    required super.id,
    required super.avatar,
  });

  factory AvatarModel.fromJson(Map<String, dynamic> json) {
    return AvatarModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      avatar: (json['avatar'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'avatar': avatar,
    };
  }
}
