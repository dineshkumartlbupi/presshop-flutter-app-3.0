import 'dart:io';
import 'package:flutter/services.dart'; // <-- ADD THIS
import 'package:flutter/material.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/view/cameraScreen/PreviewScreen.dart';
import 'package:video_player/video_player.dart';
import 'CommonWigdets.dart';

class VideoWidget extends StatefulWidget {
  MediaData? mediaData;

  VideoWidget({
    super.key,
    required this.mediaData,
  });

  @override
  VideoWidgetState createState() => VideoWidgetState();
}

class VideoWidgetState extends State<VideoWidget> {
  VideoPlayerController? _controller;
  late Future<void> _initializeVideoPlayerFuture;
  String currentTIme = "00:00";
  bool isLandscape = false;

  @override
  void initState() {
    _controller = VideoPlayerController.file(File(widget.mediaData!.mediaPath))
      ..addListener(() {
        if (_controller!.value.isInitialized) {
          setState(() {
            currentTIme = _controller!.value.position.inSeconds < 10
                ? "00:0${_controller!.value.position.inSeconds}"
                : "00:${_controller!.value.position.inSeconds}";
          });
        }
      });

    _initializeVideoPlayerFuture = _controller!.initialize().then((_) {
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    // Back to portrait when leaving screen
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _controller?.pause();
    _controller?.dispose();
    super.dispose();
  }

  void toggleOrientation() {
    if (!isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }

    setState(() {
      isLandscape = !isLandscape;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            _controller!.value.isInitialized) {
          return Container(
            color: Colors.black,
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                ),

                // Controls
                Container(
                  padding: EdgeInsets.only(
                      left: size.width * numD02, right: size.width * numD04),
                  child: Row(
                    children: [
                      // Play / Pause
                      InkWell(
                        onTap: () {
                          setState(() {
                            _controller!.value.isPlaying
                                ? _controller!.pause()
                                : _controller!.play();
                          });
                        },
                        child: Icon(
                          _controller!.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          size: size.width * numD08,
                          color: Colors.white,
                        ),
                      ),

                      // Progress bar
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: size.width * numD02),
                          child: VideoProgressIndicator(
                            _controller!,
                            allowScrubbing: true,
                            colors: VideoProgressColors(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              playedColor: colorThemePink,
                              bufferedColor: Colors.grey.withOpacity(0.5),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),

                      // Time
                      Text(
                        "$currentTIme / 00:${_controller!.value.duration.inSeconds}",
                        style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD025,
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                      ),

                      SizedBox(width: size.width * numD03),

                      // 🔄 Orientation Toggle Button
                      InkWell(
                        onTap: toggleOrientation,
                        child: Icon(
                          isLandscape
                              ? Icons.screen_rotation_alt
                              : Icons.screen_rotation,
                          size: size.width * numD06,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Center(child: showLoader());
        }
      },
    );
  }
}
