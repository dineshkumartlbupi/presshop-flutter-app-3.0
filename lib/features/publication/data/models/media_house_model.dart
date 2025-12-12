import '../../domain/entities/media_house.dart';

class MediaHouseModel extends MediaHouse {
  const MediaHouseModel({
    required super.id,
    required super.name,
    required super.icon,
  });

  factory MediaHouseModel.fromJson(Map<String, dynamic> json) {
    return MediaHouseModel(
      id: json['_id'] ?? '',
      name: (json['company_name'] != null && json['company_name'].toString().isNotEmpty) 
          ? json['company_name'] 
          : (json['publication_name'] ?? ''),
      icon: json['admin_detail'] != null ? (json['admin_detail']['admin_profile'] ?? '') : '',
    );
  }
}
