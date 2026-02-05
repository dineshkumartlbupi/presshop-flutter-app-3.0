import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:presshop/core/core_export.dart';

class FeedAudioPlayer extends StatefulWidget {

  const FeedAudioPlayer({
    super.key,
    required this.audioUrl,
    required this.size,
  });
  final String audioUrl;
  final Size size;

  @override
  State<FeedAudioPlayer> createState() => _FeedAudioPlayerState();
}

class _FeedAudioPlayerState extends State<FeedAudioPlayer> {
  late PlayerController controller;
  bool audioPlaying = false;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    controller = PlayerController();
    initWaveData(widget.audioUrl);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> initWaveData(String url) async {
    try {
      var dio = Dio();
      dio.interceptors.add(LogInterceptor(responseBody: false));

      Directory appFolder = await getApplicationDocumentsDirectory();
      final filepath = '${appFolder.path}/${url.hashCode}.m4a';

      File file = File(filepath);
      if (!await file.exists()) {
        await dio.download(url, filepath);
      }

      await controller.preparePlayer(
        path: filepath,
        shouldExtractWaveform: true,
        noOfSamples: 100,
        volume: 1.0,
      );

      controller.onPlayerStateChanged.listen((event) {
        if (event.isPaused || event.isStopped) {
          if (mounted) {
            setState(() {
              audioPlaying = false;
            });
          }
        }
      });

      if (mounted) {
        setState(() {
          isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Error initializing audio: $e");
    }
  }

  Future<void> playSound() async {
    await controller.startPlayer();
  }

  Future<void> pauseSound() async {
    await controller.pausePlayer();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return Container(
        height: widget.size.width * AppDimensions.numD50,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: AppColorTheme.colorThemePink),
      );
    }

    return Container(
      width: widget.size.width,
      alignment: Alignment.center,
      padding: EdgeInsets.all(widget.size.width * AppDimensions.numD04),
      decoration: BoxDecoration(
        color: AppColorTheme.colorThemePink,
        border: Border.all(color: AppColorTheme.colorGreyNew),
        borderRadius: BorderRadius.circular(widget.size.width * AppDimensions.numD06),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (audioPlaying)
            Lottie.asset(
              "assets/lottieFiles/ripple.json",
            ),
          InkWell(
            onTap: () {
              if (audioPlaying) {
                pauseSound();
              } else {
                playSound();
              }
              setState(() {
                audioPlaying = !audioPlaying;
              });
            },
            child: Icon(
              audioPlaying ? Icons.pause : Icons.play_arrow_rounded,
              color: Colors.white,
              size: widget.size.width * AppDimensions.numD15,
            ),
          ),
        ],
      ),
    );
  }
}
