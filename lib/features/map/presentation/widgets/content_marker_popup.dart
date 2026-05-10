import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:presshop/features/map/data/models/marker_model.dart';
import 'package:presshop/features/map/presentation/bloc/map_bloc.dart';
import 'package:presshop/features/map/presentation/bloc/map_state.dart';

class ContentMarkerPopup extends StatelessWidget {
  const ContentMarkerPopup({
    super.key,
    required this.incident,
    required this.onViewPressed,
  });
  final Incident incident;
  final VoidCallback onViewPressed;

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
                  orElse: () => current.selectedIncident?.id == incident.id
                      ? current.selectedIncident!
                      : incident,
                );
                return oldI.viewCount != newI.viewCount ||
                    oldI.likesCount != newI.likesCount ||
                    oldI.commentsCount != newI.commentsCount;
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
                              width: responsiveWidth * 0.55,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
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
                                  // Image with Padding
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8, left: 8, right: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: currentIncident.image != null
                                          ? CachedNetworkImage(
                                              imageUrl: currentIncident.image!,
                                              height: responsiveWidth * 0.28,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  Container(
                                                height: responsiveWidth * 0.28,
                                                color: Colors.grey[100],
                                                child: const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                            strokeWidth: 2)),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                height: responsiveWidth * 0.28,
                                                color: Colors.grey[100],
                                                child: const Icon(
                                                    Icons.error_outline,
                                                    color: Colors.grey),
                                              ),
                                            )
                                          : Container(
                                              height: responsiveWidth * 0.28,
                                              width: double.infinity,
                                              color: Colors.grey[200],
                                              child: const Icon(Icons.image,
                                                  size: 40, color: Colors.grey),
                                            ),
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          currentIncident.title ?? "No Title",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                            height: 1.3,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),

                                        // Location
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.location_on_outlined,
                                                size: 16,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                currentIncident.address ??
                                                    "Unknown Location",
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),

                                        // Time and Views
                                        Row(
                                          children: [
                                            Icon(Icons.access_time,
                                                size: 16,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Builder(builder: (context) {
                                              final timeStr =
                                                  currentIncident.time;
                                              if (timeStr == null) {
                                                return Text("Unknown Time",
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color:
                                                            Colors.grey[600]));
                                              }
                                              DateTime? parsed =
                                                  DateTime.tryParse(timeStr);
                                              String displayTime = timeStr;
                                              if (parsed != null) {
                                                displayTime =
                                                    DateFormat('hh:mm a')
                                                        .format(parsed);
                                              }
                                              return Text(displayTime,
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey[600]));
                                            }),
                                            const SizedBox(width: 16),
                                            Icon(Icons.visibility_outlined,
                                                size: 16,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              "${currentIncident.viewCount ?? 0}",
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),

                                        // Date
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today_outlined,
                                                size: 16,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 6),
                                            Builder(builder: (context) {
                                              final timeStr =
                                                  currentIncident.time;
                                              DateTime? parsed =
                                                  DateTime.tryParse(
                                                      timeStr ?? "");
                                              String displayDate =
                                                  currentIncident.date ??
                                                      "Unknown Date";
                                              if (parsed != null) {
                                                displayDate =
                                                    DateFormat("dd MMM yyyy")
                                                        .format(parsed);
                                              }
                                              return Text(displayDate,
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey[600]));
                                            }),
                                          ],
                                        ),

                                        const SizedBox(height: 10),

                                        // View Button
                                        SizedBox(
                                          width: double.infinity,
                                          height: 35,
                                          child: ElevatedButton(
                                            onPressed: onViewPressed,
                                            style: ElevatedButton.styleFrom(
                                              elevation: 0,
                                              backgroundColor:
                                                  const Color(0xFFEC4E54),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: const Text(
                                              "View",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Pointer
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
        ));
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
