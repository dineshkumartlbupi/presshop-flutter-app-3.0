import 'package:flutter/material.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:presshop/core/widgets/video_thumbnail_widget.dart';
import 'Inline_video_controller_manager.dart';

class InlineFlickPlayer extends StatefulWidget {
  const InlineFlickPlayer({
    super.key,
    required this.videoUrl,
    this.height = 220,
  });
  final String videoUrl;
  final double height;

  @override
  State<InlineFlickPlayer> createState() => _InlineFlickPlayerState();
}

class _InlineFlickPlayerState extends State<InlineFlickPlayer> {
  FlickManager? flickManager;

  bool showPlayer = false;
  bool isInitializing = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (InlineVideoControllerManager.currentManager == flickManager) {
      InlineVideoControllerManager.clear();
    } else {
      try {
        flickManager?.dispose();
      } catch (e) {}
    }

    super.dispose();
  }

  Future<void> _startAndPlay() async {
    if (isInitializing) return;
    isInitializing = true;

    // Create new FlickManager
    final videoPlayerController =
        VideoPlayerController.network(widget.videoUrl);

    flickManager = FlickManager(
      videoPlayerController: videoPlayerController,
      autoPlay: true, // Important
    );

    // CRITICAL: Set this as the active manager (your manager handles singleton)
    InlineVideoControllerManager.setActive(flickManager!);

    setState(() {
      showPlayer = true;
    });

    try {
      await videoPlayerController.initialize();

      // THIS IS THE KEY LINE: Unmute the video
      await videoPlayerController.setVolume(1.0);
      await flickManager?.flickControlManager?.unmute();

      // Optional: Ensure playback starts
      await flickManager!.flickControlManager?.play();

      // Extra safety: force unmute again after play
      await videoPlayerController.setVolume(1.0);
    } catch (e) {
      debugPrint('Video init error: $e');
    } finally {
      isInitializing = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Actual Flick Player UI
    if (showPlayer && flickManager != null) {
      final controller = flickManager!.flickVideoManager!.videoPlayerController;
      final initialized = controller?.value.isInitialized ?? false;
      final aspect = initialized ? controller!.value.aspectRatio : (16 / 9);

      return AspectRatio(
        aspectRatio: aspect,
        child: FlickVideoPlayer(flickManager: flickManager!),
      );
    }

    // Thumbnail with Play Button Overlay
    return GestureDetector(
      onTap: _startAndPlay,
      child: Container(
        // height: widget.height,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Thumbnail (first frame)
            VideoThumbnailWidget(
              videoUrl: widget.videoUrl,
              width: double.infinity,
              height: widget.height,
              fit: BoxFit.cover,
            ),

            // Play button in center
            const Icon(
              Icons.play_circle_fill_rounded,
              size: 70,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}
