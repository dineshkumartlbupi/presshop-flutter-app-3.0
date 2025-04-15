import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/view/cameraScreen/PreviewScreen.dart';
import 'package:record/record.dart';

import '../../main.dart';
import 'dart:ui' as ui;

class AudioRecorderScreen extends StatefulWidget {
  const AudioRecorderScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return AudioRecorderScreenState();
  }
}

class AudioRecorderScreenState extends State<AudioRecorderScreen> {
  RecorderController recorderController = RecorderController(); // Initialise
  final _audioRecorder = AudioRecorder();

  bool audioSelected = false,
      showSubmitButton = false,
      isAudioRecording = false;

  String recordingTime = "";
  Duration? stopDurationDifference;
  DateTime? stopTime;
  DateTime? startTime;
  File? recentFile;

  Timer? myTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    recorderController.dispose();
    if (myTimer != null) {
      myTimer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: CommonAppBar(
            elevation: 0,
            title: Text(
              "Record Audio",
              style: commonTextStyle(
                  size: size,
                  fontSize: size.width * numD05,
                  color: Colors.black,
                  fontWeight: FontWeight.w700),
            ),
            centerTitle: false,
            titleSpacing: size.width * numD02,
            size: size,
            showActions: true,
            leadingFxn: () {
              Navigator.pop(context);
            },
            actionWidget: [
              InkWell(
                child: Image.asset(
                  "${commonImagePath}rabbitLogo.png",
                  height: size.width * numD07,
                  width: size.width * numD07,
                ),
              ),
              SizedBox(
                width: size.width * numD04,
              )
            ],
            hideLeading: false),
        body: SafeArea(
            child: Column(
          children: [
            const Spacer(),
            isAudioRecording
                ? AudioWaveforms(
                    size: Size(MediaQuery.of(context).size.width, 100),
                    recorderController: recorderController,
                    enableGesture: false,
                    backgroundColor: Colors.transparent,
                    shouldCalculateScrolledPosition: true,
                    waveStyle: WaveStyle(
                      waveColor: colorThemePink,
                      extendWaveform: true,
                      showMiddleLine: false,
                      showDurationLabel: false,
                      gradient: ui.Gradient.linear(
                        const Offset(70, 50),
                        Offset(MediaQuery.of(context).size.width / 2, 0),
                        [Colors.red, Colors.green],
                      ),
                    ),
                  )
                : Container(),
            Text(
              recordingTime.isEmpty ? "00:00:00" : recordingTime,
              style: commonTextStyle(
                  size: size,
                  fontSize: size.width * numD15,
                  color: Colors.black,
                  fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * numD08,
                  vertical: size.width * numD04),
              child: Row(
                children: [
                  recordingTime.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            stopAudioRecording(false);
                          },
                          icon: Icon(
                            Icons.close,
                            color: Colors.red,
                            size: size.width * numD08,
                          ))
                      : Container(),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      if (isAudioRecording) {
                        pauseAudioRecording();
                      } else {
                        startAudioRecording();
                        if (!showSubmitButton) {
                          showSubmitButton = true;
                        }
                      }
                      isAudioRecording = !isAudioRecording;
                      setState(() {});
                    },
                    child: Container(
                      padding: EdgeInsets.all(isAudioRecording
                          ? size.width * numD04
                          : size.width * numD04),
                      decoration: const BoxDecoration(
                          color: colorThemePink, shape: BoxShape.circle),
                      child: Icon(
                          isAudioRecording
                              ? Icons.square
                              : Icons.mic_none_outlined,
                          color: Colors.white,
                          size: isAudioRecording
                              ? size.width * numD07
                              : size.width * numD1),
                    ),
                  ),
                  const Spacer(),
                  recordingTime.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            stopAudioRecording(true);
                          },
                          icon: Icon(
                            Icons.check,
                            color: colorOnlineGreen,
                            size: size.width * numD08,
                          ))
                      : Container(),
                ],
              ),
            ),
          ],
        )),
      ),
    );
  }

  void recordTime() {
    if (stopTime != null) {
      stopDurationDifference = stopTime!.difference(startTime!);

      debugPrint("StopDurationDifference:$stopDurationDifference");
    }

    startTime = stopDurationDifference != null
        ? DateTime.now().subtract(stopDurationDifference!)
        : DateTime.now();
    debugPrint("NewStartTime: $startTime");
    debugPrint("CurrentTime: ${DateTime.now()}");

    myTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      var diff = DateTime.now().difference(startTime!);

      int hoursDiff = diff.inHours < 60 ? diff.inHours : 0;
      int minutesDiff = diff.inMinutes < 60 ? diff.inMinutes : 0;
      int secondsDiff = diff.inSeconds < 60 ? diff.inSeconds : 0;

      String hDiff = hoursDiff < 10 ? "0$hoursDiff" : hoursDiff.toString();
      String mDiff =
          minutesDiff < 10 ? "0$minutesDiff" : minutesDiff.toString();
      String sDiff =
          secondsDiff < 10 ? "0$secondsDiff" : secondsDiff.toString();

      recordingTime = "$hDiff:$mDiff:$sDiff";
      stopDurationDifference = diff;
      debugPrint(recordingTime);

      setState(() {});
    });
  }

  void startAudioRecording() async {
    if (await _audioRecorder.hasPermission()) {
      Directory appFolder = await getApplicationDocumentsDirectory();
      bool appFolderExists = await appFolder.exists();
      if (!appFolderExists) {
        final created = await appFolder.create(recursive: true);
        debugPrint(created.path);
      }

      final filepath =
          '${appFolder.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
      debugPrint("Audio FilePath : $filepath");

      File(filepath).createSync();

      if(File(filepath).existsSync()){
        await recorderController.record(path: filepath).then((value) {
          recordTime();
        });
      }
    } else {
      debugPrint('Permissions not granted');
    }
  }

  void stopAudioRecording(bool nextScreen) async {
    if (nextScreen) {
      String? path = await recorderController.stop();

      if (myTimer != null) {
        myTimer!.cancel();
      }
      isAudioRecording = false;

      if (path!.isNotEmpty) {
        Navigator.pop(navigatorKey.currentState!.context, [path,recordingTime]);
      }
    } else {
      if (recorderController.isRecording) {
        await recorderController.stop().then((value) {
          recordingTime = "00:00:00";
          if (myTimer != null) {
            myTimer!.cancel();
          }
          isAudioRecording = false;
        });
      } else {
        recordingTime = "00:00:00";
        if (myTimer != null) {
          myTimer!.cancel();
        }
        isAudioRecording = false;
      }
    }
    setState(() {});
  }

  void pauseAudioRecording() async {
    await recorderController.pause();

    if (myTimer != null) {
      myTimer!.cancel();
      stopTime = DateTime.now();
    }
    isAudioRecording = false;

    setState(() {});
  }
}
