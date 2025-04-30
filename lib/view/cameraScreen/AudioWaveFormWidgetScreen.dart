import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../utils/Common.dart';
import 'dart:ui' as ui;

import 'PreviewScreen.dart';

class AudioWaveFormWidgetScreen extends StatefulWidget {
  String mediaPath = "";

  AudioWaveFormWidgetScreen({super.key, required this.mediaPath});

  @override
  State<StatefulWidget> createState() {
    return AudioWaveFormWidgetScreenState();
  }
}

class AudioWaveFormWidgetScreenState extends State<AudioWaveFormWidgetScreen>
    with SingleTickerProviderStateMixin {
  PlayerController waveFormPlayerController = PlayerController(); // Initialise

  bool audioPlaying = false;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initWaveData();
    });
    _controller =
        AnimationController(vsync: this, duration: Duration(minutes: 1));
  }

  @override
  void dispose() {
    waveFormPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: size.width * numD20,
          ),
          Expanded(
            flex: 2,
            child: SizedBox(
                // padding: EdgeInsets.all(size.width * numD04),
                // decoration: const BoxDecoration(color: colorThemePink, shape: BoxShape.circle),
                child: Image.asset(
              "assets/commonImages/audio_logo.png",
              width: double.infinity,
              height: double.infinity,
            )),
          ),
          SizedBox(
            height: size.width * numD20,
          ),
          Expanded(
              flex: isIpad ? 5 : 4,
              child: Padding(
                padding: EdgeInsets.all(size.width * numD04),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Lottie.asset("assets/lottieFiles/audio_waves.json",
                        width: isIpad ? size.width * num2 : double.infinity,
                        fit: BoxFit.fill,
                        controller: _controller),
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
                          padding: EdgeInsets.all(
                              size.width * (isIpad ? numD01 : numD018)),
                          decoration: const BoxDecoration(
                              color: colorThemePink, shape: BoxShape.circle),
                          child: Container(
                            padding: EdgeInsets.all(
                                size.width * (isIpad ? numD01 : numD04)),
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 4)),
                            child: Icon(
                              audioPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow_rounded,
                              size: size.width * (isIpad ? numD1 : numD16),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Future initWaveData() async {
    debugPrint("Wave-path:${widget.mediaPath}");
    await waveFormPlayerController.preparePlayer(
      path: widget.mediaPath,
      shouldExtractWaveform: true,
      noOfSamples: 100,
      volume: 1.0,
    );

    waveFormPlayerController.onPlayerStateChanged.listen((event) {
      if (event.isPaused) {
        audioPlaying = false;
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  Future playSound() async {
    debugPrint("PlayTheSound");

    await waveFormPlayerController.startPlayer().then((value) {
      debugPrint("PlayerState: ${waveFormPlayerController.playerState}");
    });
    _controller.forward();
    // Start audio player
  }

  Future pauseSound() async {
    await waveFormPlayerController.pausePlayer(); // Start audio player
    _controller.stop();
  }
}
