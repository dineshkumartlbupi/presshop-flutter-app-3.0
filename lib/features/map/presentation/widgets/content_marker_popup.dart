import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:presshop/core/constants/app_assets.dart';
import 'package:presshop/core/constants/app_dimensions.dart';
import 'package:presshop/features/map/data/models/marker_model.dart';

class ContentMarkerPopup extends StatelessWidget {
  final Incident incident;
  final VoidCallback onViewPressed;

  const ContentMarkerPopup({
    Key? key,
    required this.incident,
    required this.onViewPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    print(
        "ContentMarkerPopup: id=${incident.id} temp=${incident.temperature} wind=${incident.wind} heading=${incident.heading}");
    return Transform.translate(
        offset: const Offset(0, 0),
        child: TweenAnimationBuilder<double>(
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
                    width: size.width * AppDimensions.numD50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                          size.width * AppDimensions.numD035),
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
                        // Image
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(
                                  size.width * AppDimensions.numD035)),
                          child: incident.image != null
                              ? Padding(
                                  padding: EdgeInsets.all(
                                      size.width * AppDimensions.numD02),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            size.width * AppDimensions.numD03)),
                                    child: CachedNetworkImage(
                                      imageUrl: incident.image!,
                                      height: size.width * AppDimensions.numD20,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : Container(
                                  height: size.width * AppDimensions.numD20,
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.image,
                                      size: size.width * AppDimensions.numD08),
                                ),
                        ),

                        Padding(
                          padding:
                              EdgeInsets.all(size.width * AppDimensions.numD02),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                incident.title ?? "No Title",
                                style: TextStyle(
                                  fontSize: size.width * AppDimensions.numD035,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                  height: size.width * AppDimensions.numD01),

                              // Location
                              Row(
                                children: [
                                  Image.asset("assets/icons/news_location.png",
                                      height:
                                          size.width * AppDimensions.numD035,
                                      color: Colors.grey[600]),
                                  SizedBox(
                                      width: size.width * AppDimensions.numD01),
                                  Expanded(
                                    child: Text(
                                      incident.address ?? "Unknown Location",
                                      style: TextStyle(
                                          fontSize: size.width *
                                              AppDimensions.numD028,
                                          color: Colors.grey[600]),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height: size.width * AppDimensions.numD01),

                              // Time and Views
                              Row(
                                children: [
                                  Image.asset(
                                    "${iconsPath}ic_clock.png",
                                    height: size.width * AppDimensions.numD03,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(
                                      width: size.width * AppDimensions.numD01),
                                  Builder(builder: (context) {
                                    final timeStr = incident.time;
                                    if (timeStr == null) {
                                      return Text("Unknown Time",
                                          style: TextStyle(
                                              fontSize: size.width *
                                                  AppDimensions.numD028,
                                              color: Colors.grey));
                                    }

                                    DateTime? parsed =
                                        DateTime.tryParse(timeStr);
                                    String displayTime = timeStr;

                                    if (parsed != null) {
                                      displayTime =
                                          DateFormat('hh:mm a').format(parsed);
                                    } else {
                                      try {
                                        displayTime = DateFormat('hh:mm a')
                                            .format(DateFormat("HH:mm")
                                                .parse(timeStr));
                                      } catch (_) {}
                                    }

                                    return Text(
                                      displayTime,
                                      style: TextStyle(
                                          fontSize: size.width *
                                              AppDimensions.numD028,
                                          color: Colors.grey[600]),
                                    );
                                  }),
                                  SizedBox(
                                      width: size.width * AppDimensions.numD03),
                                  Image.asset(
                                    "${iconsPath}news_eye.png",
                                    height: size.width * AppDimensions.numD025,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(
                                      width: size.width * AppDimensions.numD01),
                                  Text(
                                    "${incident.viewCount ?? 0}",
                                    style: TextStyle(
                                        fontSize:
                                            size.width * AppDimensions.numD028,
                                        color: Colors.grey[600]),
                                  )
                                ],
                              ),
                              SizedBox(
                                  height: size.width * AppDimensions.numD01),

                              // Date
                              Row(
                                children: [
                                  Image.asset(
                                    "${iconsPath}ic_yearly_calendar.png",
                                    height: size.width * AppDimensions.numD03,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(
                                      width: size.width * AppDimensions.numD01),
                                  Builder(builder: (context) {
                                    final timeStr = incident.time;
                                    DateTime? parsed =
                                        DateTime.tryParse(timeStr ?? "");
                                    String displayDate = "";
                                    if (parsed != null) {
                                      displayDate = DateFormat("dd MMM yyyy")
                                          .format(parsed);
                                    } else {
                                      displayDate = incident.date ?? "";
                                    }

                                    return Text(
                                      displayDate,
                                      style: TextStyle(
                                          fontSize: size.width *
                                              AppDimensions.numD028,
                                          color: Colors.grey[600]),
                                    );
                                  }),
                                ],
                              ),

                              SizedBox(
                                  height: size.width * AppDimensions.numD015),

                              // Small View Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: onViewPressed,
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: const Color(0xFFEF4444),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                        vertical:
                                            size.width * AppDimensions.numD015),
                                    minimumSize: Size(
                                        0, size.width * AppDimensions.numD05),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          size.width * AppDimensions.numD015),
                                    ),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    "View",
                                    style: TextStyle(
                                      fontSize:
                                          size.width * AppDimensions.numD025,
                                      height: 1,
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
                  Padding(
                    padding: EdgeInsets.zero,
                    child: CustomPaint(
                      size: Size(size.width * AppDimensions.numD06,
                          size.width * AppDimensions.numD03),
                      painter: _TrianglePainter(),
                    ),
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
