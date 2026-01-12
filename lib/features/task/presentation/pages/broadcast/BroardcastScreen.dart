import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
// import 'package:contacts_service/contacts_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as PH;
import 'package:permission_handler/permission_handler.dart';

import 'package:presshop/core/analytics/analytics_mixin.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/features/task/presentation/bloc/task_bloc.dart';
import 'package:presshop/features/task/presentation/bloc/task_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/features/task/presentation/bloc/task_state.dart';
import 'package:presshop/features/task/domain/entities/task_detail.dart';
import 'package:presshop/features/dashboard/presentation/pages/Dashboard.dart';
import 'package:presshop/main.dart';
import 'package:http/http.dart' as http;
import 'package:fast_contacts/fast_contacts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class BroadCastScreen extends StatefulWidget {
  String taskId = "";
  String mediaHouseId = "";

  BroadCastScreen(
      {super.key, required this.taskId, required this.mediaHouseId});

  @override
  State<BroadCastScreen> createState() => _BroadCastScreenState();
}

class _BroadCastScreenState extends State<BroadCastScreen>
    with AnalyticsPageMixin {
  late Size size;
  LatLng? _latLng;
  String _hopperAcceptedCount = "";
  String _distance = "";
  String _drivingEstTime = "";
  String _walkingEstTime = "";

  bool _isAccepted = false;
  bool isDirection = false;
  bool isMultipleContact = false;
  BitmapDescriptor? mapIcon;
  List<Marker> marker = [];
  Timer? _hopperCountTimer;
  TaskDetail? taskDetail;
  double latitude = 22.5744, longitude = 88.3629;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  TextEditingController contactSearchController = TextEditingController();
  List<ContactListModel> contactsDataList = [];
  List<ContactListModel> contactSearch = [];
  SharedPreferences? sharedPreferences;
  String currencySymbol = "";

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

/*
  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
*/

  @override
  void initState() {
    getAllIcons();
    debugPrint("Class Name : $runtimeType");
    getCurrentLocation();
    //requestContactsPermission();
    context.read<TaskBloc>().add(GetTaskDetailEvent(widget.taskId));
    context.read<TaskBloc>().add(GetTaskDetailEvent(widget.taskId));
    _getSharedPrefs();
    super.initState();
  }

  Future<void> _getSharedPrefs() async {
    sharedPreferences = await SharedPreferences.getInstance();
    currencySymbol = sharedPreferences?.getString(currencySymbolKey) ?? "£";
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    if (player.state == PlayerState.playing) {
      player.stop();
    }
    _hopperCountTimer?.cancel();
    contactSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return BlocConsumer<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskDetailLoaded) {
          taskDetail = state.taskDetail;
          if (taskDetail != null) {
            _updateGoogleMap(
                LatLng(taskDetail!.latitude, taskDetail!.longitude));
            if (_latLng != null) {
              getEstimateTime();
            }
            context
                .read<TaskBloc>()
                .add(GetHopperAcceptedCountEvent(taskDetail!.id));
          }
        } else if (state is TaskActionSuccess) {
          if (_isAccepted) {
            context.read<TaskBloc>().add(GetRoomIdEvent(
                  receiverId: taskDetail!.mediaHouseId,
                  taskId: widget.taskId,
                  roomType: "HoppertoAdmin",
                  type: "external_task",
                ));
            showSnackBar("Accepted", "You have successfully accepted the task!",
                Colors.green);
          } else {
            Navigator.pushAndRemoveUntil(
                navigatorKey.currentState!.context,
                MaterialPageRoute(
                    builder: (context) =>
                        Dashboard(initialPosition: 1, taskStatus: "rejected")),
                (route) => false);
          }
        } else if (state is RoomIdLoaded) {
          Navigator.pushAndRemoveUntil(
              navigatorKey.currentState!.context,
              MaterialPageRoute(
                  builder: (context) =>
                      Dashboard(initialPosition: 1, taskStatus: "accepted")),
              (route) => false);
        } else if (state is HopperAcceptedCountLoaded) {
          _hopperAcceptedCount = state.count;
        } else if (state is TaskError) {
          showSnackBar("Error", state.message, Colors.red);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: taskDetail == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    _googleMap(size),
                    _body(size),
                  ],
                ),
        );
      },
    );
  }

  Widget _googleMap(Size size) {
    return SizedBox(
      height: size.height / 2,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(size.width * numD06),
            bottomRight: Radius.circular(size.width * numD06)),
        child: GoogleMap(
          zoomControlsEnabled: false,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(taskDetail?.latitude ?? latitude,
                taskDetail?.longitude ?? longitude),
            zoom: 14.4746,
          ),
          onMapCreated: (GoogleMapController controller) {
            if (!_controller.isCompleted) {
              _controller.complete(controller);
            }
            if (taskDetail != null) {
              _updateGoogleMap(
                  LatLng(taskDetail!.latitude, taskDetail!.longitude));
            }
          },
          markers: Set<Marker>.of(marker),
        ),
      ),
    );
  }

  Widget _body(Size size) {
    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.zero,
          children: [
            _googleMap(size),
            Container(
              margin: EdgeInsets.only(
                left: size.width * numD02,
                right: size.width * numD02,
                top: size.width * numD03,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * numD02,
                        vertical: size.width * numD02),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(size.width * numD04),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.my_location,
                            ),
                            SizedBox(
                              width: size.width * numD02,
                            ),
                            SizedBox(
                              width: size.width * 0.426,
                              child: Text(
                                "$_hopperAcceptedCount Hoppers",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD035,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal),
                              ),
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
                              Icons.location_on_sharp,
                            ),
                            SizedBox(
                              width: size.width * 0.023,
                            ),
                            Text(
                              _distance,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                            ),
                            const Spacer(),
                            // Container(
                            //   width: 1,
                            //   height: size.width * numD04,
                            //   color: Colors.grey,
                            // ),
                          ],
                        ),
                        SizedBox(
                          height: size.width * numD02,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.directions_walk,
                            ),
                            SizedBox(
                              width: size.width * numD01,
                            ),
                            SizedBox(
                              width: size.width * numD44,
                              child: Text(
                                _walkingEstTime,
                                overflow: TextOverflow.ellipsis,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD035,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal),
                              ),
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
                            ),
                            SizedBox(
                              width: size.width * numD01,
                            ),
                            Text(
                              _drivingEstTime,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.width * numD03,
                  ),

                  Row(
                    children: [
                      ClipRRect(
                          borderRadius:
                              BorderRadius.circular(size.width * numD04),
                          child: Image.network(
                            taskDetail!.mediaHouseImage,
                            height: size.width * numD12,
                            width: size.width * numD12,
                            fit: BoxFit.cover,
                            errorBuilder: (context, object, stacktrace) {
                              return Padding(
                                padding: EdgeInsets.all(size.width * numD02),
                                child: Image.asset(
                                  "${commonImagePath}rabbitLogo.png",
                                  height: size.width * numD07,
                                  width: size.width * numD07,
                                ),
                              );
                            },
                          )),
                      SizedBox(
                        width: size.width * numD03,
                      ),
                      Text(
                        taskDetail!.mediaHouseName.toUpperCase(),
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD04,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),

                  /// News Company Name

                  SizedBox(
                    height: size.width * numD05,
                  ),

                  /// News Headline
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

                  /// News Description
                  Text(
                    "${taskDetail!.description}\n\n${taskDetail!.specialReq}",
                    style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD03,
                      color: Colors.black,
                      lineHeight: 1.8,
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.justify,
                  ),

                  /// Divider
                  const Divider(
                    thickness: 1,
                    color: colorLightGrey,
                  ),

                  Container(
                    margin: EdgeInsets.only(
                      top: size.width * numD04,
                      bottom: size.width * numD05,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                                vertical: size.width * numD055,
                                horizontal: size.width * numD02),
                            decoration: BoxDecoration(
                                color: colorLightGrey,
                                borderRadius:
                                    BorderRadius.circular(size.width * numD03)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: Colors.black,
                                      size: size.width * numD04,
                                    ),
                                    SizedBox(
                                      width: size.width * numD01,
                                    ),
                                    Text(
                                      deadlineText,
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD03,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: size.width * numD01,
                                ),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: size.width * numD01,
                                        top: size.width * numD01),
                                    child: TimerCountdown(
                                      endTime: taskDetail!.deadLine,
                                      spacerWidth: 3,
                                      enableDescriptions: false,
                                      countDownFormatter:
                                          (day, hour, min, sec) {
                                        if (taskDetail!.deadLine
                                                .difference(DateTime.now())
                                                .inDays >
                                            0) {
                                          return "${int.parse(day)}d:${hour}h:${min}m:${sec}s";
                                        } else {
                                          return "${hour}h:${min}m:${sec}s";
                                        }
                                      },
                                      format:
                                          CountDownTimerFormat.customFormats,
                                      timeTextStyle: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD03,
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal),
                                    ) /*Text(
                                                    "1h: 21m: 11s",
                                                    style: commonTextStyle(
                                                        size: size,
                                                        fontSize: size.width * numD03,
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.normal),
                                                  ),*/
                                    ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: size.width * numD05,
                        ),
                        Expanded(
                          child: Container(
                            height: size.width * numD20,
                            padding: EdgeInsets.symmetric(
                                vertical: size.width * numD03,
                                horizontal: size.width * numD02),
                            decoration: BoxDecoration(
                                color: colorLightGrey,
                                borderRadius:
                                    BorderRadius.circular(size.width * numD03)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      "${iconsPath}ic_location.png",
                                      width: size.width * numD03,
                                    ),
                                    SizedBox(
                                      width: size.width * numD01,
                                    ),
                                    Text(
                                      locationText.toUpperCase(),
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD03,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: size.width * numD01,
                                    top: size.width * numD01,
                                  ),
                                  child: Text(
                                    taskDetail!.location,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD03,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  priceOfferWidget(),

                  SizedBox(
                    height: size.width * numD1,
                  ),

                  /// Button
                  Row(
                    children: [
                      Expanded(
                          child: SizedBox(
                        height: size.width * numD15,
                        child: commonElevatedButton(
                            declineText.toTitleCase(),
                            size,
                            commonTextStyle(
                                size: size,
                                fontSize: size.width * numD04,
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                            commonButtonStyle(size, Colors.black), () {
                          _isAccepted = false;
                          if (player.state == PlayerState.playing) {
                            player.stop();
                          }
                          callAcceptRejectApi();
                          debugPrint("rejected:::::::");
                          setState(() {});
                        }),
                      )),
                      SizedBox(
                        width: size.width * numD03,
                      ),
                      Expanded(
                          child: SizedBox(
                        height: size.width * numD15,
                        child: commonElevatedButton(
                            "Accept",
                            size,
                            commonTextStyle(
                                size: size,
                                fontSize: size.width * numD04,
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                            commonButtonStyle(size, colorThemePink), () {
                          _isAccepted = true;
                          //isDirection = true;
                          if (player.state == PlayerState.playing) {
                            player.stop();
                          }
                          callAcceptRejectApi();

                          debugPrint("accepted====>");
                          setState(() {});
                        }),
                      ))
                    ],
                  ),

                  SizedBox(
                    height: size.height * numD07,
                  ),
                ],
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                margin: EdgeInsets.only(
                    top: size.width * numD14, left: size.width * numD04),
                padding: EdgeInsets.all(size.width * numD02),
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: Image.asset(
                  "${iconsPath}ic_arrow_left.png",
                  height: size.width * numD06,
                  width: size.width * numD06,
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                try {
                  Share.share(
                      "${taskDetail!.title}\n ${taskDetail!.description}.\n\n Hi there, ${sharedPreferences!.getString(firstNameKey).toString()} ${sharedPreferences!.getString(lastNameKey).toString()} has shared a task priced from $currencySymbol${taskDetail!.minimumPriceRange} to $currencySymbol${taskDetail!.maximumPriceRange} with you. Please click this ${Uri.parse(appUrl)} to download PressHop and review the task. Cheers");
                } catch (e) {
                  debugPrint("Share Error: $e");
                }
              },
              child: Container(
                margin: EdgeInsets.only(
                    top: size.width * numD14, left: size.width * numD04),
                padding: EdgeInsets.all(size.width * numD02),
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: Image.asset(
                  "${iconsPath}ic_share_now.png",
                  height: size.width * numD06,
                  width: size.width * numD06,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  /// Price Offer widget
  Widget priceOfferWidget() {
    return Column(
      children: [
        const Divider(),
        SizedBox(
          height: size.width * numD03,
        ),

        /// Price Offer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    taskDetail!.isNeedPhoto
                        ? "$currencySymbol${formatDouble(double.parse(taskDetail!.photoPrice))}"
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
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: size.width * numD016,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * numD06,
                        vertical: size.width * numD025),
                    decoration: BoxDecoration(
                        color: colorThemePink,
                        borderRadius:
                            BorderRadius.circular(size.width * numD02)),
                    child: Text(
                      photoText.toUpperCase(),
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
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
                        ? "$currencySymbol${formatDouble(double.parse(taskDetail!.interviewPrice))}"
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
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: size.width * numD016,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * numD04,
                        vertical: size.width * numD025),
                    decoration: BoxDecoration(
                        color: colorThemePink,
                        borderRadius:
                            BorderRadius.circular(size.width * numD02)),
                    child: Text(
                      interviewText.toUpperCase(),
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
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
                        ? "$currencySymbol${formatDouble(double.parse(taskDetail!.videoPrice))}"
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
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: size.width * numD016,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * numD06,
                        vertical: size.width * numD025),
                    decoration: BoxDecoration(
                        color: colorThemePink,
                        borderRadius:
                            BorderRadius.circular(size.width * numD02)),
                    child: Text(
                      videoText.toUpperCase(),
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),

        SizedBox(
          height: size.width * numD03,
        ),
      ],
    );
  }

  /// show-share-bottom-sheet
  Future<void> showShareBottomSheet() async {
    showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(size.width * numD085),
          topRight: Radius.circular(size.width * numD085),
        )),
        builder: (context) {
          return StatefulBuilder(builder: (context, StateSetter stateSetter) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// Heading
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * numD05,
                  ).copyWith(
                    top: size.width * numD05,
                    bottom: size.width * numD02,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        splashRadius: size.width * numD05,
                        icon: Icon(
                          Icons.close,
                          color: Colors.black,
                          size: size.width * numD06,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Share the task",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD045,
                                color: Colors.black,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),

                      /*    /// Share Button
                      isMultipleContact
                          ? commonElevatedButton(
                              shareText,
                              size,
                              commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                              commonButtonStyle(size, colorThemePink),
                              () {})
                          : Container(),*/
                    ],
                  ),
                ),

                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * numD04,
                      vertical: size.width * numD04,
                    ),
                    children: [
                      /// Share Sub Text
                      Text(
                        boardCastShareSubText,
                        textAlign: TextAlign.center,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        height: size.width * numD03,
                      ),

                      /// Search
                      TextFormField(
                        controller: contactSearchController,
                        cursorColor: colorTextFieldIcon,
                        onChanged: (value) {
                          contactSearch = contactsDataList
                              .where((element) => element.displayName!
                                  .trim()
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();

                          debugPrint("searchResult :: ${contactSearch.length}");
                          setState(() {});
                          stateSetter(() {});
                        },
                        decoration: InputDecoration(
                          fillColor: colorLightGrey,
                          isDense: true,
                          filled: true,
                          hintText: searchHintText,
                          hintStyle: TextStyle(
                              color: colorHint, fontSize: size.width * numD04),
                          disabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.03),
                              borderSide: const BorderSide(
                                  width: 0, color: colorLightGrey)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.03),
                              borderSide: const BorderSide(
                                  width: 0, color: colorLightGrey)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.03),
                              borderSide: const BorderSide(
                                  width: 0, color: colorLightGrey)),
                          errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.03),
                              borderSide: const BorderSide(
                                  width: 0, color: colorLightGrey)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.03),
                              borderSide: const BorderSide(
                                  width: 0, color: colorLightGrey)),
                          suffixIcon: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * numD02),
                            child: Image.asset(
                              "${iconsPath}ic_search.png",
                              color: Colors.black,
                            ),
                          ),
                          suffixIconConstraints:
                              BoxConstraints(maxHeight: size.width * numD06),
                        ),
                        textAlignVertical: TextAlignVertical.center,
                      ),

                      /// User List
                      contactsDataList.isNotEmpty
                          ? ListView.separated(
                              padding: EdgeInsets.symmetric(
                                  vertical: size.width * numD06),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                var item =
                                    contactSearchController.text.isNotEmpty
                                        ? contactSearch[index]
                                        : contactsDataList[index];
                                return InkWell(
                                  onTap: () {
                                    /* contactsDataList[index].isContactSelected = !contactsDataList[index].isContactSelected;
                                if( contactsDataList[index].isContactSelected){
                                  isMultipleContact = true;
                                }*/
                                    /*stateSetter(() {});
                                    setState(() {});*/
                                  },
                                  child: Container(
                                    padding:
                                        EdgeInsets.all(size.width * numD02),
                                    color: item.isContactSelected
                                        ? colorLightGrey
                                        : Colors.transparent,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              height: size.width * numD15,
                                              width: size.width * numD15,
                                              padding: EdgeInsets.all(
                                                  size.width * numD01),
                                              decoration: const BoxDecoration(
                                                  color: colorThemePink,
                                                  shape: BoxShape.circle),
                                              child: ClipOval(
                                                child: item.avatar != null
                                                    ? Image.memory(
                                                        item.avatar!,
                                                        height:
                                                            size.width * numD09,
                                                        width:
                                                            size.width * numD09,
                                                        fit: BoxFit.contain,
                                                        errorBuilder:
                                                            (context, dd, v) {
                                                          return Center(
                                                              child: Text(
                                                            item.displayName![0]
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontSize:
                                                                    size.width *
                                                                        numD05,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white),
                                                          ));
                                                        },
                                                      )
                                                    : Center(
                                                        child: Text(
                                                          item.displayName![0]
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize:
                                                                  size.width *
                                                                      numD05,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: size.width * numD025,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: size.width * numD30,
                                                  child: Text(
                                                    item.displayName.toString(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: commonTextStyle(
                                                        size: size,
                                                        fontSize: size.width *
                                                            numD037,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                                Text(
                                                  item.phones!.isNotEmpty
                                                      ? item
                                                          .phones!.first.number
                                                          .toString()
                                                      : '',
                                                  style: commonTextStyle(
                                                      size: size,
                                                      fontSize:
                                                          size.width * numD035,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                                onPressed: () async {
                                                  String phoneNumber = item
                                                      .phones!.first.number
                                                      .toString()
                                                      .trim();
                                                  final Uri uri = Uri(
                                                      scheme: 'sms',
                                                      path: phoneNumber,
                                                      queryParameters: {
                                                        'body':
                                                            '${taskDetail!.title}\n${taskDetail!.description}\nHi ${item.displayName}, ${sharedPreferences!.getString(firstNameKey).toString()} ${sharedPreferences!.getString(lastNameKey).toString()} has shared a task priced from $currencySymbol${taskDetail!.minimumPriceRange} to $currencySymbol${taskDetail!.maximumPriceRange} with you. Please click this ${Uri.parse(appUrl)} to download PressHop and review the task.Cheers'
                                                      });
                                                  if (await canLaunchUrl(uri)) {
                                                    await launchUrl(uri);
                                                  } else {
                                                    showSnackBar(
                                                        'PressHop',
                                                        errorOpenSMS,
                                                        Colors.black);
                                                    // Handle the case when the URL can't be launched.
                                                    throw ('Error launching Sms');
                                                  }
                                                },
                                                splashRadius:
                                                    size.width * numD05,
                                                icon: Image.asset(
                                                  "${iconsPath}message_icon.png",
                                                  height: size.width * numD06,
                                                )),
                                            IconButton(
                                                splashRadius:
                                                    size.width * numD05,
                                                onPressed: () async {
                                                  /*Uri whatsappUrl = Uri.parse(
                                                      "whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent("${taskDetail!.title}\n\n ${taskDetail!.description}"
                                                          "\n\n ${Uri.parse(appUrl)}")}"); */

                                                  Share.share(Uri.encodeComponent(
                                                      "${taskDetail!.title}\n ${taskDetail!.description}\n\n Hi ${item.displayName}, ${sharedPreferences!.getString(firstNameKey).toString()} ${sharedPreferences!.getString(lastNameKey).toString()} has shared a task priced from $currencySymbol${taskDetail!.minimumPriceRange} to $currencySymbol${taskDetail!.maximumPriceRange} with you. Please click this ${Uri.parse(appUrl)} to download PressHop and review the task. Cheers"));
                                                },
                                                icon: Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom:
                                                          size.width * numD006),
                                                  child: Image.asset(
                                                    "${iconsPath}whatsapp_icon.png",
                                                    height:
                                                        size.width * numD058,
                                                  ),
                                                ))
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return SizedBox(
                                  height: size.width * numD04,
                                );
                              },
                              itemCount: contactSearchController.text.isNotEmpty
                                  ? contactSearch.length
                                  : contactsDataList.length)
                          : Center(
                              child: Padding(
                                padding: EdgeInsets.all(size.width * numD05),
                                child: const Text("Not Contact Available"),
                              ),
                            ),

                      /* /// Share Button
                      contactsDataList != null
                          ? Container(
                        width: size.width,
                        height: size.width * numD14,
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * numD08,
                        ),
                        margin: EdgeInsets.only(
                          top: size.width * numD06,
                          bottom: size.width * numD08,
                        ),
                        child: commonElevatedButton(
                            shareText,
                            size,
                            commonTextStyle(
                                size: size,
                                fontSize: size.width * numD035,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                            commonButtonStyle(size, colorThemePink),
                                () {}),
                      )
                          : Container(),*/
                    ],
                  ),
                ),
              ],
            );
          });
        });
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
        LatLng(latLng.latitude, latLng.longitude), 12));
    setState(() {});
  }

  /// Current Lat Lng
  void getCurrentLocation() async {
    LocationData? loc = await LocationService().getCurrentLocation(context);
    if (loc != null) {
      // LocationData loc =
      //     LocationData.fromMap({"latitude": latitude, "longitude": longitude});
      setState(() {
        _latLng = LatLng(loc.latitude!, loc.longitude!);
        // _showMap = true;
        debugPrint("_longitude: $_latLng");
      });
    } else {
      showSnackBar(
          "Permission Denied", "Please Allow Loction permission", Colors.red);
    }
    taskDetail!.id.isNotEmpty
        ? context.read<TaskBloc>().add(GetTaskDetailEvent(widget.taskId))
        : null;
  }

  /// Initialize Map icon
  void getAllIcons() async {
    mapIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(5.0, 5.0)),
        "${commonImagePath}ic_cover_radius.png");
  }

  void openUrl() async {
    String googleUrl = isDirection && _latLng != null
        ? 'https://www.google.com/maps/dir/?api=1&origin=${_latLng!.latitude},'
            '${_latLng!.longitude}&destination=${taskDetail!.latitude},'
            '${taskDetail!.longitude}&travelmode=driving&dir_action=navigate'
        : 'https://www.google.com/maps/search/?api=1&query=${taskDetail!.latitude},${taskDetail!.longitude}';
    debugPrint('value data===> $googleUrl');

    String appleUrl = isDirection && _latLng != null
        ? 'http://maps.apple.com/maps?saddr=${_latLng!.latitude},'
            '${_latLng!.longitude}&daddr=${taskDetail!.latitude},'
            '${taskDetail!.longitude}'
        : 'http://maps.apple.com/?q=${taskDetail!.latitude},'
            '${taskDetail!.longitude}';
    debugPrint('value data===> $appleUrl');

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

  /// Contact Permission
  Future<void> requestContactsPermission() async {
    PH.PermissionStatus permissionStatus = await Permission.contacts.request();
    if (permissionStatus.isGranted) {
      debugPrint('Contact permission granted:::::::::::::::::::::::::::::::::');
      // Permission granted, proceed with retrieving contacts
      // Navigator.pop(navigatorKey.currentContext!);
      getContacts();
    } else {
      debugPrint(
          'Contact permission not granted::::::::::::::::::::::::::::::::');
      // Permission denied, handle accordingly (e.g., show error message)
    }
  }

  /// Contact List
  Future<void> getContacts() async {
    Iterable<Contact> contacts = await FastContacts.getAllContacts();
    for (var contact in contacts) {
      contactsDataList.add(ContactListModel(
        displayName: contact.displayName,
        givenName: contact.displayName,
        middleName: contact.structuredName?.middleName,
        phones: contact.phones,
        avatar: null,
        isContactSelected: false,
      ));
    }
  }

  ///--------Apis Section------------

  // void taskDetailApi() {
  //   NetworkClass("$taskDetailUrl${widget.taskId}", this, taskDetailUrlRequest)
  //       .callRequestServiceHeader(false, "get", null);
  // }

  void getEstimateTime() {
    debugPrint("::: Inside estimate Time Fuc ::::");
    dynamic mapKey;
    if (Platform.isIOS) {
      mapKey = appleMapAPiKey;
    } else {
      mapKey = googleMapAPiKey;
    }

    String drivingMode =
        "https://maps.googleapis.com/maps/api/distancematrix/json?origins="
        "${_latLng!.latitude},${_latLng!.longitude}&&destinations="
        "${taskDetail!.latitude},${taskDetail!.longitude}"
        "&mode=driving&key=$mapKey";

    String walkingMode =
        "https://maps.googleapis.com/maps/api/distancematrix/json?origins="
        "${_latLng!.latitude},${_latLng!.longitude}&destinations="
        "${taskDetail!.latitude},${taskDetail!.longitude}&mode=walking&key=$mapKey";

    debugPrint("drivingMode : $drivingMode");
    debugPrint("walkingMode : $walkingMode");

    var res = http.get(Uri.parse(drivingMode)).then((value) {
      debugPrint("Status Code : ${value.statusCode}");
      debugPrint("Body : ${value.body}");
      if (value.statusCode <= 201) {
        var data = jsonDecode(value.body);
        var dataModel = data["rows"] as List;
        if (dataModel.isNotEmpty) {
          var dataModel2 = dataModel.first["elements"] as List;
          if (dataModel2.isNotEmpty) {
            _drivingEstTime = dataModel2.first["duration"]["text"] ?? "";
            _distance = dataModel2.first["distance"]["text"] ?? "";
          }
        }
      }
      setState(() {});
    });

    var res1 = http.get(Uri.parse(walkingMode)).then((value) {
      debugPrint("Status Code : ${value.statusCode}");
      debugPrint("Body : ${value.body}");
      debugPrint("");
      if (value.statusCode <= 201) {
        var data = jsonDecode(value.body);
        var dataModel = data["rows"] as List;
        if (dataModel.isNotEmpty) {
          var dataModel2 = dataModel.first["elements"] as List;
          if (dataModel2.isNotEmpty) {
            _walkingEstTime = dataModel2.first["duration"]["text"] ?? "";
            _distance = dataModel2.first["distance"]["text"] ?? "";
          }
          setState(() {});
        }
      }
    });
  }

  /// Accept Reject Api
  void callAcceptRejectApi() {
    context.read<TaskBloc>().add(AcceptRejectTaskEvent(
          taskId: widget.taskId,
          mediaHouseId: widget.mediaHouseId,
          status: _isAccepted ? "accepted" : "rejected",
        ));
  }

  /// Get Room Id
  void callGetRoomIdApi() {
    context.read<TaskBloc>().add(GetRoomIdEvent(
          receiverId: taskDetail!.mediaHouseId,
          taskId: widget.taskId,
          roomType: "HoppertoAdmin",
          type: "external_task",
        ));
  }

  /// Get Hopper Accepted List
  void callGetHopperAcceptedCount() {
    // This is now handled via Bloc event in listener or init
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        /// Get Hopper Accepted List
        case getHopperAcceptedCountReq:
          {
            var data = jsonDecode(response);
            debugPrint("getHopperAcceptedCountReq Error : $data");
            showSnackBar("Error", data.toString(), Colors.red);
            break;
          }

        /// Get Room Id
        case getRoomIdReq:
          {
            var data = jsonDecode(response);
            debugPrint("getRoomIdReq Error : $data");
            showSnackBar("Error", data.toString(), Colors.red);
            break;
          }

        case taskDetailUrlRequest:
          debugPrint("BroadcastedData::::Error");
          break;

        /// Task Accept Reject
        case taskAcceptRejectRequestReq:
          {
            var data = jsonDecode(response);
            debugPrint("taskAcceptRejectRequestReq Success : $data");
            if (data != null && data['data'] != null) {
              showSnackBar("Error", data['data'].toString(), Colors.red);
            } else {
              showSnackBar("Error", data.toString(), Colors.red);
            }
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
        /// Get Hopper Accepted List
        case getHopperAcceptedCountReq:
          var data = jsonDecode(response);
          debugPrint("getHopperAcceptedCountReq Success : $data");
          _hopperAcceptedCount = (data["count"] ?? "0").toString();
          /*  _hopperCountTimer = Timer(
              const Duration(seconds: 10), () => callGetHopperAcceptedCount());*/
          break;

        /// Get Room Id
        case getRoomIdReq:
          var data = jsonDecode(response);
          debugPrint("getRoomIdReq Success : $data");
          //  openUrl();
          Navigator.pushAndRemoveUntil(
              navigatorKey.currentState!.context,
              MaterialPageRoute(
                  builder: (context) =>
                      Dashboard(initialPosition: 1, taskStatus: "accepted")),
              (route) => false);
          break;

        /// Task Accept Reject
        case taskAcceptRejectRequestReq:
          var data = jsonDecode(response);
          debugPrint("taskAcceptRejectRequestReq Success : $data");
          debugPrint("taskStatus ========> $_isAccepted");
          if (_isAccepted) {
            debugPrint("taskStatus true ========> $_isAccepted");
            callGetRoomIdApi();
            showSnackBar("Accepted", "You have successfully accepted the task!",
                Colors.green);
          } else {
            var taskStatusValue = data['data']['task_status'].toString();
            debugPrint("taskStatus false========> $_isAccepted");

            Navigator.pushAndRemoveUntil(
                navigatorKey.currentState!.context,
                MaterialPageRoute(
                    builder: (context) => Dashboard(
                        initialPosition: 1, taskStatus: taskStatusValue)),
                (route) => false);
          }
          break;

        case taskDetailUrlRequest:
          debugPrint("BroadcastedData::::Success:  $response");

          var map = jsonDecode(response);
          if (map["code"] == 200 && map["task"] != null) {
            // broadCastedData = BroadcastedData.fromJson(map["task"]); // This line is removed as broadCastedData is no longer used directly
            taskDetail = TaskDetailModel.fromJson(map["task"] ?? {});
            callGetHopperAcceptedCount();
            if (_latLng != null) {
              getEstimateTime();
            }
            _updateGoogleMap(
                LatLng(taskDetail!.latitude, taskDetail!.longitude));
            // Future.delayed(const Duration(seconds: 5),()=>_updateGoogleMap(LatLng(broadcastedData!.latitude, broadcastedData!.longitude)));
          }
          setState(() {});

          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  @override
  // TODO: implement pageName
  String get pageName => "BroardcastScreen";
}

class ContactListModel {
  String? identifier, displayName, givenName, middleName;
  List<Phone>? phones = [];
  Uint8List? avatar;
  bool isContactSelected = false;

  ContactListModel(
      {required this.displayName,
      required this.givenName,
      required this.middleName,
      required this.phones,
      required this.avatar,
      required this.isContactSelected});
}

/// Show loader dialog
Future<void> _showLoaderDialog(BuildContext context) async {
  // Show the dialog and wait for it to be fully rendered
  showDialog(
    barrierDismissible: false,
    barrierColor: Colors.white.withOpacity(0),
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0),
        content: Center(child: showLoader()),
      );
    },
  );
}
