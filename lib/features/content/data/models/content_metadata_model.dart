import '../../domain/entities/content_metadata.dart';

class ContentMetadataModel extends ContentMetadata {
  const ContentMetadataModel({
    required super.media,
    required super.isNsfw,
    required super.deepFake,
    required super.thumbnail,
    required super.mediaType,
    required super.isWatermarked,
    required super.originalFileName,
    required super.watermarkedMedia,
  });

  factory ContentMetadataModel.fromJson(Map<String, dynamic> json) {
    return ContentMetadataModel(
      media: (json['media'] ?? '').toString(),
      isNsfw: json['is_nsfw'] == true,
      deepFake: json['deep_fake'] == true,
      thumbnail: (json['thumbnail'] ?? '').toString(),
      mediaType: (json['media_type'] ?? '').toString(),
      isWatermarked: json['is_watermarked'] == true,
      originalFileName: (json['originalFileName'] ?? '').toString(),
      watermarkedMedia: (json['watermarked_media'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'media': media,
        'is_nsfw': isNsfw,
        'deep_fake': deepFake,
        'thumbnail': thumbnail,
        'media_type': mediaType,
        'is_watermarked': isWatermarked,
        'originalFileName': originalFileName,
        'watermarked_media': watermarkedMedia,
      };
}
