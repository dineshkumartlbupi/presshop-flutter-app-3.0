import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:presshop/core/core_export.dart';
import '../../domain/entities/feed.dart';

mixin MediaControllerMixin<T extends StatefulWidget> on State<T> {
  final Map<String, ChewieController> _videoControllers = {};
  final List<String> _controllerOrder = [];
  static const int _maxCachedControllers = 5;

  @override
  void dispose() {
    for (var controller in _videoControllers.values) {
      controller.videoPlayerController.dispose();
      controller.dispose();
    }
    super.dispose();
  }

  ChewieController? initialController(Feed feed, int currentMediaIndex) {
    String key = "${feed.id}_$currentMediaIndex";
    if (_videoControllers.containsKey(key)) {
      _controllerOrder.remove(key);
      _controllerOrder.add(key);
      return _videoControllers[key];
    }

    ChewieController? chewieController;
    var content = feed.contentList[currentMediaIndex];

    String url = getMediaImageUrl(content.mediaUrl,
        isVideo: content.mediaType == "video");

    if (content.mediaType == "video") {
      debugPrint("videoLink=====> $url");

      // fixS3Url is now called inside getMediaImageUrl, so no need for complex logic here
      final videoUri = Uri.tryParse(url);

      if (videoUri != null) {
        final videoPlayerController =
            VideoPlayerController.networkUrl(videoUri);
        chewieController = ChewieController(
          videoPlayerController: videoPlayerController,
          autoPlay: false,
          looping: false,
          showControls: true,
          aspectRatio: 16 / 9,
          autoInitialize: true,
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
        );
        _videoControllers[key] = chewieController;
        _controllerOrder.add(key);

        if (_controllerOrder.length > _maxCachedControllers) {
          String oldestKey = _controllerOrder.removeAt(0);
          var oldestController = _videoControllers.remove(oldestKey);
          oldestController?.videoPlayerController.dispose();
          oldestController?.dispose();
        }
      }
    }
    return chewieController;
  }
}
