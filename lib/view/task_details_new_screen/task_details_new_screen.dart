import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/Common.dart';
import '../../utils/CommonAppBar.dart';
import '../../utils/CommonModel.dart';
import '../../utils/CommonWigdets.dart';
import '../../utils/PermissionHandler.dart';
import '../../utils/countdownTimerScreen.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../../utils/networkOperations/NetworkResponse.dart';
import '../broadCastChatTaskScreen/broadCastChatTaskScreen.dart';
import '../chatScreens/FullVideoView.dart';
import '../dashboard/Dashboard.dart';
import '../myEarning/MyEarningScreen.dart';

class TaskDetailNewScreen extends StatefulWidget {
  String taskStatus = "";
  String taskId = "";
  String totalEarning = "";

  TaskDetailNewScreen(
      {super.key,
      required this.taskStatus,
      required this.taskId,
      required this.totalEarning});

  @override
  State<TaskDetailNewScreen> createState() => _TaskDetailNewScreenState();
}

class _TaskDetailNewScreenState extends State<TaskDetailNewScreen>
    implements NetworkResponse {
  TaskDetailModel? taskDetail;
  String roomId = "";
  bool isExtraTime = false;
  BitmapDescriptor? mapIcon;
  List<Marker> marker = [];

  LatLng? _latLng;
  bool isDirection = false;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  void initState() {
    getAllIcons();
    getCurrentLocation();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => taskDetailApi());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(
          taskDetailText,
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: size.width * appBarHeadingFontSize),
        ),
        centerTitle: false,
        titleSpacing: 0,
        size: size,
        showActions: true,
        leadingFxn: () {
          Navigator.pop(context);
        },
        actionWidget: [
          InkWell(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => Dashboard(initialPosition: 2)),
                  (route) => false);
            },
            child: Image.asset(
              "${commonImagePath}rabbitLogo.png",
              height: size.width * numD07,
              width: size.width * numD07,
            ),
          ),
          SizedBox(
            width: size.width * numD04,
          )
        ],
      ),
      body: taskDetail != null
          ? Padding(
              padding: EdgeInsets.all(size.width * numD028),
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Status Or Media House Name
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * numD01,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              taskDetail!.companyName.toUpperCase(),
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD036,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              widget.totalEarning == "0" &&
                                      widget.taskStatus == "accepted"
                                  ? "TASK ACCEPTED"
                                  : "COMPLETED",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD036,
                                  color: widget.taskStatus == "rejected"
                                      ? Colors.black
                                      : colorThemePink,
                                  fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: size.width * numD02,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: size.width * numD35,
                              child: Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.black),
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD042),
                                ),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD04),
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        GoogleMap(
                                          scrollGesturesEnabled: false,
                                          mapType: MapType.normal,
                                          initialCameraPosition: _kGooglePlex,
                                          markers: marker.map((e) => e).toSet(),
                                          onMapCreated:
                                              (GoogleMapController controller) {
                                            _controller.complete(controller);
                                          },
                                          compassEnabled: false,
                                          mapToolbarEnabled: false,
                                          zoomControlsEnabled: false,
                                          zoomGesturesEnabled: false,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(
                                              size.width * numD07),
                                          child: Image.asset(
                                            "${commonImagePath}ic_cover_radius.png",
                                          ),
                                        ),
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () {
                                            isDirection = false;
                                            setState(() {});
                                            openUrl();
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: size.width * numD06,
                                                vertical: size.width * numD018),
                                            decoration: BoxDecoration(
                                                color: colorThemePink,
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft: Radius.circular(
                                                      size.width * numD01),
                                                  bottomRight: Radius.circular(
                                                      size.width * numD02),
                                                )),
                                            child: Text(
                                              "Click the Map & GO",
                                              style: commonTextStyle(
                                                  size: size,
                                                  fontSize:
                                                      size.width * numD032,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        )
                                      ],
                                    )),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: size.width * numD03,
                          ),
                          Expanded(
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Container(
                                  height: size.width * numD35,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: colorGrey5,
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD04)),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: size.width * numD03,
                                      ),
                                      Text(
                                        isExtraTime
                                            ? "Extra time added"
                                            : isTimeOver()
                                                ? "Time over"
                                                : "Time remaining",
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width * numD035,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      FittedBox(
                                        child: Padding(
                                            padding: EdgeInsets.all(
                                                size.width * numD04),
                                            child: TimerCountdown(
                                              key: Key(taskDetail!.deadLine
                                                  .toString()),
                                              endTime: taskDetail!.deadLine,
                                              spacerWidth: 3,
                                              enableDescriptions: false,
                                              onEnd: () {
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) {
                                                  setState(() {
                                                    isExtraTime = isTimeOver()
                                                        ? false
                                                        : true;
                                                  });
                                                  if (!isTimeOver()) {
                                                    taskDetail!.deadLine =
                                                        taskDetail!.deadLine
                                                            .add(Duration(
                                                                hours: 3));
                                                  }
                                                });
                                              },
                                              countDownFormatter:
                                                  (day, hour, min, sec) {
                                                if (taskDetail!.deadLine
                                                        .difference(
                                                            DateTime.now())
                                                        .inDays >
                                                    0) {
                                                  //return "$day:$hour:$min:$sec";
                                                  return "${int.parse(day)}d:${hour}h:${min}m";
                                                } else if (taskDetail!.deadLine
                                                        .difference(
                                                            DateTime.now())
                                                        .inHours >
                                                    0) {
                                                  return "$hour:$min:$sec";
                                                } else {
                                                  return "$min:$sec";
                                                }
                                              },
                                              format: CountDownTimerFormat
                                                  .customFormats,
                                              timeTextStyle: commonTextStyle(
                                                  size: size,
                                                  fontSize: size.width * numD06,
                                                  color: widget.taskStatus ==
                                                          "accepted"
                                                      ? colorOnlineGreen
                                                      : colorThemePink,
                                                  fontWeight: FontWeight.w500),
                                            )),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size.width * numD07,
                                      vertical: size.width * numD018),
                                  decoration: BoxDecoration(
                                      color: colorThemePink,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(
                                            size.width * numD04),
                                        bottomRight: Radius.circular(
                                            size.width * numD04),
                                      )),
                                  child: Center(
                                    child: Text(
                                      "Deadline ${dateTimeFormatter(dateTime: taskDetail!.deadLine.toString(), format: "hh:mm a").toLowerCase()}",
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD032,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: size.width * numD04,
                      ),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Time Date
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: size.width * numD045,
                                    ),
                                    SizedBox(
                                      width: size.width * numD018,
                                    ),
                                    Text(
                                        dateTimeFormatter(
                                            dateTime: taskDetail!.createdAt,
                                            format: "hh:mm a"),
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width * numD03,
                                            color: colorHint,
                                            fontWeight: FontWeight.w500)),
                                    SizedBox(
                                      width: size.width * numD02,
                                    ),
                                    Icon(
                                      Icons.calendar_month,
                                      size: size.width * numD045,
                                    ),
                                    SizedBox(
                                      width: size.width * numD018,
                                    ),
                                    Text(
                                        dateTimeFormatter(
                                            dateTime: taskDetail!.createdAt,
                                            format: "dd MMM yyyy"),
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width * numD03,
                                            color: colorHint,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                SizedBox(
                                  height: size.width * numD025,
                                ),

                                /// Location
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: size.width * numD045,
                                    ),
                                    SizedBox(
                                      width: size.width * numD02,
                                    ),
                                    Expanded(
                                      child: Text(
                                        taskDetail!.location,
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width * numD028,
                                            color: colorHint,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: size.width * numD025,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: size.width * numD045,
                                    ),
                                    SizedBox(
                                      width: size.width * numD02,
                                    ),
                                    Text(
                                      "20 miles",
                                      overflow: TextOverflow.ellipsis,
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD028,
                                          color: colorHint,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(
                                      width: size.width * numD018,
                                    ),
                                    Container(
                                      width: 1,
                                      height: size.width * numD04,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(
                                      width: size.width * numD02,
                                    ),
                                    Icon(
                                      Icons.directions_walk_rounded,
                                      size: size.width * numD045,
                                    ),
                                    SizedBox(
                                      width: size.width * numD01,
                                    ),
                                    Text(
                                      "34 mins",
                                      overflow: TextOverflow.ellipsis,
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD028,
                                          color: colorHint,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(
                                      width: size.width * numD01,
                                    ),
                                    Container(
                                      width: 1,
                                      height: size.width * numD04,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(
                                      width: size.width * numD02,
                                    ),
                                    Icon(
                                      Icons.directions_car,
                                      size: size.width * numD045,
                                    ),
                                    SizedBox(
                                      width: size.width * numD01,
                                    ),
                                    Text(
                                      "3 mins",
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD028,
                                          color: colorHint,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: size.width * numD02,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: size.width * numD075,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: size.width * numD025,
                      ),

                      const Divider(
                        thickness: 1,
                        color: colorGreyChat,
                      ),

                      Text("HEADING",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w500)),
                      SizedBox(
                        height: size.width * numD018,
                      ),
                      Text(
                        taskDetail!.title,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD04,
                            color: Colors.black,
                            lineHeight: 1.5,
                            fontWeight: FontWeight.w700),
                      ),

                      SizedBox(
                        height: size.width * numD06,
                      ),
                      Text("DESCRIPTION",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w500)),
                      SizedBox(
                        height: size.width * numD018,
                      ),

                      Text(taskDetail!.description,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD03,
                              color: Colors.black,
                              lineHeight: 2,
                              fontWeight: FontWeight.normal)),

                      SizedBox(
                        height: size.width * numD06,
                      ),

                      taskDetail!.specialReq.isNotEmpty
                          ? Text("SPECIAL REQUIREMENTS",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500))
                          : Container(),
                      SizedBox(
                        height: taskDetail!.specialReq.isNotEmpty
                            ? size.width * numD025
                            : 0,
                      ),

                      taskDetail!.specialReq.isNotEmpty
                          ? Text(taskDetail!.specialReq,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD03,
                                  color: Colors.black,
                                  lineHeight: 2,
                                  fontWeight: FontWeight.normal))
                          : Container(),

                      SizedBox(
                        height: taskDetail!.specialReq.isNotEmpty
                            ? size.width * numD025
                            : 0,
                      ),

                      const Divider(
                        thickness: 1,
                        color: colorGreyChat,
                      ),

                      SizedBox(
                        height: size.width * numD025,
                      ),

                      Text("PRICE OFFERED",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w500)),
                      SizedBox(
                        height: size.width * numD05,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(
                                    taskDetail!.isNeedPhoto
                                        ? "$euroUniqueCode${formatDouble(double.parse(taskDetail!.photoPrice))}"
                                        : "-",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD058,
                                        color: colorThemePink,
                                        fontWeight: FontWeight.w800)),
                                Text("Offered",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD035,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500)),
                                SizedBox(
                                  height: size.width * numD018,
                                ),
                                Container(
                                  width: size.width * numD26,
                                  padding: EdgeInsets.symmetric(
                                      vertical: size.width * numD02),
                                  decoration: BoxDecoration(
                                      color: colorThemePink,
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD02)),
                                  child: Center(
                                      child: Text("PHOTO",
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD035,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500))),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                    taskDetail!.isNeedInterview
                                        ? "$euroUniqueCode${formatDouble(double.parse(taskDetail!.interviewPrice))}"
                                        : "-",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD058,
                                        color: colorThemePink,
                                        fontWeight: FontWeight.w800)),
                                Text("Offered",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD035,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500)),
                                SizedBox(
                                  height: size.width * numD018,
                                ),
                                Container(
                                  width: size.width * numD26,
                                  padding: EdgeInsets.symmetric(
                                      vertical: size.width * numD02),
                                  decoration: BoxDecoration(
                                      color: colorThemePink,
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD02)),
                                  child: Center(
                                      child: Text("INTERVIEW",
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD035,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500))),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                    taskDetail!.isNeedVideo
                                        ? "$euroUniqueCode${formatDouble(double.parse(taskDetail!.videoPrice))}"
                                        : "-",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD058,
                                        color: colorThemePink,
                                        fontWeight: FontWeight.w800)),
                                Text("Offered",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD035,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500)),
                                SizedBox(
                                  height: size.width * numD018,
                                ),
                                Container(
                                  width: size.width * numD26,
                                  padding: EdgeInsets.symmetric(
                                      vertical: size.width * numD02),
                                  decoration: BoxDecoration(
                                      color: colorThemePink,
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD02)),
                                  child: Center(
                                      child: Text("VIDEO",
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD035,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500))),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: size.width * numD025,
                      ),

                      const Divider(
                        thickness: 1,
                        color: colorGreyChat,
                      ),
                      SizedBox(
                        height: size.width * numD025,
                      ),

                      taskDetail!.mediaList.isNotEmpty
                          ? Text("UPLOADED CONTENT",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500))
                          : Container(),
                      SizedBox(
                        height: taskDetail!.mediaList.isNotEmpty
                            ? size.width * numD05
                            : 0,
                      ),

                      GridView.builder(
                        itemCount: taskDetail!.mediaList.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: size.width * numD035,
                            crossAxisSpacing: size.width * numD018),
                        itemBuilder: (context, index) {
                          var item = taskDetail!.mediaList[index];
                          debugPrint("item.type::::${item.type}");
                          return Stack(
                            children: [
                              InkWell(
                                onTap: () {
                                  if (item.type == "video") {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MediaViewScreen(
                                                  mediaFile: taskMediaUrl +
                                                      item.imageVideoUrl,
                                                  type: MediaTypeEnum.video,
                                                )));
                                  } else if (item.type == "audio") {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MediaViewScreen(
                                                  mediaFile: taskMediaUrl +
                                                      item.imageVideoUrl,
                                                  type: MediaTypeEnum.audio,
                                                )));
                                  } else {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MediaViewScreen(
                                                  mediaFile: taskMediaUrl +
                                                      item.imageVideoUrl,
                                                  type: MediaTypeEnum.image,
                                                )));
                                  }
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD028),
                                  child: item.type == "audio"
                                      ? Container(
                                          height: double.infinity,
                                          width: size.width / 2,
                                          decoration: BoxDecoration(
                                              color: colorThemePink,
                                              border: Border.all(
                                                  color: colorGreyNew),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size.width * numD028)),
                                          child: Icon(
                                            Icons.play_arrow_rounded,
                                            color: Colors.white,
                                            size: size.width * 0.17,
                                          ))
                                      : item.type == "video"
                                          ? Image.network(
                                              item.thumbnail,
                                              width: size.width / 2,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Image.asset(
                                                  '${dummyImagePath}placeholderImage.png',
                                                  width: size.width / 2,
                                                  height: double.infinity,
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            )
                                          : Image.network(
                                              taskMediaUrl + item.imageVideoUrl,
                                              width: size.width / 2,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Image.asset(
                                                  '${dummyImagePath}placeholderImage.png',
                                                  width: size.width / 2,
                                                  height: double.infinity,
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            ),
                                ),
                              ),
                              Positioned(
                                right: size.width * numD01,
                                top: size.width * numD01,
                                child: item.type != "audio"
                                    ? Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: size.width * numD006,
                                            vertical: size.width * numD002),
                                        decoration: BoxDecoration(
                                            color: colorLightGreen
                                                .withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(
                                                size.width * numD01)),
                                        child: Icon(
                                          item.type == "video"
                                              ? Icons.videocam_outlined
                                              : Icons.camera_alt_outlined,
                                          size: size.width * numD035,
                                          color: Colors.white,
                                        ))
                                    : Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: size.width * numD008,
                                            vertical: size.width * numD005),
                                        decoration: BoxDecoration(
                                            color: colorLightGreen
                                                .withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(
                                                size.width * numD01)),
                                        child: Image.asset(
                                          "${iconsPath}ic_mic1.png",
                                          fit: BoxFit.cover,
                                          height: size.width * numD025,
                                          width: size.width * numD025,
                                        ),
                                      ),
                              ),
                              /*  item.type == "video"
                                  ? Positioned(
                                      right: size.width * numD01,
                                      top: size.width * numD18,
                                      bottom: 0,
                                      child: Text("02:22",
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD025,
                                              color: Colors.white,
                                              fontWeight: FontWeight.normal)),
                                    )
                                  : Container(),*/
                            ],
                          );
                        },
                      ),

                      SizedBox(
                        height: size.width * numD1,
                      ),

                      widget.taskStatus != "rejected"
                          ? GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (context) =>
                                            BroadCastChatTaskScreen(
                                              taskDetail: taskDetail!,
                                              roomId: roomId,
                                            )))
                                    .then((value) => taskDetailApi());
                              },
                              child: SizedBox(
                                height: size.width * numD13,
                                width: size.width,
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      height: size.width * numD13,
                                      width: size.width,
                                      child: Shimmer.fromColors(
                                        period: Duration(seconds: 4),
                                        baseColor: colorThemePink,
                                        highlightColor: Colors.white,
                                        child: commonElevatedButton(
                                            manageTaskText,
                                            size,
                                            commonButtonTextStyle(size),
                                            commonButtonStyle(
                                                size, Colors.white), () {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                                  builder: (context) =>
                                                      BroadCastChatTaskScreen(
                                                        taskDetail: taskDetail!,
                                                        roomId: roomId,
                                                      )))
                                              .then((value) => taskDetailApi());
                                        }),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        manageTaskText,
                                        style: commonButtonTextStyle(size),
                                        selectionColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              width: size.width,
                              height: size.width * numD14,
                              margin: EdgeInsets.symmetric(
                                  horizontal: size.width * numD04),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              size.width * numD04))),
                                  onPressed: () {},
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        youHaveEarnedText,
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width * numD035,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Text(
                                        "${euroUniqueCode}0",
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width * numD065,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  )),
                            ),

                      SizedBox(
                        height: size.width * numD02,
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * numD02),
                        child: RichText(
                            textAlign: TextAlign.justify,
                            text: TextSpan(
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD03,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400),
                                children: [
                                  const TextSpan(
                                    text: "Click",
                                  ),
                                  TextSpan(
                                      text: " Manage Tasks",
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD03,
                                          color: colorThemePink,
                                          fontWeight: FontWeight.w400)),
                                  const TextSpan(
                                    text:
                                        " to view your active assignments, track deadlines, upload photos and videos, and monitor your earnings—all in one place!",
                                  )
                                ])),
                      ),

                      SizedBox(
                        height: size.height * numD02,
                      ),

                      // Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: size.width * numD06),
                      //   child: RichText(
                      //       textAlign: TextAlign.justify,
                      //       text: TextSpan(style: commonTextStyle(size: size, fontSize: size.width * numD03, color: Colors.black, fontWeight: FontWeight.w400), children: [
                      //         const TextSpan(
                      //           text: "Press 'Manage Content' to view any offers, and sell your content to the press. You can also easily track your earnings and monitor pending and received payments - all in one place.",
                      //         )
                      //       ])),
                      // )
                    ]),
              ),
            )
          : showLoader(),
    );
  }

  /// Initialize Map icon
  void getAllIcons() async {
    mapIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(5, 5)),
        "${commonImagePath}ic_cover_radius.png");
  }

  /// Update Map Location
  Future<void> _updateGoogleMap(LatLng latLng) async {
    final GoogleMapController controller = await _controller.future;
    marker.add(Marker(
      markerId: const MarkerId("1"),
      position: latLng,
      icon: mapIcon!,
    ));
    controller.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(latLng.latitude, latLng.longitude), 14));
    setState(() {});
  }

  /// Current Lat Lng
  void getCurrentLocation() async {
    bool serviceEnable = await checkGps();
    bool locationEnable = await locationPermission();
    if (serviceEnable && locationEnable) {
      LocationData loc = await Location.instance.getLocation();
      setState(() {
        _latLng = LatLng(loc.latitude!, loc.longitude!);
        debugPrint("_longitude: $_latLng");
      });
    } else {
      showSnackBar(
          "Permission Denied", "Please Allow Location permission", Colors.red);
    }
  }

  openUrl() async {
    String googleUrl = isDirection
        ? 'https://www.google.com/maps/dir/?api=1&origin=${_latLng!.latitude},'
            '${_latLng!.longitude}&destination=${taskDetail!.latitude},'
            '${taskDetail!.longitude}&travelmode=driving&dir_action=navigate'
        : 'https://www.google.com/maps/search/?api=1&query=${taskDetail!.latitude},${taskDetail!.longitude}';

    String appleUrl = isDirection
        ? 'http://maps.apple.com/maps?saddr=${_latLng!.latitude},'
            '${_latLng!.longitude}&daddr=${taskDetail!.latitude},'
            '${taskDetail!.longitude}'
        : 'http://maps.apple.com/?q=${taskDetail!.latitude},'
            '${taskDetail!.longitude}';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      debugPrint('launching com googleUrl');
      await launchUrl(Uri.parse(googleUrl),
          mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(Uri.parse(appleUrl))) {
      debugPrint('launching apple url');
      await launchUrl(Uri.parse(appleUrl),
          mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch url';
    }
  }

  bool isTimeOver() {
    var extraTime = taskDetail!.deadLine.add(Duration(hours: 3));
    if (extraTime.difference(DateTime.now()).inSeconds < 0) {
      return true;
    }
    return false;
  }

  void taskDetailApi() {
    NetworkClass("$taskDetailUrl${widget.taskId}", this, taskDetailUrlRequest)
        .callRequestServiceHeader(false, "get", null);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case taskDetailUrlRequest:
          {
            var data = jsonDecode(response);
            debugPrint("taskDetailUrlRequest Error : $data");
            break;
          }
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case taskDetailUrlRequest:
          {
            var data = jsonDecode(response);
            debugPrint("taskDetailUrlRequest Success : $data");
            taskDetail = TaskDetailModel.fromJson(data["task"] ?? {});
            debugPrint("taskDetail id::: ${taskDetail!.id}");
            //_updateGoogleMap(LatLng(taskDetail!.latitude, taskDetail!.longitude));
            if (data["resp"] != null) {
              roomId = (data["resp"]["room_id"] ?? "").toString();
              debugPrint("Room Id task Manager : $roomId");
            }
            if (mounted) {
              setState(() {});
            }
            break;
          }
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }
}
