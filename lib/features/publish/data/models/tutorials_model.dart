class TutorialsModel {
  String id = "";
  String video = "";
  String thumbnail = "";
  String description = "";
  String category = "";
  String duration = "";
  int view = 0;
  bool showVideo = false;

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
        video: json['video'] ?? "",
        description: json['description'] ?? "",
        category: json['category'] ?? "",
        duration: json['duration'] ?? "",
        view: json['count_for_hopper'] ?? 0,
        thumbnail: json['thumbnail'] ?? "",
        showVideo: false);
  }
}
