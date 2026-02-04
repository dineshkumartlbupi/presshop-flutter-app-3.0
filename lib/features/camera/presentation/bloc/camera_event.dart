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
  const CameraModeChangeEvent(this.mode);
  final String mode;

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
  const UpdateExposureEvent(this.exposure);
  final double exposure;

  @override
  List<Object> get props => [exposure];
}

class UpdateZoomEvent extends CameraEvent {
  const UpdateZoomEvent(this.zoom);
  final double zoom;

  @override
  List<Object> get props => [zoom];
}

class CameraLifecycleEvent extends CameraEvent {
  const CameraLifecycleEvent(this.state);
  final AppLifecycleState state;

  @override
  List<Object> get props => [state];
}

class CameraTimerTickEvent extends CameraEvent {
  const CameraTimerTickEvent(this.time);
  final String time;

  @override
  List<Object> get props => [time];
}

class UpdateCapturedMediaEvent extends CameraEvent {
  const UpdateCapturedMediaEvent(this.media);
  final List<CameraData> media;

  @override
  List<Object> get props => [media];
}

class PickDocumentEvent extends CameraEvent {}
