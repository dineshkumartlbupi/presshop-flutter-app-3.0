import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:presshop/view/menuScreen/ManageTaskScreen.dart';
import 'package:presshop/view/myEarning/MyEarningScreen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/Common.dart';
import '../../utils/CommonAppBar.dart';
import '../../utils/CommonModel.dart';
import '../../utils/PermissionHandler.dart';
import '../../utils/countdownTimerScreen.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../boardcastScreen/BroardcastScreen.dart';
import '../cameraScreen/imagePreview.dart';
import '../chatScreens/FullVideoView.dart';
import '../dashboard/Dashboard.dart';
import 'MyTaskScreen.dart';

class TaskDetailScreen extends StatefulWidget {
  String taskStatus = "";
  String taskId = "";
  String totalEarning = "";

  TaskDetailScreen(
      {super.key,
      required this.taskStatus,
      required this.taskId,
      required this.totalEarning});

  @override
  State<StatefulWidget> createState() {
    return TaskDetailScreenState();
  }
}

class TaskDetailScreenState extends State<TaskDetailScreen>
    implements NetworkResponse {
  late Size size;
  TaskDetailModel? taskDetail;
  String roomId = "";
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
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => taskDetailApi());
    debugPrint("TaskDetailScreen: Running");
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
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
          ? SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.only(top: size.width * numD04),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * numD04),
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
                                taskDetail!.mediaHouseName,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD036,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                widget.totalEarning == "0" &&
                                        widget.taskStatus == "accepted"
                                    ? widget.taskStatus.toUpperCase()
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

                        /// Map or Timer
                        widget.taskStatus != "rejected"
                            ? Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: size.width * numD35,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1, color: Colors.black),
                                          borderRadius: BorderRadius.circular(
                                              size.width * numD04),
                                        ),
                                        child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                size.width * numD04),
                                            child: Stack(
                                              children: [
                                                GoogleMap(
                                                  scrollGesturesEnabled: false,
                                                  mapType: MapType.normal,
                                                  initialCameraPosition:
                                                      _kGooglePlex,
                                                  markers: marker
                                                      .map((e) => e)
                                                      .toSet(),
                                                  onMapCreated:
                                                      (GoogleMapController
                                                          controller) {
                                                    _controller
                                                        .complete(controller);
                                                  },
                                                  compassEnabled: false,
                                                  mapToolbarEnabled: false,
                                                  zoomControlsEnabled: false,
                                                  zoomGesturesEnabled: false,
                                                ),
                                                Positioned.fill(child: InkWell(
                                                  onTap: () {
                                                    isDirection = false;
                                                    setState(() {});
                                                    openUrl();
                                                  },
                                                ))
                                              ],
                                            )),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: size.width * numD05,
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: size.width * numD35,
                                      decoration: BoxDecoration(
                                          color: colorGrey5,
                                          borderRadius: BorderRadius.circular(
                                              size.width * numD04)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                              padding: EdgeInsets.all([
                                                "accepted",
                                                "Delayed"
                                              ].contains(widget.taskStatus)
                                                  ? 0
                                                  : size.width * numD04),
                                              decoration: BoxDecoration(
                                                  color: [
                                                    "accepted",
                                                    "Delayed"
                                                  ].contains(widget.taskStatus)
                                                      ? Colors.transparent
                                                      : colorThemePink,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          size.width * numD04)),
                                              child: widget.taskStatus ==
                                                          "Delayed" ||
                                                      widget.taskStatus ==
                                                              "accepted" &&
                                                          widget.totalEarning == "0"
                                                  ? TimerCountdown(
                                                      endTime:
                                                          taskDetail!.deadLine,
                                                      spacerWidth: 3,
                                                      enableDescriptions: false,
                                                      countDownFormatter: (day,
                                                          hour, min, sec) {
                                                        if (taskDetail!.deadLine
                                                                .difference(
                                                                    DateTime
                                                                        .now())
                                                                .inDays >
                                                            0) {
                                                          //return "$day:$hour:$min:$sec";
                                                          return "${day}d:${hour}h:${min}m";
                                                        } else if (taskDetail!
                                                                .deadLine
                                                                .difference(
                                                                    DateTime
                                                                        .now())
                                                                .inHours >
                                                            0) {
                                                          return "${hour}h:${min}m:${sec}s";
                                                        } else {
                                                          return "$min:$sec";
                                                        }
                                                      },
                                                      format:
                                                          CountDownTimerFormat
                                                              .customFormats,
                                                      timeTextStyle:
                                                          commonTextStyle(
                                                              size: size,
                                                              fontSize: /*!taskDetail!
                                                                      .deadLine
                                                                      .difference(
                                                                          DateTime
                                                                              .now())
                                                                      .inDays >
                                                                  0
                                                              ? size.width *
                                                                  numD07
                                                              :*/
                                                                  size.width *
                                                                      numD055,
                                                              color: widget
                                                                          .taskStatus ==
                                                                      "accepted"
                                                                  ? colorOnlineGreen
                                                                  : colorThemePink,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                    ) /*Text(
                                                CountD,
                                                style: commonTextStyle(
                                                    size: size,
                                                    fontSize:
                                                        size.width * numD095,
                                                    color: widget.taskStatus ==
                                                            "accepted"
                                                        ? Colors.green
                                                        : colorThemePink,
                                                    fontWeight: FontWeight.w600),
                                              )*/
                                                  : Container(
                                                      padding: EdgeInsets.all(
                                                          size.width * numD02),
                                                      decoration: BoxDecoration(
                                                          color: colorThemePink,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(size
                                                                          .width *
                                                                      numD02)),
                                                      child: Icon(
                                                        Icons.check,
                                                        color: Colors.black,
                                                        size:
                                                            size.width * numD09,
                                                      ),
                                                    )),
                                          SizedBox(
                                            height:
                                                widget.taskStatus == "Delayed"
                                                    ? 0
                                                    : size.width * numD02,
                                          ),
                                          Text(
                                            widget.taskStatus == "Delayed"
                                                ? "delay"
                                                : widget.taskStatus ==
                                                            "accepted" &&
                                                        widget.totalEarning ==
                                                            '0'
                                                    ? "time remaining"
                                                    : "On time",
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD035,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              )
                            : Container(),
                        SizedBox(
                          height: widget.taskStatus != "rejected"
                              ? size.width * numD04
                              : 0,
                        ),

                        /// Location
                        widget.taskStatus != "rejected"
                            ? Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                              "${iconsPath}ic_location.png",
                                              height: size.width * numD05,
                                              color: colorTextFieldIcon,
                                            ),
                                            SizedBox(
                                              width: size.width * numD02,
                                            ),
                                            Text(
                                              locationText,
                                              style: commonTextStyle(
                                                  size: size,
                                                  fontSize:
                                                      size.width * numD035,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600),
                                            )
                                          ],
                                        ),

                                        /// Location
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: size.width * numD01,
                                              left: size.width * numD01),
                                          child: Text(
                                            taskDetail!.location,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD03,
                                                color: Colors.black,
                                                fontWeight: FontWeight.normal),
                                            textAlign: TextAlign.start,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: size.width * numD05,
                                  ),

                                  /*  commonElevatedButton(
                                "Go",
                                size,
                                commonButtonTextStyle(size),
                                commonButtonStyle(size, colorThemePink),
                                    () {

                                }),*/
                                  Expanded(
                                    child: widget.taskStatus == "accepted" &&
                                            widget.totalEarning == "0"
                                        ? SizedBox(
                                            height: size.width * numD1,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                isDirection = true;
                                                setState(() {});
                                                openUrl();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      colorThemePink,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              size.width *
                                                                  numD04))),
                                              child: Text(
                                                'Go',
                                                style: TextStyle(
                                                    fontSize:
                                                        size.width * numD033),
                                              ),
                                            ))
                                        : Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: size.width * numD06,
                                                vertical: size.width * numD01),
                                            decoration: BoxDecoration(
                                                color: colorLightGrey,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        size.width * numD03)),
                                            child: Column(
                                              children: [
                                                Text(
                                                  youHaveEarnedText,
                                                  maxLines: 4,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: commonTextStyle(
                                                      size: size,
                                                      fontSize:
                                                          size.width * numD035,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                                Text(
                                                  "$euroUniqueCode${widget.totalEarning}",
                                                  maxLines: 4,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: commonTextStyle(
                                                      size: size,
                                                      fontSize:
                                                          size.width * numD06,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                  )
                                ],
                              )
                            : Container(),
                        SizedBox(
                          height: widget.taskStatus != "rejected"
                              ? size.width * numD04
                              : 0,
                        ),
                        widget.taskStatus != "rejected"
                            ? const Divider(
                                color: colorGrey1,
                              )
                            : Container(),
                        SizedBox(
                          height: widget.taskStatus != "rejected"
                              ? size.width * numD04
                              : 0,
                        ),

                        /// Title
                        Text(
                          taskDetail!.title,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD04,
                              color: Colors.black,
                              lineHeight: 1.5,
                              fontWeight: FontWeight.w600),
                        ),

                        SizedBox(
                          height: size.width * numD02,
                        ),

                        /// Description
                        Text(
                          taskDetail!.description,
                          textAlign: TextAlign.justify,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD03,
                              color: Colors.black,
                              lineHeight: 2,
                              fontWeight: FontWeight.normal),
                        ),

                        SizedBox(
                          height: taskDetail!.specialReq.isNotEmpty
                              ? size.width * numD01
                              : 0,
                        ),

                        /// Special Requirement
                        Text(
                          taskDetail!.specialReq,
                          textAlign: TextAlign.justify,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD03,
                              color: Colors.black,
                              lineHeight: 2,
                              fontWeight: FontWeight.normal),
                        ),
                        SizedBox(
                          height: taskDetail!.specialReq.isNotEmpty
                              ? size.width * numD09
                              : 0,
                        ),

                        /// Price Offer
                        Visibility(
                            visible: widget.taskStatus != "rejected",
                            child: priceOfferWidget()),

                        SizedBox(
                          height: size.width * numD04,
                        ),

                        /// Uploaded Content
                        widget.taskStatus != "rejected" &&
                                widget.taskStatus != "Delayed" &&
                                taskDetail!.mediaList.isNotEmpty
                            ? Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * numD04,
                                    vertical: size.width * numD04),
                                decoration: BoxDecoration(
                                    color: colorLightGrey,
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD04)),
                                child: Column(
                                  children: [
                                    Text(
                                      uploadedContentText,
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD035,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(
                                      height: size.width * numD04,
                                    ),
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 4,
                                              mainAxisSpacing:
                                                  size.width * numD04,
                                              crossAxisSpacing:
                                                  size.width * numD04),
                                      itemBuilder: (context, index) {
                                        var item = taskDetail!.mediaList[index];
                                        return InkWell(
                                          onTap: () {
                                            if (item.type == "video") {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          MediaViewScreen(
                                                            mediaFile:
                                                                taskMediaUrl +
                                                                    item.imageVideoUrl,
                                                            type: MediaTypeEnum
                                                                .video,
                                                          )));
                                            } else if (item.type == "audio") {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          MediaViewScreen(
                                                            mediaFile:
                                                                taskMediaUrl +
                                                                    item.imageVideoUrl,
                                                            type: MediaTypeEnum
                                                                .audio,
                                                          )));
                                            } else {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ImagePreview(
                                                            imageURL: taskMediaUrl +
                                                                item.imageVideoUrl,
                                                          )));
                                            }
                                          },
                                          child: Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        size.width * numD04),
                                                child: item.type == "audio"
                                                    ? Container(
                                                        height:
                                                            size.width * 0.2,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  colorGreyNew),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(size
                                                                          .width *
                                                                      numD04),
                                                        ),
                                                        child: Icon(
                                                          Icons.play_circle,
                                                          color: colorThemePink,
                                                          size:
                                                              size.width * 0.17,
                                                        ))
                                                    : Image.network(
                                                        (item.type == "video"
                                                            ? mediaThumbnailUrl +
                                                                item
                                                                    .imageVideoUrl
                                                            : taskMediaUrl +
                                                                item.imageVideoUrl),
                                                        width: size.width / 2,
                                                        height: double.infinity,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          return Image.asset(
                                                            '${dummyImagePath}placeholderImage.png',
                                                            width:
                                                                size.width / 2,
                                                            height:
                                                                double.infinity,
                                                            fit: BoxFit.cover,
                                                          );
                                                        },
                                                      ),
                                              ),
                                              Positioned(
                                                right: size.width * numD02,
                                                top: size.width * numD02,
                                                child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: size
                                                                    .width *
                                                                numD01,
                                                            vertical:
                                                                size
                                                                        .width *
                                                                    0.002),
                                                    decoration: BoxDecoration(
                                                        color: colorLightGreen
                                                            .withOpacity(0.8),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(size
                                                                        .width *
                                                                    numD015)),
                                                    child: Icon(
                                                      item.type == "audio"
                                                          ? Icons.audiotrack
                                                          : item.type == "video"
                                                              ? Icons
                                                                  .videocam_outlined
                                                              : Icons
                                                                  .camera_alt_outlined,
                                                      size: size.width * numD05,
                                                      color: Colors.white,
                                                    )),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      itemCount: taskDetail!.mediaList.length,
                                    ),
                                  ],
                                ),
                              )
                            : Container(),

                        SizedBox(
                          height: size.width * numD1,
                        ),

                        widget.taskStatus != "rejected"
                            ? Container(
                                width: size.width,
                                height: size.width * numD13,
                                margin: EdgeInsets.symmetric(
                                    horizontal: size.width * numD04),
                                child: commonElevatedButton(
                                    manageTaskText,
                                    size,
                                    commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD035,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700),
                                    commonButtonStyle(size, colorThemePink),
                                    () {
                                  debugPrint(
                                      "taskDetail:::::::${taskDetail!.title}");
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) =>
                                              ManageTaskScreen(
                                                taskDetail: taskDetail!,
                                                roomId: roomId,
                                                type: 'task_content',
                                              )))
                                      .then((value) => taskDetailApi());
                                }),
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
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        MyEarningScreen(openDashboard: false)));
                              },
                              child: Text(
                                viewYourEarnings,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD036,
                                    color: colorThemePink,
                                    fontWeight: FontWeight.w500),
                              )),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  /// Price Offer widget
  Widget priceOfferWidget() {
    return Column(
      children: [
        const Divider(
          color: colorGrey1,
        ),
        SizedBox(
          height: size.width * numD05,
        ),

        /// Price Offer
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    taskDetail!.isNeedPhoto
                        ? "$euroUniqueCode${taskDetail!.photoPrice}"
                        : "-",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD06,
                        color: colorThemePink,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    offeredText,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: colorHint,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * numD04,
                        vertical: size.width * numD02),
                    decoration: BoxDecoration(
                        color: colorLightGrey,
                        borderRadius:
                            BorderRadius.circular(size.width * numD02)),
                    child: Text(
                      photoText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    taskDetail!.isNeedInterview
                        ? "$euroUniqueCode${taskDetail!.interviewPrice}"
                        : "-",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD06,
                        color: colorThemePink,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    offeredText,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: colorHint,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * numD04,
                        vertical: size.width * numD02),
                    decoration: BoxDecoration(
                        color: colorLightGrey,
                        borderRadius:
                            BorderRadius.circular(size.width * numD02)),
                    child: Text(
                      interviewText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    taskDetail!.isNeedVideo
                        ? "$euroUniqueCode${taskDetail!.videoPrice}"
                        : "-",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD06,
                        color: colorThemePink,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    offeredText,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: colorHint,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * numD04,
                        vertical: size.width * numD02),
                    decoration: BoxDecoration(
                        color: colorLightGrey,
                        borderRadius:
                            BorderRadius.circular(size.width * numD02)),
                    child: Text(
                      videoText,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),

        SizedBox(
          height: size.width * numD05,
        ),

        const Divider(
          color: colorGrey1,
        ),
      ],
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

  ///--------Apis Section------------

  void taskDetailApi() {
    NetworkClass("$taskDetailUrl${widget.taskId}", this, taskDetailUrlRequest)
        .callRequestServiceHeader(true, "get", null);
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
            debugPrint("taskDetailUrlRequest 1 Success : $data");
            taskDetail = TaskDetailModel.fromJson(data["task"] ?? {});
            debugPrint("taskDetail id::: ${taskDetail!.id}");
            _updateGoogleMap(
                LatLng(taskDetail!.latitude, taskDetail!.longitude));
            if (data["resp"] != null) {
              roomId = (data["resp"]["room_id"] ?? "").toString();
              debugPrint("Room Id task Manager : $roomId");
            }
            if (data["code"] == 200 && data["task"] != null) {
              var broadCastedData = TaskDetailModel.fromJson(data["task"]);
              debugPrint("taskDetailUrlRequest: 2 $broadCastedData");
              broadcastDialog(
                size: MediaQuery.of(context).size,
                taskDetail: broadCastedData,
                onTapView: () {
                  /// --------------------------------------------------------------------
                  // if (mounted) {
                  //   if (dashBoardInterface != null) {
                  //     dashBoardInterface!.saveDraft();
                  //   }
                  // } else {
                  //   debugPrint('Unmounted:::::dashBoardInterface');
                  // }
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => BroadCastScreen(
                            taskId: broadCastedData.id,
                            mediaHouseId: broadCastedData.mediaHouseId,
                          )));

                  /// --------------------------------------------------------------------
                  /// --------------------------------------------------------------------
                },
              );
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
