import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:presshop/core/core_export.dart';

Future<CroppedFile?> cropImage(String path) async {
  return await ImageCropper().cropImage(
      sourcePath: path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Presshop Editor',
          toolbarColor: colorThemePink,
          toolbarWidgetColor: Colors.black,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Presshop Editor',
        )
      ]);
}
