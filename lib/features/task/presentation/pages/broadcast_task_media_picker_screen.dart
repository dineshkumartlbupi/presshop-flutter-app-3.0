import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/new_home_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/features/camera/data/models/camera_model.dart';
import 'package:presshop/features/camera/presentation/bloc/camera_bloc.dart';
import 'package:presshop/features/camera/presentation/bloc/camera_event.dart';
import 'package:presshop/features/camera/presentation/bloc/camera_state.dart';
import 'package:presshop/core/di/injection_container.dart' as di;
import 'package:go_router/go_router.dart';
import 'package:presshop/main.dart';
import 'package:presshop/features/camera/presentation/pages/add_more_content_screen.dart';

class BroadcastTaskMediaPickerScreen extends StatefulWidget {
  const BroadcastTaskMediaPickerScreen({
    super.key,
    this.picAgain = true,
    this.hideBottomBar = false,
  });
  final bool picAgain;
  final bool hideBottomBar;

  @override
  State<StatefulWidget> createState() {
    return BroadcastTaskMediaPickerScreenState();
  }
}

class BroadcastTaskMediaPickerScreenState
    extends State<BroadcastTaskMediaPickerScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late AnimationController _exposureModeControlRowAnimationController;
  late Animation<double> _exposureModeControlRowAnimation;

  double _baseScale = 1.0;
  int _pointers = 0;
  bool showFocusCircle = false;
  double x = 0;
  double y = 0;

  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentZoom = 1.0;

  CameraBloc? _bloc;
  CameraStatus? _lastStatus;

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

    _bloc = di.sl<CameraBloc>();
    // Important: Clear previous captured media when starting a fresh picker
    _bloc!.add(const UpdateCapturedMediaEvent([]));
    _bloc!.add(const CameraResetStatusEvent());

    debugPrint("📸 BroadcastTaskMediaPickerScreen: Initializing...");
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _bloc!.add(const CameraInitializeEvent(force: true));
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _bloc?.add(CameraLifecycleEvent(state));
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    closeCamera();
    WidgetsBinding.instance.removeObserver(this);
    _exposureModeControlRowAnimationController.dispose();
    super.dispose();
  }

  void resumeCamera({bool force = false}) {
    if (_bloc != null && !_bloc!.isClosed) {
      _bloc!.add(CameraInitializeEvent(force: force));
    }
  }

  void closeCamera() {
    if (_bloc != null && !_bloc!.isClosed) {
      _bloc!.add(CameraLifecycleEvent(AppLifecycleState.paused));
    }
  }

  void pauseCamera() {
    if (_bloc != null && !_bloc!.isClosed) {
      _bloc!.add(const CameraPausePreviewEvent());
    }
  }

  Future<Uint8List?> _getLatestGalleryImageBytes() async {
    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth && !ps.hasAccess) return null;
      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.common,
        filterOption: FilterOptionGroup(
          orders: [
            const OrderOption(type: OrderOptionType.createDate, asc: false)
          ],
        ),
      );
      if (paths.isEmpty) return null;
      for (var path in paths) {
        final List<AssetEntity> assets =
            await path.getAssetListRange(start: 0, end: 1);
        if (assets.isNotEmpty) {
          return await assets.first
              .thumbnailDataWithSize(const ThumbnailSize(200, 200));
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocProvider.value(
      value: _bloc!,
      child: BlocConsumer<CameraBloc, CameraState>(
        listener: (context, state) async {
          if (state.status == CameraStatus.ready &&
              _lastStatus != CameraStatus.ready &&
              state.cameraController != null &&
              state.cameraController!.value.isInitialized) {
            try {
              _minAvailableExposureOffset =
                  await state.cameraController!.getMinExposureOffset();
              _maxAvailableExposureOffset =
                  await state.cameraController!.getMaxExposureOffset();
              _maxAvailableZoom =
                  await state.cameraController!.getMaxZoomLevel();
              _minAvailableZoom =
                  await state.cameraController!.getMinZoomLevel();
              if (mounted) setState(() {});
            } catch (e) {
              debugPrint("Error: $e");
            }
          }
          _lastStatus = state.status;

          // In this screen, we don't pop on success, we let the user capture more or tap "Done"
          if (state.status == CameraStatus.success &&
              state.capturedMedia.isNotEmpty) {
            _bloc?.add(const CameraResetStatusEvent());
            if (mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
              context.pop(state.capturedMedia);
            }
            return;
          }
        },
        builder: (context, state) {
          final bgColor = state.selectedMode == AppStrings.audioText
              ? Theme.of(context).scaffoldBackgroundColor
              : Colors.black;

          return Scaffold(
            backgroundColor: bgColor,
            appBar: _buildAppBar(context, state, size, bgColor),
            bottomNavigationBar: (!widget.hideBottomBar)
                ? _buildBottomBar(context, state, size, bgColor)
                : null,
            body: Container(
              color: bgColor,
              child: _buildBody(context, state, size),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, CameraState state, Size size, Color bgColor) {
    return NewHomeAppBar(
      size: size,
      hideLeading: false,
      showFilter: false,
      appBarbackgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(size.width * AppDimensions.numD1),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: size.width * AppDimensions.numD04,
              vertical: size.width * AppDimensions.numD02),
          child: Row(
            children: [
              Expanded(
                  child: _buildModeButton(
                      context, AppStrings.scanText, state, size)),
              Expanded(
                  child: _buildModeButton(
                      context, AppStrings.photoText, state, size)),
              Expanded(
                  child: _buildModeButton(
                      context, AppStrings.videoText, state, size)),
              Expanded(
                  child: _buildModeButton(
                      context, AppStrings.audioText, state, size)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(
      BuildContext context, String mode, CameraState state, Size size) {
    final isSelected = state.selectedMode == mode;
    return InkWell(
      onTap: () {
        if (state.selectedMode == mode) return;
        if (mode == AppStrings.scanText) {
          context.read<CameraBloc>().add(const CameraScanDocEvent());
        } else {
          context.read<CameraBloc>().add(CameraModeChangeEvent(mode));
        }
      },
      child: Center(
        child: Text(
          mode,
          style: TextStyle(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: size.width * AppDimensions.numD035,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildBottomBar(
      BuildContext context, CameraState state, Size size, Color bgColor) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: size.width * AppDimensions.numD04,
            vertical: size.height * AppDimensions.numD02),
        child: Row(
          children: [
            Expanded(
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
                    commonButtonStyle(size, Theme.of(context).primaryColor),
                    () {
                  context.pop();
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CameraState state, Size size) {
    if (state.status == CameraStatus.permissionDenied ||
        state.status == CameraStatus.requestingPermission) {
      return _buildPermissionDeniedUI(context, size, state);
    }
    if (state.selectedMode == AppStrings.audioText) {
      return _buildAudioBody(context, state, size);
    }
    if ((state.status == CameraStatus.loading ||
            state.status == CameraStatus.initial) &&
        (state.cameraController == null ||
            !state.cameraController!.value.isInitialized)) {
      return Center(
        child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
      );
    }

    if (((state.cameraController != null &&
                state.cameraController!.value.isInitialized) ||
            state.status == CameraStatus.failure ||
            state.status == CameraStatus.previewPaused) &&
        state.status != CameraStatus.loading) {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: Stack(
          children: [
            _buildCameraPreview(context, state, size),
            Positioned(
              left: 0,
              right: 0,
              bottom: size.width * AppDimensions.numD25,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _exposureModeControlRowWidget(size, state),
              ),
            ),
            // Plus Icon (Pick from Files)
            Align(
              alignment: Alignment.bottomLeft,
              child: InkWell(
                onTap: () =>
                    context.read<CameraBloc>().add(PickDocumentEvent()),
                child: Container(
                  margin: EdgeInsets.only(
                      left: size.width * AppDimensions.numD1,
                      bottom: size.width * AppDimensions.numD05),
                  padding: EdgeInsets.all(size.width * AppDimensions.numD02),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white24
                              : Colors.grey.shade400,
                          width: 1.2)),
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
            // Capture Button
            Align(
              alignment: Alignment.bottomCenter,
              child: InkWell(
                onTap: () {
                  if (state.selectedMode == AppStrings.videoText) {
                    state.isRecording
                        ? context
                            .read<CameraBloc>()
                            .add(CameraStopRecordingEvent())
                        : context
                            .read<CameraBloc>()
                            .add(CameraStartRecordingEvent());
                  } else if (state.selectedMode == AppStrings.scanText) {
                    context.read<CameraBloc>().add(CameraScanDocEvent());
                  } else {
                    context.read<CameraBloc>().add(CameraCaptureImageEvent());
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(
                      bottom: size.width * AppDimensions.numD05),
                  padding: EdgeInsets.all(size.width * AppDimensions.numD01),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white24
                              : Colors.grey.shade400,
                          width: 1.2)),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        (state.selectedMode == AppStrings.videoText &&
                                state.isRecording)
                            ? Icons.stop_circle_outlined
                            : Icons.circle,
                        color: Theme.of(context).primaryColor,
                        size: size.width * AppDimensions.numD13,
                      ),
                      if (state.isVideoLoading)
                        SizedBox(
                          width: size.width * AppDimensions.numD13,
                          height: size.width * AppDimensions.numD13,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Gallery
            Align(
              alignment: Alignment.bottomRight,
              child: InkWell(
                onTap: () {
                  pauseCamera();
                  context.pushNamed(AppRoutes.customGalleryName,
                      extra: {'picAgain': true}).then((value) {
                    if (value != null) {
                      final List<CameraData> gallerySelected =
                          value as List<CameraData>;
                      if (mounted) {
                        context.pop(gallerySelected);
                      }
                    } else {
                      resumeCamera();
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
                    borderRadius: BorderRadius.circular(
                        size.width * AppDimensions.numD025),
                    child: PersistentGalleryThumbnail(
                        galleryMedia: state.galleryMedia,
                        fallbackLoader: _getLatestGalleryImageBytes),
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
            // Top Controls
            Positioned(
              top: size.width * AppDimensions.numD06,
              left: size.width * AppDimensions.numD04,
              right: size.width * AppDimensions.numD04,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!state.isFrontCamera)
                    IconButton(
                        icon: Icon(
                            state.isFlashOn ? Icons.flash_on : Icons.flash_off,
                            color: Colors.black,
                            size: size.width * AppDimensions.numD05),
                        onPressed: () => context
                            .read<CameraBloc>()
                            .add(CameraFlashToggleEvent()),
                        style: IconButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white24
                                    : Colors.white,
                            shape: const CircleBorder()))
                  else
                    SizedBox(width: size.width * AppDimensions.numD1),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: Image.asset("${iconsPath}arrow_square_down.png",
                              color: Colors.black,
                              height: size.width * AppDimensions.numD05),
                          onPressed: () {
                            _exposureModeControlRowAnimationController.value ==
                                    1
                                ? _exposureModeControlRowAnimationController
                                    .reverse()
                                : _exposureModeControlRowAnimationController
                                    .forward();
                          },
                          style: IconButton.styleFrom(
                              backgroundColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white24
                                  : Colors.white,
                              shape: const CircleBorder())),
                      _exposureModeControlRowUpperWidget(size, state),
                      if (state.selectedMode == AppStrings.videoText)
                        Text(state.recordingTime,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * AppDimensions.numD035,
                                fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(
                      icon: Image.asset("${iconsPath}ic_rotate.png",
                          height: size.width * AppDimensions.numD05),
                      onPressed: () =>
                          context.read<CameraBloc>().add(CameraSwitchEvent()),
                      style: IconButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white24
                                  : Colors.white,
                          shape: const CircleBorder())),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Container(
        color: Colors.black,
        child: state.status == CameraStatus.loading
            ? Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor))
            : const SizedBox.shrink());
  }

  Widget _buildPermissionDeniedUI(
      BuildContext context, Size size, CameraState state) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined,
              size: 100, color: Theme.of(context).hintColor),
          const SizedBox(height: 20),
          Text("Camera Permission Required",
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ElevatedButton(
              onPressed: () => context
                  .read<CameraBloc>()
                  .add(const CameraInitializeEvent(force: true)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor),
              child:
                  Text("Allow Access", style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildAudioBody(BuildContext context, CameraState state, Size size) {
    return Column(
      children: [
        const Spacer(),
        if (state.isRecording && state.recorderController != null)
          AudioWaveforms(
            size: Size(size.width, 100),
            recorderController: state.recorderController!,
            enableGesture: false,
            backgroundColor: Colors.transparent,
            waveStyle: WaveStyle(
                waveColor: Theme.of(context).primaryColor,
                extendWaveform: true,
                showMiddleLine: false),
          ),
        Text(state.recordingTime.isEmpty ? "00:00:00" : state.recordingTime,
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: size.width * 0.15)),
        const Spacer(),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: size.width * AppDimensions.numD08,
              vertical: size.width * AppDimensions.numD04),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => context.read<CameraBloc>().add(state.isRecording
                    ? AudioStopRecordingEvent()
                    : AudioStartRecordingEvent()),
                child: Container(
                  padding: EdgeInsets.all(size.width * AppDimensions.numD01),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white24
                              : Colors.grey.shade400,
                          width: 1.2)),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                          state.isRecording
                              ? Icons.stop_circle_outlined
                              : Icons.circle,
                          color: Theme.of(context).primaryColor,
                          size: size.width * AppDimensions.numD13),
                      if (state.status == CameraStatus.loading)
                        const CircularProgressIndicator(color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _exposureModeControlRowWidget(Size size, CameraState state) {
    return SizeTransition(
      sizeFactor: _exposureModeControlRowAnimation,
      child: Slider(
        value: _currentExposureOffset,
        min: _minAvailableExposureOffset,
        max: _maxAvailableExposureOffset,
        activeColor: Theme.of(context).primaryColor,
        onChanged: (val) {
          setState(() => _currentExposureOffset = val);
          context.read<CameraBloc>().add(UpdateExposureEvent(val));
        },
      ),
    );
  }

  Widget _exposureModeControlRowUpperWidget(Size size, CameraState state) {
    return SizeTransition(
      sizeFactor: _exposureModeControlRowAnimation,
      child: Text("Automatically enhanced",
          style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontSize: size.width * AppDimensions.numD03)),
    );
  }

  Widget _buildCameraPreview(
      BuildContext context, CameraState state, Size size) {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onScaleStart: (details) => _baseScale = _currentZoom,
        onScaleUpdate: (details) {
          if (_pointers != 2) return;
          _currentZoom = (_baseScale * details.scale)
              .clamp(_minAvailableZoom, _maxAvailableZoom);
          context.read<CameraBloc>().add(UpdateZoomEvent(_currentZoom));
        },
        onTapDown: (details) {
          final offset = Offset(
            details.localPosition.dx / constraints.maxWidth,
            details.localPosition.dy / constraints.maxHeight,
          );
          state.cameraController?.setExposurePoint(offset);
          state.cameraController?.setFocusPoint(offset);

          setState(() {
            showFocusCircle = true;
            x = details.localPosition.dx;
            y = details.localPosition.dy;
          });
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) setState(() => showFocusCircle = false);
          });
        },
        child: SizedBox(
          height: size.height,
          width: size.width,
          child: FittedBox(
            fit: BoxFit.cover,
            alignment: Alignment.center,
            child: SizedBox(
              width: size.width,
              child: (state.status == CameraStatus.ready ||
                          state.status == CameraStatus.recording ||
                          state.status == CameraStatus.recordingPaused ||
                          state.status == CameraStatus.previewPaused ||
                          state.status == CameraStatus.success) &&
                      state.cameraController != null
                  ? Visibility(
                      visible: state.status == CameraStatus.ready ||
                          state.status == CameraStatus.recording ||
                          state.status == CameraStatus.success ||
                          state.isRecording,
                      maintainState: false,
                      child: ValueListenableBuilder<CameraValue>(
                        valueListenable: state.cameraController!,
                        builder: (context, value, child) {
                          if (value.isInitialized) {
                            return CameraPreview(state.cameraController!,
                                key: ValueKey(state.initCount));
                          } else {
                            return Container(
                              color: Colors.black,
                              width: size.width,
                              height: size.height,
                            );
                          }
                        },
                      ),
                    )
                  : Container(
                      color: Colors.black,
                      width: size.width,
                      height: size.height,
                    ),
            ),
          ),
        ),
      );
    });
  }
}
