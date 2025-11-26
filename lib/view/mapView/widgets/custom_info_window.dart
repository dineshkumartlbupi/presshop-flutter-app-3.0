import 'package:flutter/material.dart';
import 'package:presshop/view/mapView/models/marker_model.dart';

class CustomInfoWindow extends StatelessWidget {
  final Incident incident;
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
    if (incident.markerType == 'icon') {
      if (incident.address != null && incident.address!.isNotEmpty) {
        return incident.address!;
      }
      if (incident.type != null) {
        return incident.type![0].toUpperCase() + incident.type!.substring(1);
      }
      return "Incident";
    } else if (incident.markerType == 'content') {
      return incident.title ?? incident.name ?? "Content";
    } else if (incident.markerType == 'hopper') {
      return incident.name ?? "Hopper";
    }
    return incident.name ?? incident.title ?? "Incident";
  }

  Widget _getImageWidget() {
    if (incident.markerType == 'icon' && incident.type != null) {
      // For icon markers, use asset image
      final assetPath = markerIcons[incident.type] ?? markerIcons['accident']!;
      return Image.asset(
        assetPath,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            color: Colors.grey[300],
            child: const Icon(Icons.error),
          );
        },
      );
    } else if (incident.image != null && incident.image!.isNotEmpty) {
      // For content/hopper markers, use network image
      return Image.network(
        incident.image!,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            color: Colors.grey[300],
            child: const Icon(Icons.error),
          );
        },
      );
    } else {
      // Fallback
      return Container(
        width: 60,
        height: 60,
        color: Colors.grey[300],
        child: const Icon(Icons.place),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Colors.transparent, // Important
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // MAIN CARD
          Container(
            width: 220,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _getImageWidget(),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDisplayName(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (incident.time != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          incident.time!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      ElevatedButton(
                        onPressed: onPressed,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 12,
                          ),
                        ),
                        child: const Text("View Details"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🔽 POINTER TRIANGLE
          CustomPaint(size: const Size(20, 10), painter: _TrianglePainter()),
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
