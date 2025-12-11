import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:presshop/features/camera/data/models/camera_model.dart';

enum CameraStatus { initial, loading, ready, failure, permissionDenied, recording, recordingPaused, success }

class CameraState extends Equatable {
  final CameraStatus status;
  final CameraController? cameraController;
  final RecorderController? recorderController;
  final String selectedMode;
  final bool isRecording;
  final bool isAudioRecording;
  final bool isFrontCamera;
  final bool isFlashOn;
  final String recordingTime;
  final List<AssetEntity> galleryMedia;
  final List<CameraData> capturedMedia;
  final String errorMessage;

  const CameraState({
    this.status = CameraStatus.initial,
    this.cameraController,
    this.recorderController,
    this.selectedMode = "Photo",
    this.isRecording = false,
    this.isAudioRecording = false,
    this.isFrontCamera = false,
    this.isFlashOn = false,
    this.recordingTime = "",
    this.galleryMedia = const [],
    this.capturedMedia = const [],
    this.errorMessage = "",
  });

  CameraState copyWith({
    CameraStatus? status,
    CameraController? cameraController,
    RecorderController? recorderController,
    String? selectedMode,
    bool? isRecording,
    bool? isAudioRecording,
    bool? isFrontCamera,
    bool? isFlashOn,
    String? recordingTime,
    List<AssetEntity>? galleryMedia,
    List<CameraData>? capturedMedia,
    String? errorMessage,
  }) {
    return CameraState(
      status: status ?? this.status,
      cameraController: cameraController ?? this.cameraController,
      recorderController: recorderController ?? this.recorderController,
      selectedMode: selectedMode ?? this.selectedMode,
      isRecording: isRecording ?? this.isRecording,
      isAudioRecording: isAudioRecording ?? this.isAudioRecording,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      recordingTime: recordingTime ?? this.recordingTime,
      galleryMedia: galleryMedia ?? this.galleryMedia,
      capturedMedia: capturedMedia ?? this.capturedMedia,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        cameraController,
        recorderController,
        selectedMode,
        isRecording,
        isAudioRecording,
        isFrontCamera,
        isFlashOn,
        recordingTime,
        galleryMedia,
        capturedMedia,
        errorMessage,
      ];
}
