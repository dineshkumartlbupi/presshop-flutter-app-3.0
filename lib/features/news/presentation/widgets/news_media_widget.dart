import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:presshop/core/constants/app_assets.dart';
import 'package:presshop/core/constants/app_dimensions.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class NewsMediaWidget extends StatefulWidget {
  const NewsMediaWidget({
    super.key,
    required this.mediaUrl,
    required this.imageUrl,
    required this.isVideo,
    required this.size,
  });
  final String mediaUrl;
  final String imageUrl;
  final bool isVideo;
  final Size size;

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
        height: widget.size.width * AppDimensions.numD50,
        width: double.infinity,
        color: Colors.black,
        child: _chewieController != null &&
                _chewieController!.videoPlayerController.value.isInitialized
            ? Stack(
                children: [
                  Chewie(controller: _chewieController!),
                  Image.asset(
                    "${commonImagePath}watermark1.png",
                    height: double.infinity,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ],
              )
            : widget.imageUrl.isNotEmpty
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      CachedNetworkImage(
                        imageUrl: widget.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error, color: Colors.white),
                      ),
                      const Icon(Icons.play_circle_fill,
                          color: Colors.white, size: 50),
                      Image.asset(
                        "${commonImagePath}watermark1.png",
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
      );
    } else {
      return Stack(
        children: [
          CachedNetworkImage(
            imageUrl: widget.imageUrl,
            width: double.infinity,
            height: widget.size.width * AppDimensions.numD50,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Container(
              height: widget.size.width * AppDimensions.numD50,
              color: Theme.of(context).cardColor,
              child: Icon(Icons.broken_image,
                  size: 50, color: Theme.of(context).hintColor),
            ),
          ),
          Image.asset(
            "${commonImagePath}watermark1.png",
            height: double.infinity,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ],
      );
    }
  }
}
