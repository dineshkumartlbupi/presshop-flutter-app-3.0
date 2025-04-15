import 'dart:io';
import 'dart:ui' as ui;

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
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

  const MediaViewScreen(
      {super.key, required this.mediaFile, required this.type});

  @override
  _MediaViewScreenState createState() => _MediaViewScreenState();
}

class _MediaViewScreenState extends State<MediaViewScreen> {
  FlickManager? flickManager;

  late Size size;

  AudioPlayer audioPlayer = AudioPlayer();
  PlayerController controller = PlayerController();

  bool audioPlaying = false;
  bool isLoading = false;

  @override
  void initState() {
    debugPrint("mediaUrl =====> ${widget.mediaFile}");
    if (widget.type == MediaTypeEnum.video) {
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.network(taskMediaUrl+widget.mediaFile),
      );
    } else if (widget.type == MediaTypeEnum.audio) {
      initWaveData();
    }
    super.initState();
    debugPrint("Media Path=========>${widget.mediaFile}");
    debugPrint("Media Type=========>${widget.type}");
  }

  @override
  void dispose() {
    flickManager?.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor:widget.type == MediaTypeEnum.audio?Colors.white:Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor:widget.type == MediaTypeEnum.audio?Colors.white:Colors.black,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leadingWidth: size.width * numD11,
        title: Text(
          widget.type == MediaTypeEnum.video ? 'Playing Video' : "",
          style: TextStyle(
              color: widget.type == MediaTypeEnum.video
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: size.width * appBarHeadingFontSize),
        ),
        leading: Container(
          margin: EdgeInsets.only(left: size.width * numD04),
          child: InkWell(
            child: Image.asset(
              "${iconsPath}ic_arrow_left.png",
              height: size.width * numD03,
              width: size.width * numD03,
              color:widget.type == MediaTypeEnum.audio?Colors.black:Colors.white,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: SafeArea(
        child: widget.type == MediaTypeEnum.video
            ? videoWidget()
            : widget.type == MediaTypeEnum.image
                ? imageWidget()
                : widget.type == MediaTypeEnum.pickFile
                    ? pickImageFileWidget()
                    : audioWidget(),
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

    await dio.download(widget.mediaFile, filepath);

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
  }
  Future pauseSound() async {
    await controller.pausePlayer();
  }

  Widget audioWidget() {
    return isLoading
        ? Column(
            children: [
              SizedBox(
                height: size.width * numD05,
              ),
              Container(
                padding: EdgeInsets.all(size.width * numD02),
                decoration: const BoxDecoration(
                    color: colorThemePink, shape: BoxShape.circle),
                child: Container(
                    padding: EdgeInsets.all(size.width * numD07),
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white, width: size.width * numD01)),
                    child: Icon(
                      Icons.mic_none_outlined,
                      size: size.width * numD25,
                      color: Colors.white,
                    )),
              ),
              const Spacer(),
              AudioFileWaveforms(
                size: Size(size.width, 100.0),
                playerController: controller,
                enableSeekGesture: true,
                waveformType: WaveformType.long,
                continuousWaveform: true,
                playerWaveStyle: PlayerWaveStyle(
                  fixedWaveColor: Colors.black,
                  liveWaveColor: colorThemePink,
                  spacing: 6,
                  liveWaveGradient: ui.Gradient.linear(
                    const Offset(70, 50),
                    Offset(MediaQuery.of(context).size.width / 2, 0),
                    [Colors.red, Colors.green],
                  ),
                  fixedWaveGradient: ui.Gradient.linear(
                    const Offset(70, 50),
                    Offset(MediaQuery.of(context).size.width / 2, 0),
                    [Colors.red, Colors.green],
                  ),
                  seekLineColor: colorThemePink,
                  seekLineThickness: 2,
                  showSeekLine: true,
                  showBottom: true,
                ),
              ),
              SizedBox(
                height: size.width * numD15,
              ),
              InkWell(
                onTap: () {
                  if (audioPlaying) {
                    pauseSound();
                  } else {
                    playSound();
                  }

                  audioPlaying = !audioPlaying;
                  setState(() {});
                },
                child: Icon(
                  audioPlaying ? Icons.pause_circle : Icons.play_circle,
                  color: colorThemePink,
                  size: size.width * numD20,
                ),
              ),
              const Spacer(),
            ],
          )
        : const Center(
          child: CircularProgressIndicator(
      color: colorThemePink,
    ),
        );
  }
}
