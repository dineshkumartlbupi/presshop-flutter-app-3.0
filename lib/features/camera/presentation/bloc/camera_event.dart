import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:presshop/features/camera/data/models/camera_model.dart';

abstract class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object> get props => [];
}

class CameraInitializeEvent extends CameraEvent {}

class CameraSwitchEvent extends CameraEvent {}

class CameraFlashToggleEvent extends CameraEvent {}

class CameraModeChangeEvent extends CameraEvent {
  final String mode;
  const CameraModeChangeEvent(this.mode);

  @override
  List<Object> get props => [mode];
}

class CameraCaptureImageEvent extends CameraEvent {}

class CameraStartRecordingEvent extends CameraEvent {}

class CameraStopRecordingEvent extends CameraEvent {}

class CameraScanDocEvent extends CameraEvent {}

class AudioStartRecordingEvent extends CameraEvent {}

class AudioStopRecordingEvent extends CameraEvent {}

class LoadGalleryMediaEvent extends CameraEvent {}

class UpdateExposureEvent extends CameraEvent {
  final double exposure;
  const UpdateExposureEvent(this.exposure);
  
  @override
  List<Object> get props => [exposure];
}

class UpdateZoomEvent extends CameraEvent {
  final double zoom;
  const UpdateZoomEvent(this.zoom);

  @override
  List<Object> get props => [zoom];
}

class CameraLifecycleEvent extends CameraEvent {
  final AppLifecycleState state;
  const CameraLifecycleEvent(this.state);

  @override
  List<Object> get props => [state];
}

class CameraTimerTickEvent extends CameraEvent {
  final String time;
  const CameraTimerTickEvent(this.time);

  @override
  List<Object> get props => [time];
}

class UpdateCapturedMediaEvent extends CameraEvent {
  final List<CameraData> media;
  const UpdateCapturedMediaEvent(this.media);
  
  @override
  List<Object> get props => [media];
}

class PickDocumentEvent extends CameraEvent {}
