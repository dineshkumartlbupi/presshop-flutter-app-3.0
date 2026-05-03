import 'package:flutter/material.dart';
import 'package:presshop/features/camera/data/models/camera_model.dart';

/// Base class for all camera events
sealed class CameraEvent {
  const CameraEvent();
}

/// Event to initialize the camera
class CameraInitializeEvent extends CameraEvent {

  const CameraInitializeEvent({this.force = false});
  final bool force;
}

/// Event to handle app lifecycle changes
class CameraLifecycleEvent extends CameraEvent {

  const CameraLifecycleEvent(this.state);
  final AppLifecycleState state;
}

/// Event to switch between front and back camera
class CameraSwitchEvent extends CameraEvent {
  const CameraSwitchEvent();
}

/// Event to toggle flash on/off
class CameraFlashToggleEvent extends CameraEvent {
  const CameraFlashToggleEvent();
}

/// Event to change camera mode (Photo, Video, Audio, Scan)
class CameraModeChangeEvent extends CameraEvent {

  const CameraModeChangeEvent(this.mode);
  final String mode;
}

/// Event to capture an image
class CameraCaptureImageEvent extends CameraEvent {
  const CameraCaptureImageEvent();
}

/// Event to start video recording
class CameraStartRecordingEvent extends CameraEvent {
  const CameraStartRecordingEvent();
}

/// Event to stop video recording
class CameraStopRecordingEvent extends CameraEvent {
  const CameraStopRecordingEvent();
}

/// Event to scan a document
class CameraScanDocEvent extends CameraEvent {
  const CameraScanDocEvent();
}

/// Event to start audio recording
class AudioStartRecordingEvent extends CameraEvent {
  const AudioStartRecordingEvent();
}

/// Event to stop audio recording
class AudioStopRecordingEvent extends CameraEvent {
  const AudioStopRecordingEvent();
}

/// Event to pick a document (PDF/DOC)
class PickDocumentEvent extends CameraEvent {
  const PickDocumentEvent();
}

/// Event to load gallery media
class LoadGalleryMediaEvent extends CameraEvent {
  const LoadGalleryMediaEvent();
}

/// Event to update captured media list
class UpdateCapturedMediaEvent extends CameraEvent {

  const UpdateCapturedMediaEvent(this.media);
  final List<CameraData> media;
}

/// Event to update exposure offset
class UpdateExposureEvent extends CameraEvent {

  const UpdateExposureEvent(this.exposure);
  final double exposure;
}

/// Event to update zoom level
class UpdateZoomEvent extends CameraEvent {

  const UpdateZoomEvent(this.zoom);
  final double zoom;
}

/// Event for timer tick during recording
class CameraTimerTickEvent extends CameraEvent {

  const CameraTimerTickEvent(this.time);
  final String time;
}

/// Event to reset the camera status to initial
class CameraResetStatusEvent extends CameraEvent {
  const CameraResetStatusEvent();
}
