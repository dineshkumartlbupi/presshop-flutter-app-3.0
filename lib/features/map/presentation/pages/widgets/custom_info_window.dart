import 'package:flutter/material.dart';
import 'package:presshop/features/map/domain/entities/incident_entity.dart';

class CustomInfoWindow extends StatelessWidget {
  final IncidentEntity incident;
  final VoidCallback onPressed;

  const CustomInfoWindow({
    super.key,
    required this.incident,
    required this.onPressed,
  });

  static const Map<String, String> markerIcons = {
    "accident": "assets/markers/carcrash.png",
    "fire": "assets/markers/fire.png",
    "medical": "assets/markers/medical.png",
    "gun": "assets/markers/gun.png",
    "protest": "assets/markers/fight.png",
    "knife": "assets/markers/knife.png",
    "fight": "assets/markers/fight.png",
  };

  String _getDisplayName() {
    // IncidentEntity might have null type, logic remains same
    if (incident.type.isNotEmpty) {
      return incident.type[0].toUpperCase() + incident.type.substring(1);
    }
    return incident.name ?? "Incident";
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 6,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // MAIN CARD
          Container(
            width: 280,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOP ROW (ICON + TITLE)
                Row(
                  children: [
                    Image.asset(
                      markerIcons[incident.type] ?? markerIcons["accident"]!,
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _getDisplayName(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // DIVIDER
                Container(height: 1, color: Colors.grey.shade300),

                const SizedBox(height: 12),

                // TIME ROW
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 20,
                      color: Colors.grey.shade800,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      incident.time ?? "Unknown Time",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // LOCATION ROW
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 22,
                      color: Colors.grey.shade800,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        incident.address ?? "Unknown Location",
                        style: TextStyle(
                          fontSize: 16,
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
