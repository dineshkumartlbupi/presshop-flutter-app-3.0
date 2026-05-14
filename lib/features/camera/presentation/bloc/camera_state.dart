import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:presshop/core/services/permission_service.dart';
import 'package:presshop/features/camera/data/models/camera_model.dart';

enum CameraStatus {
  initial,
  loading,
  requestingPermission,
  ready,
  failure,
  permissionDenied,
  recording,
  recordingPaused,
  success,
  disposing,
  previewPaused,
}

class CameraState extends Equatable {
  const CameraState({
    this.status = CameraStatus.initial,
    this.cameraController,
    this.recorderController,
    this.selectedMode = "Photo",
    this.isRecording = false,
    this.isVideoLoading = false, // New field
    this.isAudioRecording = false,
    this.isFrontCamera = false,
    this.isFlashOn = false,
    this.recordingTime = "",
    this.galleryMedia = const [],
    this.capturedMedia = const [],
    this.errorMessage = "",
    this.initCount = 0,
    this.minExposure = 0,
    this.maxExposure = 0,
    this.minZoom = 1.0,
    this.maxZoom = 1.0,
    this.permissionDetail,
  });

  final CameraStatus status;
  final CameraController? cameraController;
  final RecorderController? recorderController;
  final String selectedMode;
  final bool isRecording;
  final bool isVideoLoading; // New field
  final bool isAudioRecording;
  final bool isFrontCamera;
  final bool isFlashOn;
  final String recordingTime;
  final List<AssetEntity> galleryMedia;
  final List<CameraData> capturedMedia;
  final String errorMessage;
  final int initCount;
  final double minExposure;
  final double maxExposure;
  final double minZoom;
  final double maxZoom;
  final PermissionStatusDetail? permissionDetail;

  CameraState copyWith({
    CameraStatus? status,
    CameraController? cameraController,
    bool clearController = false,
    RecorderController? recorderController,
    String? selectedMode,
    bool? isRecording,
    bool? isVideoLoading, // New parameter
    bool? isAudioRecording,
    bool? isFrontCamera,
    bool? isFlashOn,
    String? recordingTime,
    List<AssetEntity>? galleryMedia,
    List<CameraData>? capturedMedia,
    String? errorMessage,
    int? initCount,
    double? minExposure,
    double? maxExposure,
    double? minZoom,
    double? maxZoom,
    PermissionStatusDetail? permissionDetail,
  }) {
    return CameraState(
      status: status ?? this.status,
      cameraController:
          clearController ? null : (cameraController ?? this.cameraController),
      recorderController: recorderController ?? this.recorderController,
      selectedMode: selectedMode ?? this.selectedMode,
      isRecording: isRecording ?? this.isRecording,
      isVideoLoading: isVideoLoading ?? this.isVideoLoading, // New assignment
      isAudioRecording: isAudioRecording ?? this.isAudioRecording,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      recordingTime: recordingTime ?? this.recordingTime,
      galleryMedia: galleryMedia ?? this.galleryMedia,
      capturedMedia: capturedMedia ?? this.capturedMedia,
      errorMessage: errorMessage ?? this.errorMessage,
      initCount: initCount ?? this.initCount,
      minExposure: minExposure ?? this.minExposure,
      maxExposure: maxExposure ?? this.maxExposure,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      permissionDetail: permissionDetail ?? this.permissionDetail,
    );
  }

  @override
  List<Object?> get props => [
        status,
        cameraController,
        recorderController,
        selectedMode,
        isRecording,
        isVideoLoading, // New prop
        isAudioRecording,
        isFrontCamera,
        isFlashOn,
        recordingTime,
        galleryMedia,
        capturedMedia,
        errorMessage,
        initCount,
        minExposure,
        maxExposure,
        minZoom,
        maxZoom,
        permissionDetail,
      ];
}
