import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class NewsMediaWidget extends StatefulWidget {
  final String mediaUrl;
  final String imageUrl;
  final bool isVideo;
  final Size size;

  const NewsMediaWidget({
    Key? key,
    required this.mediaUrl,
    required this.imageUrl,
    required this.isVideo,
    required this.size,
  }) : super(key: key);

  @override
  State<NewsMediaWidget> createState() => _NewsMediaWidgetState();
}

class _NewsMediaWidgetState extends State<NewsMediaWidget> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo && widget.mediaUrl.isNotEmpty) {
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.mediaUrl));
    await _videoPlayerController!.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: false,
      looping: false,
      aspectRatio: _videoPlayerController!.value.aspectRatio,
      placeholder: widget.imageUrl.isNotEmpty
          ? Image.network(widget.imageUrl, fit: BoxFit.cover, cacheHeight: 400)
          : const Center(child: CircularProgressIndicator()),
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isVideo) {
      return Container(
        height: widget.size.height * 0.3,
        width: double.infinity,
        color: Colors.black,
        child: _chewieController != null &&
                _chewieController!.videoPlayerController.value.isInitialized
            ? Chewie(controller: _chewieController!)
            : widget.imageUrl.isNotEmpty
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        widget.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        cacheHeight: (widget.size.height * 0.3 * 2).toInt(),
                      ),
                      const Icon(Icons.play_circle_fill,
                          color: Colors.white, size: 50),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
      );
    } else {
      return Image.network(
        widget.imageUrl,
        width: double.infinity,
        height: widget.size.height * 0.3,
        fit: BoxFit.cover,
        cacheHeight: (widget.size.height * 0.3 * 2).toInt(),
        errorBuilder: (context, error, stackTrace) => Container(
          height: widget.size.height * 0.3,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
        ),
      );
    }
  }
}
