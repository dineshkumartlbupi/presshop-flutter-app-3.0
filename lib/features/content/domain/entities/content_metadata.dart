import 'package:equatable/equatable.dart';

class ContentMetadata extends Equatable {

  const ContentMetadata({
    required this.media,
    required this.isNsfw,
    required this.deepFake,
    required this.thumbnail,
    required this.mediaType,
    required this.isWatermarked,
    required this.originalFileName,
    required this.watermarkedMedia,
  });
  final String media;
  final bool isNsfw;
  final bool deepFake;
  final String thumbnail;
  final String mediaType;
  final bool isWatermarked;
  final String originalFileName;
  final String watermarkedMedia;

  // Getters for UI compatibility
  String get mediaUrl => media;
  String get thumbnailUrl => thumbnail;
  String get watermarkUrl => watermarkedMedia;

  @override
  List<Object?> get props => [
        media,
        isNsfw,
        deepFake,
        thumbnail,
        mediaType,
        isWatermarked,
        originalFileName,
        watermarkedMedia,
      ];
}
