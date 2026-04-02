import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/features/task/domain/entities/task_assigned_entity.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:http/http.dart' as http;

AlertDialog? alertDialog;
final Set<String> _shownBroadcastIds = {};
BitmapDescriptor? mapIcon;
Map<String, BitmapDescriptor> hopperAvatarIcons = {};
void getAllIcons() async {
  mapIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(5.0, 5.0)),
      "${commonImagePath}ic_cover_radius.png");
}

Future<BitmapDescriptor> getMarkerIcon(String url, Size size) async {
  try {
    final http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) throw Exception("Failed to load image");
    final Uint8List bytes = response.bodyBytes;

    final ui.Codec codec = await ui.instantiateImageCodec(bytes,
        targetWidth: size.width.toInt(), targetHeight: size.height.toInt());
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ui.Image image = fi.image;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..filterQuality = FilterQuality.high;
    final double radius = size.width / 2;

    // Draw circle background
    canvas.drawCircle(
        Offset(radius, radius), radius, Paint()..color = Colors.white);

    // Clip to circle
    canvas.clipPath(
        ui.Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height)));

    // Draw image
    canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(0, 0, size.width, size.height),
        paint);

    // Draw border
    final Paint borderPaint = Paint()
      ..color = AppColorTheme.colorThemePink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;
    canvas.drawCircle(Offset(radius, radius), radius - 3.0, borderPaint);

    final ui.Image finalImage = await pictureRecorder
        .endRecording()
        .toImage(size.width.toInt(), size.height.toInt());
    final ByteData? byteData =
        await finalImage.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  } catch (e) {
    debugPrint("Error creating marker icon: $e");
    return mapIcon ?? BitmapDescriptor.defaultMarker;
  }
}

Future<void> loadHopperAvatars(
    List<dynamic> hoppers, Function(void Function()) setState,
    [Size size = const Size(60, 60)]) async {
  bool updated = false;
  for (var hopper in hoppers) {
    String avatarUrl = getMediaImageUrl(hopper.avatar);
    if (avatarUrl.isNotEmpty && !hopperAvatarIcons.containsKey(avatarUrl)) {
      final icon = await getMarkerIcon(avatarUrl, size);
      hopperAvatarIcons[avatarUrl] = icon;
      updated = true;
    }
  }
  if (updated) {
    setState(() {});
  }
}

void commonDialog(BuildContext context, String message, VoidCallback pressed) {
  var screenWidth = MediaQuery.of(context).size.width;
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            contentPadding: EdgeInsets.symmetric(
                horizontal: screenWidth * AppDimensions.numD04),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                          screenWidth * AppDimensions.numD015)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: screenWidth * AppDimensions.numD04,
                            right: screenWidth * AppDimensions.numD04,
                            top: screenWidth * AppDimensions.numD05),
                        child: Text(
                          message,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: screenWidth * AppDimensions.numD04),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(
                            top: screenWidth * AppDimensions.numD06,
                            left: screenWidth * AppDimensions.numD04,
                            right: screenWidth * AppDimensions.numD04,
                            bottom: screenWidth * AppDimensions.numD04),
                        child: ElevatedButton(
                          onPressed: pressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColorTheme.colorThemePink,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text(
                            "Ok",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * AppDimensions.numD04,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ));
      });
}

LatLng getTaskLatLng(TaskAssignedDetailEntity task) {
  final coords = task.addressLocation.coordinates;

  // GeoJSON format: [longitude, latitude]
  if (coords.length >= 2) {
    return LatLng(coords[1], coords[0]);
  }

  // fallback to direct lat/lng
  return LatLng(
    task.latitude ?? 0.0,
    task.longitude ?? 0.0,
  );
}

void broadcastDialog({
  required Size size,
  required TaskAssignedEntity taskDetail,
  required VoidCallback onTapViewDetails,
}) {
  if (_shownBroadcastIds.contains(taskDetail.task.id)) {
    return;
  }
  if (mapIcon == null) {
    getAllIcons();
  }
  _shownBroadcastIds.add(taskDetail.task.id);

  showDialog(
      context: navigatorKey.currentState!.context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              contentPadding: EdgeInsets.zero,
              insetPadding: EdgeInsets.symmetric(
                  horizontal: size.width * AppDimensions.numD04),
              content: StatefulBuilder(
                builder: (context, setState) {
                  final coords = taskDetail.task.addressLocation.coordinates;
                  final latitude = (coords.length >= 2)
                      ? coords[1]
                      : (taskDetail.task.latitude ?? 0.0);

                  final longitude = (coords.length >= 2)
                      ? coords[0]
                      : (taskDetail.task.longitude ?? 0.0);

                  final LatLng taskLatLng = LatLng(latitude, longitude);

                  // Load hopper avatars for markers
                  loadHopperAvatars(
                      taskDetail.task.activeHoppersLocations, setState);

                  return Container(
                    width: size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            size.width * AppDimensions.numD045)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// Heading
                        Padding(
                          padding: EdgeInsets.only(
                            left: size.width * AppDimensions.numD04,
                            right: size.width * AppDimensions.numD03,
                            top: size.width * AppDimensions.numD04,
                          ),
                          child: Row(
                            children: [
                              Text(
                                AppStrings.newBroadcastedTask.toTitleCase(),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: size.width * AppDimensions.numD04,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              SizedBox(
                                height: size.width * AppDimensions.numD07,
                                width: size.width * AppDimensions.numD07,
                                child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      if (player.state == PlayerState.playing) {
                                        player.stop();
                                      }
                                      context.pop();
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.black,
                                      size: size.width * AppDimensions.numD06,
                                    )),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * AppDimensions.numD04),
                          child: const Divider(
                            color: Colors.black,
                            thickness: 0.5,
                          ),
                        ),
                        SizedBox(
                          height: size.width * AppDimensions.numD02,
                        ),

                        /// Image, Title , des
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * AppDimensions.numD04),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        size.width * AppDimensions.numD04),
                                    border: Border.all(color: Colors.black)),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        size.width * AppDimensions.numD04),
                                    child: Image.network(
                                      taskDetail.task.mediaHouse.profileImage,
                                      height: size.width * AppDimensions.numD20,
                                      width: size.width * AppDimensions.numD20,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, object, stacktrace) {
                                        return Padding(
                                          padding: EdgeInsets.all(size.width *
                                              AppDimensions.numD02),
                                          child: Image.asset(
                                            "${commonImagePath}rabbitLogo.png",
                                            height: size.width *
                                                AppDimensions.numD20,
                                            width: size.width *
                                                AppDimensions.numD20,
                                          ),
                                        );
                                      },
                                    )),
                              ),
                              SizedBox(
                                width: size.width * AppDimensions.numD04,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: size.width * AppDimensions.numD01,
                                    ),

                                    /// Heading
                                    Text(
                                      taskDetail.task.heading,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: size.width *
                                              AppDimensions.numD035,
                                          fontWeight: FontWeight.w700),
                                    ),

                                    /// Description
                                    Text(
                                      taskDetail.task.description,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              size.width * AppDimensions.numD03,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// Left & Right Cards
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * AppDimensions.numD04,
                            vertical: size.width * AppDimensions.numD03,
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                /// Date/Time Card
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(
                                        size.width * AppDimensions.numD03),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7F7F7),
                                      borderRadius: BorderRadius.circular(
                                          size.width * AppDimensions.numD03),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                              "${iconsPath}ic_yearly_calendar.png",
                                              width: size.width *
                                                  AppDimensions.numD035,
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                                width: size.width *
                                                    AppDimensions.numD02),
                                            Text(
                                              dateTimeFormatter(
                                                dateTime: taskDetail
                                                    .task.createdAt
                                                    .toString(),
                                                format: "dd MMM yyyy",
                                              ),
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: size.width *
                                                    AppDimensions.numD03,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                            height: size.width *
                                                AppDimensions.numD015),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              size: size.width *
                                                  AppDimensions.numD035,
                                              color: Colors.black54,
                                            ),
                                            SizedBox(
                                                width: size.width *
                                                    AppDimensions.numD02),
                                            Text(
                                              "From : ${dateTimeFormatter(dateTime: taskDetail.task.createdAt.toString(), format: "hh:mm a")}",
                                              style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: size.width *
                                                    AppDimensions.numD028,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                            height: size.width *
                                                AppDimensions.numD01),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              size: size.width *
                                                  AppDimensions.numD035,
                                              color: Colors.black54,
                                            ),
                                            SizedBox(
                                                width: size.width *
                                                    AppDimensions.numD02),
                                            Text(
                                              "To      : ${dateTimeFormatter(dateTime: taskDetail.task.deadlineDate.toString(), format: "hh:mm a")}",
                                              style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: size.width *
                                                    AppDimensions.numD028,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    width: size.width * AppDimensions.numD03),

                                /// Location Card
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(
                                        size.width * AppDimensions.numD03),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7F7F7),
                                      borderRadius: BorderRadius.circular(
                                          size.width * AppDimensions.numD03),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: size.width *
                                                  AppDimensions.numD038,
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                                width: size.width *
                                                    AppDimensions.numD01),
                                            Expanded(
                                              child: Text(
                                                AppStrings.locationText
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: size.width *
                                                      AppDimensions.numD028,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                            height: size.width *
                                                AppDimensions.numD015),
                                        Text(
                                          taskDetail.task.location,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: size.width *
                                                AppDimensions.numD028,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: size.width * AppDimensions.numD02),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: size.width * AppDimensions.numD04),
                          height: size.width * 0.5,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                size.width * AppDimensions.numD03),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                size.width * AppDimensions.numD03),
                            child: Stack(
                              children: [
                                GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(
                                        (taskDetail.task.latitude ?? 0.0) != 0.0
                                            ? taskDetail.task.latitude!
                                            : 51.520412,
                                        (taskDetail.task.longitude ?? 0.0) != 0.0
                                            ? taskDetail.task.longitude!
                                            : -0.158022),
                                    zoom: 12,
                                  ),
                                  zoomControlsEnabled: false,
                                  myLocationButtonEnabled: false,
                                  mapToolbarEnabled: false,
                                  scrollGesturesEnabled: false,
                                  zoomGesturesEnabled: false,
                                  rotateGesturesEnabled: false,
                                  tiltGesturesEnabled: false,
                                  markers: {
                                    Marker(
                                      markerId: const MarkerId("task_location"),
                                      position: LatLng(
                                          (taskDetail.task.latitude ?? 0.0) != 0.0
                                              ? taskDetail.task.latitude!
                                              : 51.520412,
                                          (taskDetail.task.longitude ?? 0.0) != 0.0
                                              ? taskDetail.task.longitude!
                                              : -0.158022),
                                      anchor: const Offset(0.5, 0.5),
                                      zIndex: 0,
                                      icon: mapIcon ??
                                          BitmapDescriptor.defaultMarker,
                                    ),
                                    ...taskDetail.task.activeHoppersLocations
                                        .map((hopper) {
                                      return Marker(
                                        markerId: MarkerId(hopper.id.isNotEmpty
                                            ? hopper.id
                                            : "${hopper.latitude}_${hopper.longitude}"),
                                        position: LatLng(
                                            hopper.latitude, hopper.longitude),
                                        anchor: const Offset(0.5, 0.5),
                                        zIndex: 1,
                                        icon: hopperAvatarIcons[
                                                getMediaImageUrl(
                                                    hopper.avatar)] ??
                                            BitmapDescriptor.defaultMarker,
                                      );
                                    }).toSet(),
                                  },
                                ),
                                Positioned(
                                  bottom: size.width * AppDimensions.numD03,
                                  left: size.width * AppDimensions.numD03,
                                  right: size.width * AppDimensions.numD03,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            size.width * AppDimensions.numD03,
                                        vertical:
                                            size.width * AppDimensions.numD03),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          size.width * AppDimensions.numD02),
                                      // boxShadow: const [
                                      //   BoxShadow(
                                      //     color: Colors.black12,
                                      //     blurRadius: 4,
                                      //     offset: Offset(0, 2),
                                      //   ),
                                      // ],
                                    ),
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        text:
                                            "${taskDetail.task.activeHoppersCount} active Hoppers nearby. ",
                                        style: commonTextStyle(
                                            size: size,
                                            // fontSize: size.width * numD035,
                                            // color: Colors.black,
                                            // fontWeight: FontWeight.bold,
                                            fontSize: size.width *
                                                AppDimensions.numD03,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500),
                                        children: [
                                          TextSpan(
                                            text: "Grab it before it's gone.",
                                            style: commonTextStyle(
                                                size: size,
                                                // fontSize: size.width * numD035,
                                                color: AppColorTheme
                                                    .colorThemePink,
                                                // fontWeight: FontWeight.bold,
                                                fontSize: size.width *
                                                    AppDimensions.numD03,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: size.width * AppDimensions.numD02),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * AppDimensions.numD08,
                              vertical: size.width * AppDimensions.numD04),
                          decoration: BoxDecoration(
                              color: AppColorTheme.colorThemePink,
                              borderRadius: BorderRadius.circular(
                                  size.width * AppDimensions.numD04)),
                          child: GestureDetector(
                            onTap: onTapViewDetails,
                            child: Text(
                              "View Task $currencySymbol${formatDouble(double.tryParse(taskDetail.task.hopperTaskAmount) ?? 0.0)}",
                              style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD04,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: size.width * AppDimensions.numD02,
                        ),

                        /// Illustration
                        // Image.asset(
                        //   "assets/illustrations/priceimage2.png",
                        //   height: size.width * AppDimensions.numD25,
                        //   fit: BoxFit.contain,
                        // ),

                        // SizedBox(height: size.width * AppDimensions.numD05),

                        // /// Price and Hours
                        // RichText(
                        //   textAlign: TextAlign.center,
                        //   text: TextSpan(
                        //     children: [
                        //       TextSpan(
                        //         text:
                        //             "${taskDetail.task.currencySymbol.isNotEmpty ? taskDetail.task.currencySymbol : currencySymbol}${taskDetail.task.hopperTaskAmount} ",
                        //         style: TextStyle(
                        //           color: Colors.black,
                        //           fontSize: size.width * AppDimensions.numD07,
                        //           fontWeight: FontWeight.w800,
                        //         ),
                        //       ),
                        //       TextSpan(
                        //         text:
                        //             "for ${taskDetail.task.hopperInfo.first.hours } hours",
                        //         style: TextStyle(
                        //           color: Colors.black,
                        //           fontSize: size.width * AppDimensions.numD04,
                        //           fontWeight: FontWeight.w600,
                        //         ),
                        //       ),
                        //       // TextSpan(
                        //       //   text:
                        //       //       "for ${taskDetail.task.hopperInfo.isNotEmpty ? taskDetail.task.hopperInfo.first.hours : "0"} hours",
                        //       //   style: TextStyle(
                        //       //     color: Colors.black,
                        //       //     fontSize: size.width * AppDimensions.numD04,
                        //       //     fontWeight: FontWeight.w600,
                        //       //   ),
                        //       // ),
                        //     ],
                        //   ),
                        // ),

                        // SizedBox(height: size.width * AppDimensions.numD02),

                        // Padding(
                        // padding: EdgeInsets.symmetric(
                        //     horizontal: size.width * AppDimensions.numD04,
                        //     vertical: size.width * AppDimensions.numD04),
                        // child: SizedBox(
                        //   width: size.width,
                        //   height: size.width * AppDimensions.numD12,
                        //   child: commonElevatedButton(
                        //       "View Details",
                        //       size,
                        //       commonTextStyle(
                        //           size: size,
                        //           fontSize:
                        //               size.width * AppDimensions.numD035,
                        //           color: Colors.white,
                        //           fontWeight: FontWeight.w700),
                        //       commonButtonStyle(
                        //           size, AppColorTheme.colorThemePink),
                        //       onTapViewDetails),
                        // ),
                        // ),
                      ],
                    ),
                  );
                },
              )),
        );
      });
}

