import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:native_exif/native_exif.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:presshop/features/camera/data/models/camera_model.dart';
import 'package:presshop/main.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:presshop/core/core_export.dart';

import 'camera_controller_builder.dart';
import 'camera_event.dart';
import 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraBloc(this._locationService,
      {CameraState? initialState,
      CameraControllerBuilder? cameraControllerBuilder})
      : _cameraControllerBuilder =
            cameraControllerBuilder ?? const CameraControllerBuilder(),
        super(initialState ?? const CameraState()) {
    on<CameraInitializeEvent>(_onInitialize);
    on<CameraSwitchEvent>(_onSwitchCamera);
    on<CameraFlashToggleEvent>(_onToggleFlash);
    on<CameraModeChangeEvent>(_onChangeMode);
    on<CameraCaptureImageEvent>(_onCaptureImage);
    on<CameraStartRecordingEvent>(_onStartVideoRecording);
    on<CameraStopRecordingEvent>(_onStopVideoRecording);
    on<CameraScanDocEvent>(_onScanDoc);
    on<AudioStartRecordingEvent>(_onStartAudioRecording);
    on<AudioStopRecordingEvent>(_onStopAudioRecording);
    on<LoadGalleryMediaEvent>(_onLoadGalleryMedia);
    on<UpdateExposureEvent>(_onUpdateExposure);
    on<UpdateZoomEvent>(_onUpdateZoom);
    on<CameraLifecycleEvent>(_onLifecycleEvent);
    on<UpdateCapturedMediaEvent>(
        (event, emit) => emit(state.copyWith(capturedMedia: event.media)));
    on<CameraTimerTickEvent>(
        (event, emit) => emit(state.copyWith(recordingTime: event.time)));
    on<PickDocumentEvent>(_onPickDocument);
  }
  Timer? _recordingTimer;
  DateTime? _startTime;
  // Duration? _stopDurationDifference;
  // double _currentZoom = 1.0;

  // Dependency Injection for testing
  final CameraControllerBuilder _cameraControllerBuilder;

  // Location
  final LocationService _locationService;
  double _latitude = 0;
  double _longitude = 0;
  bool _isInitializing = false;

  @override
  Future<void> close() {
    _recordingTimer?.cancel();
    state.cameraController?.dispose();
    state.recorderController?.dispose();
    return super.close();
  }

  Future<void> _onInitialize(
      CameraInitializeEvent event, Emitter<CameraState> emit) async {
    // Prevent concurrent initializations
    if (_isInitializing) {
      debugPrint("🚀 CameraBloc: Init skipped - Already initializing.");
      return;
    }

    if (!event.force &&
        state.status == CameraStatus.ready &&
        state.cameraController != null &&
        state.cameraController!.value.isInitialized) {
      debugPrint("🚀 CameraBloc: Init skipped - Already ready.");
      return;
    }

    debugPrint("🚀 CameraBloc: Starting initialization...");
    _isInitializing = true;
    emit(state.copyWith(status: CameraStatus.loading));

    try {
      // Ensure previous controller is fully disposed before starting new one
      if (state.cameraController != null) {
        try {
          debugPrint("🚀 CameraBloc: Disposing previous controller...");
          await state.cameraController!
              .dispose()
              .timeout(const Duration(seconds: 2));
        } catch (e) {
          debugPrint("Error disposing previous controller during init: $e");
        }
      }

      // 1. Check permissions first
      debugPrint("🚀 CameraBloc: Checking permissions...");

      // Rapid check first - avoid the queue if already granted
      bool cameraGranted = await Permission.camera.isGranted;
      bool micGranted = await Permission.microphone.isGranted;

      if (!cameraGranted || !micGranted) {
        // Parallel permission request
        final permissions = await [
          Permission.camera,
          Permission.microphone,
        ].request().timeout(const Duration(seconds: 5), onTimeout: () => {});

        cameraGranted = permissions[Permission.camera]?.isGranted ??
            await Permission.camera.isGranted;
        micGranted = permissions[Permission.microphone]?.isGranted ??
            await Permission.microphone.isGranted;
      }

      debugPrint(
          "🚀 CameraBloc: Perms - Camera: $cameraGranted, Mic: $micGranted");

      if (!cameraGranted) {
        // Only enter the queue if we really need to (trigger settings/dialog)
        final retryStatus = await _locationService
            .requestPermission(Permission.camera)
            .timeout(const Duration(seconds: 5), onTimeout: () => false);

        if (!retryStatus) {
          debugPrint("🚀 CameraBloc: Camera permission denied!");
          emit(state.copyWith(
              status: CameraStatus.failure,
              errorMessage: "Camera permission denied"));
          return;
        }
      }

      // 2. Fetch available cameras
      if (cameras.isEmpty) {
        try {
          debugPrint("🚀 CameraBloc: Fetching available cameras...");
          cameras =
              await availableCameras().timeout(const Duration(seconds: 5));
          debugPrint("🚀 CameraBloc: Cameras fetched: ${cameras.length}");
        } catch (e) {
          debugPrint("🚀 CameraBloc: Error fetching cameras: $e");
        }
      }

      if (cameras.isEmpty) {
        emit(state.copyWith(
            status: CameraStatus.failure,
            errorMessage: "No cameras available"));
        return;
      }

      final cameraDescription =
          state.isFrontCamera && cameras.length > 1 ? cameras[1] : cameras[0];

      debugPrint(
          "🚀 CameraBloc: Creating controller for ${cameraDescription.name}...");

      final controller = _cameraControllerBuilder.create(
        cameraDescription,
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg,
        enableAudio: false,
      );

      debugPrint("🚀 CameraBloc: Initializing controller...");

      try {
        await controller.initialize().timeout(const Duration(seconds: 8),
            onTimeout: () {
          throw TimeoutException("Camera controller initialization timed out");
        });

        debugPrint("🚀 CameraBloc: Controller initialized.");

        // Wait for Flutter surface to be ready
        await Future.delayed(const Duration(milliseconds: 200));

        if (controller.value.isInitialized) {
          await controller.resumePreview().timeout(const Duration(seconds: 2),
              onTimeout: () => debugPrint("Resume preview timeout"));
          debugPrint("🚀 CameraBloc: Preview resumed.");
        }

        RecorderController? recorderController = state.recorderController;
        recorderController ??= RecorderController()
          ..androidEncoder = AndroidEncoder.aac
          ..androidOutputFormat = AndroidOutputFormat.mpeg4
          ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
          ..sampleRate = 44100
          ..bitRate = 48000;

        emit(state.copyWith(
          status: CameraStatus.ready,
          cameraController: controller,
          recorderController: recorderController,
        ));
        debugPrint("🚀 CameraBloc: Emitted READY state.");
      } catch (e) {
        debugPrint("❌ CameraBloc: Initialization FAILED: $e");
        emit(state.copyWith(
            status: CameraStatus.failure,
            errorMessage: "Camera failed to initialize: $e",
            cameraController: null));
      }
    } catch (e) {
      debugPrint("❌ CameraBloc: Unexpected error during init: $e");
      emit(state.copyWith(
          status: CameraStatus.failure, errorMessage: "Unexpected error: $e"));
    } finally {
      _isInitializing = false;
    }

    // Background tasks
    if (!isClosed) {
      add(const LoadGalleryMediaEvent());
      unawaited(_initLocation());
    }
  }

  /// Non-blocking location initialization
  Future<void> _initLocation() async {
    try {
      if (navigatorKey.currentContext != null) {
        final loc = await _locationService.getCurrentLocation(
            navigatorKey.currentContext!,
            shouldShowSettingPopup: false);
        if (loc != null) {
          _latitude = loc.latitude ?? 0;
          _longitude = loc.longitude ?? 0;
          debugPrint(
              "🚀 CameraBloc: Location fetched successfully: $_latitude, $_longitude");
        }
      }
    } catch (e) {
      debugPrint("🚀 CameraBloc: Location error (silenced): $e");
    }
  }

  Future<void> _onLifecycleEvent(
      CameraLifecycleEvent event, Emitter<CameraState> emit) async {
    if (event.state == AppLifecycleState.inactive ||
        event.state == AppLifecycleState.paused ||
        event.state == AppLifecycleState.detached) {
      // Avoid redundant disposal cycles
      if (state.status == CameraStatus.disposing) return;

      final controller = state.cameraController;
      if (controller != null) {
        // Set state to disposing and clear controller immediately to prevent other events from using it
        emit(state.copyWith(
            status: CameraStatus.disposing, clearController: true));

        try {
          if (controller.value.isInitialized &&
              controller.value.isRecordingVideo) {
            await controller.stopVideoRecording();
          }
          _stopTimer();
        } catch (e) {
          debugPrint("Error stopping recording during lifecycle change: $e");
        }

        try {
          await controller.dispose();
        } catch (e) {
          debugPrint("Error disposing camera during lifecycle change: $e");
        }

        emit(state.copyWith(status: CameraStatus.initial));
      } else {
        emit(state.copyWith(status: CameraStatus.initial));
      }
    } else if (event.state == AppLifecycleState.resumed) {
      // If we were disposing, wait a bit or ensure we can re-init
      // Debounce slightly to ensure surface is ready
      await Future.delayed(const Duration(milliseconds: 200));
      add(CameraInitializeEvent());
    }
  }

  Future<void> _onSwitchCamera(
      CameraSwitchEvent event, Emitter<CameraState> emit) async {
    if (cameras.length < 2) return;
    final newIsFront = !state.isFrontCamera;
    emit(state.copyWith(
        isFrontCamera: newIsFront, status: CameraStatus.loading));

    final existingController = state.cameraController;
    if (existingController != null) {
      await existingController.dispose();
    }

    final cameraDescription = newIsFront ? cameras[1] : cameras[0];
    final controller = _cameraControllerBuilder.create(
      cameraDescription,
      ResolutionPreset.high, // Changed from max to high
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await controller.initialize();
      emit(state.copyWith(
          status: CameraStatus.ready, cameraController: controller));
    } catch (e) {
      emit(state.copyWith(
          status: CameraStatus.failure,
          errorMessage: "Failed to switch camera"));
    }
  }

  Future<void> _onToggleFlash(
      CameraFlashToggleEvent event, Emitter<CameraState> emit) async {
    final controller = state.cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    final newFlash = !state.isFlashOn;
    try {
      await controller.setFlashMode(newFlash ? FlashMode.torch : FlashMode.off);
      emit(state.copyWith(isFlashOn: newFlash));
    } catch (e) {
      debugPrint("Flash error: $e");
    }
  }

  void _onChangeMode(CameraModeChangeEvent event, Emitter<CameraState> emit) {
    if (state.selectedMode == event.mode) return;

    bool shouldInitCamera = false;
    bool isFront = state.isFrontCamera;

    if (event.mode == "Photo" || event.mode == "Video") {
      isFront = false;
      shouldInitCamera = true;
    }

    emit(state.copyWith(selectedMode: event.mode, isFrontCamera: isFront));
    if (shouldInitCamera) {
      add(CameraInitializeEvent());
    }
  }

  Future<void> _onCaptureImage(
      CameraCaptureImageEvent event, Emitter<CameraState> emit) async {
    final controller = state.cameraController;
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      return;
    }

    try {
      await controller.setFlashMode(FlashMode.off);
      XFile picture = await controller.takePicture();
      await controller.pausePreview();

      // GPS Exif
      final exif = await Exif.fromPath(picture.path);
      await exif.writeAttributes({
        "GPSLatitude": _latitude.toString(),
        "GPSLongitude": _longitude.toString()
      });
      await exif.close();

      // Gallery
      await ImageGallerySaverPlus.saveFile(picture.path);

      final data = CameraData(
        path: picture.path,
        mimeType: "image",
        videoImagePath: "",
        latitude: _latitude.toString(),
        longitude: _longitude.toString(),
        dateTime: DateFormat("HH:mm, dd MMM yyyy").format(DateTime.now()),
        location: sharedPreferences
                ?.getString(SharedPreferencesKeys.currentAddress) ??
            "",
        country: sharedPreferences
                ?.getString(SharedPreferencesKeys.currentCountry) ??
            "",
        city: sharedPreferences?.getString(SharedPreferencesKeys.currentCity) ??
            "",
        state:
            sharedPreferences?.getString(SharedPreferencesKeys.currentState) ??
                "",
      );

      List<CameraData> newList = List.from(state.capturedMedia)..add(data);
      emit(
          state.copyWith(capturedMedia: newList, status: CameraStatus.success));
    } catch (e) {
      emit(state.copyWith(
          status: CameraStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onStartVideoRecording(
      CameraStartRecordingEvent event, Emitter<CameraState> emit) async {
    final controller = state.cameraController;
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isRecordingVideo) {
      return;
    }

    try {
      emit(state.copyWith(isVideoLoading: true));
      await controller.startVideoRecording();
      _startTimer();
      emit(state.copyWith(
          isRecording: true,
          status: CameraStatus.recording,
          isVideoLoading: false));
    } catch (e) {
      emit(state.copyWith(
          errorMessage: "Failed to start recording: $e",
          isVideoLoading: false));
    }
  }

  Future<void> _onStopVideoRecording(
      CameraStopRecordingEvent event, Emitter<CameraState> emit) async {
    final controller = state.cameraController;
    if (controller == null ||
        !controller.value.isInitialized ||
        !controller.value.isRecordingVideo) {
      return;
    }

    try {
      emit(state.copyWith(isVideoLoading: true));

      // Enforce a minimum recording duration of 1.5 seconds to avoid empty files
      final duration = DateTime.now().difference(_startTime ?? DateTime.now());
      if (duration.inMilliseconds < 1500) {
        await Future.delayed(
            Duration(milliseconds: 1500 - duration.inMilliseconds));
      }

      // Check if controller was disposed while we were waiting
      if (state.cameraController == null ||
          state.status == CameraStatus.disposing) {
        emit(state.copyWith(
            isRecording: false,
            isVideoLoading: false,
            status: CameraStatus.failure,
            errorMessage: "Recording failed: Camera was closed."));
        return;
      }

      XFile? file;
      try {
        if (controller.value.isInitialized &&
            controller.value.isRecordingVideo) {
          file = await controller.stopVideoRecording();
        } else {
          debugPrint(
              "DEBUG: stopVideoRecording skipped - not recording or already stopped");
        }
      } catch (e) {
        debugPrint("DEBUG: Native error during stopVideoRecording: $e");
        // Check for common "Disposed" or "Abandoned" errors
        if (e.toString().contains("disposed") ||
            e.toString().contains("abandoned")) {
          emit(state.copyWith(
              isRecording: false,
              isVideoLoading: false,
              status: CameraStatus.initial));
          return;
        }
      }

      _stopTimer();

      if (file == null) {
        emit(state.copyWith(
            isRecording: false,
            isVideoLoading: false,
            status: CameraStatus.failure,
            errorMessage:
                "Recording failed: Could not stop recording correctly."));
        return;
      }

      File recordedFile = File(file.path);
      bool fileExists = false;
      int retryCount = 0;

      // Retry mechanism to ensure file is written and flushed
      while (retryCount < 5) {
        if (await recordedFile.exists() && await recordedFile.length() > 0) {
          fileExists = true;
          break;
        }
        await Future.delayed(const Duration(milliseconds: 300));
        retryCount++;
      }

      if (!fileExists) {
        debugPrint(
            "DEBUG: Video file is empty or missing after retries: ${file.path}");
        emit(state.copyWith(
            isRecording: false,
            isVideoLoading: false,
            status: CameraStatus.failure,
            errorMessage: "Recording failed: Video file is empty."));
        return;
      }

      String dir = (await getTemporaryDirectory()).path;
      String newPath = "$dir/${DateTime.now().millisecondsSinceEpoch}.mp4";
      File renamedFile = await recordedFile.rename(newPath);

      await ImageGallerySaverPlus.saveFile(renamedFile.path);

      await controller.pausePreview();

      String? thumbnail;
      try {
        thumbnail = await VideoThumbnail.thumbnailFile(
          video: renamedFile.path,
          thumbnailPath: (await getTemporaryDirectory()).path,
          imageFormat: vt.ImageFormat.PNG,
          maxWidth: 128,
          quality: 25,
        );
      } catch (e) {
        debugPrint("DEBUG: Video thumbnail generation failed: $e");
      }

      final data = CameraData(
        path: renamedFile.path,
        mimeType: "video",
        videoImagePath: thumbnail ?? "",
        latitude: _latitude.toString(),
        longitude: _longitude.toString(),
        dateTime: DateFormat("HH:mm, dd MMM yyyy").format(DateTime.now()),
        location: sharedPreferences
                ?.getString(SharedPreferencesKeys.currentAddress) ??
            "",
        country: sharedPreferences
                ?.getString(SharedPreferencesKeys.currentCountry) ??
            "",
        city: sharedPreferences?.getString(SharedPreferencesKeys.currentCity) ??
            "",
        state:
            sharedPreferences?.getString(SharedPreferencesKeys.currentState) ??
                "",
      );

      List<CameraData> newList = List.from(state.capturedMedia)..add(data);
      emit(state.copyWith(
          isRecording: false,
          isVideoLoading: false,
          capturedMedia: newList,
          status: CameraStatus.success,
          recordingTime: "00:00:00"));
    } catch (e) {
      debugPrint("DEBUG: _onStopVideoRecording exception: $e");
      emit(state.copyWith(
          status: CameraStatus.failure,
          isRecording: false, // Ensure recording state is reset
          isVideoLoading: false,
          errorMessage: e.toString()));
    }
  }

  Future<void> _onStartAudioRecording(
      AudioStartRecordingEvent event, Emitter<CameraState> emit) async {
    final recController = state.recorderController;
    if (recController == null) return;

    var status =
        await _locationService.requestPermission(Permission.microphone);
    if (status) {
      Directory appFolder = await getApplicationDocumentsDirectory();
      final filepath =
          '${appFolder.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await recController.record(path: filepath);
      _startTimer();
      emit(state.copyWith(
          isAudioRecording: true,
          isRecording: true,
          status: CameraStatus.recording));
    } else {
      emit(state.copyWith(status: CameraStatus.permissionDenied));
    }
  }

  Future<void> _onStopAudioRecording(
      AudioStopRecordingEvent event, Emitter<CameraState> emit) async {
    final recController = state.recorderController;
    if (recController == null) return;

    final path = await recController.stop();
    _stopTimer();

    if (path != null && path.isNotEmpty) {
      final data = CameraData(
        path: path,
        mimeType: "audio",
        videoImagePath: "",
        latitude: _latitude.toString(),
        longitude: _longitude.toString(),
        dateTime: DateFormat("HH:mm, dd MMM yyyy").format(DateTime.now()),
        location: sharedPreferences
                ?.getString(SharedPreferencesKeys.currentAddress) ??
            "",
        country: sharedPreferences
                ?.getString(SharedPreferencesKeys.currentCountry) ??
            "",
        city: sharedPreferences?.getString(SharedPreferencesKeys.currentCity) ??
            "",
        state:
            sharedPreferences?.getString(SharedPreferencesKeys.currentState) ??
                "",
      );

      List<CameraData> newList = List.from(state.capturedMedia)..add(data);
      emit(state.copyWith(
          isAudioRecording: false,
          isRecording: false,
          capturedMedia: newList,
          status: CameraStatus.success,
          recordingTime: "00:00:00"));
    } else {
      emit(state.copyWith(
          isAudioRecording: false,
          isRecording: false,
          recordingTime: "00:00:00"));
    }
  }

  Future<void> _onScanDoc(
      CameraScanDocEvent event, Emitter<CameraState> emit) async {
    try {
      List<String>? imageList = await CunningDocumentScanner.getPictures();
      if (imageList != null && imageList.isNotEmpty) {
        await state.cameraController?.pausePreview();
        List<CameraData> newMedia = [];
        for (var path in imageList) {
          newMedia.add(CameraData(
            path: path,
            mimeType: "image",
            videoImagePath: "",
            latitude: _latitude.toString(),
            longitude: _longitude.toString(),
            dateTime: DateFormat("HH:mm, dd MMM yyyy").format(DateTime.now()),
            location: sharedPreferences
                    ?.getString(SharedPreferencesKeys.currentAddress) ??
                "",
            country: sharedPreferences
                    ?.getString(SharedPreferencesKeys.currentCountry) ??
                "",
            city: sharedPreferences
                    ?.getString(SharedPreferencesKeys.currentCity) ??
                "",
            state: sharedPreferences
                    ?.getString(SharedPreferencesKeys.currentState) ??
                "",
          ));
        }
        List<CameraData> newList = List.from(state.capturedMedia)
          ..addAll(newMedia);
        emit(state.copyWith(
            capturedMedia: newList, status: CameraStatus.success));
      }
    } catch (e) {
      debugPrint("Scan error: $e");
    }
  }

  Future<void> _onPickDocument(
      PickDocumentEvent event, Emitter<CameraState> emit) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      await state.cameraController?.pausePreview();

      String mimeType = lookupMimeType(file.path) ?? "pdf";
      if (mimeType == "application/msword") {
        mimeType = "doc";
      } else {
        mimeType = "pdf";
      }

      final data = CameraData(
        path: file.path,
        mimeType: mimeType,
        fromGallary: false,
        videoImagePath: '',
        latitude: _latitude.toString(),
        longitude: _longitude.toString(),
        dateTime: DateFormat("HH:mm, dd MMM yyyy").format(DateTime.now()),
        location: sharedPreferences
                ?.getString(SharedPreferencesKeys.currentAddress) ??
            "",
        country: sharedPreferences
                ?.getString(SharedPreferencesKeys.currentCountry) ??
            "",
        city: sharedPreferences?.getString(SharedPreferencesKeys.currentCity) ??
            "",
        state:
            sharedPreferences?.getString(SharedPreferencesKeys.currentState) ??
                "",
      );

      List<CameraData> newList = List.from(state.capturedMedia)..add(data);
      emit(
          state.copyWith(capturedMedia: newList, status: CameraStatus.success));
    }
  }

  Future<void> _onLoadGalleryMedia(
      LoadGalleryMediaEvent event, Emitter<CameraState> emit) async {
    try {
      // Use the safe request lock even for gallery to avoid concurrent PlatformException
      // Note: We don't necessarily need to request a specific permission via LocationService
      // if we just want to wait for other requests to finish.
      // But PhotoManager has its own logic. Let's just use it safely.
      final bool status =
          await _locationService.requestPermission(Permission.photos);

      if (status) {
        // We still check PhotoManager for actual authorization state if needed,
        // but requestPermission already handled the UX and settings redirection.
        final PermissionState ps = await PhotoManager.requestPermissionExtend();
        if (ps.isAuth) {
          List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
            onlyAll: true,
            type: RequestType.image,
            filterOption: FilterOptionGroup(
              orders: [
                const OrderOption(type: OrderOptionType.updateDate, asc: false),
              ],
            ),
          );
          if (albums.isNotEmpty) {
            List<AssetEntity> media =
                await albums[0].getAssetListPaged(page: 0, size: 1);
            emit(state.copyWith(galleryMedia: media));
          }
        }
      }
    } catch (e) {
      debugPrint("Gallery load error: $e");
    }
  }

  Future<void> _onUpdateExposure(
      UpdateExposureEvent event, Emitter<CameraState> emit) async {
    await state.cameraController?.setExposureOffset(event.exposure);
  }

  Future<void> _onUpdateZoom(
      UpdateZoomEvent event, Emitter<CameraState> emit) async {
    await state.cameraController?.setZoomLevel(event.zoom);
  }

  void _startTimer() {
    _startTime = DateTime.now();
    // _stopDurationDifference = null;
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final startTime = _startTime;
      if (startTime == null) return;

      final diff = now.difference(startTime);
      int hours = diff.inHours;
      int minutes = diff.inMinutes % 60;
      int seconds = diff.inSeconds % 60;
      final timeStr =
          "${hours < 10 ? '0$hours' : hours}:${minutes < 10 ? '0$minutes' : minutes}:${seconds < 10 ? '0$seconds' : seconds}";

      if (!isClosed) {
        add(CameraTimerTickEvent(timeStr));
      }
    });
  }

  void _stopTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }
}
