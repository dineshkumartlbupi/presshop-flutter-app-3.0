import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class FeedVideoPlayer extends StatelessWidget {

  const FeedVideoPlayer({
    super.key,
    required this.videoKey,
    required this.chewieController,
  });
  final Key videoKey;
  final ChewieController? chewieController;

  @override
  Widget build(BuildContext context) {
    if (chewieController == null) {
      return Container();
    }

    return VisibilityDetector(
      key: videoKey,
      onVisibilityChanged: (visibility) {
        if (visibility.visibleFraction < 0.6) {
          chewieController?.pause();
        }
      },
      child: Chewie(
        key: videoKey,
        controller: chewieController!,
      ),
    );
  }
}
