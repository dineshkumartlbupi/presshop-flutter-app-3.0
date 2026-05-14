import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/services/permission_service.dart'
    show PermissionService;
import 'package:presshop/core/widgets/new_home_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/core/widgets/video_widget.dart';
import 'package:presshop/features/camera/data/models/camera_model.dart';
import 'package:presshop/features/camera/presentation/bloc/camera_bloc.dart';
import 'package:presshop/features/camera/presentation/bloc/camera_event.dart';
import 'package:presshop/features/camera/presentation/bloc/camera_state.dart';
import 'package:presshop/core/di/injection_container.dart' as di;
import 'package:go_router/go_router.dart';
import 'package:presshop/features/camera/presentation/pages/preview_screen.dart';

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
    required this.previousScreen,
    this.autoInitialize = true,
    this.hideBottomBar = false,
  });
  final ScreenNameEnum previousScreen;
  final bool autoInitialize;
  final bool hideBottomBar;

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
    // Ensure we start with a clean state for captured media
    clearCapturedMedia();
    if (widget.autoInitialize) {
      _bloc!.add(const CameraInitializeEvent());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _bloc?.add(CameraLifecycleEvent(state));
    if (state == AppLifecycleState.resumed) {
      debugPrint("🔄 CameraScreen: App resumed. Lifecycle event sent to Bloc.");
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    closeCamera(); // Ensure camera hardware is released immediately
    WidgetsBinding.instance.removeObserver(this);
    _exposureModeControlRowAnimationController.dispose();
    super.dispose();
  }

  void resumeCamera({bool force = false}) {
    if (_bloc != null && !_bloc!.isClosed) {
      debugPrint("🔄 CameraScreen: Ensuring camera is initialized");
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
      debugPrint("🔄 CameraScreen: Pausing camera preview");
      _bloc!.add(const CameraPausePreviewEvent());
    }
  }

  void clearCapturedMedia() {
    if (_bloc != null && !_bloc!.isClosed) {
      debugPrint("🗑️ CameraScreen: Clearing captured media");
      _bloc!.add(const UpdateCapturedMediaEvent([]));
    }
  }

  Future<Uint8List?> _getLatestGalleryImageBytes() async {
    try {
      // Ensure we have permissions first
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth && !ps.hasAccess) {
        debugPrint(
            '📸 CameraScreen: Gallery permission not granted for thumbnail.');
        return null;
      }

      // Fetch albums with explicit sorting (Latest first)
      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType
            .common, // Fetch both images and videos for the thumbnail
        filterOption: FilterOptionGroup(
          orders: [
            const OrderOption(type: OrderOptionType.createDate, asc: false),
          ],
        ),
      );

      if (paths.isEmpty) {
        debugPrint('📸 CameraScreen: No gallery albums found.');
        return null;
      }

      // Find the first album that actually has media
      for (var path in paths) {
        final List<AssetEntity> assets =
            await path.getAssetListRange(start: 0, end: 1);
        if (assets.isNotEmpty) {
          debugPrint(
              '📸 CameraScreen: Found latest gallery item in album: ${path.name}');
          return await assets.first
              .thumbnailDataWithSize(const ThumbnailSize(200, 200));
        }
      }

      debugPrint('📸 CameraScreen: All albums are empty.');
      return null;
    } catch (e) {
      debugPrint('Error fetching latest gallery image: $e');
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
          // Update local limits when camera is ready
          // ONLY run this if status changed to ready to avoid redundant calls (blinking)
          if (state.status == CameraStatus.ready &&
              _lastStatus != CameraStatus.ready &&
              state.cameraController != null &&
              state.cameraController!.value.isInitialized) {
            try {
              debugPrint(
                  "📸 CameraScreen: Camera ready, initializing UI limits");
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
            } catch (e) {
              debugPrint("Error getting camera info (ignored): $e");
            }
          }
          _lastStatus = state.status;

          if (state.status == CameraStatus.failure) {
            debugPrint(
                "📸 CameraScreen: Camera failure: ${state.errorMessage}");

            // Redirect logic removed to show internal failure UI instead
          }

          if (state.status == CameraStatus.success) {
            if (mounted) {
              _bloc?.add(const CameraResetStatusEvent());
              if (widget.previousScreen != ScreenNameEnum.manageTaskScreen) {
                _navigateToPreview(state);
              }
              // For manageTaskScreen, we stay on this screen and show the Tick/Cross overlay via _buildBody
            }
          }

          if (state.status == CameraStatus.permissionDenied) {
            // Handled by Dashboard
            debugPrint("📸 CameraScreen: Permission denied status received");
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.black, // Root background must be black
            appBar: _buildAppBar(context, state, size),
            // bottomNavigationBar: (!widget.hideBottomBar && state.capturedMedia.isNotEmpty)
            //     ? _buildBottomBar(context, state, size)
            //     : null,
            body: Container(
              color: Colors.black, // Ensure body is also black
              child: _buildBody(context, state, size),
            ),
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
              horizontal: size.width * AppDimensions.numD04,
              vertical: size.width * AppDimensions.numD02),
          child: Column(
            children: [
              Row(
                children: [
                  if (widget.previousScreen != ScreenNameEnum.manageTaskScreen)
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
                      context,
                      AppStrings.audioText,
                      state,
                      size,
                      label: widget.previousScreen ==
                              ScreenNameEnum.manageTaskScreen
                          ? AppStrings.interviewText
                          : AppStrings.audioText,
                    ),
                  ),
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
        if (state.selectedMode == mode) return;
        if (mode == AppStrings.scanText) {
          context.read<CameraBloc>().add(const CameraScanDocEvent());
        } else {
          context.read<CameraBloc>().add(CameraModeChangeEvent(mode));
        }
      },
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label ?? mode,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: isSelected
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? Colors.red
                        : AppColorTheme.colorThemePink)
                    : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black),
                fontSize: size.width * AppDimensions.numD035,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
          ),
        ),
      ),
    );
  }

  // Widget? _buildBottomBar(BuildContext context, CameraState state, Size size) {
  //   return SafeArea(
  //     child: Padding(
  //       padding: EdgeInsets.only(
  //           left: size.width * AppDimensions.numD04,
  //           top: size.height * AppDimensions.numD032,
  //           bottom: size.height * AppDimensions.numD035,
  //           right: size.width * AppDimensions.numD04),
  //       child: SizedBox(
  //         height: size.width * AppDimensions.numD13,
  //         child: commonElevatedButton(
  //             "Cancel",
  //             size,
  //             commonTextStyle(
  //                 size: size,
  //                 fontSize: size.width * AppDimensions.numD04,
  //                 color: Colors.white,
  //                 fontWeight: FontWeight.w700),
  //             commonButtonStyle(size, AppColorTheme.colorThemePink), () {
  //           _navigateToPreview(state);
  //         }),
  //       ),
  //     ),
  //   );
  // }

  void _navigateToPreview(CameraState state) async {
    // Close camera hardware before navigating to avoid resource hogging/stuck states
    closeCamera();

    await context.pushNamed(
      AppRoutes.previewName,
      extra: {
        'cameraData': null,
        'type': state.selectedMode.toLowerCase() == "video"
            ? "video"
            : state.selectedMode.toLowerCase() ==
                    AppStrings.scanText.toLowerCase()
                ? "scan"
                : state.selectedMode.toLowerCase() == "pdf"
                    ? "pdf"
                    : "camera",
        'cameraListData': state.capturedMedia,
        'mediaList': <MediaData>[],
      },
    ).then((value) {
      // On return from PreviewPage
      if (!mounted) return;

      if (_bloc?.state.selectedMode == AppStrings.scanText) {
        // If we were in scan mode, switch back to photo mode which will auto-init
        _bloc?.add(const CameraModeChangeEvent(AppStrings.photoText));
      } else {
        // For other modes, just ensure the camera is ready
        resumeCamera();
      }
    });
  }

  Widget _buildBody(BuildContext context, CameraState state, Size size) {
    // 1. Show permission UI if denied or requesting
    if (state.status == CameraStatus.permissionDenied ||
        state.status == CameraStatus.requestingPermission) {
      return _buildPermissionDeniedUI(context, size, state);
    }

    // 2. Show audio body if in audio mode
    if (state.selectedMode == AppStrings.audioText) {
      return _buildAudioBody(context, state, size);
    }

    // 3. Show camera preview and overlays if controller is ready, OR if we have a failure
    // Also show if preview is paused (it will just show the last frame or a black screen, which is better than a loader)
    if (((state.cameraController != null &&
                state.cameraController!.value.isInitialized) ||
            state.status == CameraStatus.failure ||
            state.status == CameraStatus.previewPaused) &&
        state.status != CameraStatus.loading) {
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

          // Capture/Record Button
          Align(
            alignment: Alignment.bottomCenter,
            child: InkWell(
              onTap: state.isVideoLoading ||
                      state.status == CameraStatus.loading
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
                        context
                            .read<CameraBloc>()
                            .add(CameraCaptureImageEvent());
                      }
                    },
              child: Container(
                margin:
                    EdgeInsets.only(bottom: size.width * AppDimensions.numD05),
                padding: EdgeInsets.all(size.width * AppDimensions.numD01),
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white24
                            : Colors.grey.shade400,
                        width: 1.2)),
                child: state.isVideoLoading
                    ? SizedBox.shrink()
                    // ? SizedBox(
                    //     width: size.width * AppDimensions.numD13,
                    //     height: size.width * AppDimensions.numD13,
                    //     child: Padding(
                    //       padding:
                    //           EdgeInsets.all(size.width * AppDimensions.numD03),
                    //       child: CircularProgressIndicator(
                    //         strokeWidth: 2,
                    //         color: AppColorTheme.colorThemePink,
                    //       ),
                    //     ),
                    //   )
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
                  pauseCamera();
                  context.pushNamed(
                    AppRoutes.customGalleryName,
                    extra: {
                      'picAgain': false,
                    },
                  ).then((value) {
                    resumeCamera();
                    if (value != null) {
                      // ignore: use_build_context_synchronously
                      if (!context.mounted) return;
                      context.read<CameraBloc>().add(
                          UpdateCapturedMediaEvent(value as List<CameraData>));
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
                      fallbackLoader: _getLatestGalleryImageBytes,
                    ),
                  ),
                ),
              ),
            ),

          // Done Button (only if we have items and in Add More mode or generally)
          // if (state.capturedMedia.isNotEmpty)
          //   Align(
          //     alignment: Alignment.bottomRight,
          //     child: Container(
          //       margin: EdgeInsets.only(
          //           bottom: size.width * AppDimensions.numD25, // Above gallery
          //           right: size.width * AppDimensions.numD08),
          //       child: InkWell(
          //         onTap: () {
          //           _navigateToPreview(state);
          //         },
          //         child: Container(
          //           padding: EdgeInsets.all(size.width * AppDimensions.numD02),
          //           decoration: const BoxDecoration(
          //             color: AppColorTheme.colorOnlineGreen,
          //             shape: BoxShape.circle,
          //           ),
          //           child: Icon(Icons.check,
          //               color: Colors.white,
          //               size: size.width * AppDimensions.numD08),
          //         ),
          //       ),
          //     ),
          //   ),

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

          // Manage Task Direct Capture Overlay (Tick/Cross)
          if (widget.previousScreen == ScreenNameEnum.manageTaskScreen &&
              state.capturedMedia.isNotEmpty)
            _buildManageTaskCaptureOverlay(context, state, size),

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
                          if (_exposureModeControlRowAnimationController
                                  .value ==
                              1) {
                            _exposureModeControlRowAnimationController
                                .reverse();
                          } else {
                            _exposureModeControlRowAnimationController
                                .forward();
                          }
                        },
                        child: Container(
                          padding:
                              EdgeInsets.all(size.width * AppDimensions.numD01),
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: Image.asset(
                              "${iconsPath}arrow_square_down.png",
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
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w500)),
                    ],
                  ),

                  // Rotate Camera
                  InkWell(
                    onTap: () =>
                        context.read<CameraBloc>().add(CameraSwitchEvent()),
                    child: Container(
                      padding:
                          EdgeInsets.all(size.width * AppDimensions.numD01),
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

    // 4. Default fallback: show loader while hardware initializes
    return Container(
      color: Colors.black,
      child: state.status == CameraStatus.loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                      color: AppColorTheme.colorThemePink),
                  const SizedBox(height: 16),
                  Text(
                    "Initializing Camera...",
                    style: TextStyle(
                        color: Colors.white70, fontSize: size.width * 0.035),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildPermissionDeniedUI(
      BuildContext context, Size size, CameraState state) {
    final detail = state.permissionDetail;
    final isPermanent = state.errorMessage == "permanently_denied";

    String missingText = "";
    if (detail != null) {
      List<String> missing = [];
      if (!detail.cameraGranted) missing.add("Camera");
      if (!detail.micGranted) missing.add("Microphone");
      if (!detail.galleryGranted) missing.add("Gallery");
      missingText = missing.join(", ");
    }

    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: size.width * 0.2,
            color: AppColorTheme.colorThemePink,
          ),
          SizedBox(height: size.width * 0.05),
          Text(
            "Permissions Required",
            style: TextStyle(
              color: Colors.white,
              fontSize: size.width * 0.045,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size.width * 0.02),
          Text(
            isPermanent
                ? "The following permissions are disabled in settings: $missingText. Please enable them to continue."
                : "We need access to your $missingText to capture and share content.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: size.width * 0.035,
            ),
            textAlign: TextAlign.center,
          ),
          if (detail != null) ...[
            SizedBox(height: size.width * 0.04),
            _buildMiniPermissionStatus(size, "Camera", detail.cameraGranted),
            _buildMiniPermissionStatus(size, "Microphone", detail.micGranted),
            _buildMiniPermissionStatus(size, "Gallery", detail.galleryGranted),
          ],
          SizedBox(height: size.width * 0.08),
          SizedBox(
            width: double.infinity,
            height: size.width * 0.12,
            child: ElevatedButton(
              onPressed: () async {
                if (isPermanent) {
                  await openAppSettings();
                } else {
                  context
                      .read<CameraBloc>()
                      .add(const CameraInitializeEvent(force: true));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorTheme.colorThemePink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isPermanent ? "Open Settings" : "Allow Access",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: size.width * 0.04),
          TextButton.icon(
            onPressed: () {
              context
                  .read<CameraBloc>()
                  .add(const CameraInitializeEvent(force: true));
            },
            icon: const Icon(Icons.refresh, color: Colors.white70),
            label: const Text(
              "Already allowed? Tap to Refresh",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          if (!isPermanent) ...[
            SizedBox(height: size.width * 0.04),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text(
                "Not Now",
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniPermissionStatus(Size size, String label, bool granted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            granted ? Icons.check_circle : Icons.cancel,
            color: granted ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style:
                TextStyle(color: Colors.white70, fontSize: size.width * 0.032),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(
      BuildContext context, CameraState state, Size size) {
    if (state.status == CameraStatus.failure) {
      final isPermissionError = state.errorMessage == "permanently_denied" ||
          state.errorMessage == "permission_denied";
      final isNoCamera = state.errorMessage.contains("No cameras available") ||
          state.errorMessage.contains("No camera found");

      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPermissionError
                    ? Icons.lock_outline
                    : Icons.camera_alt_outlined,
                size: 100,
                color: Colors.grey,
              ),
              SizedBox(height: size.height * 0.04),
              Text(
                isPermissionError
                    ? (state.errorMessage == "permanently_denied"
                        ? 'Permissions are permanently denied. Please enable them in system settings to continue.'
                        : 'Camera and Microphone permissions are required to use this feature. Please allow them to continue.')
                    : (isNoCamera
                        ? 'Camera is not available on this device.'
                        : 'Failed to initialize camera. Please try again.'),
                textAlign: TextAlign.center,
                style: commonTextStyle(
                  size: size,
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              SizedBox(height: size.height * 0.04),
              SizedBox(
                width: size.width * 0.6,
                height: 50,
                child: commonElevatedButton(
                  state.errorMessage == "permanently_denied"
                      ? "Open Settings"
                      : "Retry",
                  size,
                  commonButtonTextStyle(size),
                  commonButtonStyle(size, AppColorTheme.colorThemePink),
                  () {
                    if (state.errorMessage == "permanently_denied") {
                      di.sl<PermissionService>().openSettings();
                    } else {
                      context
                          .read<CameraBloc>()
                          .add(const CameraInitializeEvent(force: true));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.status == CameraStatus.loading ||
        (state.status == CameraStatus.initial &&
            state.cameraController == null &&
            state.selectedMode != AppStrings.audioText)) {
      return Container(
        color: Colors.black,
        child: state.status == CameraStatus.loading
            ? const Center(
                child: CircularProgressIndicator(
                    color: AppColorTheme.colorThemePink))
            : const SizedBox.shrink(),
      );
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
          ),
        );
      }),
    );
  }

  Widget _buildAudioBody(BuildContext context, CameraState state, Size size) {
    return Column(
      children: [
        const Spacer(),
        state.isRecording && state.recorderController != null
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.red
                    : AppColorTheme.colorThemePink,
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
                      border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white24
                              : Colors.grey.shade400,
                          width: 1.2)),
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
                    _navigateToPreview(state);
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

  Widget _buildManageTaskCaptureOverlay(
      BuildContext context, CameraState state, Size size) {
    final media = state.capturedMedia.last;
    return Container(
      color: Colors.black,
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          // Captured Media Preview
          Center(
            child: media.mimeType == "image"
                ? Image.file(File(media.path), fit: BoxFit.contain)
                : media.mimeType == "video"
                    ? VideoWidget(
                        mediaData: MediaData(
                          mediaPath: media.path,
                          mimeType: "video",
                          dateTime: media.dateTime,
                          latitude: media.latitude,
                          longitude: media.longitude,
                          location: media.location,
                          country: media.country,
                          state: media.state,
                          city: media.city,
                          thumbnail: media.videoImagePath,
                          isFromGallery: false,
                        ),
                      )
                    : Center(
                        child: Text(
                          "Captured: ${media.mimeType}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
          ),
          // Action Buttons
          Positioned(
            bottom: size.width * AppDimensions.numD15,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cancel (Cross)
                InkWell(
                  onTap: () {
                    final updatedList =
                        List<CameraData>.from(state.capturedMedia);
                    updatedList.removeLast();
                    context
                        .read<CameraBloc>()
                        .add(UpdateCapturedMediaEvent(updatedList));
                  },
                  child: Container(
                    padding: EdgeInsets.all(size.width * AppDimensions.numD04),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close,
                        color: Colors.white,
                        size: size.width * AppDimensions.numD08),
                  ),
                ),
                // Confirm (Tick)
                InkWell(
                  onTap: () {
                    context.pop(state.capturedMedia);
                  },
                  child: Container(
                    padding: EdgeInsets.all(size.width * AppDimensions.numD04),
                    decoration: BoxDecoration(
                      color: AppColorTheme.colorOnlineGreen.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check,
                        color: Colors.white,
                        size: size.width * AppDimensions.numD08),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                SizedBox(width: size.width * AppDimensions.numD04),
                Text(_minAvailableExposureOffset.toStringAsFixed(1),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * AppDimensions.numD03,
                        fontWeight: FontWeight.w500)),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                        trackHeight: size.width * AppDimensions.numD009),
                    child: Slider(
                      value: _currentExposureOffset,
                      min: _minAvailableExposureOffset,
                      max: _maxAvailableExposureOffset,
                      activeColor: AppColorTheme.colorThemePink,
                      onChanged: (val) {
                        setState(() => _currentExposureOffset = val);
                        context
                            .read<CameraBloc>()
                            .add(UpdateExposureEvent(val));
                      },
                    ),
                  ),
                ),
                Text(_maxAvailableExposureOffset.toStringAsFixed(1),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * AppDimensions.numD03,
                        fontWeight: FontWeight.w500)),
                SizedBox(width: size.width * AppDimensions.numD04),
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

class PersistentGalleryThumbnail extends StatefulWidget {
  const PersistentGalleryThumbnail({
    super.key,
    required this.galleryMedia,
    required this.fallbackLoader,
  });
  final List<dynamic> galleryMedia;
  final Future<Uint8List?> Function() fallbackLoader;

  @override
  State<PersistentGalleryThumbnail> createState() =>
      _PersistentGalleryThumbnailState();
}

class _PersistentGalleryThumbnailState
    extends State<PersistentGalleryThumbnail> {
  Future<Uint8List?>? _thumbFuture;
  int _mediaCount = -1;

  @override
  void initState() {
    super.initState();
    _loadFuture();
  }

  @override
  void didUpdateWidget(PersistentGalleryThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.galleryMedia.length != _mediaCount ||
        oldWidget.galleryMedia.isNotEmpty != widget.galleryMedia.isNotEmpty) {
      _loadFuture();
    }
  }

  Future<void> _loadFuture() async {
    _mediaCount = widget.galleryMedia.length;
    if (widget.galleryMedia.isNotEmpty) {
      _thumbFuture = _getGalleryFuture();
    } else {
      _thumbFuture = widget.fallbackLoader();
    }
    if (mounted) setState(() {});
  }

  Future<Uint8List?> _getGalleryFuture() async {
    try {
      final AssetEntity asset = widget.galleryMedia.first;
      final Uint8List? data =
          await asset.thumbnailDataWithSize(const ThumbnailSize(200, 200));
      if (data == null) return await widget.fallbackLoader();
      return data;
    } catch (e) {
      debugPrint("Error loading gallery thumbnail: $e");
      return await widget.fallbackLoader();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _thumbFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.black12,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white54),
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return Image.memory(snapshot.data!, fit: BoxFit.cover);
        }

        // Fallback to a placeholder only if no data could be fetched
        return Image.asset(
          "${CommonAssets.dummyImagePath}walk2.png",
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Container(color: Colors.grey.shade900),
        );
      },
    );
  }
}
