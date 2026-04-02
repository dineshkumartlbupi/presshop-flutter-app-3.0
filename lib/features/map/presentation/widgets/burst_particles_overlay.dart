import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class BurstParticle {
  Offset position;
  double scale;
  double opacity;
  double speed;

  BurstParticle({
    required this.position,
    required this.scale,
    required this.opacity,
    required this.speed,
  });
}

class BurstParticlesOverlay extends StatefulWidget {
  final AnimationController controller;
  final ui.Image? burstImage;
  final String? burstType;

  const BurstParticlesOverlay({
    Key? key,
    required this.controller,
    this.burstImage,
    this.burstType,
  }) : super(key: key);

  @override
  State<BurstParticlesOverlay> createState() => _BurstParticlesOverlayState();
}

class _BurstParticlesOverlayState extends State<BurstParticlesOverlay> {
  final List<BurstParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onAnimationTick);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onAnimationTick);
    super.dispose();
  }

  void _onAnimationTick() {
    if (widget.controller.value == 0) {
      _initParticles();
    }
    _updateParticles();
  }

  void _initParticles() {
    final size = MediaQuery.of(context).size;
    _particles.clear();
    for (int i = 0; i < 40; i++) {
      double randomX = Random().nextDouble() * size.width;
      double randomY = size.height + Random().nextDouble() * 300;
      _particles.add(
        BurstParticle(
          position: Offset(randomX, randomY),
          scale: 0.4 + Random().nextDouble() * 0.8,
          opacity: 1.0,
          speed: 1.0 + Random().nextDouble() * 1.5,
        ),
      );
    }
  }

  void _updateParticles() {
    final t = widget.controller.value;
    final size = MediaQuery.of(context).size;

    for (var p in _particles) {
      p.scale = 0.6 + t * 0.5;
      p.opacity = (1 - t).clamp(0.0, 1.0);
      p.position = p.position.translate(
        (p.position.dx - size.width / 2) * 0.02 * t,
        -size.height * 0.01 * p.speed,
      );
    }
    if (t == 1) _particles.clear();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: BurstPainter(_particles, widget.burstImage),
        child: Container(),
      ),
    );
  }
}

class BurstPainter extends CustomPainter {
  final List<BurstParticle> particles;
  final ui.Image? burstImage;

  BurstPainter(this.particles, this.burstImage);

  @override
  void paint(Canvas canvas, Size size) {
    if (burstImage == null) return;

    for (var p in particles) {
      final paint = Paint()..color = Colors.white.withOpacity(p.opacity);
      final destRect = Rect.fromCenter(
        center: p.position,
        width: 40 * p.scale,
        height: 40 * p.scale,
      );
      canvas.drawImageRect(
        burstImage!,
        Rect.fromLTWH(0, 0, burstImage!.width.toDouble(), burstImage!.height.toDouble()),
        destRect,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
