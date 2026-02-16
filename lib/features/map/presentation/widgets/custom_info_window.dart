import 'package:flutter/material.dart';
import 'package:presshop/features/map/constants/map_news_constants.dart';
import 'package:presshop/features/map/data/models/marker_model.dart';
import 'package:intl/intl.dart';
import 'package:presshop/core/constants/app_dimensions.dart';
import 'package:presshop/core/constants/app_assets.dart';

class CustomInfoWindow extends StatelessWidget {
  final Incident incident;
  final VoidCallback onPressed;

  const CustomInfoWindow({
    super.key,
    required this.incident,
    required this.onPressed,
  });

  String _getDisplayTitle(String? type, String? address) {
    String typeName = (type ?? "Incident");
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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Transform.translate(
      offset: const Offset(0, 0),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuart,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            alignment: Alignment.bottomCenter, // Scale from center bottom
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Container(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            elevation: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // MAIN CARD
                Container(
                  width: size.width * AppDimensions.numD65,
                  padding: EdgeInsets.only(
                      left: size.width * AppDimensions.numD04,
                      right: size.width * AppDimensions.numD04,
                      top: size.width * AppDimensions.numD02,
                      bottom: size.width * AppDimensions.numD04),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                        size.width * AppDimensions.numD045),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: size.width * AppDimensions.numD02,
                        offset: Offset(0, size.width * AppDimensions.numD008),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // TOP ROW (ICON + CITY)
                      Container(
                        padding: EdgeInsets.only(
                            bottom: size.width * AppDimensions.numD02),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                              burstIcons[incident.type] ??
                                  markerIcons[incident.type] ??
                                  markerIcons["nomarker"]!,
                              height: size.width * AppDimensions.numD10,
                            ),
                            SizedBox(width: size.width * AppDimensions.numD015),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    // Use heading if available, else fallback
                                    incident.heading ??
                                        _getDisplayTitle(
                                            incident.type, incident.address),
                                    style: TextStyle(
                                      fontSize:
                                          size.width * AppDimensions.numD045,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (incident.temperature != null ||
                                      incident.wind != null ||
                                      (incident.type
                                              ?.toLowerCase()
                                              .contains('snow') ??
                                          false) ||
                                      (incident.type
                                              ?.toLowerCase()
                                              .contains('weather') ??
                                          false) ||
                                      (incident.type
                                              ?.toLowerCase()
                                              .contains('storm') ??
                                          false)) ...[
                                    SizedBox(
                                        height:
                                            size.width * AppDimensions.numD01),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${incident.temperature ?? '--'}°C",
                                          style: TextStyle(
                                            fontSize: size.width *
                                                AppDimensions.numD032,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(
                                            width: size.width *
                                                AppDimensions.numD02),
                                        Text(
                                          "${incident.wind ?? '--'} km/h Wind",
                                          style: TextStyle(
                                            fontSize: size.width *
                                                AppDimensions.numD032,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // DIVIDER
                      Container(height: 1, color: Colors.grey.shade300),

                      SizedBox(height: size.width * AppDimensions.numD025),

                      // FULL ADDRESS
                      if (incident.address != null &&
                          incident.address!.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(top: 4),
                              child: SizedBox(
                                width: size.width * AppDimensions.numD06,
                                child: Image.asset(
                                    "assets/icons/news_location.png",
                                    height: size.width * AppDimensions.numD04,
                                    color: Colors.grey[800]),
                              ),
                            ),
                            SizedBox(width: size.width * AppDimensions.numD02),
                            Expanded(
                              child: Text(
                                incident.address!,
                                style: TextStyle(
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: Colors.grey.shade700,
                                  // height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],

                      if (incident.description != null &&
                          incident.description!.isNotEmpty) ...[
                        SizedBox(height: size.width * AppDimensions.numD02),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: size.width * AppDimensions.numD06,
                              child: Icon(Icons.info_outline,
                                  size: size.width * AppDimensions.numD04,
                                  color: Colors.grey[800]),
                            ),
                            SizedBox(width: size.width * AppDimensions.numD02),
                            Expanded(
                              child: Text(
                                incident.description!,
                                style: TextStyle(
                                  fontSize: size.width * AppDimensions.numD032,
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                  height: 1.3,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],

                      SizedBox(height: size.width * AppDimensions.numD02),

                      // TIME AND VIEW COUNT (ROW)
                      Row(
                        children: [
                          // Time (Left)
                          Row(
                            children: [
                              SizedBox(
                                width: size.width * AppDimensions.numD06,
                                child: Image.asset(
                                  "${iconsPath}ic_clock.png",
                                  height: size.width * AppDimensions.numD035,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(
                                  width: size.width * AppDimensions.numD025),
                              Text(
                                _formatTime(incident.time),
                                style: TextStyle(
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(width: size.width * AppDimensions.numD03),

                          // Views (Right)
                          Row(
                            children: [
                              Image.asset(
                                "assets/icons/news_eye.png",
                                height: size.width * AppDimensions.numD03,
                                color: Colors.grey.shade800,
                              ),
                              SizedBox(
                                  width: size.width * AppDimensions.numD015),
                              Text(
                                "${incident.viewCount ?? 0}",
                                style: TextStyle(
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: size.width * AppDimensions.numD02),

                      // DATE
                      Row(
                        children: [
                          SizedBox(
                            width: size.width * AppDimensions.numD06,
                            child: Image.asset(
                              "${iconsPath}ic_yearly_calendar.png",
                              height: size.width * AppDimensions.numD035,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(width: size.width * AppDimensions.numD02),
                          Text(
                            _formatDate(incident.date, incident.time),
                            style: TextStyle(
                              fontSize: size.width * AppDimensions.numD035,
                              color: Colors.grey.shade700,
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
                      size: Size(size.width * AppDimensions.numD06,
                          size.width * AppDimensions.numD03),
                      painter: _TrianglePainter()),
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
