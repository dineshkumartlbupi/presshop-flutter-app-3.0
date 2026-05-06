import 'package:flutter/material.dart';
import 'package:presshop/core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:presshop/features/map/constants/map_news_constants.dart';
import 'package:presshop/features/map/presentation/bloc/map_bloc.dart';
import 'package:presshop/features/map/presentation/bloc/map_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white24 : Colors.grey.shade400;

    return Transform.translate(
      offset: const Offset(0, 0),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return BlocBuilder<MapBloc, MapState>(
            buildWhen: (previous, current) {
              final oldI = previous.newsList.firstWhere(
                (i) => i.id == incident.id,
                orElse: () => previous.selectedIncident?.id == incident.id
                    ? previous.selectedIncident!
                    : incident,
              );
              final newI = current.newsList.firstWhere(
                (i) => i.id == incident.id,
                orElse: () => incident,
              );
              return oldI.viewCount != newI.viewCount;
            },
            builder: (context, state) {
              final currentIncident = state.newsList.firstWhere(
                (i) => i.id == incident.id,
                orElse: () => state.selectedIncident?.id == incident.id
                    ? state.selectedIncident!
                    : incident,
              );

              return Transform.scale(
                scale: value,
                alignment: Alignment.bottomCenter,
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
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
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20),
                              // border: Border.all(color: borderColor),
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
                                Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: (currentIncident.avatar !=
                                                      null &&
                                                  currentIncident
                                                      .avatar!.isNotEmpty)
                                              ? CachedNetworkImageProvider(
                                                  currentIncident.avatar!)
                                              : const AssetImage(
                                                      'assets/markers/avatar.png')
                                                  as ImageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            currentIncident.username ??
                                                "Anonymous",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color,
                                            ),
                                          ),
                                          Text(
                                            "posted an alert : ${_formatRelativeTime(currentIncident.time)}",
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

                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: borderColor),
                                ),

                                // Header Row
                                Row(
                                  children: [
                                    Image.asset(
                                      burstIcons[currentIncident.type] ??
                                          markerIcons[currentIncident.type] ??
                                          markerIcons["nomarker"]!,
                                      height: 36,
                                      width: 36,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                  Icons.warning_amber_rounded,
                                                  size: 36,
                                                  color: Colors.orange),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        currentIncident.heading ??
                                            _getDisplayTitle(
                                                currentIncident.type,
                                                currentIncident.address),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),

                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: borderColor),
                                ),

                                // Details
                                if (currentIncident.address != null &&
                                    currentIncident.address!.isNotEmpty) ...[
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.location_on_outlined,
                                          size: 18, color: Colors.grey[600]),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          currentIncident.address!,
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
                                if (currentIncident.description != null &&
                                    currentIncident
                                        .description!.isNotEmpty) ...[
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.info_outline,
                                          size: 18, color: Colors.grey[600]),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          currentIncident.description!,
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
                                    Icon(Icons.access_time,
                                        size: 18, color: Colors.grey[600]),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatTime(currentIncident.time),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(Icons.visibility_outlined,
                                        size: 18, color: Colors.grey[600]),
                                    const SizedBox(width: 6),
                                    Text(
                                      "${currentIncident.viewCount ?? 0}",
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 4),

                                // Date
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_outlined,
                                        size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatDate(currentIncident.date,
                                          currentIncident.time),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Triangle
                          CustomPaint(
                            size: const Size(20, 10),
                            painter:
                                _TrianglePainter(Theme.of(context).cardColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
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
