import 'package:flutter/material.dart';

class RouteInfoWindow extends StatelessWidget {
  final String distance;
  final String duration;
  final VoidCallback onClose;

  const RouteInfoWindow({
    super.key,
    required this.distance,
    required this.duration,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        elevation: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 200,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Trip Details",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                      GestureDetector(
                        onTap: onClose,
                        child: const Icon(Icons.close,
                            size: 20, color: Colors.grey),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(height: 1, color: Colors.grey.shade200),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.compare_arrows,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        distance,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        duration,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // TRIANGLE
            Padding(
              padding: EdgeInsets.zero,
              child: CustomPaint(
                  size: const Size(20, 12), painter: _TrianglePainter()),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
