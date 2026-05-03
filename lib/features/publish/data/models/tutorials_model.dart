import 'package:hive/hive.dart';

part 'tutorials_model.g.dart';

@HiveType(typeId: 0)
class TutorialsModel {

  TutorialsModel(
      {required this.id,
      required this.video,
      required this.description,
      required this.category,
      required this.duration,
      required this.view,
      required this.thumbnail,
      required this.showVideo});

  factory TutorialsModel.fromJson(Map<String, dynamic> json) {
    return TutorialsModel(
        id: json['_id'] ?? json['id'] ?? "",
        video: json['url'] ?? json['video'] ?? "",
        description: json['description'] ?? "",
        category: json['category'] ?? "",
        duration: json['duration'] ?? "00:00",
        view: json['views'] ?? json['count_for_hopper'] ?? 0,
        thumbnail: json['thumbnail'] ?? "",
        showVideo: false);
  }
  @HiveField(0)
  String id = "";
  @HiveField(1)
  String video = "";
  @HiveField(2)
  String thumbnail = "";
  @HiveField(3)
  String description = "";
  @HiveField(4)
  String category = "";
  @HiveField(5)
  String duration = "";
  @HiveField(6)
  int view = 0;
  @HiveField(7)
  bool showVideo = false;
}
