import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoThumbnailWidget extends StatefulWidget {
  const VideoThumbnailWidget({
    Key? key,
    required this.videoUrl,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.fit,
  }) : super(key: key);
  final String videoUrl;
  final String? thumbnailUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  String? _thumbnailPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.thumbnailUrl != null && widget.thumbnailUrl!.isNotEmpty) {
      _isLoading = false;
    } else {
      _generateThumbnail();
    }
  }

  @override
  void didUpdateWidget(covariant VideoThumbnailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl ||
        oldWidget.thumbnailUrl != widget.thumbnailUrl) {
      if (widget.thumbnailUrl != null && widget.thumbnailUrl!.isNotEmpty) {
        setState(() {
          _isLoading = false;
        });
      } else {
        _generateThumbnail();
      }
    }
  }

  Future<void> _generateThumbnail() async {
    if (widget.videoUrl.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    debugPrint("Generating thumbnail for: ${widget.videoUrl}");

    try {
      final fileName = await VideoThumbnail.thumbnailFile(
        video: widget.videoUrl,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG,
        maxHeight: 500, // Adjust quality as needed
        quality: 75,
      );
      if (mounted) {
        setState(() {
          _thumbnailPath = fileName;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error generating thumbnail: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.black12,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final isThumbnailAVideo = widget.thumbnailUrl != null &&
        (widget.thumbnailUrl!.toLowerCase().endsWith(".mp4") ||
            widget.thumbnailUrl!.toLowerCase().endsWith(".mov") ||
            widget.thumbnailUrl!.toLowerCase().endsWith(".m4v") ||
            widget.thumbnailUrl!.toLowerCase().endsWith(".quicktime"));

    if (widget.thumbnailUrl != null &&
        widget.thumbnailUrl!.isNotEmpty &&
        !isThumbnailAVideo) {
      return CachedNetworkImage(
        imageUrl: widget.thumbnailUrl!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit ?? BoxFit.cover,
        placeholder: (context, url) => Container(
          width: widget.width,
          height: widget.height,
          color: Colors.black12,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          width: widget.width,
          height: widget.height,
          color: Colors.black,
          child: const Center(
              child: Icon(Icons.broken_image, color: Colors.white)),
        ),
      );
    }

    if (_thumbnailPath != null) {
      return Image.file(
        File(_thumbnailPath!),
        width: widget.width,
        height: widget.height,
        fit: widget.fit ?? BoxFit.cover,
      );
    }

    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.black,
      child: const Center(child: Icon(Icons.videocam_off, color: Colors.white)),
    );
  }
}
