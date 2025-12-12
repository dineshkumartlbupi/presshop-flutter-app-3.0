import '../../domain/entities/tutorial.dart';

class TutorialModel extends Tutorial {
  const TutorialModel({
    required super.id,
    required super.video,
    required super.thumbnail,
    required super.description,
    required super.category,
    required super.duration,
    required super.view,
    required super.showVideo,
  });

  factory TutorialModel.fromJson(Map<String, dynamic> json) {
    return TutorialModel(
      id: json['_id'] ?? "",
      video: json['video'] ?? "",
      description: json['description'] ?? "",
      category: json['category'] ?? "",
      duration: json['duration'] ?? "",
      view: json['count_for_hopper'] ?? 0,
      thumbnail: json['thumbnail'] ?? "",
      showVideo: false,
    );
  }
}
