import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as img_pkg;
import 'package:presshop/features/map/data/models/marker_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class MarkerService {
  // Cache for bitmap descriptors to avoid reprocessing same images
  final Map<String, BitmapDescriptor> _bitmapCache = {};

  List<Incident> getIncidents() => [];

  Future<BitmapDescriptor> bitmapResize(
    String assetPath, {
    int width = 50,
  }) async {
    final byteData = await rootBundle.load(assetPath);
    final uint8list = byteData.buffer.asUint8List();

    final codec = await ui.instantiateImageCodec(uint8list, targetWidth: width);
    final frame = await codec.getNextFrame();
    final img = frame.image;

    final byteDataImage = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(byteDataImage!.buffer.asUint8List());
  }

  Future<BitmapDescriptor> bitmapFromIncidentAsset(
    String assetPath,
    int width,
  ) async {
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();

    final codec = await ui.instantiateImageCodec(bytes, targetWidth: width);
    final frame = await codec.getNextFrame();
    final img = frame.image;

    final byteDataImage = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteDataImage!.buffer.asUint8List());
  }

  Future<BitmapDescriptor> bitmapFromUrl(
    String url, {
    int width = 70,
    String defaultAsset = "assets/markers/bg-removed-content.png",
  }) async {
    // Check cache first
    final cacheKey = '$url:$width';
    if (_bitmapCache.containsKey(cacheKey)) {
      return _bitmapCache[cacheKey]!;
    }

    try {
      if (url.isEmpty) {
        return bitmapResize(defaultAsset, width: width);
      }

      // Download and process in background isolate
      final result = await compute(_processImageFromUrl, {
        'url': url,
        'width': width,
      });

      if (result != null) {
        final bitmap = BitmapDescriptor.bytes(result);
        _bitmapCache[cacheKey] = bitmap;
        return bitmap;
      }

      return bitmapResize(defaultAsset, width: width);
    } catch (e) {
      print("Error loading marker from URL: $e");
      return bitmapResize(defaultAsset, width: width);
    }
  }

  // Static function to run in isolate
  static Future<Uint8List?> _processImageFromUrl(
      Map<String, dynamic> params) async {
    try {
      final url = params['url'] as String;
      final width = params['width'] as int;

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final img = img_pkg.decodeImage(bytes);
        if (img == null) return null;

        final resized = img_pkg.copyResize(img, width: width);
        final rounded = img_pkg.copyCropCircle(resized);

        return Uint8List.fromList(img_pkg.encodePng(rounded));
      }
      return null;
    } catch (e) {
      return null;
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
    int size = 120,
    String? mediaType,
  }) async {
    final cacheKey = 'content:$url:$size:$mediaType';
    if (_bitmapCache.containsKey(cacheKey)) {
      return _bitmapCache[cacheKey]!;
    }
    try {
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: size);
      final frame = await codec.getNextFrame();
      final ui.Image img = frame.image;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final bgPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      final rect = Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble());
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(28));

      canvas.drawRRect(rrect, bgPaint);

      final clipPath = Path()..addRRect(rrect);
      canvas.clipPath(clipPath);
      final srcSize = Size(img.width.toDouble(), img.height.toDouble());
      final dstSize = Size(size.toDouble(), size.toDouble());
      final srcRect = _centerCrop(srcSize, dstSize);

      canvas.drawImageRect(
        img,
        srcRect,
        rect,
        Paint(),
      );

      canvas.drawRRect(
        rrect,
        Paint()
          ..color = const Color.fromARGB(170, 158, 158, 158)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 20,
      );

      // 🔹 Load and Draw Overlay Icon (Image/Video Icon)
      try {
        final String assetPath = (mediaType?.toLowerCase() == 'video')
            ? 'assets/markers/video-icon.png'
            : 'assets/markers/image-icon.png';

        final overlayData = await rootBundle.load(assetPath);
        final overlayBytes = overlayData.buffer.asUint8List();
        final overlayCodec =
            await ui.instantiateImageCodec(overlayBytes, targetWidth: 40);
        final overlayFrame = await overlayCodec.getNextFrame();
        final ui.Image overlayImg = overlayFrame.image;

        final overlaySize =
            Size(overlayImg.width.toDouble(), overlayImg.height.toDouble());

        // Position at Top Right
        final overlayOffset = Offset(
          size - overlaySize.width - 8, // Padding from right
          8, // Padding from top
        );

        canvas.drawImage(overlayImg, overlayOffset, Paint());
      } catch (e) {
        debugPrint("Error loading overlay icon: $e");
      }

      // Convert to png bytes and release native peer
      final ui.Image finalImage = await recorder.endRecording().toImage(
            size,
            size,
          );

      final byteData = await finalImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final bitmap = BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
      _bitmapCache[cacheKey] = bitmap;
      return bitmap;
    } catch (e) {
      debugPrint("Error creating content marker: $e. Using default.");
      final defaultBitmap = await bitmapResize(
          "assets/markers/bg-removed-content.png",
          width: size);
      _bitmapCache[cacheKey] = defaultBitmap;
      return defaultBitmap;
    }
  }

  // Clear cache if needed (call when memory is low)
  void clearCache() {
    _bitmapCache.clear();
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
