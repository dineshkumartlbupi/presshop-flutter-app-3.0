import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as img_pkg;
import 'package:presshop/features/map/data/models/marker_model.dart';
import 'package:http/http.dart' as http;

class MarkerService {
  final Map<String, String> markerIcons = {
    "accident": "assets/markers/marker-icons/carcrash.png", // Corrected path
    "fire": "assets/markers/marker-icons/fire.png",
    "medical": "assets/markers/marker-icons/medical.png",
    "gun": "assets/markers/marker-icons/gun.png",
    "protest": "assets/markers/marker-icons/protest.png",
    "knife": "assets/markers/marker-icons/knife.png",
    "fight": "assets/markers/marker-icons/fight.png",
    "content": "assets/markers/bg-removed-content.png",
    "hopper": "assets/markers/avatar.png",
  };

  List<Incident> getIncidents() => [];

  Future<BitmapDescriptor> bitmapResize(
    String assetPath, {
    int width = 50,
  }) async {
    final byteData = await rootBundle.load(assetPath);
    final uint8list = byteData.buffer.asUint8List();

    final img = img_pkg.decodeImage(uint8list);
    if (img == null) return BitmapDescriptor.defaultMarker;
    final resized = img_pkg.copyResize(img, width: width);
    final resizedBytes = img_pkg.encodePng(resized);
    return BitmapDescriptor.bytes(resizedBytes);
  }

  Future<BitmapDescriptor> bitmapFromIncidentAsset(
    String assetPath,
    int width,
  ) async {
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();

    final img = img_pkg.decodeImage(bytes)!;
    final resized = img_pkg.copyResize(img, width: width);

    return BitmapDescriptor.fromBytes(
      Uint8List.fromList(img_pkg.encodePng(resized)),
    );
  }

  Future<BitmapDescriptor> bitmapFromUrl(
    String url, {
    int width = 70,
    String defaultAsset = "assets/markers/bg-removed-content.png",
  }) async {
    try {
      if (url.isEmpty) {
        return bitmapResize(defaultAsset, width: width);
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final img = img_pkg.decodeImage(bytes);
        if (img == null) return bitmapResize(defaultAsset, width: width);

        final resized = img_pkg.copyResize(img, width: width);
        final rounded = img_pkg.copyCropCircle(resized);

        return BitmapDescriptor.fromBytes(
          Uint8List.fromList(img_pkg.encodePng(rounded)),
        );
      }
      return bitmapResize(defaultAsset, width: width);
    } catch (e) {
      print("Error loading marker from URL: $e");
      return bitmapResize(defaultAsset, width: width);
    }
  }

  Future<BitmapDescriptor> createAvatarMarker(
    String url, {
    Size size = const Size(60, 60),
  }) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to load avatar: ${response.statusCode}');
      }

      final bytes = response.bodyBytes;
      final codec = await ui.instantiateImageCodec(bytes,
          targetWidth: size.width.toInt());
      final frame = await codec.getNextFrame();
      final ui.Image img = frame.image;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final double radius = size.width / 2;

      // 1. Draw Image (Clipped to Circle)
      final Path clipPath = Path()
        ..addOval(
            Rect.fromCircle(center: Offset(radius, radius), radius: radius));
      canvas.clipPath(clipPath);

      final srcSize = Size(img.width.toDouble(), img.height.toDouble());
      final dstSize = size;
      final srcRect = _centerCrop(srcSize, dstSize);
      final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);

      canvas.drawImageRect(img, srcRect, dstRect, Paint());

      // 2. Draw White Border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.1;
      canvas.drawCircle(Offset(radius, radius), radius, borderPaint);

      final picture = recorder.endRecording();
      final finalImage =
          await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData =
          await finalImage.toByteData(format: ui.ImageByteFormat.png);

      return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
    } catch (e) {
      print("Error creating avatar marker: $e. Using default.");
      return createCircularAssetMarker("assets/markers/avatar.png");
    }
  }

  Future<BitmapDescriptor> createCircularAssetMarker(
    String assetPath, {
    Size size = const Size(60, 60),
  }) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();

      final codec = await ui.instantiateImageCodec(bytes,
          targetWidth: size.width.toInt());
      final frame = await codec.getNextFrame();
      final ui.Image img = frame.image;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final double radius = size.width / 2;

      // 1. Draw Image (Clipped to Circle)
      final Path clipPath = Path()
        ..addOval(
            Rect.fromCircle(center: Offset(radius, radius), radius: radius));
      canvas.clipPath(clipPath);

      final srcSize = Size(img.width.toDouble(), img.height.toDouble());
      final dstSize = size;
      final srcRect = _centerCrop(srcSize, dstSize);
      final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);

      canvas.drawImageRect(img, srcRect, dstRect, Paint());

      // 2. Draw White Border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.1;
      canvas.drawCircle(Offset(radius, radius), radius, borderPaint);

      final picture = recorder.endRecording();
      final finalImage =
          await picture.toImage(size.width.toInt(), size.height.toInt());
      final outputByteData =
          await finalImage.toByteData(format: ui.ImageByteFormat.png);

      return BitmapDescriptor.fromBytes(outputByteData!.buffer.asUint8List());
    } catch (e) {
      print("Error creating circular asset marker: $e");
      return BitmapDescriptor.defaultMarker;
    }
  }

  Future<BitmapDescriptor> createContentMarker(
    String url, {
    int size = 70,
    String defaultAsset = "assets/markers/bg-removed-content.png",
  }) async {
    try {
      Uint8List bytes;
      if (url.isNotEmpty) {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          bytes = response.bodyBytes;
        } else {
          bytes = (await rootBundle.load(defaultAsset)).buffer.asUint8List();
        }
      } else {
        bytes = (await rootBundle.load(defaultAsset)).buffer.asUint8List();
      }

      final codec = await ui.instantiateImageCodec(bytes, targetWidth: size);
      final frame = await codec.getNextFrame();
      final ui.Image img = frame.image;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // White Rounded Rectangle background
      final bgPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      final rect = Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble());
      final rrect = RRect.fromRectAndRadius(
          rect, Radius.circular(size * 0.23)); // ~28 for size 120

      canvas.drawRRect(rrect, bgPaint);

      // Clip image to rounded rectangle
      final clipPath = Path()..addRRect(rrect);
      canvas.clipPath(clipPath);

      final srcSize = Size(img.width.toDouble(), img.height.toDouble());
      final dstSize = Size(size.toDouble(), size.toDouble());
      final srcRect = _centerCrop(srcSize, dstSize);

      canvas.drawImageRect(img, srcRect, rect, Paint());

      final picture = recorder.endRecording();
      final finalImage = await picture.toImage(size, size);
      final byteData =
          await finalImage.toByteData(format: ui.ImageByteFormat.png);

      return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
    } catch (e) {
      print("Error creating content marker: $e");
      return bitmapResize(defaultAsset, width: size);
    }
  }

  Rect _centerCrop(Size src, Size dst) {
    double srcRatio = src.width / src.height;
    double dstRatio = dst.width / dst.height;

    double width, height, left, top;

    if (srcRatio > dstRatio) {
      height = src.height;
      width = src.height * dstRatio;
      left = (src.width - width) / 2;
      top = 0;
    } else {
      width = src.width;
      height = src.width / dstRatio;
      left = 0;
      top = (src.height - height) / 2;
    }

    return Rect.fromLTWH(left, top, width, height);
  }
}
