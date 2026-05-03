import 'package:camera/camera.dart';

class CameraControllerBuilder {
  const CameraControllerBuilder();

  CameraController create(
    CameraDescription description,
    ResolutionPreset resolutionPreset, {
    bool enableAudio = true,
    ImageFormatGroup? imageFormatGroup,
  }) {
    return CameraController(
      description,
      resolutionPreset,
      enableAudio: enableAudio,
      imageFormatGroup: imageFormatGroup,
    );
  }
}
