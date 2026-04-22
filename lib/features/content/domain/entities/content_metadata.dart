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
    required this.watermark,
  });
  final String media;
  final bool isNsfw;
  final bool deepFake;
  final String thumbnail;
  final String mediaType;
  final bool isWatermarked;
  final String originalFileName;
  final String watermarkedMedia;
  final String watermark;

  // Getters for UI compatibility
  String get mediaUrl => media;
  String get thumbnailUrl => thumbnail;
  String get watermarkUrl => watermark.isNotEmpty ? watermark : watermarkedMedia;

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
        watermark,
      ];

  ContentMetadata copyWith({
    String? media,
    bool? isNsfw,
    bool? deepFake,
    String? thumbnail,
    String? mediaType,
    bool? isWatermarked,
    String? originalFileName,
    String? watermarkedMedia,
    String? watermark,
  }) {
    return ContentMetadata(
      media: media ?? this.media,
      isNsfw: isNsfw ?? this.isNsfw,
      deepFake: deepFake ?? this.deepFake,
      thumbnail: thumbnail ?? this.thumbnail,
      mediaType: mediaType ?? this.mediaType,
      isWatermarked: isWatermarked ?? this.isWatermarked,
      originalFileName: originalFileName ?? this.originalFileName,
      watermarkedMedia: watermarkedMedia ?? this.watermarkedMedia,
      watermark: watermark ?? this.watermark,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'media': media,
      'is_nsfw': isNsfw,
      'deep_fake': deepFake,
      'thumbnail': thumbnail,
      'media_type': mediaType,
      'is_watermarked': isWatermarked,
      'originalFileName': originalFileName,
      'watermarked_media': watermarkedMedia,
      'watermark': watermark,
    };
  }
}
