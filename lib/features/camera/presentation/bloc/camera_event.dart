import 'package:flutter/material.dart';
import 'package:presshop/features/camera/data/models/camera_model.dart';

/// Base class for all camera events
sealed class CameraEvent {
  const CameraEvent();
}

/// Event to initialize the camera
class CameraInitializeEvent extends CameraEvent {
  final bool force;

  const CameraInitializeEvent({this.force = false});
}

/// Event to handle app lifecycle changes
class CameraLifecycleEvent extends CameraEvent {
  final AppLifecycleState state;

  const CameraLifecycleEvent(this.state);
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
  final String mode;

  const CameraModeChangeEvent(this.mode);
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
  final List<CameraData> media;

  const UpdateCapturedMediaEvent(this.media);
}

/// Event to update exposure offset
class UpdateExposureEvent extends CameraEvent {
  final double exposure;

  const UpdateExposureEvent(this.exposure);
}

/// Event to update zoom level
class UpdateZoomEvent extends CameraEvent {
  final double zoom;

  const UpdateZoomEvent(this.zoom);
}

/// Event for timer tick during recording
class CameraTimerTickEvent extends CameraEvent {
  final String time;

  const CameraTimerTickEvent(this.time);
}
