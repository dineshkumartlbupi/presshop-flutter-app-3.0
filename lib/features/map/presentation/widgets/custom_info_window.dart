import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:presshop/features/map/constants/map_news_constants.dart';
import 'package:presshop/features/map/data/models/marker_model.dart';
import 'package:intl/intl.dart';

class CustomInfoWindow extends StatelessWidget {

  const CustomInfoWindow({
    super.key,
    required this.incident,
    required this.onPressed,
  });
  final Incident incident;
  final VoidCallback onPressed;

  String _getDisplayTitle(String? type, String? address) {
    String typeName = type ?? "Incident";
    if (typeName.isNotEmpty) {
      typeName =
          typeName[0].toUpperCase() + typeName.substring(1).toLowerCase();
    }

    String city = "Unknown City";
    if (address != null && address.isNotEmpty) {
      List<String> parts = address.split(',');
      if (parts.length > 1) {
        city = parts[1].trim();
      } else {
        city = address;
      }
    }

    return "$typeName at $city";
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return "No Time";

    DateTime? parsed = DateTime.tryParse(timeStr);
    if (parsed != null) {
      return DateFormat('hh:mm a').format(parsed);
    }

    try {
      return DateFormat('hh:mm a').format(DateFormat("HH:mm").parse(timeStr));
    } catch (_) {}

    return timeStr;
  }

  String _formatDate(String? dateStr, String? timeStr) {
    if (dateStr != null && dateStr.isNotEmpty) {
      try {
        DateTime? parsed = DateTime.tryParse(dateStr);
        if (parsed != null) {
          return DateFormat("dd MMM yyyy").format(parsed);
        }
      } catch (_) {}
      return dateStr;
    }

    if (timeStr != null && timeStr.isNotEmpty) {
      try {
        DateTime? parsed = DateTime.tryParse(timeStr);
        if (parsed != null) {
          return DateFormat("dd MMM yyyy").format(parsed);
        }
      } catch (_) {}
    }

    return "No Date";
  }

  String _formatRelativeTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return "some time ago";
    try {
      DateTime? parsed = DateTime.tryParse(timeStr);
      if (parsed == null) return "some time ago";
      
      final diff = DateTime.now().difference(parsed);
      if (diff.inDays > 365) return "${(diff.inDays / 365).floor()} years ago";
      if (diff.inDays > 30) return "${(diff.inDays / 30).floor()} months ago";
      if (diff.inDays > 0) return "${diff.inDays} days ago";
      if (diff.inHours > 0) return "${diff.inHours} hours ago";
      if (diff.inMinutes > 0) return "${diff.inMinutes} minutes ago";
      return "just now";
    } catch (_) {
      return "some time ago";
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double responsiveWidth = size.width > 600 ? 650 : size.width;

    return Transform.translate(
      offset: const Offset(0, 0),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            alignment: Alignment.bottomCenter,
            child: Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: Container(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            elevation: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: responsiveWidth * 0.7,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Poster Info
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: (incident.avatar != null && incident.avatar!.isNotEmpty)
                                    ? CachedNetworkImageProvider(incident.avatar!)
                                    : const AssetImage('assets/markers/avatar.png') as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  incident.username ?? "Anonymous",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  "posted an alert : ${_formatRelativeTime(incident.time)}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1, thickness: 1),
                      ),

                      // Header Row
                      Row(
                        children: [
                          Image.asset(
                            burstIcons[incident.type] ?? markerIcons[incident.type] ?? markerIcons["nomarker"]!,
                            height: 36,
                            width: 36,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.warning_amber_rounded, size: 36, color: Colors.orange),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              incident.heading ?? _getDisplayTitle(incident.type, incident.address),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(height: 1, thickness: 1),
                      ),

                      // Details
                      if (incident.address != null && incident.address!.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on_outlined, size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                incident.address!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                      ],

                      // Description
                      if (incident.description != null && incident.description!.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                incident.description!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                      ],

                      // Time and Views
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            _formatTime(incident.time),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.visibility_outlined, size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            "${incident.viewCount ?? 0}",
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 4),

                      // Date
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            _formatDate(incident.date, incident.time),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Triangle
                CustomPaint(
                  size: const Size(20, 10),
                  painter: _TrianglePainter(),
                ),
              ],
            ),
          ),
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
