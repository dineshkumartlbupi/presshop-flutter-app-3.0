import '../../domain/entities/hashtag.dart';

class HashtagModel extends Hashtag {
  const HashtagModel({
    required super.id,
    required super.name,
    super.count,
  });

  factory HashtagModel.fromJson(Map<String, dynamic> json) {
    return HashtagModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? json['hashtag'] ?? '',
      count: json['count'] ?? json['usage_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'count': count,
    };
  }
}
