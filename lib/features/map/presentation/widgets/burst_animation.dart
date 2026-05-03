import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class BurstParticle {

  BurstParticle({
    required this.position,
    required this.scale,
    required this.opacity,
    required this.speed,
  });
  Offset position;
  double scale;
  double opacity;
  double speed;
}

class BurstPainter extends CustomPainter {

  BurstPainter(this.particles, this.image);
  final List<BurstParticle> particles;
  final ui.Image? image;

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) return;

    final paint = Paint();

    for (var p in particles) {
      paint.color = Colors.white.withOpacity(p.opacity);
      final double iconSize = 40 * p.scale;
      final offset = p.position - Offset(iconSize / 2, iconSize / 2);
      final src = Rect.fromLTWH(
        0,
        0,
        image!.width.toDouble(),
        image!.height.toDouble(),
      );
      final dst = Rect.fromLTWH(offset.dx, offset.dy, iconSize, iconSize);
      canvas.drawImageRect(image!, src, dst, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
