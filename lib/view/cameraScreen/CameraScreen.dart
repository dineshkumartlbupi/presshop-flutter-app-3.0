import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:native_exif/native_exif.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonSharedPrefrence.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/commonEnums.dart';
import 'package:presshop/view/cameraScreen/CustomGallary.dart';
import 'package:presshop/view/cameraScreen/PreviewScreen.dart';
import 'package:record/record.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../main.dart';
import 'dart:ui' as ui;
import '../../utils/image_crop_util.dart';
import '../dashboard/Dashboard.dart';
import '../permission_error_screen.dart';

String getRandomString(int length) {
  const characters = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
  Random random = Random();
  return String.fromCharCodes(Iterable.generate(
      length, (_) => characters.codeUnitAt(random.nextInt(characters.length))));
}

class CameraScreen extends StatefulWidget {
  final bool picAgain;
  final ScreenNameEnum previousScreen;

  const CameraScreen({
    super.key,
    required this.picAgain,
    required this.previousScreen,
  });

  @override
  State<StatefulWidget> createState() {
    return CameraScreenState();
  }
}

class CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? cameraController;

  Exif? exif;

  //final ImagePicker _picker = ImagePicker();
  final _audioRecorder = AudioRecorder();
  int totalEntitiesCount = 0;
  final int _sizePerPage = 50;
  int page = 0;

  RecorderController recorderController = RecorderController();

  // Initialise
  double x = 0, y = 0, latitude = 0, longitude = 0;

  String selectedType = photoText, recordingTime = "", mediaPath = "";
  bool notesSelected = false,
      scanSelected = false,
      photoSelected = false,
      audioSelected = false,
      frontCamera = false,
      flashOn = false,
      showFocusCircle = false,
      _isRecordingInProgress = false,
      isAudioRecording = false;

  Duration? stopDurationDifference;
  DateTime? stopTime;
  DateTime? startTime;

  File? recentFile;

  Timer? myTimer;

  Future<void>? cameraValue;
  List<AssetEntity> _mediaList = [];
  List<CameraData> camListData = [];
  AssetPathEntity? _path;
  int _pointers = 0;
  late double _minAvailableZoom;
  late double _maxAvailableZoom;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  bool pageReplaced = false;

  late AnimationController _exposureModeControlRowAnimationController;
  late Animation<double> _exposureModeControlRowAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    pageReplaced = false;
    _initialiseControllers();
    // getMedia();
    if (cameras.isNotEmpty) {
      initCamera(cameras[0]);
    }

    selectedType = photoText;
    frontCamera = false;
  }

  @override
  void dispose() {
    debugPrint("CameraDisposed");
    pageReplaced = true;
    if (cameraController != null) {
      cameraController!.dispose();
      _exposureModeControlRowAnimationController.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (pageReplaced) {
      return;
    }
    debugPrint("LifecycleState: $state");
    if (state == AppLifecycleState.inactive) {
      if (cameraController != null && cameraController!.value.isInitialized) {
        cameraController!.dispose();
        cameraController = null;
      }
    } else if (state == AppLifecycleState.resumed) {
      if (mounted) {
        if (cameraController != null && cameraController!.value.isInitialized) {
          cameraController!.dispose();
        }
        cameraController = null;
        initCamera(frontCamera ? cameras[1] : cameras[0]);
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  void requestPermission() async {
    PermissionStatus status = await Permission.audio.request();
    if (status.isGranted) {
      startAudioRecording();
    } else if (status.isDenied || status.isPermanentlyDenied) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => PermissionErrorScreen(
                    permissionsStatus: {
                      Permission.microphone: false,
                    },
                  )));
    }
  }

  Future initCamera(CameraDescription cameraDescription) async {
    cameraController = CameraController(cameraDescription, ResolutionPreset.max,
        imageFormatGroup: ImageFormatGroup.jpeg);
    cameraValue = null;
    cameraValue = cameraController!.initialize().then((_) async {
      debugPrint("Initialiseddddddd");
      //  cameraController!.setZoomLevel(1.0 - 0.5);
      _minAvailableExposureOffset =
          await cameraController!.getMinExposureOffset();
      _maxAvailableExposureOffset =
          await cameraController!.getMaxExposureOffset();
      _maxAvailableZoom = await cameraController!.getMaxZoomLevel();
      _minAvailableZoom = await cameraController!.getMinZoomLevel();

      if (!mounted) {
        debugPrint("NotMounted");

        return;
      }
      debugPrint("YesMount");
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            pageReplaced = true;
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        PermissionErrorScreen(permissionsStatus: {
                          Permission.camera: false,
                          Permission.microphone: false,
                        })));
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
    final deviceRatio = size.width / size.height;
    debugPrint('camera-screen::::::::::::::::::::::::::::::::::::::::::::::::');
    //   final cameraHeight = (size.height - size.width * numD25);
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: size.width * numD1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: size.width * numD06, vertical: size.width * numD02),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
*/

                    /// Scan
                    if (widget.previousScreen !=
                        ScreenNameEnum.manageTaskScreen)
                      InkWell(
                          onTap: () {
                            debugPrint("inside scan=====>");

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

                    /// Photo
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

                    /// Video
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

                    /// Audio
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
                            child: Text(
                                widget.previousScreen ==
                                        ScreenNameEnum.manageTaskScreen
                                    ? interviewText
                                    : audioText,
                                style: TextStyle(
                                    color: selectedType == audioText
                                        ? colorThemePink
                                        : Colors.black,
                                    fontSize: size.width * numD035,
                                    fontWeight: FontWeight.w500)))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: widget.picAgain
          ? Padding(
              padding: EdgeInsets.only(
                  left: size.width * numD04,
                  top: size.height * numD032,
                  bottom: size.height * numD035,
                  right: size.width * numD02),
              child: SizedBox(
                height: size.width * numD13,
                child: commonElevatedButton(
                    "Cancel",
                    size,
                    commonTextStyle(
                        size: size,
                        fontSize: size.width * numD04,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),
                    commonButtonStyle(size, colorThemePink), () {
                  Navigator.pop(context);
                }),
              ),
            )
          : null,
      body: selectedType == photoText ||
              selectedType == videoText ||
              selectedType == scanText
          ? Stack(
              children: [
                cameraController != null &&
                        cameraController!.value.isInitialized
                    ? Listener(
                        onPointerDown: (_) => _pointers++,
                        onPointerUp: (_) => _pointers--,
                        child: LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return Center(
                              child: GestureDetector(
                            onScaleStart: _handleScaleStart,
                            onScaleUpdate: _handleScaleUpdate,
                            onTapDown: (details) =>
                                onViewFinderTap(details, constraints),
                            onTapUp: _onTap,
                            child: SizedBox(
                              height: size.height,
                              width: size.width,
                              child: AspectRatio(
                                aspectRatio:
                                    cameraController!.value.aspectRatio,
                                child: CameraPreview(cameraController!),
                              ),
                            ),
                          ));
                        }))
                    : Container(),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: size.width * numD25,
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: _exposureModeControlRowWidget(size)),
                ),

                /// Doc
                Align(
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
                ),

                /// Camera ,video
                Align(
                  alignment: Alignment.bottomCenter,
                  child: InkWell(
                    onTap: () {
                      debugPrint("VideoSelected $selectedType");
                      if (selectedType == videoText) {
                        if (_isRecordingInProgress) {
                          stopVideoRecording();
                          debugPrint("hellostop =====> ");
                        } else {
                          startVideoRecording();
                          debugPrint("hellostart =====> ");
                        }
                      } else {
                        ///Rajan
                        Future.delayed(const Duration(milliseconds: 500), () {
                          takePicture();
                        });
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

                /// Gallery
                selectedType == photoText || selectedType == videoText
                    ? Align(
                        alignment: Alignment.bottomRight,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) => CustomGallery(
                                          picAgain: widget.picAgain,
                                        )))
                                .then((value) {
                              camListData = value;
                              if (value != null) {
                                Navigator.pop(
                                    navigatorKey.currentState!.context,
                                    camListData);
                              }
                            });
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
                              child: /*mediaPath.isNotEmpty
                                  ?*/
                                  _mediaList.isNotEmpty
                                      ? FutureBuilder(
                                          future: _mediaList.first
                                              .thumbnailDataWithSize(
                                                  const ThumbnailSize(
                                                      200, 200)),
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
                                                        padding:
                                                            EdgeInsets.only(
                                                                right: 5,
                                                                bottom: 5),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: cameraController != null
                                      ? onExposureModeButtonPressed
                                      : null,
                                  child: Container(
                                      padding:
                                          EdgeInsets.all(size.width * numD01),
                                      decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle),
                                      child: Image.asset(
                                          "${iconsPath}arrow_square_down.png",
                                          color: Colors.black,
                                          height: size.width * numD042)),
                                ),
                                _exposureModeControlRowUpperWidget(size),
                                SizedBox(
                                  height: size.width * numD01,
                                ),
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
                              ],
                            ),
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
                    ),*/
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
                                    debugPrint("StopRec: False");
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
                              child: /* Container(
                              padding: EdgeInsets.all(isAudioRecording
                                  ? size.width * numD04
                                  : size.width * numD04),
                              decoration: const BoxDecoration(
                                  color: Colors.amber,
                                  shape: BoxShape.circle),
                              child: Icon(
                                  isAudioRecording
                                      ? Icons.square
                                      : Icons.mic_none_outlined,
                                  color: Colors.white,
                                  size: isAudioRecording
                                      ? size.width * numD07
                                      : size.width * numD1),
                            )
   ,*/
                                  Container(
                                // margin: EdgeInsets.only(bottom: size.width * numD05),
                                padding: EdgeInsets.all(size.width * numD01),
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: colorThemePink)),
                                child: Icon(
                                  isAudioRecording
                                      ? Icons.stop_circle_outlined
                                      : Icons.circle,
                                  color: colorThemePink,
                                  size: size.width * numD13,
                                ),
                              )),
                          const Spacer(),
                          recordingTime.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    debugPrint("StopRec: True");
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
      ..sampleRate = 44100
      ..bitRate = 48000;

    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _exposureModeControlRowAnimation = CurvedAnimation(
      parent: _exposureModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
  }

  Future getMedia() async {
    var result = await PhotoManager.requestPermissionExtend();

    if (result.isAuth) {
      List<AssetPathEntity> paths =
          await PhotoManager.getAssetPathList(onlyAll: true);

      if (paths.isNotEmpty) {
        _path = paths.first;
        debugPrint("Path:::: $_path");
        //  setState(() {});

        if (_path != null) {
          totalEntitiesCount = await _path!.assetCountAsync;

          List<AssetEntity> media =
              await _path!.getAssetListPaged(page: page, size: _sizePerPage);

          _mediaList = media;
          debugPrint("MyMedia: $media");
        }
      }
      debugPrint("MyMediaSize: ${_mediaList.length}");

      /*   if (_mediaList.isNotEmpty) {
        mediaPath = _mediaList.first.relativePath ?? "";
       // debugPrint("path===> ${_mediaList.first.thumbnailData}");
        debugPrint("MediaPath: $mediaPath");
      }*/

      if (!mounted) {
        return;
      }
      setState(() {});
    } else {
      //PhotoManager.openSetting();
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => PermissionErrorScreen(permissionsStatus: {
                    Permission.camera: false,
                    Permission.photos: false,
                    Permission.microphone: false,
                  })));
    }
  }

  Future takePicture() async {
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
      cameraController!.pausePreview();
      //var cropdata = await cropImage(picture.path);
      exif = await Exif.fromPath(picture.path);
      String sLat = latitude.toString();
      String sLong = longitude.toString();
      await exif!.writeAttributes({"GPSLatitude": sLat, "GPSLongitude": sLong});

      GallerySaver.saveImage(picture.path);

      camListData.add(CameraData(
        path: picture.path,
        mimeType: "image",
        videoImagePath: "",
        latitude: sharedPreferences!.getDouble(currentLat).toString() ?? "",
        longitude: sharedPreferences!.getDouble(currentLon).toString() ?? "",
        dateTime: DateFormat("HH:mm, dd MMM yyyy").format(DateTime.now()),
        location: sharedPreferences!.getString(currentAddress) ?? "",
        country: sharedPreferences!.getString(currentCountry) ?? "",
        city: sharedPreferences!.getString(currentCity) ?? "",
        state: sharedPreferences!.getString(currentState) ?? "",
      ));

      if (widget.picAgain) {
        Future.delayed(const Duration(microseconds: 500), () {
          Navigator.pop(navigatorKey.currentState!.context, camListData);
        });
      } else {
        Future.delayed(const Duration(microseconds: 500), () {
          Navigator.push(
              navigatorKey.currentState!.context,
              MaterialPageRoute(
                  builder: (context) => PreviewScreen(
                        cameraData: null,
                        pickAgain: widget.picAgain,
                        type: "camera",
                        cameraListData: camListData,
                        mediaList: [],
                      ))).then((value) {
            if (cameraController != null) {
              cameraController!.resumePreview();
            }
          });
        });
      }
    } on CameraException catch (e) {
      debugPrint('Error occurred while taking picture: $e');
      return null;
    }
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    cameraController?.setExposurePoint(Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    ));
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    if (_pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await cameraController!.setZoomLevel(_currentScale);
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  void onExposureModeButtonPressed() {
    if (_exposureModeControlRowAnimationController.value == 1) {
      _exposureModeControlRowAnimationController.reverse();
    } else {
      _exposureModeControlRowAnimationController.forward();
    }
  }

  Widget _exposureModeControlRowWidget(Size size) {
    final ButtonStyle styleAuto = TextButton.styleFrom(
        foregroundColor:
            cameraController?.value.exposureMode == ExposureMode.auto
                ? colorThemePink
                : Colors.white);
    /* final ButtonStyle styleLocked = TextButton.styleFrom(
      foregroundColor:
          cameraController?.value.exposureMode == ExposureMode.locked
              ? colorThemePink
              : Colors.white
    );*/
/*    final ButtonStyle styleReset = TextButton.styleFrom(

      foregroundColor:
          (cameraController!.value.exposureMode != ExposureMode.locked) &&
                  cameraController!.value.exposureMode != ExposureMode.auto
              ? colorThemePink
              : Colors.white,
    );*/

    return SizeTransition(
      sizeFactor: _exposureModeControlRowAnimation,
      child: ClipRect(
        child: Column(
          children: <Widget>[
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                /*    TextButton(
                  style: styleAuto,
                  onPressed: cameraController != null
                      ? () => onSetExposureModeButtonPressed(ExposureMode.auto)
                      : null,
                  onLongPress: () {
                    if (cameraController != null) {
                      cameraController!.setExposurePoint(null);
                    }
                  },
                  child: Text(
                    selectedType==scanText?'This scan is automatically enhanced':selectedType == videoText?"This video is automatically enhanced":"This pic is automatically enhanced",
                    style: TextStyle(
                        fontSize: size.width * numD03,
                        fontWeight: FontWeight.w500),
                  ),
                ),*/
                /*TextButton(
               //   style: styleLocked,
                  onPressed: cameraController != null
                      ? () =>
                          onSetExposureModeButtonPressed(ExposureMode.locked)
                      : null,
                  child: Text(
                    'LOCKED',
                    style: TextStyle(
                        fontSize: size.width * numD03,
                        fontWeight: FontWeight.w500),
                  ),
                ),*/
                /*TextButton(
                  style: styleReset,
                  onPressed: cameraController != null
                      ? () => cameraController!.setExposureOffset(0.0)
                      : null,
                  child:  Text('RESET OFFSET',style: TextStyle(
                      fontSize: size.width * numD03,
                      fontWeight: FontWeight.w500
                  ),),
                ),*/
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  _minAvailableExposureOffset.toString(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * numD03,
                      fontWeight: FontWeight.w500),
                ),
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: size.width * numD009,
                  ),
                  child: Slider(
                    value: _currentExposureOffset,
                    min: _minAvailableExposureOffset,
                    max: _maxAvailableExposureOffset,
                    label: _currentExposureOffset.toString(),
                    activeColor: colorThemePink,
                    onChanged: _minAvailableExposureOffset ==
                            _maxAvailableExposureOffset
                        ? null
                        : setExposureOffset,
                  ),
                ),
                Text(
                  _maxAvailableExposureOffset.toString(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * numD03,
                      fontWeight: FontWeight.w500),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _exposureModeControlRowUpperWidget(Size size) {
    final ButtonStyle styleAuto = TextButton.styleFrom(
        foregroundColor:
            cameraController?.value.exposureMode == ExposureMode.auto
                ? colorThemePink
                : Colors.white);
    /* final ButtonStyle styleLocked = TextButton.styleFrom(
      foregroundColor:
          cameraController?.value.exposureMode == ExposureMode.locked
              ? colorThemePink
              : Colors.white
    );*/
/*    final ButtonStyle styleReset = TextButton.styleFrom(
      foregroundColor:
          (cameraController!.value.exposureMode != ExposureMode.locked) &&
                  cameraController!.value.exposureMode != ExposureMode.auto
              ? colorThemePink
              : Colors.white,
    );*/

    return SizeTransition(
      sizeFactor: _exposureModeControlRowAnimation,
      child: ClipRect(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  style: styleAuto,
                  onPressed: cameraController != null
                      ? () => onSetExposureModeButtonPressed(ExposureMode.auto)
                      : null,
                  onLongPress: () {
                    if (cameraController != null) {
                      cameraController!.setExposurePoint(null);
                    }
                  },
                  child: Text(
                    selectedType == scanText
                        ? 'This scan is automatically enhanced'
                        : selectedType == videoText
                            ? "This video is automatically enhanced"
                            : "This pic is automatically enhanced",
                    style: TextStyle(
                        fontSize: size.width * numD03,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> setExposureOffset(double offset) async {
    if (cameraController == null) {
      return;
    }

    setState(() {
      _currentExposureOffset = offset;
    });
    try {
      offset = await cameraController!.setExposureOffset(offset);
    } on CameraException catch (e) {
      rethrow;
    }
  }

  void onSetExposureModeButtonPressed(ExposureMode mode) {
    setExposureMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> setExposureMode(ExposureMode mode) async {
    if (cameraController == null) {
      return;
    }

    try {
      await cameraController!.setExposureMode(mode);
    } on CameraException catch (e) {
      rethrow;
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
      cameraController!.setExposurePoint(point);

      setState(() {
        showFocusCircle = false;
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
      return null;
    }

    if (myTimer != null) {
      myTimer!.cancel();
    }
    AudioPlayer().play(AssetSource("${audioPath}video_stop.wav"));

    try {
      XFile file = await cameraController!.stopVideoRecording();

      // Get the directory
      String dir = (await getTemporaryDirectory()).path;
      String newPath =
          "$dir/${DateTime.now().millisecondsSinceEpoch}.mp4"; // Rename to mp4

      File recordedFile = File(file.path);
      File renamedFile = await recordedFile.rename(newPath); // Rename the file

      debugPrint('Renamed Video Path: ${renamedFile.path}');

      setState(() {
        _isRecordingInProgress = false;
      });

      GallerySaver.saveVideo(renamedFile.path);
      cameraController!.pausePreview();

      Future.delayed(const Duration(milliseconds: 300), () async {
        await generateThumbnail(renamedFile.path);
      });
    } on CameraException catch (e) {
      debugPrint('Error stopping video recording: $e');
      return null;
    }
  }

  Future getVideoThumbNail(String path) async {
    final thumbnail = await VideoThumbnail.thumbnailFile(
      video: path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: vt.ImageFormat.PNG,
      maxHeight: 500,
      quality: 100,
    );
    debugPrint("MimeType: ${lookupMimeType(path)}");
    camListData.add(CameraData(
      path: path,
      videoImagePath: thumbnail ?? "",
      mimeType: "video",
      latitude: sharedPreferences!.getDouble(currentLat).toString() ?? "",
      longitude: sharedPreferences!.getDouble(currentLon).toString() ?? "",
      dateTime: DateFormat("HH:mm, dd MMM yyyy").format(DateTime.now()),
      location: sharedPreferences!.getString(currentAddress) ?? "",
      country: sharedPreferences!.getString(currentCountry) ?? "",
      city: sharedPreferences!.getString(currentCity) ?? "",
      state: sharedPreferences!.getString(currentState) ?? "",
    ));

    if (widget.picAgain) {
      Navigator.pop(navigatorKey.currentContext!, camListData);
    } else {
      Navigator.push(
          navigatorKey.currentContext!,
          MaterialPageRoute(
              builder: (context) => PreviewScreen(
                    cameraData: null,
                    pickAgain: widget.picAgain,
                    type: "camera",
                    cameraListData: camListData,
                    mediaList: [],
                  ))).then((value) {
        if (cameraController != null) {
          cameraController!.resumePreview();
        }
        recordingTime = "";
        setState(() {});
      });
    }
  }

  Future<void> generateThumbnail(String videoPath) async {
    try {
      final String? thumbnail = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: vt.ImageFormat.PNG,
        maxWidth: 128,
        quality: 25,
      );
      debugPrint("MimeType: ${lookupMimeType(videoPath)}");
      camListData.add(CameraData(
        path: videoPath,
        videoImagePath: thumbnail ?? "",
        mimeType: "video",
        latitude: sharedPreferences!.getDouble(currentLat).toString() ?? "",
        longitude: sharedPreferences!.getDouble(currentLon).toString() ?? "",
        dateTime: DateFormat("HH:mm, dd MMM yyyy").format(DateTime.now()),
        location: sharedPreferences!.getString(currentAddress) ?? "",
        country: sharedPreferences!.getString(currentCountry) ?? "",
        city: sharedPreferences!.getString(currentCity) ?? "",
        state: sharedPreferences!.getString(currentState) ?? "",
      ));

      if (widget.picAgain) {
        Navigator.pop(navigatorKey.currentContext!, camListData);
      } else {
        Navigator.push(
            navigatorKey.currentContext!,
            MaterialPageRoute(
                builder: (context) => PreviewScreen(
                      cameraData: null,
                      pickAgain: widget.picAgain,
                      type: "camera",
                      cameraListData: camListData,
                      mediaList: [],
                    ))).then((value) {
          if (cameraController != null) {
            cameraController!.resumePreview();
          }
          recordingTime = "";
          setState(() {});
        });
      }
    } catch (e) {
      debugPrint("Error generating thumbnail: $e");
    }
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
      final filepath = '${appFolder.path}/${getRandomString(10)}recording.m4a';
      debugPrint(filepath);
      debugPrint("FilePath: $filepath");
      await recorderController.record(path: filepath).then((value) {
        recordTime();
      });
    } else {
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
      camListData.clear();
      if (path!.isNotEmpty) {
        debugPrint("MimeType: ${lookupMimeType(path)}");
        camListData.add(CameraData(
          path: path,
          mimeType: "audio",
          videoImagePath: "",
          latitude: sharedPreferences!.getDouble(currentLat).toString() ?? "",
          longitude: sharedPreferences!.getDouble(currentLon).toString() ?? "",
          dateTime: DateFormat("HH:mm, dd MMM yyyy").format(DateTime.now()),
          location: sharedPreferences!.getString(currentAddress) ?? "",
          country: sharedPreferences!.getString(currentCountry) ?? "",
          city: sharedPreferences!.getString(currentCity) ?? "",
          state: sharedPreferences!.getString(currentState) ?? "",
        ));
        if (widget.picAgain) {
          if (context.mounted) {
            Navigator.pop(navigatorKey.currentState!.context, camListData);
          }
        } else {
          Navigator.push(
              navigatorKey.currentContext!,
              MaterialPageRoute(
                  builder: (context) => PreviewScreen(
                        cameraData: null,
                        pickAgain: widget.picAgain,
                        type: "camera",
                        cameraListData: camListData,
                        mediaList: [],
                      ))).then((value) {
            if (cameraController != null) {
              cameraController!.resumePreview();
            }
          });
        }
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

  openImageScanner() async {
    debugPrint("inside scanner===>  ");
    List<String>? imageList =
        // await CunningDocumentScanner.getPictures(scanSelected);
        await CunningDocumentScanner.getPictures();
    // List<String>? imageList = await CunningDocumentScanner.getPictures();
    //  final image = await CunningDocumentScanner.getPictures();
    if (imageList!.isNotEmpty) {
      for (var element in imageList) {
        debugPrint("image path ====> $element");
        if (element.isNotEmpty) {
          if (cameraController != null) {
            cameraController!.pausePreview();
          }
          camListData.add(CameraData(
            path: element,
            mimeType: "image",
            videoImagePath: "",
            latitude: sharedPreferences!.getDouble(currentLat).toString() ?? "",
            longitude:
                sharedPreferences!.getDouble(currentLon).toString() ?? "",
            dateTime: DateFormat("HH:mm, dd MMM yyyy").format(DateTime.now()),
            location: sharedPreferences!.getString(currentAddress) ?? "",
            country: sharedPreferences!.getString(currentCountry) ?? "",
            city: sharedPreferences!.getString(currentCity) ?? "",
            state: sharedPreferences!.getString(currentState) ?? "",
          ));
        }
      }
      if (widget.picAgain) {
        debugPrint("navigator:::::::");
        Future.delayed(const Duration(microseconds: 500), () {
          Navigator.pop(navigatorKey.currentState!.context, camListData);
        });
      } else {
        debugPrint("navigator1111:::::::");
        Future.delayed(const Duration(microseconds: 500), () {
          Navigator.push(
              navigatorKey.currentState!.context,
              MaterialPageRoute(
                  builder: (context) => PreviewScreen(
                        cameraData: null,
                        pickAgain: widget.picAgain,
                        type: "scan",
                        cameraListData: camListData,
                        mediaList: [],
                      ))).then((value) {
            if (cameraController != null) {
              cameraController!.resumePreview();
            }
          });
        });
      }
    } else {
      Navigator.of(navigatorKey.currentContext!).push(MaterialPageRoute(
          builder: (context) => Dashboard(
                initialPosition: 2,
              )));
    }

    //  setState(() {});
  }

  /// PDF Document
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
      String mimeType = "";
      debugPrint("MimeType: ${lookupMimeType(file.path)}");
      mimeType = lookupMimeType(file.path).toString();
      if (lookupMimeType(file.path) == "application/msword") {
        mimeType = "doc";
      } else {
        mimeType = "pdf";
      }

      debugPrint("selectedMimeType: $mimeType");
      camListData.add(CameraData(
        path: file.path,
        mimeType: mimeType,
        fromGallary: true,
        videoImagePath: '',
        latitude: sharedPreferences!.getDouble(currentLat).toString() ?? "",
        longitude: sharedPreferences!.getDouble(currentLon).toString() ?? "",
        dateTime: DateFormat("HH:mm, dd MMM yyyy").format(DateTime.now()),
        location: sharedPreferences!.getString(currentAddress) ?? "",
        country: sharedPreferences!.getString(currentCountry) ?? "",
        city: sharedPreferences!.getString(currentCity) ?? "",
        state: sharedPreferences!.getString(currentState) ?? "",
      ));

      if (widget.picAgain) {
        Navigator.pop(navigatorKey.currentContext!, camListData);
      } else {
        Navigator.push(
            navigatorKey.currentContext!,
            MaterialPageRoute(
                builder: (context) => PreviewScreen(
                      cameraData: null,
                      pickAgain: widget.picAgain,
                      type: "pdf",
                      cameraListData: camListData,
                      mediaList: [],
                    ))).then((value) {
          if (cameraController != null) {
            cameraController!.resumePreview();
          }
        });
      }
    } else {
      // User canceled the picker
    }
  }
}

class CameraData {
  String path;
  String mimeType = "";
  String videoImagePath = "";
  String latitude = "";
  String location = "";
  String longitude = "";
  String country = "";
  String city = "";
  String state = "";
  String dateTime = "";
  bool fromGallary = false;

  CameraData(
      {required this.path,
      required this.mimeType,
      required this.videoImagePath,
      required this.latitude,
      required this.longitude,
      required this.location,
      required this.country,
      required this.city,
      required this.state,
      this.fromGallary = false,
      required this.dateTime});
}
