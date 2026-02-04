import 'package:equatable/equatable.dart';

class Tutorial extends Equatable {

  const Tutorial({
    required this.id,
    required this.video,
    required this.thumbnail,
    required this.description,
    required this.category,
    required this.duration,
    required this.view,
    required this.showVideo,
  });
  final String id;
  final String video;
  final String thumbnail;
  final String description;
  final String category;
  final String duration;
  final int view;
  final bool showVideo;

  @override
  List<Object?> get props => [id, video, thumbnail, description, category, duration, view, showVideo];
}
