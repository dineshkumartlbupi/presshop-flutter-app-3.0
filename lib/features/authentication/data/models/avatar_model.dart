import '../../domain/entities/avatar.dart';

class AvatarModel extends Avatar {
  const AvatarModel({
    required super.id,
    required super.avatar,
    super.baseUrl,
  });

  factory AvatarModel.fromJson(Map<String, dynamic> json, {String? baseUrl}) {
    return AvatarModel(
      id: json['_id'] ?? '',
      avatar: json['avatar'] ?? '',
      baseUrl: baseUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'avatar': avatar,
      if (baseUrl != null) 'base_url': baseUrl,
    };
  }
}
