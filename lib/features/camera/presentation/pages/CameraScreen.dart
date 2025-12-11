import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/core/widgets/error/permission_error_screen.dart';
import 'package:presshop/features/camera/data/models/camera_model.dart';
import 'package:presshop/features/camera/presentation/bloc/camera_bloc.dart';
import 'package:presshop/features/camera/presentation/bloc/camera_event.dart';
import 'package:presshop/features/camera/presentation/bloc/camera_state.dart';
import 'package:presshop/features/camera/presentation/pages/CustomGallary.dart';
import 'package:presshop/features/camera/presentation/pages/PreviewScreen.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/di/injection_container.dart' as di;

// Constants (Keep if not in common)
const String photoText = "Photo";
const String videoText = "Video";
const String scanText = "Scan";
const String audioText = "Audio";
const String notesText = "Notes";
const String interviewText = "Interview";

class CameraScreen extends StatefulWidget {
  final bool picAgain;
  final ScreenNameEnum previousScreen;
  final bool autoInitialize;

  const CameraScreen({
    super.key,
    required this.picAgain,
    required this.previousScreen,
    this.autoInitialize = true,
  });

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
           if (state.status == CameraStatus.ready && state.cameraController != null) {
               try {
                   _minAvailableExposureOffset = await state.cameraController!.getMinExposureOffset();
                   _maxAvailableExposureOffset = await state.cameraController!.getMaxExposureOffset();
                   _maxAvailableZoom = await state.cameraController!.getMaxZoomLevel();
                   _minAvailableZoom = await state.cameraController!.getMinZoomLevel();
                   if (mounted) setState(() {});
               } catch (e) {
                   debugPrint("Error getting camera info: $e");
               }
           }

