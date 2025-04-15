import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math';

class WavePainter extends CustomPainter {
  final double animationValue;
  final Color waveColor;
  final double waveThickness;
  final List<double> waveData;

  WavePainter(this.animationValue,
      {this.waveColor = Colors.black,
        this.waveThickness = 2.0,
        this.waveData = const []});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = waveThickness;

    List<Offset> points = [];
    double xOffset = animationValue * size.width;

    if (waveData.isNotEmpty) {
      double dataWidth = waveData.length.toDouble();
      double xStep = size.width / dataWidth;

      for (int i = 0; i < waveData.length; i++) {
        double x = i * xStep;
        double y = size.height * (1 - waveData[i]);
        points.add(Offset(x, y));
      }
    } else {
      // Increased the number of points for smoother wave
      for (double x = 0; x < size.width + 20; x += 2) { // Increased resolution
        // Reduced the amplitude of the sine waves to fit within the container
        double y = size.height / 2 +
            sin((x + xOffset) / 15) * 10 +  // Adjusted frequency and amplitude
            sin((x + xOffset) / 8) * 5;    // Adjusted frequency and amplitude
        points.add(Offset(x, y));
      }
    }
    canvas.drawPoints(PointMode.polygon, points, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is WavePainter) {
      return oldDelegate.animationValue != animationValue ||
          oldDelegate.waveColor != waveColor ||
          oldDelegate.waveThickness != waveThickness ||
          oldDelegate.waveData != waveData;
    }
    return true;
  }
}

class HeartbeatWave extends StatefulWidget {
  final Color waveColor;
  final double waveThickness;
  final List<double> waveData;

  HeartbeatWave(
      {this.waveColor = Colors.black,
        this.waveThickness = 2.0,
        this.waveData = const []});

  @override
  _HeartbeatWaveState createState() => _HeartbeatWaveState();
}

class _HeartbeatWaveState extends State<HeartbeatWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: false);

    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          color: Colors.grey,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: WavePainter(_animation.value,
                    waveColor: widget.waveColor,
                    waveThickness: widget.waveThickness,
                    waveData: widget.waveData),
                size: Size(double.infinity, 100),
              );
            },
          ),
        ),
      ),
    );
  }
}

// class HeartbeatWave extends StatefulWidget {
//   const HeartbeatWave({super.key});
//
//   @override
//   State<HeartbeatWave> createState() => _HeartbeatWaveState();
// }
//
// class _HeartbeatWaveState extends State<HeartbeatWave>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500), // Changed from 2000ms
//     )..repeat();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: SizedBox(
//           width: 300,
//           height: 200,
//           child: CustomPaint(
//             painter: HeartbeatPainter(_controller),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class HeartbeatPainter extends CustomPainter {
//   final Animation<double> animation;
//   HeartbeatPainter(this.animation) : super(repaint: animation);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.black
//       ..strokeWidth = 2.0
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.butt // Added for smoother edges
//       ..strokeJoin = StrokeJoin.miter; // Added for smoother connections
//
//     final path = Path();
//     final width = size.width;
//     final height = size.height;
//     final centerY = height / 2;
//
//     path.moveTo(0, centerY);
//     double t = animation.value * width;
//
//     // Reduced period from 100 to 70 for closer waves
//     double period = 70;
//
//     for (double x = 0; x <= width; x += 0.5) { // Smaller steps for smoother curve
//       if (x < t) {
//         double y = centerY;
//         double relativeX = x % period;
//
//         // Smoother heartbeat pattern using sine for transitions
//         if (relativeX < 15) {
//           // Small peak (P wave) with sine smoothing
//           y = centerY - (math.sin(relativeX * math.pi / 30) * height * 0.15);
//         } else if (relativeX < 20) {
//           // Transition down
//           y = centerY + (math.sin((relativeX - 15) * math.pi / 10) * height * 0.05);
//         } else if (relativeX < 30) {
//           // Big peak up (QRS complex)
//           y = centerY - (math.sin((relativeX - 20) * math.pi / 20) * height * 0.4);
//         } else if (relativeX < 40) {
//           // Big peak down
//           y = centerY + (math.sin((relativeX - 30) * math.pi / 20) * height * 0.35);
//         } else if (relativeX < 45) {
//           // Sharp down with smoothing
//           y = centerY + (math.sin((relativeX - 40) * math.pi / 10) * height * 0.1);
//         }
//
//         // Use quadratic bezier for smoother transitions
//         if (x == 0) {
//           path.lineTo(x, y);
//         } else {
//           final previousX = x - 0.5;
//           final previousY = path.getBounds().bottom;
//           final controlX = previousX + 0.25;
//           final controlY = (previousY + y) / 2;
//           path.quadraticBezierTo(controlX, controlY, x, y);
//         }
//       } else {
//         path.lineTo(x, centerY);
//       }
//     }
//
//     canvas.drawPath(path, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }