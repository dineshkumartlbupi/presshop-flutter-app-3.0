import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:presshop/core/constants/string_constants.dart';
import 'package:presshop/core/constants/string_constants_new2.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:presshop/features/chat/presentation/pages/FullVideoView.dart';
import 'package:presshop/features/task/presentation/pages/broadcast_chat/broadCastChatTaskScreen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:presshop/main.dart';
import 'package:presshop/core/widgets/animated_button.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/features/dashboard/presentation/pages/Dashboard.dart';
import 'package:presshop/features/task/presentation/bloc/task_bloc.dart';
import 'package:presshop/features/task/presentation/bloc/task_state.dart';
import 'package:presshop/features/task/presentation/bloc/task_event.dart';
import 'package:presshop/features/task/domain/entities/task_assigned_entity.dart';

// ignore: must_be_immutable
class TaskDetailNewScreen extends StatefulWidget {
  TaskDetailNewScreen(
      {super.key,
      required this.taskStatus,
      required this.taskId,
      required this.totalEarning});
  String taskStatus = "";
  String taskId = "";
  String totalEarning = "";

  @override
  State<TaskDetailNewScreen> createState() => _TaskDetailNewScreenState();
}

class _TaskDetailNewScreenState extends State<TaskDetailNewScreen> {
  TaskAssignedEntity? taskDetail;
  String roomId = "";
  bool isExtraTime = false;
  bool isOwner = false;
  BitmapDescriptor? mapIcon;
  List<Marker> marker = [];
  bool shouldRestartAnimation = false;
  LatLng? _latLng;
  bool isDirection = false;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  // static const CameraPosition _kLake = CameraPosition(
  //     bearing: 192.8334901395799,
  //     target: LatLng(37.43296265331129, -122.08832357078792),
  //     tilt: 59.440717697143555,
  //     zoom: 19.151926040649414);

