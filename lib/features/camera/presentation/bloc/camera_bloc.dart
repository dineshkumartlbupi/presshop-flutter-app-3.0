import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:native_exif/native_exif.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:presshop/core/services/location_service.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
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

import 'camera_event.dart';
import 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  Timer? _recordingTimer;
  DateTime? _startTime;
  Duration? _stopDurationDifference;
  double _currentZoom = 1.0;
  
  // Location
  final LocationService _locationService = LocationService();
  double _latitude = 0;
  double _longitude = 0;

  CameraBloc() : super(const CameraState()) {
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
    on<UpdateCapturedMediaEvent>((event, emit) => emit(state.copyWith(capturedMedia: event.media)));
    on<CameraTimerTickEvent>((event, emit) => emit(state.copyWith(recordingTime: event.time)));
    on<PickDocumentEvent>(_onPickDocument);
  }

  @override
  Future<void> close() {
    _recordingTimer?.cancel();
    state.cameraController?.dispose();
    state.recorderController?.dispose();
    return super.close();
  }


  Future<void> _onInitialize(
      CameraInitializeEvent event, Emitter<CameraState> emit) async {
    emit(state.copyWith(status: CameraStatus.loading));
    
    // Init Location
    try {
        if (navigatorKey.currentContext != null) {
            final loc = await _locationService.getCurrentLocation(navigatorKey.currentContext!, shouldShowSettingPopup: false);
            if (loc != null) {
              _latitude = loc.latitude ?? 0;
              _longitude = loc.longitude ?? 0;
            }
        }
    } catch(e) {
      debugPrint("Location error in Bloc: $e");
    }

    RecorderController? recorderController = state.recorderController;
    if (recorderController == null) {
        recorderController = RecorderController()
        ..androidEncoder = AndroidEncoder.aac
        ..androidOutputFormat = AndroidOutputFormat.mpeg4
        ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
        ..sampleRate = 44100
        ..bitRate = 48000;
    }

    // Init Camera
    if (cameras.isEmpty) {
        try {
          cameras = await availableCameras();
        } catch (_) {}
    }

    if (cameras.isNotEmpty) {
      final cameraDescription = state.isFrontCamera && cameras.length > 1 ? cameras[1] : cameras[0];
      final controller = CameraController(
        cameraDescription,
        ResolutionPreset.max,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      try {
        await controller.initialize();
        emit(state.copyWith(
          status: CameraStatus.ready,
          cameraController: controller,
          recorderController: recorderController,
        ));
      } catch (e) {
        emit(state.copyWith(
          status: CameraStatus.failure,
          errorMessage: e.toString(),
          recorderController: recorderController,
        ));
      }
    } else {
      emit(state.copyWith(status: CameraStatus.failure, errorMessage: "No cameras found", recorderController: recorderController));
    }
    
    // Load Gallery
    add(LoadGalleryMediaEvent());
  }

  Future<void> _onLifecycleEvent(CameraLifecycleEvent event, Emitter<CameraState> emit) async {
      if (event.state == AppLifecycleState.inactive) {
         state.cameraController?.dispose();
      } else if (event.state == AppLifecycleState.resumed) {
          add(CameraInitializeEvent());
      }
  }

  Future<void> _onSwitchCamera(CameraSwitchEvent event, Emitter<CameraState> emit) async {
      if (cameras.length < 2) return;
      final newIsFront = !state.isFrontCamera;
      emit(state.copyWith(isFrontCamera: newIsFront, status: CameraStatus.loading));
      
      await state.cameraController?.dispose();
      
      final cameraDescription = newIsFront ? cameras[1] : cameras[0];
      final controller = CameraController(
        cameraDescription,
        ResolutionPreset.max,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      
      try {
        await controller.initialize();
        emit(state.copyWith(status: CameraStatus.ready, cameraController: controller));
      } catch (e) {
         emit(state.copyWith(status: CameraStatus.failure, errorMessage: "Failed to switch camera"));
      }
  }

  Future<void> _onToggleFlash(CameraFlashToggleEvent event, Emitter<CameraState> emit) async {
     if (state.cameraController == null || !state.cameraController!.value.isInitialized) return;
     final newFlash = !state.isFlashOn;
     try {
       await state.cameraController!.setFlashMode(newFlash ? FlashMode.torch : FlashMode.off);
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

  Future<void> _onCaptureImage(CameraCaptureImageEvent event, Emitter<CameraState> emit) async {
      final controller = state.cameraController;
      if (controller == null || !controller.value.isInitialized || controller.value.isTakingPicture) return;

      try {
          await controller.setFlashMode(FlashMode.off); 
          XFile picture = await controller.takePicture();
          await controller.pausePreview();
          
           // GPS Exif
           final exif = await Exif.fromPath(picture.path);
           await exif.writeAttributes({"GPSLatitude": _latitude.toString(), "GPSLongitude": _longitude.toString()});
           await exif.close();
           
           // Gallery
           final bytes = await File(picture.path).readAsBytes();
           await ImageGallerySaverPlus.saveImage(
             Uint8List.fromList(bytes),
             name: "captured_image_${DateTime.now().millisecondsSinceEpoch}",
           );
           
           final data = CameraData(
            path: picture.path,
            mimeType: "image",
            videoImagePath: "",
            latitude: _latitude.toString(),
            longitude: _longitude.toString(),
            dateTime: DateFormat("HH:mm, dd MMM yyyy").format(DateTime.now()),
            location: sharedPreferences?.getString(currentAddress) ?? "",
            country: sharedPreferences?.getString(currentCountry) ?? "",
            city: sharedPreferences?.getString(currentCity) ?? "",
            state: sharedPreferences?.getString(currentState) ?? "",
           );
           
           List<CameraData> newList = List.from(state.capturedMedia)..add(data);
           emit(state.copyWith(capturedMedia: newList, status: CameraStatus.success));
      } catch (e) {
          emit(state.copyWith(status: CameraStatus.failure, errorMessage: e.toString()));
      }
  }

  Future<void> _onStartVideoRecording(CameraStartRecordingEvent event, Emitter<CameraState> emit) async {
      final controller = state.cameraController;
      if (controller == null || !controller.value.isInitialized || controller.value.isRecordingVideo) return;
      
      try {
          await controller.startVideoRecording();
          _startTimer();
          emit(state.copyWith(isRecording: true, status: CameraStatus.recording));
      } catch (e) {
          emit(state.copyWith(errorMessage: "Failed to start recording: $e"));
      }
  }

  Future<void> _onStopVideoRecording(CameraStopRecordingEvent event, Emitter<CameraState> emit) async {
      final controller = state.cameraController;
      if (controller == null || !controller.value.isRecordingVideo) return;
      
      try {
          XFile file = await controller.stopVideoRecording();
          _stopTimer();
          
          String dir = (await getTemporaryDirectory()).path;
          String newPath = "$dir/${DateTime.now().millisecondsSinceEpoch}.mp4";
          File recordedFile = File(file.path);
          File renamedFile = await recordedFile.rename(newPath);
          
          final bytes = await File(renamedFile.path).readAsBytes();
          await ImageGallerySaverPlus.saveImage(
             Uint8List.fromList(bytes),
             name: "captured_video_${DateTime.now().millisecondsSinceEpoch}",
          );
          
          await controller.pausePreview();
          
          final String? thumbnail = await VideoThumbnail.thumbnailFile(
            video: renamedFile.path,
            thumbnailPath: (await getTemporaryDirectory()).path,
            imageFormat: vt.ImageFormat.PNG,
            maxWidth: 128,
            quality: 25,
          );
          
           final data = CameraData(
            path: renamedFile.path,
            mimeType: "video",
            videoImagePath: thumbnail ?? "",
            latitude: _latitude.toString(),
            longitude: _longitude.toString(),
            dateTime: DateFormat("HH:mm, dd MMM yyyy").format(DateTime.now()),
            location: sharedPreferences?.getString(currentAddress) ?? "",
            country: sharedPreferences?.getString(currentCountry) ?? "",
            city: sharedPreferences?.getString(currentCity) ?? "",
            state: sharedPreferences?.getString(currentState) ?? "",
           );
           
           List<CameraData> newList = List.from(state.capturedMedia)..add(data);
           emit(state.copyWith(
               isRecording: false, 
               capturedMedia: newList, 
               status: CameraStatus.success,
               recordingTime: "00:00:00"
           ));
           
      } catch (e) {
          emit(state.copyWith(status: CameraStatus.failure, errorMessage: e.toString()));
      }
  }
  
  Future<void> _onStartAudioRecording(AudioStartRecordingEvent event, Emitter<CameraState> emit) async {
       final recController = state.recorderController;
       if (recController == null) return;
       
       var status = await Permission.microphone.request();
       if (status.isGranted) {
           Directory appFolder = await getApplicationDocumentsDirectory();
           final filepath = '${appFolder.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
           await recController.record(path: filepath);
           _startTimer();
           emit(state.copyWith(isAudioRecording: true, isRecording: true, status: CameraStatus.recording));
       } else {
           emit(state.copyWith(status: CameraStatus.permissionDenied));
       }
  }
  
  Future<void> _onStopAudioRecording(AudioStopRecordingEvent event, Emitter<CameraState> emit) async {
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
            location: sharedPreferences?.getString(currentAddress) ?? "",
            country: sharedPreferences?.getString(currentCountry) ?? "",
            city: sharedPreferences?.getString(currentCity) ?? "",
            state: sharedPreferences?.getString(currentState) ?? "",
           );
           
           List<CameraData> newList = List.from(state.capturedMedia)..add(data);
           emit(state.copyWith(
               isAudioRecording: false, 
               isRecording: false,
               capturedMedia: newList, 
               status: CameraStatus.success,
               recordingTime: "00:00:00"
           ));
      } else {
           emit(state.copyWith(
               isAudioRecording: false, 
               isRecording: false,
               recordingTime: "00:00:00"
           ));
      }
  }

  Future<void> _onScanDoc(CameraScanDocEvent event, Emitter<CameraState> emit) async {
      try {
          List<String>? imageList = await CunningDocumentScanner.getPictures();
          if (imageList != null && imageList.isNotEmpty) {
               state.cameraController?.pausePreview();
               List<CameraData> newMedia = [];
               for(var path in imageList) {
                    newMedia.add(CameraData(
                        path: path,
                        mimeType: "image", 
                        videoImagePath: "",
                        latitude: _latitude.toString(),
                        longitude: _longitude.toString(),
                        dateTime: DateFormat("HH:mm, dd MMM yyyy").format(DateTime.now()),
                        location: sharedPreferences?.getString(currentAddress) ?? "",
                        country: sharedPreferences?.getString(currentCountry) ?? "",
                        city: sharedPreferences?.getString(currentCity) ?? "",
                        state: sharedPreferences?.getString(currentState) ?? "",
                   ));
               }
               List<CameraData> newList = List.from(state.capturedMedia)..addAll(newMedia);
               emit(state.copyWith(capturedMedia: newList, status: CameraStatus.success));
          }
      } catch (e) {
          debugPrint("Scan error: $e");
      }
  }
  
  Future<void> _onPickDocument(PickDocumentEvent event, Emitter<CameraState> emit) async {
       FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc'],
        );

        if (result != null) {
          File file = File(result.files.single.path!);
          state.cameraController?.pausePreview();
          
          String mimeType = lookupMimeType(file.path) ?? "pdf";
          if (mimeType == "application/msword") mimeType = "doc";
          else mimeType = "pdf";

          final data = CameraData(
            path: file.path,
            mimeType: mimeType,
            fromGallary: false,
            videoImagePath: '',
            latitude: _latitude.toString(),
            longitude: _longitude.toString(),
            dateTime: DateFormat("HH:mm, dd MMM yyyy").format(DateTime.now()),
            location: sharedPreferences?.getString(currentAddress) ?? "",
            country: sharedPreferences?.getString(currentCountry) ?? "",
            city: sharedPreferences?.getString(currentCity) ?? "",
            state: sharedPreferences?.getString(currentState) ?? "",
          );
          
          List<CameraData> newList = List.from(state.capturedMedia)..add(data);
          emit(state.copyWith(capturedMedia: newList, status: CameraStatus.success));
        }
  }

  Future<void> _onLoadGalleryMedia(LoadGalleryMediaEvent event, Emitter<CameraState> emit) async {
      try {
          final PermissionState ps = await PhotoManager.requestPermissionExtend();
          if (ps.isAuth) {
              List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(onlyAll: true);
              if (albums.isNotEmpty) {
                   List<AssetEntity> media = await albums[0].getAssetListPaged(page: 0, size: 1);
                   emit(state.copyWith(galleryMedia: media));
              }
          }
      } catch (e) {
          debugPrint("Gallery load error: $e");
      }
  }

  Future<void> _onUpdateExposure(UpdateExposureEvent event, Emitter<CameraState> emit) async {
      await state.cameraController?.setExposureOffset(event.exposure);
  }
  
  Future<void> _onUpdateZoom(UpdateZoomEvent event, Emitter<CameraState> emit) async {
      await state.cameraController?.setZoomLevel(event.zoom);
  }

  void _startTimer() {
      _startTime = DateTime.now();
      _stopDurationDifference = null;
      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          final now = DateTime.now();
          final diff = now.difference(_startTime!);
          int hours = diff.inHours;
          int minutes = diff.inMinutes % 60;
          int seconds = diff.inSeconds % 60;
          final timeStr = "${hours < 10 ? '0$hours' : hours}:${minutes < 10 ? '0$minutes' : minutes}:${seconds < 10 ? '0$seconds' : seconds}";
          
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
