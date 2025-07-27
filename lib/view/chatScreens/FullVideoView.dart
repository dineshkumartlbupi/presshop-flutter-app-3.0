import 'dart:io';
import 'dart:ui' as ui;

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:video_player/video_player.dart';

import '../../utils/Common.dart';
import '../../utils/CommonWigdets.dart';

enum MediaTypeEnum {
  video,
  image,
  audio,
  pickFile,
}

class MediaViewScreen extends StatefulWidget {
  final String mediaFile;
  final MediaTypeEnum type;
  final isFromTutorialScreen;

  const MediaViewScreen(
      {super.key,
      required this.mediaFile,
      required this.type,
      this.isFromTutorialScreen = false});

  @override
  _MediaViewScreenState createState() => _MediaViewScreenState();
}

class _MediaViewScreenState extends State<MediaViewScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  FlickManager? flickManager;

  late Size size;

  PlayerController controller = PlayerController();

  bool audioPlaying = false;
  bool isLoading = false;

  @override
  void initState() {
    debugPrint("mediaUrl =====> ${widget.mediaFile}");
    if (widget.type == MediaTypeEnum.video) {
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.network(
            widget.isFromTutorialScreen
                ? widget.mediaFile
                : (taskMediaUrl + widget.mediaFile)),
      );
    } else if (widget.type == MediaTypeEnum.audio) {
      initWaveData();
    }
    _animationController =
        AnimationController(vsync: this, duration: Duration(minutes: 1));
    super.initState();
    debugPrint("Media Path=========>${widget.mediaFile}");
    debugPrint("Media Type=========>${widget.type}");
  }

  @override
  void dispose() {
    flickManager?.dispose();
    _animationController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor:
          widget.type == MediaTypeEnum.audio ? Colors.white : Colors.black,
      appBar: CommonAppBar(
          appBarbackgroundColor:
              widget.type == MediaTypeEnum.audio ? Colors.white : Colors.black,
          leadingIconColor:
              widget.type == MediaTypeEnum.audio ? Colors.black : Colors.white,
          elevation: 0,
          title: Text(
            widget.type == MediaTypeEnum.video ? 'Playing Video' : "",
            style: TextStyle(
                color: widget.type == MediaTypeEnum.video
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: size.width * appBarHeadingFontSize),
          ),
          centerTitle: true,
          titleSpacing: size.width * numD11,
          size: size,
          showActions: false,
          leadingFxn: () {
            Navigator.pop(context);
          },
          actionWidget: [],
          hideLeading: false),

      // AppBar(
      //   elevation: 0,
      //   backgroundColor:
      //       widget.type == MediaTypeEnum.audio ? Colors.white : Colors.black,
      //   centerTitle: true,
      //   automaticallyImplyLeading: false,
      //   leadingWidth: size.width * numD11,
      //   title: Text(
      //     widget.type == MediaTypeEnum.video ? 'Playing Video' : "",
      //     style: TextStyle(
      //         color: widget.type == MediaTypeEnum.video
      //             ? Colors.white
      //             : Colors.black,
      //         fontWeight: FontWeight.bold,
      //         fontSize: size.width * appBarHeadingFontSize),
      //   ),
      //   leading: Container(
      //     margin: EdgeInsets.only(left: size.width * numD04),
      //     child: InkWell(
      //       child: Image.asset(
      //         "${iconsPath}ic_arrow_left.png",
      //         height: size.width * numD03,
      //         width: size.width * numD03,
      //         color: widget.type == MediaTypeEnum.audio
      //             ? Colors.black
      //             : Colors.white,
      //       ),
      //       onTap: () {
      //         Navigator.pop(context);
      //       },
      //     ),
      //   ),
      // ),
      body: SafeArea(
        child: widget.type == MediaTypeEnum.video
            ? videoWidget()
            : widget.type == MediaTypeEnum.image
                ? imageWidget()
                : widget.type == MediaTypeEnum.pickFile
                    ? pickImageFileWidget()
                    : audioWidgetNew(),
      ),
    );
  }

  Widget videoWidget() {
    return FlickVideoPlayer(
      flickManager: flickManager!,
      flickVideoWithControlsFullscreen: const FlickVideoWithControls(
        willVideoPlayerControllerChange: false,
        controls: FlickLandscapeControls(),
      ),
    );
  }

  Widget pickImageFileWidget() {
    return PhotoView(
        minScale: PhotoViewComputedScale.contained * 1.0,
        maxScale: PhotoViewComputedScale.contained * 10.0,
        imageProvider: FileImage(File(widget.mediaFile)));
  }

  Widget imageWidget() {
    return Stack(
      alignment: Alignment.center,
      children: [
        PhotoView(
            minScale: PhotoViewComputedScale.contained * 1.0,
            maxScale: PhotoViewComputedScale.contained * 10.0,
            imageProvider: NetworkImage(widget.mediaFile)),
        ClipRRect(
            borderRadius: BorderRadius.circular(size.width * numD04),
            child: Image.asset(
              "${commonImagePath}watermark1.png",
              height: size.height / 3,
              width: double.infinity,
              fit: BoxFit.cover,
            )),
      ],
    );
  }

  Future initWaveData() async {
    var dio = Dio();
    dio.interceptors.add(LogInterceptor(responseBody: false));
    Directory appFolder = await getApplicationDocumentsDirectory();
    bool appFolderExists = await appFolder.exists();
    if (!appFolderExists) {
      final created = await appFolder.create(recursive: true);
      debugPrint(created.path);
    }

    final filepath = '${appFolder.path}/dummyFileRecordFile.m4a';
    debugPrint("Audio FilePath : $filepath");

    File(filepath).createSync();

    try {
      await dio.download(widget.mediaFile, filepath);
    } catch (e) {
      await dio.download(taskMediaUrl + widget.mediaFile, filepath);
    }

    await controller.preparePlayer(
      path: filepath,
      shouldExtractWaveform: true,
      noOfSamples: 100,
      volume: 1.0,
    );

    controller.onPlayerStateChanged.listen((event) {
      if (event.isPaused) {
        audioPlaying = false;
        if (mounted) {
          setState(() {});
        }
      }
    });
    isLoading = true;

    setState(() {});
  }

  Future playSound() async {
    await controller.startPlayer();
    _animationController.forward();
  }

  Future pauseSound() async {
    await controller.pausePlayer();
    _animationController.stop();
  }

  Widget audioWidgetNew() {
    return isLoading
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: size.height * numD025,
              ),
              Expanded(
                flex: 4,
                child: SizedBox(
                    // padding: EdgeInsets.all(size.width * numD04),
                    // decoration: const BoxDecoration(color: colorThemePink, shape: BoxShape.circle),
                    child: Image.asset("assets/commonImages/audio_logo.png")),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: size.width * numD04, right: size.width * numD04),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Lottie.asset("assets/lottieFiles/audio_waves.json",
                          width: double.infinity,
                          height: size.height * (isIpad ? numD70 : numD40),
                          backgroundLoading: true,
                          fit: BoxFit.fill,
                          controller: _animationController),
                      Align(
                        alignment: Alignment.center,
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            if (audioPlaying) {
                              pauseSound();
                            } else {
                              playSound();
                            }
                            audioPlaying = !audioPlaying;
                            setState(() {});
                          },
                          child: Container(
                            padding: EdgeInsets.all(size.width * numD018),
                            decoration: const BoxDecoration(
                                color: colorThemePink, shape: BoxShape.circle),
                            child: Container(
                              padding: EdgeInsets.all(
                                  size.width * (isIpad ? numD03 : numD04)),
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 4)),
                              child: Icon(
                                audioPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow_rounded,
                                size: size.width * numD16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          )
        : const Center(
            child: CircularProgressIndicator(
              color: colorThemePink,
            ),
          );
  }
}
