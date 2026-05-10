import 'package:flutter/material.dart';
import 'package:presshop/core/theme/app_colors.dart';
import 'package:presshop/core/utils/ui_utils.dart';

class RouteInfoWindow extends StatelessWidget {
  const RouteInfoWindow({
    super.key,
    required this.distance,
    required this.duration,
    required this.onClose,
  });
  final String distance;
  final String duration;
  final VoidCallback onClose;

  String _formatDuration(String durationStr) {
    try {
      // Extract numeric value from string (e.g., "440 min" -> 440)
      final numericPart = durationStr.replaceAll(RegExp(r'[^0-9]'), '');
      if (numericPart.isEmpty) return durationStr;

      final totalMinutes = int.parse(numericPart);
      if (totalMinutes >= 60) {
        final hours = totalMinutes ~/ 60;
        final minutes = totalMinutes % 60;
        if (minutes == 0) {
          return "${hours}h";
        }
        return "${hours}h ${minutes}m";
      }
      return durationStr;
    } catch (e) {
      return durationStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double scalingWidth = isIpad ? 550 : size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white24 : Colors.grey.shade400;

    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: scalingWidth * 0.5,
            padding: EdgeInsets.symmetric(
                horizontal: scalingWidth * 0.04, vertical: scalingWidth * 0.03),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
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
                    Text(
                      "Trip Details",
                      style: TextStyle(
                          fontSize: scalingWidth * 0.032,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).hintColor),
                    ),
                    GestureDetector(
                      onTap: onClose,
                      child: Icon(Icons.close,
                          size: scalingWidth * 0.045,
                          color: Theme.of(context).iconTheme.color),
                    )
                  ],
                ),
                SizedBox(height: scalingWidth * 0.02),
                Container(height: 1, color: borderColor),
                SizedBox(height: scalingWidth * 0.02),
                Row(
                  children: [
                    Icon(Icons.compare_arrows,
                        size: scalingWidth * 0.04, color: Colors.grey),
                    SizedBox(width: scalingWidth * 0.02),
                    Text(
                      distance,
                      style: TextStyle(
                        fontSize: scalingWidth * 0.04,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: scalingWidth * 0.015),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: scalingWidth * 0.04, color: Colors.grey),
                    SizedBox(width: scalingWidth * 0.02),
                    Text(
                      _formatDuration(duration),
                      style: TextStyle(
                        fontSize: scalingWidth * 0.04,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
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
              size: Size(scalingWidth * 0.05, scalingWidth * 0.03),
              painter: _TrianglePainter(Theme.of(context).cardColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
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
