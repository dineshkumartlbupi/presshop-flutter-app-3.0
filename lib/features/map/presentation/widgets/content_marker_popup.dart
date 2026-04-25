import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presshop/core/constants/app_assets.dart';
import 'package:presshop/core/constants/app_dimensions.dart';
import 'package:presshop/features/map/data/models/marker_model.dart';

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
                    width: responsiveWidth * AppDimensions.numD60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                          responsiveWidth * AppDimensions.numD045),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: responsiveWidth * AppDimensions.numD02,
                          offset: Offset(
                              0, responsiveWidth * AppDimensions.numD008),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Image with Padding
                        Padding(
                          padding: EdgeInsets.only(
                            top: responsiveWidth * AppDimensions.numD025,
                            left: responsiveWidth * AppDimensions.numD025,
                            right: responsiveWidth * AppDimensions.numD025,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                responsiveWidth * AppDimensions.numD03),
                            child: incident.image != null
                                ? CachedNetworkImage(
                                    imageUrl: incident.image!,
                                    height:
                                        responsiveWidth * AppDimensions.numD25,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      height: responsiveWidth *
                                          AppDimensions.numD35,
                                      color: Colors.grey[100],
                                      child: const Center(
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2)),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      height: responsiveWidth *
                                          AppDimensions.numD35,
                                      color: Colors.grey[100],
                                      child: const Icon(Icons.error_outline,
                                          color: Colors.grey),
                                    ),
                                  )
                                : Container(
                                    height:
                                        responsiveWidth * AppDimensions.numD35,
                                    width: double.infinity,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image,
                                        size: 40, color: Colors.grey),
                                  ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(
                            left: responsiveWidth * AppDimensions.numD03,
                            right: responsiveWidth * AppDimensions.numD03,
                            top: responsiveWidth * AppDimensions.numD02,
                            bottom: responsiveWidth * AppDimensions.numD03,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                incident.title ?? "No Title",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),

                              // Location
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width:
                                        responsiveWidth * AppDimensions.numD06,
                                    child: Image.asset(
                                        "assets/icons/news_location.png",
                                        height: responsiveWidth *
                                            AppDimensions.numD04,
                                        color: Colors.grey[800]),
                                  ),
                                  SizedBox(
                                      width: responsiveWidth *
                                          AppDimensions.numD01),
                                  Expanded(
                                    child: Text(
                                      incident.address ?? "Unknown Location",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height:
                                      responsiveWidth * AppDimensions.numD015),

                              // Time and Views
                              Row(
                                children: [
                                  SizedBox(
                                    width:
                                        responsiveWidth * AppDimensions.numD06,
                                    child: Image.asset(
                                      "${iconsPath}ic_clock.png",
                                      height: responsiveWidth *
                                          AppDimensions.numD035,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  SizedBox(
                                      width: responsiveWidth *
                                          AppDimensions.numD01),
                                  Builder(builder: (context) {
                                    final timeStr = incident.time;
                                    if (timeStr == null) {
                                      return Text("No Time",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ));
                                    }
                                    DateTime? parsed =
                                        DateTime.tryParse(timeStr);
                                    String displayTime = timeStr;
                                    if (parsed != null) {
                                      displayTime =
                                          DateFormat('hh:mm a').format(parsed);
                                    }
                                    return Text(displayTime,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ));
                                  }),
                                  SizedBox(
                                      width: responsiveWidth *
                                          AppDimensions.numD03),
                                  Image.asset(
                                    "assets/icons/news_eye.png",
                                    height:
                                        responsiveWidth * AppDimensions.numD03,
                                    color: Colors.grey.shade800,
                                  ),
                                  SizedBox(
                                      width: responsiveWidth *
                                          AppDimensions.numD01),
                                  TweenAnimationBuilder<double>(
                                    duration:
                                        const Duration(milliseconds: 1500),
                                    curve: Curves.easeOut,
                                    tween: Tween<double>(
                                      begin: 0,
                                      end: (incident.viewCount ?? 0).toDouble(),
                                    ),
                                    builder: (context, value, child) {
                                      return Text(
                                        "${value.toInt()}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      );
                                    },
                                  )
                                ],
                              ),
                              SizedBox(
                                  height:
                                      responsiveWidth * AppDimensions.numD015),

                              // Date
                              Row(
                                children: [
                                  SizedBox(
                                    width:
                                        responsiveWidth * AppDimensions.numD06,
                                    child: Image.asset(
                                      "${iconsPath}ic_yearly_calendar.png",
                                      height: responsiveWidth *
                                          AppDimensions.numD035,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  SizedBox(
                                      width: responsiveWidth *
                                          AppDimensions.numD01),
                                  Builder(builder: (context) {
                                    final timeStr = incident.time;
                                    DateTime? parsed =
                                        DateTime.tryParse(timeStr ?? "");
                                    String displayDate =
                                        incident.date ?? "No Date";
                                    if (parsed != null) {
                                      displayDate = DateFormat("dd MMM yyyy")
                                          .format(parsed);
                                    }
                                    return Text(displayDate,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ));
                                  }),
                                ],
                              ),

                              SizedBox(
                                  height:
                                      responsiveWidth * AppDimensions.numD02),

                              // View Button
                              SizedBox(
                                width: double.infinity,
                                height: 35,
                                child: ElevatedButton(
                                  onPressed: onViewPressed,
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: const Color(0xFFEC4E54),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    "View",
                                    style: TextStyle(
                                      fontSize: 15,
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
                    painter: _TrianglePainter(),
                  ),
                ],
              ),
            ),
          ),
        ));
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