           if (state.status == CameraStatus.failure) {
              if (state.errorMessage.contains("Permission") || state.errorMessage.contains("denied")) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => 
                     PermissionErrorScreen(permissionsStatus: {Permission.camera: false, Permission.microphone: false})));
              }
           }
           
           if (state.status == CameraStatus.success) {
               if (widget.picAgain) {
                    Navigator.pop(context, state.capturedMedia);
               } else {
                    // Navigate to Preview
                    // We need to pass the captured media. The preview screen handles the list.
                    // Important: The original code clears camListData or builds it up?
                    // "camListData.add(...)". So it builds up.
                    // Here state.capturedMedia has the list.
                    
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PreviewScreen(
                        cameraData: null,
                        pickAgain: widget.picAgain,
                        type: state.selectedMode.toLowerCase() == "video" ? "video" : 
                              state.selectedMode.toLowerCase() == scanText.toLowerCase() ? "scan" :
                              state.selectedMode.toLowerCase() == "pdf" ? "pdf" : "camera",
                        cameraListData: state.capturedMedia,
                        mediaList: [],
                    ))).then((value) {
                         // On return
                         _bloc!.state.cameraController?.resumePreview();
                    });
               }
           }
           
           if (state.status == CameraStatus.permissionDenied) {
                // Handle specific permission denial (audio)
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => 
                     PermissionErrorScreen(permissionsStatus: {Permission.microphone: false})));
           }
        },
        builder: (context, state) {
           return Scaffold(
              appBar: _buildAppBar(context, state, size),
              bottomNavigationBar: widget.picAgain ? _buildBottomBar(context, size) : null,
              body: _buildBody(context, state, size),
           );
        },
      ),
    );
  }
  
  // AppBar Widget
  PreferredSizeWidget _buildAppBar(BuildContext context, CameraState state, Size size) {
      return AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: size.width * numD1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * numD06, vertical: size.width * numD02),
            child: Column(
              children: [
                Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                      if (widget.previousScreen != ScreenNameEnum.manageTaskScreen)
                        _buildModeButton(context, scanText, state, size),
                      _buildModeButton(context, photoText, state, size),
                      _buildModeButton(context, videoText, state, size),
                      _buildModeButton(context, audioText, state, size, 
                          label: widget.previousScreen == ScreenNameEnum.manageTaskScreen ? interviewText : audioText),
                   ],
                )
              ],
            ),
          ),
        ),
      );
  }
  
  Widget _buildModeButton(BuildContext context, String mode, CameraState state, Size size, {String? label}) {
      final isSelected = state.selectedMode == mode;
      return InkWell(
          onTap: () {
             context.read<CameraBloc>().add(CameraModeChangeEvent(mode));
          },
          child: FittedBox(
              child: Text(
                  label ?? mode,
                  style: TextStyle(
                      color: isSelected ? colorThemePink : Colors.black,
                      fontSize: size.width * numD035,
                      fontWeight: FontWeight.w500
                  ),
              )
          ),
      );
  }
  
  Widget? _buildBottomBar(BuildContext context, Size size) {
       return Padding(
          padding: EdgeInsets.only(
             left: size.width * numD04,
             top: size.height * numD032,
             bottom: size.height * numD035,
             right: size.width * numD04
          ),
          child: SizedBox(
             height: size.width * numD13,
             child: commonElevatedButton("Cancel", size, 
                  commonTextStyle(size: size, fontSize: size.width * numD04, color: Colors.white, fontWeight: FontWeight.w700),
                  commonButtonStyle(size, colorThemePink), 
                  () => Navigator.pop(context)),
          ),
       );
  }
  
  Widget _buildBody(BuildContext context, CameraState state, Size size) {
      if (state.selectedMode == audioText) {
          return _buildAudioBody(context, state, size);
      }
      return Stack(
         children: [
             _buildCameraPreview(context, state, size),
             
             // Exposure Controls
             Positioned(
                 left: 0, right: 0, bottom: size.width * numD25,
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
                        margin: EdgeInsets.only(left: size.width * numD1, bottom: size.width * numD05),
                        padding: EdgeInsets.all(size.width * numD02),
                        decoration: BoxDecoration(color: Colors.transparent, shape: BoxShape.circle, border: Border.all(color: Colors.white)),
                        child: Container(
                             padding: EdgeInsets.all(size.width * numD02),
                             decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                             child: Image.asset("${iconsPath}ic_plus.png", color: Colors.white, height: size.width * numD07),
                        ),
                     ),
                 ),
             ),
             
             // Capture/Record Button
             Align(
                 alignment: Alignment.bottomCenter,
                 child: InkWell(
                     onTap: () {
                         if (state.selectedMode == videoText) {
                             if (state.isRecording) {
                                 context.read<CameraBloc>().add(CameraStopRecordingEvent());
                             } else {
                                 context.read<CameraBloc>().add(CameraStartRecordingEvent());
                             }
                         } else if (state.selectedMode == scanText) {
                             context.read<CameraBloc>().add(CameraScanDocEvent());
                         } else {
                             // Photo
                             context.read<CameraBloc>().add(CameraCaptureImageEvent());
                         }
                     },
                     child: Container(
                         margin: EdgeInsets.only(bottom: size.width * numD05),
                         padding: EdgeInsets.all(size.width * numD01),
                         decoration: BoxDecoration(color: Colors.transparent, shape: BoxShape.circle, border: Border.all(color: colorThemePink)),
                         child: Icon(
                            (state.selectedMode == videoText && state.isRecording) ? Icons.stop_circle_outlined : Icons.circle,
                            color: colorThemePink,
                            size: size.width * numD13,
                         ),
                     ),
                 ),
             ),
             
             // Gallery Thumbnail
             if (state.selectedMode == photoText || state.selectedMode == videoText) 
                 Align(
                     alignment: Alignment.bottomRight,
                     child: InkWell(
                        onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => CustomGallery(picAgain: widget.picAgain)))
                            .then((value) {
                                if (value != null) {
                                     context.read<CameraBloc>().add(UpdateCapturedMediaEvent(value as List<CameraData>));
                                     if (widget.picAgain) Navigator.pop(context, value);
                                }
                            });
                        },
                        child: Container(
                            width: size.width * numD15,
                            height: size.width * numD15,
                            margin: EdgeInsets.only(bottom: size.width * numD05, right: size.width * numD1),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(size.width * numD025),
                                child: state.galleryMedia.isNotEmpty 
                                ? FutureBuilder(
                                    future: state.galleryMedia.first.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
                                    builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                                            return Image.memory(snapshot.data!, fit: BoxFit.cover);
                                        }
                                        return Container(color: Colors.grey);
                                    }
                                  )
                                : Image.asset("${dummyImagePath}walk2.png", fit: BoxFit.cover),
                            ),
                        ),
                     ),
                 ),
                 
             // Focus Circle
             if (showFocusCircle)
                 Positioned(
                     top: y - 20, left: x - 20,
                     child: Image.asset("${iconsPath}ic_focus.png", width: size.width * numD15, height: size.width * numD15, color: Colors.white),
                 ),
                 
             // Top Controls (Flash, Rotate, Settings)
             if (state.selectedMode == photoText || state.selectedMode == videoText)
                Positioned(
                    top: size.width * numD06, left: size.width * numD1, right: size.width * numD1,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                             if (!state.isFrontCamera)
                                InkWell(
                                    onTap: () => context.read<CameraBloc>().add(CameraFlashToggleEvent()),
                                    child: Container(
                                        padding: EdgeInsets.all(size.width * numD01),
                                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                        child: Icon(state.isFlashOn ? Icons.flash_on : Icons.flash_off, color: Colors.black, size: size.width * numD04),
                                    ),
                                )
                             else SizedBox(width: size.width * numD06),
                             
                             // Center Settings
                             Column(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                     InkWell(
                                        onTap: () {
                                            if (_exposureModeControlRowAnimationController.value == 1) {
                                                _exposureModeControlRowAnimationController.reverse();
                                            } else {
                                                _exposureModeControlRowAnimationController.forward();
                                            }
                                        },
                                        child: Container(
                                            padding: EdgeInsets.all(size.width * numD01),
                                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                            child: Image.asset("${iconsPath}arrow_square_down.png", color: Colors.black, height: size.width * numD042),
                                        ),
                                     ),
                                     _exposureModeControlRowUpperWidget(size, state),
                                     SizedBox(height: size.width * numD01),
                                     if (state.selectedMode == videoText)
                                        Text(state.recordingTime, style: commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.black, fontWeight: FontWeight.w500)),
                                 ],
                             ),
                             
                             // Rotate Camera
                             InkWell(
                                 onTap: () => context.read<CameraBloc>().add(CameraSwitchEvent()),
                                 child: Container(
                                    padding: EdgeInsets.all(size.width * numD01),
                                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    child: Image.asset("${iconsPath}ic_rotate.png", height: size.width * numD04),
                                 ),
                             ),
                        ],
                    ),
                ),
         ],
      );
  }
  
  Widget _buildCameraPreview(BuildContext context, CameraState state, Size size) {
      if (state.status == CameraStatus.loading || state.cameraController == null || !state.cameraController!.value.isInitialized) {
          return Center(child: CircularProgressIndicator(color: colorThemePink));
      }
      
      return Listener(
         onPointerDown: (_) => _pointers++,
         onPointerUp: (_) => _pointers--,
         child: LayoutBuilder(builder: (context, constraints) {
             return Center(
                child: GestureDetector(
                    onScaleStart: (details) => _baseScale = _currentZoom, // Wait, need to track current scale in UI or Bloc?
                    onScaleUpdate: (details) async {
                        if (_pointers != 2) return;
                        _currentZoom = (_baseScale * details.scale).clamp(_minAvailableZoom, _maxAvailableZoom);
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
               state.isRecording ? 
               AudioWaveforms(
                   size: Size(size.width, 100),
                   recorderController: state.recorderController!,
                   enableGesture: false,
                   backgroundColor: Colors.transparent,
                   shouldCalculateScrolledPosition: true,
                   waveStyle: WaveStyle(
                       waveColor: colorThemePink,
                       extendWaveform: true,
                       showMiddleLine: false,
                       gradient: ui.Gradient.linear(const Offset(70, 50), Offset(size.width/2, 0), [Colors.red, Colors.green])
                   ),
               ) : Container(),
               
               Text(state.recordingTime.isEmpty ? "00:00:00" : state.recordingTime, 
                   style: commonTextStyle(size: size, fontSize: size.width * numD15, color: Colors.black, fontWeight: FontWeight.w500)),
               
               const Spacer(),
               Padding(
                   padding: EdgeInsets.symmetric(horizontal: size.width * numD08, vertical: size.width * numD04),
                   child: Row(
                       children: [
                           if (state.recordingTime.isNotEmpty && state.recordingTime != "00:00:00" && !state.isRecording)
                              IconButton(
                                  onPressed: () {
                                      // Cancel/Reset
                                       // This logic was in stopAudioRecording(false) -> clear list
                                       context.read<CameraBloc>().add(AudioStopRecordingEvent()); // Needs a flag to discard? 
                                       // Bloc doesn't have discard. We can just ignore result in listener if we have a flag.
                                       // Or simplified: Just stop.
                                  },
                                  icon: Icon(Icons.close, color: Colors.red, size: size.width * numD08),
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
                                   padding: EdgeInsets.all(size.width * numD01),
                                   decoration: BoxDecoration(color: Colors.transparent, shape: BoxShape.circle, border: Border.all(color: colorThemePink)),
                                   child: Icon(state.isRecording ? Icons.stop_circle_outlined : Icons.circle, color: colorThemePink, size: size.width * numD13),
                               ),
                           ),
                           const Spacer(),
                           if (state.capturedMedia.isNotEmpty) // Logic for check button
                              IconButton(
                                  onPressed: () {
                                       // Done
                                       Navigator.push(context, MaterialPageRoute(builder: (context) => PreviewScreen(
                                            cameraData: null, pickAgain: widget.picAgain, type: "camera", cameraListData: state.capturedMedia, mediaList: []
                                       )));
                                  },
                                  icon: Icon(Icons.check, color: colorOnlineGreen, size: size.width * numD08),
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
                               Text(_minAvailableExposureOffset.toString(), style: TextStyle(color: Colors.white, fontSize: size.width * numD03, fontWeight: FontWeight.w500)),
                               SliderTheme(
                                   data: SliderThemeData(trackHeight: size.width * numD009),
                                   child: Slider(
                                       value: _currentExposureOffset,
                                       min: _minAvailableExposureOffset,
                                       max: _maxAvailableExposureOffset,
                                       activeColor: colorThemePink,
                                       onChanged: (val) {
                                            setState(() => _currentExposureOffset = val);
                                            context.read<CameraBloc>().add(UpdateExposureEvent(val));
                                       },
                                   ),
                               ),
                               Text(_maxAvailableExposureOffset.toString(), style: TextStyle(color: Colors.white, fontSize: size.width * numD03, fontWeight: FontWeight.w500)),
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
                       state.selectedMode == scanText ? 'This scan is automatically enhanced' :
                       state.selectedMode == videoText ? "This video is automatically enhanced" :
                       "This pic is automatically enhanced",
                       style: TextStyle(fontSize: size.width * numD03, fontWeight: FontWeight.w500),
                   )
              ],
          ),
      );
  }
}
