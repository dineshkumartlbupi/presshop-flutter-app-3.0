// InlineFlickPlayer.dart
import 'package:flutter/material.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:video_player/video_player.dart';
import 'InlineVideoControllerManager.dart';

class InlineFlickPlayer extends StatefulWidget {
  final String videoUrl;
  final double height;

  const InlineFlickPlayer({
    super.key,
    required this.videoUrl,
    this.height = 220,
  });

  @override
  State<InlineFlickPlayer> createState() => _InlineFlickPlayerState();
}

class _InlineFlickPlayerState extends State<InlineFlickPlayer> {
  FlickManager? flickManager;
  bool showPlayer = false;
  bool isInitializing = false;

  @override
  void dispose() {
    // If this instance created the manager and it's still current, clear it.
    if (InlineVideoControllerManager.currentManager == flickManager) {
      InlineVideoControllerManager.clear();
    } else {
      // Otherwise just dispose our local manager (if any).
      try {
        flickManager?.dispose();
      } catch (e) {}
    }
    super.dispose();
  }

  Future<void> _startAndPlay() async {
    if (isInitializing) return;
    isInitializing = true;

    // Create manager with network controller
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network(widget.videoUrl),
    );

    // Make this manager the active one (will pause previous).
    InlineVideoControllerManager.setActive(flickManager!);

    setState(() {
      showPlayer = true;
    });

    // Wait for underlying VideoPlayer to initialize, then play.
    try {
      final controller =
          flickManager!.flickVideoManager!.videoPlayerController!;
      await controller.initialize();
      // Ensure aspect ratio widget can use controller.value.aspectRatio
      // Start playback via the control manager (recommended).
      flickManager!.flickControlManager?.play();
      // Optionally set loop:
      // controller.setLooping(true);
    } catch (e) {
      // initialization failed — keep the UI updated.
      debugPrint('Video init error: $e');
    } finally {
      isInitializing = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show player when showPlayer true and manager exists and initialized
    if (showPlayer && flickManager != null) {
      final controller = flickManager!.flickVideoManager!.videoPlayerController;
      final initialized = controller?.value.isInitialized ?? false;
      final aspect = initialized ? controller!.value.aspectRatio : (16 / 9);

      return AspectRatio(
        aspectRatio: aspect,
        child: FlickVideoPlayer(
          flickManager: flickManager!,
          // You can add controls config here if you want:
          // flickVideoWithControls: const FlickVideoWithControls(controls: FlickPortraitControls()),
        ),
      );
    }

    // Thumbnail / Play-button
    return GestureDetector(
      onTap: _startAndPlay,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Icon(
            Icons.play_circle_fill,
            size: 60,
            color: Color.fromARGB(171, 255, 44, 44),
          ),
        ),
      ),
    );
  }
}
