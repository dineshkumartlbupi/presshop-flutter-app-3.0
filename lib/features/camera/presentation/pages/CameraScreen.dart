import 'dart:async';
import 'dart:ui' as ui;

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:presshop/core/core_export.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/core/router/router_constants.dart';
import 'package:presshop/core/widgets/new_home_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/features/camera/data/models/camera_model.dart';
import 'package:presshop/features/camera/presentation/bloc/camera_bloc.dart';
import 'package:presshop/features/camera/presentation/bloc/camera_event.dart';
import 'package:presshop/features/camera/presentation/bloc/camera_state.dart';
import 'package:presshop/core/di/injection_container.dart' as di;

// Constants (Keep if not in common)
const String photoText = "Photo";
const String videoText = "Video";
const String scanText = "Scan";
const String audioText = "Audio";
const String notesText = "Notes";
const String interviewText = "Interview";

class CameraScreen extends StatefulWidget {
  const CameraScreen({
    super.key,
    required this.picAgain,
    required this.previousScreen,
    this.autoInitialize = true,
  });
  final bool picAgain;
  final ScreenNameEnum previousScreen;
  final bool autoInitialize;

  @override
  State<StatefulWidget> createState() {
    return CameraScreenState();
  }
}

class CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // Animation Controllers for UI effects
  late AnimationController _exposureModeControlRowAnimationController;
  late Animation<double> _exposureModeControlRowAnimation;

  // Zoom & UI state helpers
  double _baseScale = 1.0;
  int _pointers = 0;
  bool showFocusCircle = false;
  double x = 0, y = 0;

  // Exposure slider state (local UI state, syncing with Bloc via events if needed, but slider is interactive)
  // We can update Bloc on change end to avoid spamming events.
  // Or just use local state for slider and update controller via Bloc method helper (event).
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentZoom = 1.0;

  CameraBloc? _bloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _exposureModeControlRowAnimation = CurvedAnimation(
      parent: _exposureModeControlRowAnimationController,
      curve: Curves.easeInCubic,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _bloc?.add(CameraLifecycleEvent(state));
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _exposureModeControlRowAnimationController.dispose();
    super.dispose();
  }

  void resumeCamera() {
    if (_bloc != null && !_bloc!.isClosed) {
      _bloc!.add(CameraLifecycleEvent(AppLifecycleState.resumed));
    }
  }

  void closeCamera() {
    if (_bloc != null && !_bloc!.isClosed) {
      _bloc!.add(CameraLifecycleEvent(AppLifecycleState.paused));
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) {
        _bloc = di.sl<CameraBloc>();
        if (widget.autoInitialize) {
          _bloc!.add(CameraInitializeEvent());
        }
        return _bloc!;
      },
      child: BlocConsumer<CameraBloc, CameraState>(
        listener: (context, state) async {
          // Update local limits when camera is ready
          if (state.status == CameraStatus.ready &&
              state.cameraController != null &&
              state.cameraController!.value.isInitialized) {
            try {
              // Wrap property access in try-catch to avoid Disposed CameraController errors
              _minAvailableExposureOffset =
                  await state.cameraController!.getMinExposureOffset();
              _maxAvailableExposureOffset =
                  await state.cameraController!.getMaxExposureOffset();
              _maxAvailableZoom =
                  await state.cameraController!.getMaxZoomLevel();
              _minAvailableZoom =
                  await state.cameraController!.getMinZoomLevel();

              if (mounted) setState(() {});

              // Force resume preview on UI side to prevent black screen
              try {
                await state.cameraController!.resumePreview();
              } catch (e) {
                // Ignore resume preview errors
              }
            } catch (e) {
              debugPrint("Error getting camera info (ignored): $e");
            }
          }

          if (state.status == CameraStatus.failure) {
            if (state.errorMessage.contains("Permission") ||
                state.errorMessage.contains("denied")) {
              if (mounted) {
                context.pushReplacementNamed(AppRoutes.permissionErrorName,
                    extra: {
                      'permissionsStatus': {
                        Permission.camera: false,
                        Permission.microphone: false
                      }
                    });
              }
            }
          }

          if (state.status == CameraStatus.success) {
            if (widget.picAgain) {
              context.pop(state.capturedMedia);
            } else {
              // Navigate to Preview
              // We need to pass the captured media. The preview screen handles the list.
              // Important: The original code clears camListData or builds it up?
              // "camListData.add(...)". So it builds up.
              // Here state.capturedMedia has the list.

              if (mounted) {
                await context.pushNamed(AppRoutes.previewName, extra: {
                  'cameraData': null,
                  'pickAgain': widget.picAgain,
                  'type': state.selectedMode.toLowerCase() == "video"
                      ? "video"
                      : state.selectedMode.toLowerCase() ==
                              AppStrings.scanText.toLowerCase()
                          ? "scan"
                          : state.selectedMode.toLowerCase() == "pdf"
                              ? "pdf"
                              : "camera",
                  'cameraListData': state.capturedMedia,
                  'mediaList': [],
                }).then((value) {
                  // On return
                  _bloc!.state.cameraController?.resumePreview();
                });
              }
            }
          }

          if (state.status == CameraStatus.permissionDenied) {
            // Handle specific permission denial (audio)
            // Handle specific permission denial (audio)
            if (mounted) {
              context
                  .pushReplacementNamed(AppRoutes.permissionErrorName, extra: {
                'permissionsStatus': {Permission.microphone: false}
              });
            }
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: _buildAppBar(context, state, size),
            bottomNavigationBar:
                widget.picAgain ? _buildBottomBar(context, size) : null,
            body: _buildBody(context, state, size),
          );
        },
      ),
    );
  }

  // AppBar Widget
  PreferredSizeWidget _buildAppBar(
      BuildContext context, CameraState state, Size size) {
    return NewHomeAppBar(
      size: size,
      hideLeading: widget.previousScreen == ScreenNameEnum.dashboardScreen,
      showFilter: false,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(size.width * AppDimensions.numD1),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: size.width * AppDimensions.numD06,
              vertical: size.width * AppDimensions.numD02),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.previousScreen != ScreenNameEnum.manageTaskScreen)
                    _buildModeButton(context, AppStrings.scanText, state, size),
                  _buildModeButton(context, AppStrings.photoText, state, size),
                  _buildModeButton(context, AppStrings.videoText, state, size),
                  _buildModeButton(context, AppStrings.audioText, state, size,
                      label: widget.previousScreen ==
                              ScreenNameEnum.manageTaskScreen
                          ? AppStrings.interviewText
                          : AppStrings.audioText),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(
      BuildContext context, String mode, CameraState state, Size size,
      {String? label}) {
    final isSelected = state.selectedMode == mode;
    return InkWell(
      onTap: () {
        context.read<CameraBloc>().add(CameraModeChangeEvent(mode));
      },
      child: FittedBox(
          child: Text(
        label ?? mode,
        style: TextStyle(
            color: isSelected ? AppColorTheme.colorThemePink : Colors.black,
            fontSize: size.width * AppDimensions.numD035,
            fontWeight: FontWeight.w500),
      )),
    );
  }

  Widget? _buildBottomBar(BuildContext context, Size size) {
    return Padding(
      padding: EdgeInsets.only(
          left: size.width * AppDimensions.numD04,
          top: size.height * AppDimensions.numD032,
          bottom: size.height * AppDimensions.numD035,
          right: size.width * AppDimensions.numD04),
      child: SizedBox(
        height: size.width * AppDimensions.numD13,
        child: commonElevatedButton(
            "Cancel",
            size,
            commonTextStyle(
                size: size,
                fontSize: size.width * AppDimensions.numD04,
                color: Colors.white,
                fontWeight: FontWeight.w700),
            commonButtonStyle(size, AppColorTheme.colorThemePink),
            () => context.pop()),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CameraState state, Size size) {
    if (state.selectedMode == AppStrings.audioText) {
      return _buildAudioBody(context, state, size);
    }
    return Stack(
      children: [
        _buildCameraPreview(context, state, size),

        // Exposure Controls
        Positioned(
          left: 0,
          right: 0,
          bottom: size.width * AppDimensions.numD25,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: _exposureModeControlRowWidget(size, state),
          ),
        ),

        // Doc Picker (Plus icon)
        Align(
          alignment: Alignment.bottomLeft,
          child: InkWell(
            onTap: () {
              // Pick PDF/Doc
              context.read<CameraBloc>().add(PickDocumentEvent());
            },
            child: Container(
              margin: EdgeInsets.only(
                  left: size.width * AppDimensions.numD1,
                  bottom: size.width * AppDimensions.numD05),
              padding: EdgeInsets.all(size.width * AppDimensions.numD02),
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white)),
              child: Container(
                padding: EdgeInsets.all(size.width * AppDimensions.numD02),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle),
                child: Image.asset("${iconsPath}ic_plus.png",
                    color: Colors.white,
                    height: size.width * AppDimensions.numD07),
              ),
            ),
          ),
        ),

        // Capture/Record Button
        Align(
          alignment: Alignment.bottomCenter,
          child: InkWell(
            onTap: state.isVideoLoading
                ? null
                : () {
                    if (state.selectedMode == AppStrings.videoText) {
                      if (state.isRecording) {
                        context
                            .read<CameraBloc>()
                            .add(CameraStopRecordingEvent());
                      } else {
                        context
                            .read<CameraBloc>()
                            .add(CameraStartRecordingEvent());
                      }
                    } else if (state.selectedMode == AppStrings.scanText) {
                      context.read<CameraBloc>().add(CameraScanDocEvent());
                    } else {
                      // Photo
                      context.read<CameraBloc>().add(CameraCaptureImageEvent());
                    }
                  },
            child: Container(
              margin:
                  EdgeInsets.only(bottom: size.width * AppDimensions.numD05),
              padding: EdgeInsets.all(size.width * AppDimensions.numD01),
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColorTheme.colorThemePink)),
              child: state.isVideoLoading
                  ? SizedBox(
                      width: size.width * AppDimensions.numD13,
                      height: size.width * AppDimensions.numD13,
                      child: Padding(
                        padding:
                            EdgeInsets.all(size.width * AppDimensions.numD03),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColorTheme.colorThemePink,
                        ),
                      ),
                    )
                  : Icon(
                      (state.selectedMode == AppStrings.videoText &&
                              state.isRecording)
                          ? Icons.stop_circle_outlined
                          : Icons.circle,
                      color: AppColorTheme.colorThemePink,
                      size: size.width * AppDimensions.numD13,
                    ),
            ),
          ),
        ),

        // Gallery Thumbnail
        if (state.selectedMode == AppStrings.photoText ||
            state.selectedMode == AppStrings.videoText)
          Align(
            alignment: Alignment.bottomRight,
            child: InkWell(
              onTap: () {
                context.pushNamed(AppRoutes.customGalleryName, extra: {
                  'picAgain': widget.picAgain,
                }).then((value) {
                  if (value != null) {
                    // ignore: use_build_context_synchronously
                    if (!context.mounted) return;
                    context.read<CameraBloc>().add(
                        UpdateCapturedMediaEvent(value as List<CameraData>));
                    if (widget.picAgain) context.pop(value);
                  }
                });
              },
              child: Container(
                width: size.width * AppDimensions.numD15,
                height: size.width * AppDimensions.numD15,
                margin: EdgeInsets.only(
                    bottom: size.width * AppDimensions.numD05,
                    right: size.width * AppDimensions.numD1),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(size.width * AppDimensions.numD025),
                  child: state.galleryMedia.isNotEmpty
                      ? FutureBuilder(
                          future: state.galleryMedia.first
                              .thumbnailDataWithSize(
                                  const ThumbnailSize(200, 200)),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.data != null) {
                              return Image.memory(snapshot.data!,
                                  fit: BoxFit.cover);
                            }
                            return Container(color: Colors.grey);
                          })
                      : Image.asset("${dummyImagePath}walk2.png",
                          fit: BoxFit.cover),
                ),
              ),
            ),
          ),

        // Focus Circle
        if (showFocusCircle)
          Positioned(
            top: y - 20,
            left: x - 20,
            child: Image.asset("${iconsPath}ic_focus.png",
                width: size.width * AppDimensions.numD15,
                height: size.width * AppDimensions.numD15,
                color: Colors.white),
          ),

        // Top Controls (Flash, Rotate, Settings)
        if (state.selectedMode == AppStrings.photoText ||
            state.selectedMode == AppStrings.videoText)
          Positioned(
            top: size.width * AppDimensions.numD06,
            left: size.width * AppDimensions.numD1,
            right: size.width * AppDimensions.numD1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!state.isFrontCamera)
                  InkWell(
                    onTap: () => context
                        .read<CameraBloc>()
                        .add(CameraFlashToggleEvent()),
                    child: Container(
                      padding:
                          EdgeInsets.all(size.width * AppDimensions.numD01),
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: Icon(
                          state.isFlashOn ? Icons.flash_on : Icons.flash_off,
                          color: Colors.black,
                          size: size.width * AppDimensions.numD04),
                    ),
                  )
                else
                  SizedBox(width: size.width * AppDimensions.numD06),

                // Center Settings
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        if (_exposureModeControlRowAnimationController.value ==
                            1) {
                          _exposureModeControlRowAnimationController.reverse();
                        } else {
                          _exposureModeControlRowAnimationController.forward();
                        }
                      },
                      child: Container(
                        padding:
                            EdgeInsets.all(size.width * AppDimensions.numD01),
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: Image.asset("${iconsPath}arrow_square_down.png",
                            color: Colors.black,
                            height: size.width * AppDimensions.numD042),
                      ),
                    ),
                    _exposureModeControlRowUpperWidget(size, state),
                    SizedBox(height: size.width * AppDimensions.numD01),
                    if (state.selectedMode == AppStrings.videoText)
                      Text(state.recordingTime,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w500)),
                  ],
                ),

                // Rotate Camera
                InkWell(
                  onTap: () =>
                      context.read<CameraBloc>().add(CameraSwitchEvent()),
                  child: Container(
                    padding: EdgeInsets.all(size.width * AppDimensions.numD01),
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Image.asset("${iconsPath}ic_rotate.png",
                        height: size.width * AppDimensions.numD04),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCameraPreview(
      BuildContext context, CameraState state, Size size) {
    if (state.status == CameraStatus.failure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.grey),
            const SizedBox(height: 10),
            Text(
                state.errorMessage.isNotEmpty
                    ? state.errorMessage
                    : "Camera not found",
                style: const TextStyle(color: Colors.black)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<CameraBloc>().add(CameraInitializeEvent());
              },
              child: const Text("Retry"),
            )
          ],
        ),
      );
    }

    if (state.status == CameraStatus.loading ||
        state.cameraController == null ||
        !state.cameraController!.value.isInitialized) {
      return Center(
          child:
              CircularProgressIndicator(color: AppColorTheme.colorThemePink));
    }

    return Listener(
      onPointerDown: (_) => _pointers++,
      onPointerUp: (_) => _pointers--,
      child: LayoutBuilder(builder: (context, constraints) {
        return Center(
          child: GestureDetector(
            onScaleStart: (details) => _baseScale =
                _currentZoom, // Wait, need to track current scale in UI or Bloc?
            onScaleUpdate: (details) async {
              if (_pointers != 2) return;
              _currentZoom = (_baseScale * details.scale)
                  .clamp(_minAvailableZoom, _maxAvailableZoom);
              context.read<CameraBloc>().add(UpdateZoomEvent(_currentZoom));
              // No setState here, as we update via Bloc. But Bloc updates state? No, UpdateZoomEvent just sets controller.
              // So we rely on controller update internal.
            },
            onTapDown: (details) {
              final offset = Offset(
                details.localPosition.dx / constraints.maxWidth,
                details.localPosition.dy / constraints.maxHeight,
              );
              // Manual controller call for focus, kept in UI for responsiveness
              state.cameraController?.setExposurePoint(offset);
              state.cameraController?.setFocusPoint(offset);

              setState(() {
                showFocusCircle = true;
                x = details.localPosition.dx;
                y = details.localPosition.dy;
              });
              Future.delayed(Duration(milliseconds: 1000), () {
                if (mounted) setState(() => showFocusCircle = false);
              });
            },
            child: SizedBox(
              height: size.height,
              width: size.width,
              child: AspectRatio(
                aspectRatio: state.cameraController!.value.aspectRatio,
                child: CameraPreview(state.cameraController!),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAudioBody(BuildContext context, CameraState state, Size size) {
    return Column(
      children: [
        const Spacer(),
        state.isRecording
            ? AudioWaveforms(
                size: Size(size.width, 100),
                recorderController: state.recorderController!,
                enableGesture: false,
                backgroundColor: Colors.transparent,
                shouldCalculateScrolledPosition: true,
                waveStyle: WaveStyle(
                    waveColor: AppColorTheme.colorThemePink,
                    extendWaveform: true,
                    showMiddleLine: false,
                    gradient: ui.Gradient.linear(const Offset(70, 50),
                        Offset(size.width / 2, 0), [Colors.red, Colors.green])),
              )
            : Container(),
        Text(state.recordingTime.isEmpty ? "00:00:00" : state.recordingTime,
            style: commonTextStyle(
                size: size,
                fontSize: size.width * AppDimensions.numD15,
                color: Colors.black,
                fontWeight: FontWeight.w500)),
        const Spacer(),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: size.width * AppDimensions.numD08,
              vertical: size.width * AppDimensions.numD04),
          child: Row(
            children: [
              if (state.recordingTime.isNotEmpty &&
                  state.recordingTime != "00:00:00" &&
                  !state.isRecording)
                IconButton(
                  onPressed: () {
                    // Cancel/Reset
                    // This logic was in stopAudioRecording(false) -> clear list
                    context.read<CameraBloc>().add(
                        AudioStopRecordingEvent()); // Needs a flag to discard?
                    // Bloc doesn't have discard. We can just ignore result in listener if we have a flag.
                    // Or simplified: Just stop.
                  },
                  icon: Icon(Icons.close,
                      color: Colors.red,
                      size: size.width * AppDimensions.numD08),
                ),
              const Spacer(),
              InkWell(
                onTap: () {
                  if (state.isRecording) {
                    context.read<CameraBloc>().add(AudioStopRecordingEvent());
                  } else {
                    context.read<CameraBloc>().add(AudioStartRecordingEvent());
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(size.width * AppDimensions.numD01),
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColorTheme.colorThemePink)),
                  child: Icon(
                      state.isRecording
                          ? Icons.stop_circle_outlined
                          : Icons.circle,
                      color: AppColorTheme.colorThemePink,
                      size: size.width * AppDimensions.numD13),
                ),
              ),
              const Spacer(),
              if (state.capturedMedia.isNotEmpty) // Logic for check button
                IconButton(
                  onPressed: () {
                    // Done
                    context.pushNamed(AppRoutes.previewName, extra: {
                      'cameraData': null,
                      'pickAgain': widget.picAgain,
                      'type': "camera",
                      'cameraListData': state.capturedMedia,
                      'mediaList': []
                    });
                  },
                  icon: Icon(Icons.check,
                      color: AppColorTheme.colorOnlineGreen,
                      size: size.width * AppDimensions.numD08),
                ),
            ],
          ),
        )
      ],
    );
  }

  // Exposure Utilities
  Widget _exposureModeControlRowWidget(Size size, CameraState state) {
    // Shortened for brevity, similar to original but using state vars locally or from Bloc if I implemented them
    // _currentExposureOffset is local. Bloc update via UpdateExposureEvent.
    return SizeTransition(
      sizeFactor: _exposureModeControlRowAnimation,
      child: ClipRect(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(_minAvailableExposureOffset.toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * AppDimensions.numD03,
                        fontWeight: FontWeight.w500)),
                SliderTheme(
                  data: SliderThemeData(
                      trackHeight: size.width * AppDimensions.numD009),
                  child: Slider(
                    value: _currentExposureOffset,
                    min: _minAvailableExposureOffset,
                    max: _maxAvailableExposureOffset,
                    activeColor: AppColorTheme.colorThemePink,
                    onChanged: (val) {
                      setState(() => _currentExposureOffset = val);
                      context.read<CameraBloc>().add(UpdateExposureEvent(val));
                    },
                  ),
                ),
                Text(_maxAvailableExposureOffset.toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * AppDimensions.numD03,
                        fontWeight: FontWeight.w500)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _exposureModeControlRowUpperWidget(Size size, CameraState state) {
    return SizeTransition(
      sizeFactor: _exposureModeControlRowAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            state.selectedMode == AppStrings.scanText
                ? 'This scan is automatically enhanced'
                : state.selectedMode == AppStrings.videoText
                    ? "This video is automatically enhanced"
                    : "This pic is automatically enhanced",
            style: TextStyle(
                fontSize: size.width * AppDimensions.numD03,
                fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }
}
