import 'package:flutter/material.dart';
import 'package:presshop/features/map/constants/map_news_constants.dart';
import 'package:presshop/features/map/data/models/marker_model.dart';

class CustomInfoWindow extends StatelessWidget {
  final Incident incident;
  final VoidCallback onPressed;

  const CustomInfoWindow({
    super.key,
    required this.incident,
    required this.onPressed,
  });

  String _getDisplayName() {
    if (incident.type != null) {
      return incident.type![0].toUpperCase() + incident.type!.substring(1);
    }
    return incident.name ?? "Incident";
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          alignment: Alignment.bottomCenter,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        elevation: 6,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // MAIN CARD
            Container(
              width: 250,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // TOP ROW (ICON + TITLE)
                  Row(
                    children: [
                      Image.asset(
                        markerIcons[incident.type] ?? markerIcons["accident"]!,
                        width: 35,
                        height: 35,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              incident.heading ?? _getDisplayName(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (incident.temperature != null ||
                                incident.wind != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Row(
                                  children: [
                                    if (incident.temperature != null)
                                      Text(
                                        "${incident.temperature}°C  ",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    if (incident.wind != null)
                                      Text(
                                        "${incident.wind} km/h Wind",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // DIVIDER
                  Container(height: 1, color: Colors.grey.shade300),

                  const SizedBox(height: 8),

                  // TIME ROW
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade800,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        incident.time ?? "Unknown Time",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // LOCATION ROW
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey.shade800,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          incident.address ?? "Unknown Location",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // TRIANGLE
            CustomPaint(size: const Size(20, 12), painter: _TrianglePainter()),
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
