import 'package:equatable/equatable.dart';

class ContentMedia extends Equatable {

  const ContentMedia({
    required this.mediaUrl,
    required this.mediaType,
    this.thumbnailUrl,
    this.watermarkUrl,
    this.mimeType,
    this.fileName,
  });
  final String mediaUrl;
  final String? thumbnailUrl;
  final String mediaType;
  final String? watermarkUrl;
  final String? mimeType;
  final String? fileName;

  @override
  List<Object?> get props => [
        mediaUrl,
        thumbnailUrl,
        mediaType,
        watermarkUrl,
        mimeType,
        fileName,
      ];
}
