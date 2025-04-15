import 'dart:io';
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
  double starRating = 0.0;
  String currentTIme = "00:00";

  @override
  void initState() {
    print("MediaFile: ${widget.mediaData!.mediaPath}");
    _controller = VideoPlayerController.file(File(widget.mediaData!.mediaPath));
    super.initState();
    _initializeVideoPlayerFuture = _controller!.initialize().then((_) {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(VideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    debugPrint("IAmDissssspose");
    if(_controller!=null){
      _controller!.pause();
      _controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    debugPrint("Again");

    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Expanded(child: VideoPlayer(_controller!)),
            Container(
              padding: EdgeInsets.only(
                  left: size.width * numD02, right: size.width * numD04),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (_controller!.value.isPlaying) {
                          _controller!.pause();
                        } else {
                          _controller!.play();
                        }
                      });
                    },
                    child: Icon(
                      _controller!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: size.width * numD08,
                      color: Colors.black,
                    ),
                  ),
                  Expanded(
                      child: Container(
                    margin: EdgeInsets.symmetric(horizontal: size.width * numD02),
                    child: VideoProgressIndicator(
                      _controller!,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        backgroundColor: Colors.black.withOpacity(0.2),
                        playedColor: colorThemePink,
                        bufferedColor: Colors.grey.withOpacity(0.5),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  )),
                  Text(
                    "$currentTIme / 00:${_controller!.value.duration.inSeconds}",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD025,
                        color: Colors.black,
                        fontWeight: FontWeight.normal),
                  )
                ],
              ),
            )
              ],
            ),
          );
        } else {
          return  Center(
            child:showLoader(),
          );
        }
      },
    );
  }
}
