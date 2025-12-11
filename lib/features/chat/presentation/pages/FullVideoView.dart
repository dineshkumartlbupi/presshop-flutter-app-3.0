import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:dio/dio.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:video_player/video_player.dart';

import 'package:presshop/core/core_export.dart';

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
  VideoPlayerController? _videoPlayerController;
  // Use a FutureBuilder key to track the initialization of the video
  Future<void>? _initializeVideoPlayerFuture;

  late Size size;

  PlayerController controller = PlayerController();

  bool audioPlaying = false;
  bool isLoading = false;

  @override
  void initState() {
    debugPrint("mediaUrl =====> ${widget.mediaFile}");
    if (widget.type == MediaTypeEnum.video) {
      final videoUrl = widget.isFromTutorialScreen
          ? widget.mediaFile
          : (taskMediaUrl + widget.mediaFile);

      debugPrint("mediaUrl1111 =====> $videoUrl");

      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      flickManager = FlickManager(
        videoPlayerController: _videoPlayerController!,
      );
      // Store the initialization future
      _initializeVideoPlayerFuture = _videoPlayerController!.initialize();
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
    _videoPlayerController?.dispose();
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
    // This is the correct logic for fixing the zoomed video
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Video is initialized, now we can get its aspect ratio
          final videoController = _videoPlayerController!;
          final double videoAspectRatio = videoController.value.aspectRatio;

          // Wrap the FlickVideoPlayer in AspectRatio to respect the video's dimensions
          return Center(
            // Center the video within the screen
            child: AspectRatio(
              aspectRatio: videoAspectRatio,
              child: FlickVideoPlayer(
                flickManager: flickManager!,
                flickVideoWithControlsFullscreen: const FlickVideoWithControls(
                  willVideoPlayerControllerChange: false,
                  // Flick Landscape controls usually use BoxFit.fit which is good.
                  controls: FlickLandscapeControls(),
                ),
              ),
            ),
          );
        } else {
          // While the video is loading, show a circular progress indicator
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
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
      // Assuming 'taskMediaUrl' is correctly defined elsewhere
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
              // Assuming 'colorThemePink' is defined in Common.dart
              color: colorThemePink,
            ),
          );
  }
}