void commonErrorDialogDialog(
    Size size, String message, String errorCode, VoidCallback callback,
    {String actionButton = "Ok",
    bool isFromNetworkError = true,
    bool shouldShowClosedButton = true}) {
  showDialog(
      context: navigatorKey.currentState!.context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            contentPadding: EdgeInsets.zero,
            insetPadding: EdgeInsets.symmetric(
                horizontal: size.width * AppDimensions.numD04),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                          size.width * AppDimensions.numD045)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: size.width * AppDimensions.numD04,
                            top: size.width * AppDimensions.numD02),
                        child: Row(
                          children: [
                            Text(
                              isFromNetworkError
                                  ? "${AppStrings.errorDialogText} $errorCode!"
                                  : errorCode,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * AppDimensions.numD04,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            if (shouldShowClosedButton)
                              IconButton(
                                  onPressed: () {
                                    context.pop();
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.black,
                                    size: size.width * AppDimensions.numD06,
                                  ))
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * AppDimensions.numD04),
                        child: const Divider(
                          color: Colors.black,
                          thickness: 0.5,
                        ),
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD02,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * AppDimensions.numD04),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD04),
                              ),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      size.width * AppDimensions.numD04),
                                  child: Image.asset(
                                    "${commonImagePath}dog.png",
                                    height: size.width * AppDimensions.numD25,
                                    width: size.width * AppDimensions.numD35,
                                    fit: BoxFit.cover,
                                  )),
                            ),
                            SizedBox(
                              width: size.width * AppDimensions.numD04,
                            ),
                            Expanded(
                              child: Text(
                                message,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        size.width * AppDimensions.numD035,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD08,
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD12,
                        width: size.width * AppDimensions.numD35,
                        child: commonElevatedButton(
                            actionButton,
                            size,
                            commonButtonTextStyle(size),
                            commonButtonStyle(
                                size, AppColorTheme.colorThemePink),
                            callback),
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD05,
                      ),
                    ],
                  ),
                );
              },
            ));
      });
}