  @override
  void initState() {
    getAllIcons();
    getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context
          .read<TaskBloc>()
          .add(GetTaskDetailEvent(widget.taskId, showLoader: false));
    });
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
          AppStringsNew2.taskDetailText,
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: size.width * AppDimensions.appBarHeadingFontSize),
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
              height: size.width * AppDimensions.numD07,
              width: size.width * AppDimensions.numD07,
            ),
          ),
          SizedBox(
            width: size.width * AppDimensions.numD04,
          )
        ],
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskDetailLoaded) {
            taskDetail = state.taskDetail;
            roomId = taskDetail!.resp.roomId;
            _updateGoogleMap(LatLng(
                taskDetail!.task.addressLocation.coordinates[0],
                taskDetail!.task.addressLocation.coordinates[1]));

            SharedPreferences.getInstance().then((input) {
              var myId = input.getString(hopperIdKey) ?? "";
              // acceptedBy is not in new model, assuming false or skipping check
              isOwner = false;
              if (mounted) {
                setState(() {});
              }
            });
          } else if (state is TaskError) {
            showSnackBar("Error", state.message, Colors.red);
          }
        },
        builder: (context, state) {
          // Sync local variable with state if needed
          if (state is TaskDetailLoaded) {
            taskDetail = state.taskDetail;
          }

          if (state is TaskError) {
            return Center(child: Text(state.message));
          }

          if (taskDetail == null) {
            return showLoader();
          }
          return Padding(
            padding: EdgeInsets.all(size.width * AppDimensions.numD028),
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Status Or Media House Name
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * AppDimensions.numD01,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${taskDetail!.task.mediaHouse.firstName} ${taskDetail!.task.mediaHouse.lastName}"
                                .toUpperCase(),
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD036,
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
                                fontSize: size.width * AppDimensions.numD036,
                                color: widget.taskStatus == "rejected"
                                    ? Colors.black
                                    : AppColorTheme.colorThemePink,
                                fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.width * AppDimensions.numD02,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: size.width * AppDimensions.numD35,
                            child: Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.black),
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD042),
                              ),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      size.width * AppDimensions.numD04),
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      GoogleMap(
                                        scrollGesturesEnabled: false,
                                        mapType: MapType.normal,
                                        initialCameraPosition: _kGooglePlex,
                                        markers: marker.map((e) => e).toSet(),
                                        onMapCreated: (controller) {
                                          _controller.complete(controller);
                                        },
                                        compassEnabled: false,
                                        mapToolbarEnabled: false,
                                        zoomControlsEnabled: false,
                                        zoomGesturesEnabled: false,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(
                                            size.width * AppDimensions.numD07),
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
                                              horizontal: size.width *
                                                  AppDimensions.numD06,
                                              vertical: size.width *
                                                  AppDimensions.numD018),
                                          decoration: BoxDecoration(
                                              color:
                                                  AppColorTheme.colorThemePink,
                                              borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(
                                                    size.width *
                                                        AppDimensions.numD01),
                                                bottomRight: Radius.circular(
                                                    size.width *
                                                        AppDimensions.numD02),
                                              )),
                                          child: Text(
                                            "Click the Map & GO",
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD032,
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
                          width: size.width * AppDimensions.numD03,
                        ),
                        Expanded(
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Container(
                                height: size.width * AppDimensions.numD35,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: AppColorTheme.colorGrey5,
                                    borderRadius: BorderRadius.circular(
                                        size.width * AppDimensions.numD04)),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: size.width * AppDimensions.numD03,
                                    ),
                                    Text(
                                      isExtraTime
                                          ? "Extra time added"
                                          : isTimeOver()
                                              ? "Time over"
                                              : "Time remaining",
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width *
                                              AppDimensions.numD035,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    FittedBox(
                                      child: Padding(
                                          padding: EdgeInsets.all(size.width *
                                              AppDimensions.numD04),
                                          child: TimerCountdown(
                                            key: Key(taskDetail!
                                                .task.deadlineDate
                                                .toString()),
                                            endTime:
                                                taskDetail!.task.deadlineDate,
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
                                                  taskDetail!.task.deadlineDate
                                                      .add(Duration(hours: 3));
                                                }
                                              });
                                            },
                                            countDownFormatter:
                                                (day, hour, min, sec) {
                                              if (taskDetail!.task.deadlineDate
                                                      .difference(
                                                          DateTime.now())
                                                      .inDays >
                                                  0) {
                                                //return "$day:$hour:$min:$sec";
                                                return "${int.parse(day)}d:${hour}h:${min}m";
                                              } else if (taskDetail!
                                                      .task.deadlineDate
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
                                                fontSize: size.width *
                                                    AppDimensions.numD06,
                                                color: widget.taskStatus ==
                                                        "accepted"
                                                    ? AppColorTheme
                                                        .colorOnlineGreen
                                                    : AppColorTheme
                                                        .colorThemePink,
                                                fontWeight: FontWeight.w500),
                                          )),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        size.width * AppDimensions.numD07,
                                    vertical:
                                        size.width * AppDimensions.numD018),
                                decoration: BoxDecoration(
                                    color: AppColorTheme.colorThemePink,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(
                                          size.width * AppDimensions.numD04),
                                      bottomRight: Radius.circular(
                                          size.width * AppDimensions.numD04),
                                    )),
                                child: Center(
                                  child: Text(
                                    "Deadline ${dateTimeFormatter(dateTime: taskDetail!.task.deadlineDate.toString(), format: "hh:mm a").toLowerCase()}",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD032,
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
                      height: size.width * AppDimensions.numD04,
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
                                    size: size.width * AppDimensions.numD045,
                                  ),
                                  SizedBox(
                                    width: size.width * AppDimensions.numD018,
                                  ),
                                  Text(
                                      dateTimeFormatter(
                                          dateTime: taskDetail!.task.createdAt
                                              .toString(),
                                          format: "hh:mm a"),
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize:
                                              size.width * AppDimensions.numD03,
                                          color: AppColorTheme.colorHint,
                                          fontWeight: FontWeight.w500)),
                                  SizedBox(
                                    width: size.width * AppDimensions.numD02,
                                  ),
                                  Icon(
                                    Icons.calendar_month,
                                    size: size.width * AppDimensions.numD045,
                                  ),
                                  SizedBox(
                                    width: size.width * AppDimensions.numD018,
                                  ),
                                  Text(
                                      dateTimeFormatter(
                                          dateTime: taskDetail!.task.createdAt
                                              .toString(),
                                          format: "dd MMM yyyy"),
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize:
                                              size.width * AppDimensions.numD03,
                                          color: AppColorTheme.colorHint,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                              SizedBox(
                                height: size.width * AppDimensions.numD025,
                              ),

                              /// Location
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: size.width * AppDimensions.numD045,
                                  ),
                                  SizedBox(
                                    width: size.width * AppDimensions.numD02,
                                  ),
                                  Expanded(
                                    child: Text(
                                      taskDetail!.task.location,
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width *
                                              AppDimensions.numD028,
                                          color: AppColorTheme.colorHint,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: size.width * AppDimensions.numD025,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: size.width * AppDimensions.numD045,
                                  ),
                                  SizedBox(
                                    width: size.width * AppDimensions.numD02,
                                  ),
                                  Text(
                                    "20 miles",
                                    overflow: TextOverflow.ellipsis,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD028,
                                        color: AppColorTheme.colorHint,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    width: size.width * AppDimensions.numD018,
                                  ),
                                  Container(
                                    width: 1,
                                    height: size.width * AppDimensions.numD04,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(
                                    width: size.width * AppDimensions.numD02,
                                  ),
                                  Icon(
                                    Icons.directions_walk_rounded,
                                    size: size.width * AppDimensions.numD045,
                                  ),
                                  SizedBox(
                                    width: size.width * AppDimensions.numD01,
                                  ),
                                  Text(
                                    "34 mins",
                                    overflow: TextOverflow.ellipsis,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD028,
                                        color: AppColorTheme.colorHint,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    width: size.width * AppDimensions.numD01,
                                  ),
                                  Container(
                                    width: 1,
                                    height: size.width * AppDimensions.numD04,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(
                                    width: size.width * AppDimensions.numD02,
                                  ),
                                  Icon(
                                    Icons.directions_car,
                                    size: size.width * AppDimensions.numD045,
                                  ),
                                  SizedBox(
                                    width: size.width * AppDimensions.numD01,
                                  ),
                                  Text(
                                    "3 mins",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD028,
                                        color: AppColorTheme.colorHint,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: size.width * AppDimensions.numD02,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: size.width * AppDimensions.numD075,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: size.width * AppDimensions.numD025,
                    ),

                    const Divider(
                      thickness: 1,
                      color: AppColorTheme.colorGreyChat,
                    ),

                    Text("HEADING",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w500)),
                    SizedBox(
                      height: size.width * AppDimensions.numD018,
                    ),
                    Text(
                      taskDetail!.task.heading,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD04,
                          color: Colors.black,
                          lineHeight: 1.5,
                          fontWeight: FontWeight.w700),
                    ),

                    SizedBox(
                      height: size.width * AppDimensions.numD06,
                    ),
                    Text("DESCRIPTION",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w500)),
                    SizedBox(
                      height: size.width * AppDimensions.numD018,
                    ),

                    Text(taskDetail!.task.description,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD03,
                            color: Colors.black,
                            lineHeight: 2,
                            fontWeight: FontWeight.normal)),

                    SizedBox(
                      height: size.width * AppDimensions.numD06,
                    ),

                    "".isNotEmpty
                        ? Text("SPECIAL REQUIREMENTS",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD035,
                                color: Colors.black,
                                fontWeight: FontWeight.w500))
                        : Container(),
                    SizedBox(
                      height: "".isNotEmpty
                          ? size.width * AppDimensions.numD025
                          : 0,
                    ),

                    "".isNotEmpty
                        ? Text("",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD03,
                                color: Colors.black,
                                lineHeight: 2,
                                fontWeight: FontWeight.normal))
                        : Container(),

                    SizedBox(
                      height: "".isNotEmpty
                          ? size.width * AppDimensions.numD025
                          : 0,
                    ),

                    const Divider(
                      thickness: 1,
                      color: AppColorTheme.colorGreyChat,
                    ),

                    SizedBox(
                      height: size.width * AppDimensions.numD025,
                    ),

                    Text("PRICE OFFERED",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w500)),
                    SizedBox(
                      height: size.width * AppDimensions.numD05,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                  taskDetail != null &&
                                          taskDetail!.task.isNeedPhoto
                                      ? "${taskDetail!.task.currencySymbol.isNotEmpty ? taskDetail!.task.currencySymbol : currencySymbol}${formatDouble(double.parse(taskDetail!.task.photoPrice))}"
                                      : "-",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize:
                                          size.width * AppDimensions.numD058,
                                      color: AppColorTheme.colorThemePink,
                                      fontWeight: FontWeight.w800)),
                              Text("Offered",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize:
                                          size.width * AppDimensions.numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                              SizedBox(
                                height: size.width * AppDimensions.numD018,
                              ),
                              Container(
                                width: size.width * AppDimensions.numD26,
                                padding: EdgeInsets.symmetric(
                                    vertical:
                                        size.width * AppDimensions.numD02),
                                decoration: BoxDecoration(
                                    color: AppColorTheme.colorThemePink,
                                    borderRadius: BorderRadius.circular(
                                        size.width * AppDimensions.numD02)),
                                child: Center(
                                    child: Text("PHOTO",
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width *
                                                AppDimensions.numD035,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500))),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                  taskDetail != null &&
                                          taskDetail!.task.isNeedInterview
                                      ? "${taskDetail!.task.currencySymbol.isNotEmpty ? taskDetail!.task.currencySymbol : currencySymbol}${formatDouble(double.parse(taskDetail!.task.interviewPrice))}"
                                      : "-",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize:
                                          size.width * AppDimensions.numD058,
                                      color: AppColorTheme.colorThemePink,
                                      fontWeight: FontWeight.w800)),
                              Text("Offered",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize:
                                          size.width * AppDimensions.numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                              SizedBox(
                                height: size.width * AppDimensions.numD018,
                              ),
                              Container(
                                width: size.width * AppDimensions.numD26,
                                padding: EdgeInsets.symmetric(
                                    vertical:
                                        size.width * AppDimensions.numD02),
                                decoration: BoxDecoration(
                                    color: AppColorTheme.colorThemePink,
                                    borderRadius: BorderRadius.circular(
                                        size.width * AppDimensions.numD02)),
                                child: Center(
                                    child: Text("INTERVIEW",
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width *
                                                AppDimensions.numD035,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500))),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                  taskDetail != null &&
                                          taskDetail!.task.isNeedVideo
                                      ? "${taskDetail!.task.currencySymbol.isNotEmpty ? taskDetail!.task.currencySymbol : currencySymbol}${formatDouble(double.parse(taskDetail!.task.videoPrice))}"
                                      : "-",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize:
                                          size.width * AppDimensions.numD058,
                                      color: AppColorTheme.colorThemePink,
                                      fontWeight: FontWeight.w800)),
                              Text("Offered",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize:
                                          size.width * AppDimensions.numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                              SizedBox(
                                height: size.width * AppDimensions.numD018,
                              ),
                              Container(
                                width: size.width * AppDimensions.numD26,
                                padding: EdgeInsets.symmetric(
                                    vertical:
                                        size.width * AppDimensions.numD02),
                                decoration: BoxDecoration(
                                    color: AppColorTheme.colorThemePink,
                                    borderRadius: BorderRadius.circular(
                                        size.width * AppDimensions.numD02)),
                                child: Center(
                                    child: Text("VIDEO",
                                        style: commonTextStyle(
                                            size: size,
                                            fontSize: size.width *
                                                AppDimensions.numD035,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500))),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.width * AppDimensions.numD025,
                    ),

                    const Divider(
                      thickness: 1,
                      color: AppColorTheme.colorGreyChat,
                    ),
                    SizedBox(
                      height: size.width * AppDimensions.numD025,
                    ),

                    taskDetail!.task.content.isNotEmpty
                        ? Text(AppStringsNew2.uploadedContentText.toUpperCase(),
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD035,
                                color: Colors.black,
                                fontWeight: FontWeight.w500))
                        : Container(),
                    SizedBox(
                      height: taskDetail!.task.content.isNotEmpty
                          ? size.width * AppDimensions.numD05
                          : 0,
                    ),

                    GridView.builder(
                      itemCount: taskDetail!.task.content.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: size.width * AppDimensions.numD035,
                          crossAxisSpacing: size.width * AppDimensions.numD018),
                      itemBuilder: (context, index) {
                        var item = taskDetail!.task.content[index];
                        debugPrint("item.type::::${item.mediaType}");
                        return Stack(
                          children: [
                            InkWell(
                              onTap: () {
                                if (item.mediaType == "video") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MediaViewScreen(
                                                mediaFile: item.media,
                                                type: MediaTypeEnum.video,
                                              )));
                                } else if (item.mediaType == "audio") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MediaViewScreen(
                                                mediaFile: getMediaImageUrl(
                                                    item.media,
                                                    isTask: true),
                                                type: MediaTypeEnum.audio,
                                              )));
                                } else {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => MediaViewScreen(
                                            mediaFile: getMediaImageUrl(
                                                item.media,
                                                isTask: true),
                                            type: MediaTypeEnum.image,
                                          )));
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD028),
                                child: item.mediaType == "audio"
                                    ? Container(
                                        height: double.infinity,
                                        width: size.width / 2,
                                        decoration: BoxDecoration(
                                            color: AppColorTheme.colorThemePink,
                                            border: Border.all(
                                                color:
                                                    AppColorTheme.colorGreyNew),
                                            borderRadius: BorderRadius.circular(
                                                size.width *
                                                    AppDimensions.numD028)),
                                        child: Icon(
                                          Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: size.width * 0.17,
                                        ))
                                    : item.mediaType == "video"
                                        ? Image.network(
                                            getMediaImageUrl(item.media,
                                                isVideo: true, isTask: true),
                                            width: size.width / 2,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Image.asset(
                                                "${commonImagePath}rabbitLogo.png",
                                                width: size.width / 2,
                                                height: double.infinity,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          )
                                        : Image.network(
                                            getMediaImageUrl(item.media,
                                                isTask: true),
                                            width: size.width / 2,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Image.asset(
                                                "${commonImagePath}rabbitLogo.png",
                                                width: size.width / 2,
                                                height: double.infinity,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          ),
                              ),
                            ),
                            Positioned(
                              right: size.width * AppDimensions.numD01,
                              top: size.width * AppDimensions.numD01,
                              child: item.mediaType != "audio"
                                  ? Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: size.width *
                                              AppDimensions.numD006,
                                          vertical: size.width *
                                              AppDimensions.numD002),
                                      decoration: BoxDecoration(
                                          color: AppColorTheme.colorLightGreen
                                              .withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(
                                              size.width *
                                                  AppDimensions.numD01)),
                                      child: Icon(
                                        item.mediaType == "video"
                                            ? Icons.videocam_outlined
                                            : Icons.camera_alt_outlined,
                                        size:
                                            size.width * AppDimensions.numD035,
                                        color: Colors.white,
                                      ))
                                  : Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: size.width *
                                              AppDimensions.numD008,
                                          vertical: size.width *
                                              AppDimensions.numD005),
                                      decoration: BoxDecoration(
                                          color: AppColorTheme.colorLightGreen
                                              .withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(
                                              size.width *
                                                  AppDimensions.numD01)),
                                      child: Image.asset(
                                        "${iconsPath}ic_mic1.png",
                                        fit: BoxFit.cover,
                                        height:
                                            size.width * AppDimensions.numD025,
                                        width:
                                            size.width * AppDimensions.numD025,
                                      ),
                                    ),
                            ),
                          ],
                        );
                      },
                    ),

                    SizedBox(
                      height: size.width * AppDimensions.numD1,
                    ),
                    // if (isOwner)
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
                                  .then((value) => context.read<TaskBloc>().add(
                                      GetTaskDetailEvent(widget.taskId,
                                          showLoader: false)));
                            },
                            child: AnimatedButtonWidget(
                              shouldRestartAnimation: shouldRestartAnimation,
                              size: size,
                              buttonText: AppStringsNew2.manageTaskText,
                              onPressed: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (context) =>
                                            BroadCastChatTaskScreen(
                                              taskDetail: taskDetail!,
                                              roomId: roomId,
                                            )))
                                    .then((value) {
                                  shouldRestartAnimation = true;
                                  context.read<TaskBloc>().add(
                                      GetTaskDetailEvent(widget.taskId,
                                          showLoader: false));
                                });
                              },
                            ),
                          )
                        : Container(
                            width: size.width,
                            height: size.width * AppDimensions.numD14,
                            margin: EdgeInsets.symmetric(
                                horizontal: size.width * AppDimensions.numD04),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            size.width *
                                                AppDimensions.numD04))),
                                onPressed: () {},
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      AppStringsNew2.youHaveEarnedText,
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width *
                                              AppDimensions.numD035,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      "${taskDetail != null && taskDetail!.task.currencySymbol.isNotEmpty ? taskDetail!.task.currencySymbol : currencySymbol}${widget.totalEarning.isNotEmpty ? widget.totalEarning : "0"}",
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width *
                                              AppDimensions.numD065,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                )),
                          ),

                    SizedBox(
                      height: size.width * AppDimensions.numD02,
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * AppDimensions.numD02),
                      child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD03,
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
                                        fontSize:
                                            size.width * AppDimensions.numD03,
                                        color: AppColorTheme.colorThemePink,
                                        fontWeight: FontWeight.w400)),
                                const TextSpan(
                                  text:
                                      " to view your active assignments, track deadlines, upload photos and videos, and monitor your earnings—all in one place!",
                                )
                              ])),
                    ),

                    SizedBox(
                      height: size.height * AppDimensions.numD02,
                    ),
                  ]),
            ),
          );
        },
      ),
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
    if (!mounted) return;
    try {
      marker.add(Marker(
        markerId: const MarkerId("1"),
        position: latLng,
        icon: mapIcon ??
            BitmapDescriptor
                .defaultMarker, // Fallback if mapIcon not loaded yet
      ));
      await controller.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(latLng.latitude, latLng.longitude), 14));
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error updating map: $e");
    }
  }

  /// Current Lat Lng
  void getCurrentLocation() async {
    LocationData? loc = await LocationService()
        .getCurrentLocation(context, shouldShowSettingPopup: false);

    if (!mounted) return;

    if (loc != null) {
      setState(() {
        _latLng = LatLng(loc.latitude!, loc.longitude!);
        debugPrint("_longitude: $_latLng");
      });
    } else {
      showSnackBar(
          "Permission Denied", "Please Allow Location permission", Colors.red);
    }
  }

  Future<void> openUrl() async {
    String googleUrl = isDirection
        ? 'https://www.google.com/maps/dir/?api=1&origin=${_latLng!.latitude},'
            '${_latLng!.longitude}&destination=${taskDetail!.task.addressLocation.coordinates[0]},'
            '${taskDetail!.task.addressLocation.coordinates[1]}&travelmode=driving&dir_action=navigate'
        : 'https://www.google.com/maps/search/?api=1&query=${taskDetail!.task.addressLocation.coordinates[0]},${taskDetail!.task.addressLocation.coordinates[1]}';

    String appleUrl = isDirection
        ? 'http://maps.apple.com/maps?saddr=${_latLng!.latitude},'
            '${_latLng!.longitude}&daddr=${taskDetail!.task.addressLocation.coordinates[0]},'
            '${taskDetail!.task.addressLocation.coordinates[1]}'
        : 'http://maps.apple.com/?q=${taskDetail!.task.addressLocation.coordinates[0]},'
            '${taskDetail!.task.addressLocation.coordinates[1]}';
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
    var extraTime = taskDetail!.task.deadlineDate.add(Duration(hours: 3));
    if (extraTime.difference(DateTime.now()).inSeconds < 0) {
      return true;
    }
    return false;
  }
}
