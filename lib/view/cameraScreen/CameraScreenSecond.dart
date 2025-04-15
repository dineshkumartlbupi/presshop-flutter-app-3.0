/*
import 'dart:async';
import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:native_exif/native_exif.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/view/cameraScreen/CustomGallary.dart';
import 'package:location/location.dart' as lc;
import 'package:record/record.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;
import '../../main.dart';
import 'dart:ui' as ui;
import '../../utils/CommonSharedPrefrence.dart';
import 'CameraScreen.dart';

class CameraScreenSecond extends StatefulWidget {
  const CameraScreenSecond({super.key});

  @override
  State<StatefulWidget> createState() {
    return CameraScreenSecondState();
  }
}

class CameraScreenSecondState extends State<CameraScreenSecond>
    with WidgetsBindingObserver {
  CameraController? cameraController;
  List<CameraData> camListData = [];
  Exif? exif;
  final ImagePicker _picker = ImagePicker();
  final _audioRecorder = Record();

  RecorderController recorderController = RecorderController(); // Initialise

  bool notesSelected = false,
      scanSelected = false,
      photoSelected = false,
      audioSelected = false,
      frontCamera = false,
      flashOn = false,
      showFocusCircle = false,
      _isRecordingInProgress = false,
      isAudioRecording = false;

  double x = 0, y = 0, latitude = 0, longitude = 0;
  lc.LocationData? locationData;
  lc.Location location = lc.Location();

  String selectedType = photoText, recordingTime = "", mediaPath = "";
  Duration? stopDurationDifference;
  DateTime? stopTime;
  DateTime? startTime;
  File? recentFile;

  Timer? myTimer;

  List<AssetEntity> _mediaList = [];
  AssetPathEntity? _path;
  int totalEntitiesCount = 0;

  final int _sizePerPage = 50;
  int page = 0;
  Future<void>? cameraValue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialiseControllers();
    initCamera(cameras[0]);
    requestLocationPermissions("");
    getMedia();
    requestPermission();
  }

  @override
  void dispose() {
    debugPrint("CameraDisposed");
    if (cameraController != null) {
      cameraController!.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("LifecycleState:::: $state");

    if (state == AppLifecycleState.inactive) {
      if (cameraController != null && cameraController!.value.isInitialized) {
        debugPrint("Condition1");
        cameraController!.dispose();
        cameraController = null;
      }
    } else if (state == AppLifecycleState.resumed) {
      debugPrint("InsideResummeee");
      debugPrint("CamCont: $cameraController");
      debugPrint("Condition3");

      if (cameraController != null && cameraController!.value.isInitialized) {
        cameraController!.dispose();
      }

      cameraController = null;
      initCamera(frontCamera ? cameras[1] : cameras[0]);
    }

    super.didChangeAppLifecycleState(state);
  }

  void requestPermission() async {
    await Permission.storage.request();
  }

  Future initCamera(CameraDescription cameraDescription) async {
    debugPrint("OInsideInitttt");
    cameraController =
        CameraController(cameraDescription, ResolutionPreset.max);
    debugPrint("OInsideInitttt2222");
    cameraValue = null;
    cameraValue = cameraController!.initialize().then((_) {
      debugPrint("Initialiseddddddd");

      if (!mounted) {
        debugPrint("NotMounte");

        return;
      }
      debugPrint("YesMount");

      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final cameraHeight = (size.height - size.width * numD25);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: selectedType == photoText || selectedType == videoText
            ? size.width * numD08
            : size.width * numD08,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * numD04),
            child: Column(
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * numD04),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
*/
/*
                      InkWell(
                          onTap: () {
                            recordingTime = "";
                            stopDurationDifference = null;
                            stopTime = null;
                            if (myTimer != null) {
                              myTimer!.cancel();
                            }
                            selectedType = notesText;

                            setState(() {});
                          },
                          child: FittedBox(
                              child: Text(
                            notesText,
                            style: TextStyle(
                                color: selectedType == notesText
                                    ? colorThemePink
                                    : Colors.black,
                                fontSize: size.width * numD04,
                                fontWeight: FontWeight.w500),
                          ))),
*//*

                      InkWell(
                          onTap: () {
                            recordingTime = "";
                            stopDurationDifference = null;
                            stopTime = null;
                            if (myTimer != null) {
                              myTimer!.cancel();
                            }
                            selectedType = scanText;
                            cameraController!.pausePreview();
                            openImageScanner();
                            setState(() {});
                          },
                          child: FittedBox(
                              child: Text(scanText,
                                  style: TextStyle(
                                      color: selectedType == scanText
                                          ? colorThemePink
                                          : Colors.black,
                                      fontSize: size.width * numD035,
                                      fontWeight: FontWeight.w500)))),
                      InkWell(
                          onTap: () {
                            recordingTime = "";
                            stopDurationDifference = null;
                            stopTime = null;
                            if (myTimer != null) {
                              myTimer!.cancel();
                            }
                            selectedType = photoText;
                            frontCamera = false;
                            initCamera(cameras[0]);
                            setState(() {});
                          },
                          child: FittedBox(
                              child: Text(photoText,
                                  style: TextStyle(
                                      color: selectedType == photoText
                                          ? colorThemePink
                                          : Colors.black,
                                      fontSize: size.width * numD035,
                                      fontWeight: FontWeight.w500)))),
                      InkWell(
                          onTap: () {
                            recordingTime = "";
                            stopDurationDifference = null;
                            stopTime = null;
                            if (myTimer != null) {
                              myTimer!.cancel();
                            }
                            selectedType = videoText;

                            frontCamera = false;
                            initCamera(cameras[0]);

                            setState(() {});
                          },
                          child: FittedBox(
                              child: Text(videoText,
                                  style: TextStyle(
                                      color: selectedType == videoText
                                          ? colorThemePink
                                          : Colors.black,
                                      fontSize: size.width * numD035,
                                      fontWeight: FontWeight.w500)))),
                      InkWell(
                          onTap: () {
                            recordingTime = "";
                            stopDurationDifference = null;
                            stopTime = null;
                            if (myTimer != null) {
                              myTimer!.cancel();
                            }
                            selectedType = audioText;

                            setState(() {});
                          },
                          child: FittedBox(
                              child: Text(audioText,
                                  style: TextStyle(
                                      color: selectedType == audioText
                                          ? colorThemePink
                                          : Colors.black,
                                      fontSize: size.width * numD035,
                                      fontWeight: FontWeight.w500)))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: size.width * numD04, vertical: size.width * numD02),
        child: commonElevatedButton(
            "Cancel",
            size,
            commonTextStyle(
                size: size,
                fontSize: size.width * numD04,
                color: Colors.white,
                fontWeight: FontWeight.w700),
            commonButtonStyle(size, colorThemePink),
            () {}),
      ),
      body: selectedType == photoText ||
              selectedType == videoText ||
              selectedType == scanText
          ? Stack(
              children: [
                cameraController != null &&
                        cameraController!.value.isInitialized
                    ? Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTapUp: _onTap,
                          child: CameraPreview(cameraController!),
                        ),
                      )
                    : Container(),
                selectedType == photoText
                    ? Align(
                        alignment: Alignment.bottomLeft,
                        child: InkWell(
                          onTap: () {
                            pickFiles();
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                                left: size.width * numD1,
                                bottom: size.width * numD05),
                            padding: EdgeInsets.all(size.width * numD02),
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white)),
                            child: Container(
                              padding: EdgeInsets.all(size.width * numD02),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                "${iconsPath}ic_plus.png",
                                color: Colors.white,
                                height: size.width * numD07,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: InkWell(
                    onTap: () {
                      debugPrint("VideoSelected $selectedType");

                      if (selectedType == videoText) {
                        if (_isRecordingInProgress) {
                          stopVideoRecording();
                        } else {
                          startVideoRecording();
                        }
                      } else {
                        showLoaderDialog(context);
                        requestLocationPermissions("Image");
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: size.width * numD05),
                      padding: EdgeInsets.all(size.width * numD01),
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(color: colorThemePink)),
                      child: Icon(
                        selectedType == videoText && _isRecordingInProgress
                            ? Icons.stop_circle_outlined
                            : Icons.circle,
                        color: colorThemePink,
                        size: size.width * numD13,
                      ),
                    ),
                  ),
                ),
                selectedType == photoText
                    ? Align(
                        alignment: Alignment.bottomRight,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => CustomGallery( picAgain:false,)));
                          },
                          child: Container(
                            width: size.width * numD15,
                            height: size.width * numD15,
                            margin: EdgeInsets.only(
                                bottom: size.width * numD05,
                                right: size.width * numD1),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(size.width * numD025),
                              child: mediaPath.isNotEmpty
                                  ? FutureBuilder(
                                      future: _mediaList.first
                                          .thumbnailDataWithSize(
                                              const ThumbnailSize(200, 200)),
                                      builder:
                                          (BuildContext context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          return Stack(
                                            children: <Widget>[
                                              Image.memory(
                                                snapshot.data!,
                                                fit: BoxFit.cover,
                                                width: size.width * numD15,
                                                height: size.width * numD15,
                                              ),
                                              if (_mediaList.first.type ==
                                                  AssetType.video)
                                                const Align(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 5, bottom: 5),
                                                    child: Icon(
                                                      Icons.videocam,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          );
                                        }
                                        return Container();
                                      },
                                    )
                                  : Image.asset(
                                      "${dummyImagePath}walk2.png",
                                      height: size.width * numD15,
                                      width: size.width * numD15,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                      )
                    : Container(),
                showFocusCircle
                    ? Positioned(
                        top: y - 20,
                        left: x - 20,
                        child: Image.asset(
                          "${iconsPath}ic_focus.png",
                          width: size.width * numD15,
                          height: size.width * numD15,
                          color: Colors.white,
                        ))
                    : Container(),
                selectedType == photoText || selectedType == videoText
                    ? Positioned(
                        top: size.width * numD06,
                        left: size.width * numD1,
                        right: size.width * numD1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            !frontCamera
                                ? InkWell(
                                    onTap: () {
                                      cameraController!.setFlashMode(flashOn
                                          ? FlashMode.off
                                          : FlashMode.torch);
                                      flashOn = !flashOn;
                                      setState(() {});
                                    },
                                    child: Container(
                                        padding:
                                            EdgeInsets.all(size.width * numD01),
                                        decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle),
                                        child: Icon(
                                            flashOn
                                                ? Icons.flash_on
                                                : Icons.flash_off,
                                            color: Colors.black,
                                            size: size.width * numD04)),
                                  )
                                : Container(),
                            selectedType == videoText
                                ? Text(
                                    recordingTime,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD035,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500),
                                  )
                                : Container(),
                            InkWell(
                              onTap: () {
                                frontCamera = !frontCamera;
                                initCamera(
                                    frontCamera ? cameras[1] : cameras[0]);
                              },
                              child: Container(
                                padding: EdgeInsets.all(size.width * numD01),
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                                child: Image.asset(
                                  "${iconsPath}ic_rotate.png",
                                  height: size.width * numD04,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
              ],
            )
          : selectedType == audioText
              ? Column(
                  children: [
                    */
/* Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                          onTap: () {},
                          child: Container(
                              padding: EdgeInsets.all(size.width * numD04),
                              margin:
                                  EdgeInsets.only(right: size.width * numD04),
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorThemePink),
                              child: Icon(
                                Icons.waves,
                                color: Colors.white,
                                size: size.width * numD07,
                              ))),
                    ),*//*

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
                                Offset(
                                    MediaQuery.of(context).size.width / 2, 0),
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
                              }

                              isAudioRecording = !isAudioRecording;
                              setState(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.all(isAudioRecording
                                  ? size.width * numD04
                                  : size.width * numD04),
                              decoration: const BoxDecoration(
                                  color: colorThemePink,
                                  shape: BoxShape.circle),
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
                    )
                  ],
                )
              : Container(),
    );
  }

  void _initialiseControllers() {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
  }

  Future getMedia() async {
    var result = await PhotoManager.requestPermissionExtend();

    if (result.isAuth) {
      // success
//load the album list
      List<AssetPathEntity> paths =
          await PhotoManager.getAssetPathList(onlyAll: true);

      if (paths.isNotEmpty) {
        setState(() {
          _path = paths.first;
        });
        debugPrint("Pathhhh: $_path");

        totalEntitiesCount = await _path!.assetCountAsync;

        List<AssetEntity> media =
            await _path!.getAssetListPaged(page: page, size: _sizePerPage);
        _mediaList = media;
        debugPrint("MyMedia: $media");
      }

      if (_mediaList.isNotEmpty) {
        mediaPath = _mediaList.first.relativePath ?? "";

        debugPrint("MediPath: $mediaPath");
      }

      if (!mounted) {
        return;
      }
      setState(() {});
    } else {
      /// if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
      PhotoManager.openSetting();
    }
  }

  Future takePicture(String address) async {
    if (cameraController == null) {
      return;
    }

    if (cameraController != null && !cameraController!.value.isInitialized) {
      return null;
    }
    if (cameraController != null && cameraController!.value.isTakingPicture) {
      return null;
    }
    AudioPlayer().play(AssetSource("${audioPath}camera_shutter.wav"));
    try {
      await cameraController!.setFlashMode(FlashMode.off);
      XFile picture = await cameraController!.takePicture();
      exif = await Exif.fromPath(picture.path);
      String sLat = latitude.toString();
      String sLong = longitude.toString();
      await exif!.writeAttributes({"GPSLatitude": sLat, "GPSLongitude": sLong});

      GallerySaver.saveImage(picture.path);
      cameraController!.pausePreview();

      camListData.add( CameraData(
          path: picture.path,
          mimeType: "image",
          videoImagePath: "",
        latitude: sharedPreferences!
            .getDouble(currentLat)
            .toString() ??
            "",
        longitude: sharedPreferences!
            .getDouble(currentLon)
            .toString() ??
            "",
        dateTime: DateFormat("HH:mm, dd MMM yyyy")
            .format(DateTime.now()),
        location: sharedPreferences!
            .getString(currentAddress) ??
            "",
        country: sharedPreferences!
            .getString(currentCountry) ??
            "",
        city: sharedPreferences!
            .getString(currentCity) ??
            "",
        state: sharedPreferences!
            .getString(currentState) ??
            "",));

      Navigator.pop(navigatorKey.currentState!.context, camListData);
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  Future<void> _onTap(TapUpDetails details) async {
    if (cameraController!.value.isInitialized) {
      showFocusCircle = true;
      x = details.localPosition.dx;
      y = details.localPosition.dy;

      double fullWidth = MediaQuery.of(context).size.width;
      double cameraHeight = fullWidth * cameraController!.value.aspectRatio;

      double xp = x / fullWidth;
      double yp = y / cameraHeight;

      Offset point = Offset(xp, yp);
      debugPrint("point : $point");

      // Manually focus
      await cameraController!.setFocusPoint(point);

      // Manually set light exposure
      //controller.setExposurePoint(point);

      setState(() {
        Future.delayed(const Duration(seconds: 2)).whenComplete(() {
          setState(() {
            showFocusCircle = false;
          });
        });
      });
    }
  }

  Future<void> startVideoRecording() async {
    if (cameraController!.value.isRecordingVideo) {
      return;
    }
    AudioPlayer()
        .play(AssetSource("${audioPath}video_start.wav"))
        .then((value) async {
      try {
        await cameraController!.startVideoRecording().then((value) {
          recordTime();
        });
        setState(() {
          _isRecordingInProgress = true;
          debugPrint("Testt: $_isRecordingInProgress");
        });
      } on CameraException catch (e) {
        debugPrint('Error starting to record video: $e');
      }
    });
  }

  Future stopVideoRecording() async {
    if (!cameraController!.value.isRecordingVideo) {
      // Recording is already is stopped state
      return null;
    }
    if (myTimer != null) {
      myTimer!.cancel();
    }
    AudioPlayer().play(AssetSource("${audioPath}video_stop.wav"));

    try {
      XFile file = await cameraController!.stopVideoRecording();
      setState(() {
        _isRecordingInProgress = false;
        debugPrint("$_isRecordingInProgress");
      });

      GallerySaver.saveVideo(file.path);
      cameraController!.pausePreview();

      getVideoThumbNail(file.path);
    } on CameraException catch (e) {
      debugPrint('Error stopping video recording: $e');
      return null;
    }
  }

  Future getVideoThumbNail(String path) async {
    final thumbnail = await vt.VideoThumbnail.thumbnailFile(
      video: path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: vt.ImageFormat.PNG,
      maxHeight: 500,
      quality: 100,
    );
    debugPrint("MimeType: ${lookupMimeType(path)}");

    camListData.add( CameraData(
        path: path,
        videoImagePath: thumbnail ?? "",
        mimeType: "video",
      latitude: sharedPreferences!
          .getDouble(currentLat)
          .toString() ??
          "",
      longitude: sharedPreferences!
          .getDouble(currentLon)
          .toString() ??
          "",
      dateTime: DateFormat("HH:mm, dd MMM yyyy")
          .format(DateTime.now()),
      location: sharedPreferences!
          .getString(currentAddress) ??
          "",
      country: sharedPreferences!
          .getString(currentCountry) ??
          "",
      city: sharedPreferences!
          .getString(currentCity) ??
          "",
      state: sharedPreferences!
          .getString(currentState) ??
          "",));

    Navigator.pop(navigatorKey.currentState!.context, camListData);
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
    debugPrint("HaspErmisss: ${await _audioRecorder.hasPermission()}");

    if (await _audioRecorder.hasPermission()) {
      Directory appFolder = await getApplicationDocumentsDirectory();
      bool appFolderExists = await appFolder.exists();
      if (!appFolderExists) {
        debugPrint("InsideSSS");
        final created = await appFolder.create(recursive: true);
        debugPrint(created.path);
      }

      final filepath = '${appFolder.path}/recording.m4a';
      debugPrint(filepath);
      debugPrint("FilePath: $filepath");

      await recorderController.record(path: filepath).then((value) {
        recordTime();
      });
    } else {
      debugPrint('PPPPPP');

      requestPermission();
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
        debugPrint("MimeType: ${lookupMimeType(path)}");

        camListData .add(CameraData(
            path: path,
            mimeType: "audio",
            videoImagePath: "",
          latitude: sharedPreferences!
              .getDouble(currentLat)
              .toString() ??
              "",
          longitude: sharedPreferences!
              .getDouble(currentLon)
              .toString() ??
              "",
          dateTime: DateFormat("HH:mm, dd MMM yyyy")
              .format(DateTime.now()),
          location: sharedPreferences!
              .getString(currentAddress) ??
              "",
          country: sharedPreferences!
              .getString(currentCountry) ??
              "",
          city: sharedPreferences!
              .getString(currentCity) ??
              "",
          state: sharedPreferences!
              .getString(currentState) ??
              "",));

        Navigator.pop(navigatorKey.currentState!.context, camListData);
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

  requestLocationPermissions(String type) async {
    lc.PermissionStatus permissionGranted;
    bool serviceEnabled;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }

    if (serviceEnabled) {
      permissionGranted = await location.hasPermission();

      debugPrint("PG: $permissionGranted");

      switch (permissionGranted) {
        case lc.PermissionStatus.granted:
          getCurrentLocationFxn(type);
          break;
        case lc.PermissionStatus.grantedLimited:
          showSnackBar("Error", "Permission is limited", Colors.red);

          break;
        case lc.PermissionStatus.denied:
          serviceEnabled = await location.requestService().then((value) {
            getCurrentLocationFxn(type);
            return true;
          });
          break;
        case lc.PermissionStatus.deniedForever:
          openAppSettings().then((value) {
            if (value) {
              getCurrentLocationFxn(type);
            }
          });
          break;
      }
    }
  }

  getCurrentLocationFxn(String type) async {
    try {
      debugPrint("GettingLocation");

      locationData = await location.getLocation();

      if (locationData != null) {
        debugPrint("NotNull");

        // showLoader = false;
        if (locationData!.latitude != null) {
          latitude = locationData!.latitude!;
          longitude = locationData!.longitude!;

          debugPrint("MyLatttt: ${locationData!.latitude}");
          debugPrint("MyLonggggg: ${locationData!.longitude}");

          if (type == "Image") {
            List<Placemark> placeMarkList =
                await placemarkFromCoordinates(latitude, longitude);

            if (placeMarkList.isNotEmpty) {
              debugPrint("PlacemarkNotEmpty");
            } else {
              debugPrint("Empty");
            }

            takePicture(
                "${placeMarkList.first.name}, ${placeMarkList.first.locality}, ${placeMarkList.first.street}, ${placeMarkList.first.administrativeArea}, ${placeMarkList.first.country}");
          }

          if (alertDialog != null) {
            alertDialog = null;
            Navigator.of(navigatorKey.currentContext!).pop();
          }
        }
      } else {
        debugPrint("Nullll");

        showSnackBar("Location Error", "nullLocationText", Colors.black);
      }
    } on Exception catch (e) {
      debugPrint("PEx: $e");

      showSnackBar("Exception", e.toString(), Colors.black);
    }
  }

  openImageScanner() async {
    final image = await CunningDocumentScanner.getPictures(scanSelected);
    //final image = await CunningDocumentScanner.getPictures();

    if (image != null && image.isNotEmpty) {
      if (cameraController != null) {
        cameraController!.pausePreview();
      }
      debugPrint("MimeType: ${lookupMimeType(image.first)}");

      camListData.add(CameraData(
          path: image.first,
          mimeType: "image",
          videoImagePath: "",
        latitude: sharedPreferences!
            .getDouble(currentLat)
            .toString() ??
            "",
        longitude: sharedPreferences!
            .getDouble(currentLon)
            .toString() ??
            "",
        dateTime: DateFormat("HH:mm, dd MMM yyyy")
            .format(DateTime.now()),
        location: sharedPreferences!
            .getString(currentAddress) ??
            "",
        country: sharedPreferences!
            .getString(currentCountry) ??
            "",
        city: sharedPreferences!
            .getString(currentCity) ??
            "",
        state: sharedPreferences!
            .getString(currentState) ??
            "",));

      Navigator.pop(navigatorKey.currentState!.context, camListData);

      setState(() {});
    }
  }

  pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      if (cameraController != null) {
        cameraController!.pausePreview();
      }
      debugPrint("MimeType: ${lookupMimeType(file.path)}");

    camListData.add(CameraData(
          path: file.path,
          mimeType: "doc",
          videoImagePath: "",
        latitude: sharedPreferences!
            .getDouble(currentLat)
            .toString() ??
            "",
        longitude: sharedPreferences!
            .getDouble(currentLon)
            .toString() ??
            "",
        dateTime: DateFormat("HH:mm, dd MMM yyyy")
            .format(DateTime.now()),
        location: sharedPreferences!
            .getString(currentAddress) ??
            "",
        country: sharedPreferences!
            .getString(currentCountry) ??
            "",
        city: sharedPreferences!
            .getString(currentCity) ??
            "",
        state: sharedPreferences!
            .getString(currentState) ??
            "",));

      Navigator.pop(navigatorKey.currentState!.context, camListData);
    } else {
      // User canceled the picker
    }
  }
}
*/