void onBoardingCompleteDialog({required Size size, required Function func}) {
  showDialog(
      context: navigatorKey.currentState!.context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            contentPadding: EdgeInsets.zero,
            insetPadding: EdgeInsets.symmetric(
                horizontal: size.width * AppDimensions.numD04),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                          size.width * AppDimensions.numD045)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: size.width * AppDimensions.numD02,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: size.width * AppDimensions.numD04),
                        child: Row(
                          children: [
                            Text(
                              "Complete your onboarding",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * AppDimensions.numD05,
                                  fontFamily: "AirbnbCereal",
                                  fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            IconButton(
                                onPressed: () {
                                  context.pop();
                                },
                                icon: Image.asset(
                                  "${iconsPath}cross.png",
                                  width: size.width * AppDimensions.numD065,
                                  height: size.width * AppDimensions.numD065,
                                  color: Colors.black,
                                ))
                          ],
                        ),
                      ),
                      const Divider(
                        color: Colors.black,
                        thickness: 0.5,
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD02,
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              left: size.width * AppDimensions.numD04,
                              right: size.width * AppDimensions.numD04),
                          child: RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                              text:
                                  "Please complete your pending onboarding process to register on ",
                              style: TextStyle(
                                  fontSize: size.width * AppDimensions.numD038,
                                  color: Colors.black,
                                  fontFamily: "AirbnbCereal",
                                  fontWeight: FontWeight.w400,
                                  height: 1.5),
                              children: [
                                TextSpan(
                                  text: "Press",
                                  style: TextStyle(
                                      fontSize:
                                          size.width * AppDimensions.numD038,
                                      color: Colors.black,
                                      fontFamily: "AirbnbCereal",
                                      fontWeight: FontWeight.w400,
                                      height: 1.5),
                                ),
                                TextSpan(
                                  text: "Hop",
                                  style: TextStyle(
                                      fontSize:
                                          size.width * AppDimensions.numD038,
                                      color: Colors.black,
                                      fontFamily: "AirbnbCereal",
                                      fontWeight: FontWeight.w400,
                                      height: 1.5),
                                )
                              ],
                            ),
                          )),
                      SizedBox(
                        height: size.width * AppDimensions.numD06,
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD13,
                        width: size.width * AppDimensions.numD45,
                        child: commonElevatedButton(
                            "Let's go",
                            size,
                            commonButtonTextStyle(size),
                            commonButtonStyle(
                                size, AppColorTheme.colorThemePink), () {
                          func();
                        }),
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD05,
                      ),
                    ],
                  ),
                );
              },
            ));
      });
}

void showSnackBar(String title, String message, Color color,
    {Duration duration = const Duration(seconds: 2)}) {
  Flushbar(
    title: title,
    message: message,
    duration: duration,
    backgroundColor: color,
    flushbarPosition: FlushbarPosition.TOP,
    titleColor: Colors.white,
    messageColor: Colors.white,
  ).show(navigatorKey.currentContext!);
}

void showLoaderDialog(BuildContext context) {
  if (alertDialog != null) {
    debugPrint("loader False:");
    context.pop();
  }
  alertDialog = AlertDialog(
    elevation: 0,
    backgroundColor: Colors.transparent,
    content: const Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          color: AppColorTheme.colorThemePink,
        ),
      ],
    ),
  );
  showDialog(
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    context: context,
    builder: (context) {
      return alertDialog!;
    },
  );
}
