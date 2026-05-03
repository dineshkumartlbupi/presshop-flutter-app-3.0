import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
// import 'package:contacts_service/contacts_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as PH;
import 'package:permission_handler/permission_handler.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/features/task/presentation/bloc/task_bloc.dart';
import 'package:presshop/features/task/presentation/bloc/task_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/features/task/presentation/bloc/task_state.dart';
import 'package:presshop/features/task/domain/entities/task_detail.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/main.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:presshop/features/task/domain/entities/task_assigned_entity.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class BroadCastScreen extends StatefulWidget {
  BroadCastScreen(
      {super.key,
      required this.taskId,
      required this.mediaHouseId,
      this.autoAction});
  String taskId = "";
  String mediaHouseId = "";
  String? autoAction;

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
  bool _hasSubmittedAction = false; // Guard to prevent premature navigation
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

  // static const CameraPosition _kGooglePlex = CameraPosition(
  //   target: LatLng(37.42796133580664, -122.085749655962),
  //   zoom: 14.4746,
  // );

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
    debugPrint(
        "🚀 BroadCastScreen initialized with taskId: '${widget.taskId}'");
    getCurrentLocation();
    //requestContactsPermission();
    context.read<TaskBloc>().add(GetTaskDetailEvent(widget.taskId));
    _getSharedPrefs();
    super.initState();
  }

  Future<void> _getSharedPrefs() async {
    sharedPreferences = await SharedPreferences.getInstance();
    currencySymbol =
        sharedPreferences?.getString(SharedPreferencesKeys.currencySymbolKey) ??
            "£";
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
        // Handle action status (accept/reject) FIRST, independently
        // Only react if user has actually submitted an action on this screen
        if (_hasSubmittedAction &&
            state.actionStatus == TaskStatus.success &&
            _isAccepted &&
            (state.roomId == null || state.roomId!.isEmpty)) {
          context.read<TaskBloc>().add(GetRoomIdEvent(
                receiverId: taskDetail!.mediaHouseId,
                taskId: widget.taskId,
                roomType: "HoppertoAdmin",
                type: "external_task",
              ));
          showSnackBar("Accepted", "You have successfully accepted the task!",
              Colors.green);
          return; // Exit listener after handling
        } else if (_hasSubmittedAction &&
            state.actionStatus == TaskStatus.success &&
            !_isAccepted) {
          context.goNamed(
            AppRoutes.dashboardName,
            extra: {
              'initialPosition': 1,
              'taskStatus': "rejected",
            },
          );
          return; // Exit listener after handling
        }

        //andle roomId (only if action was submitted)
        if (_hasSubmittedAction &&
            state.roomId != null &&
            state.roomId!.isNotEmpty) {
          debugPrint(
              "🚀 Navigating to dashboard (accepted) with roomId: ${state.roomId}");
          context.goNamed(
            AppRoutes.dashboardName,
            extra: {
              'initialPosition': 1,
              'taskStatus': "accepted",
            },
          );
          return; // Exit listener after handling
        }

        // Handle taskDetail loading
        if (state.taskDetail != null &&
            state.taskDetailStatus == TaskStatus.success) {
          TaskAssignedEntity assignedEntity = state.taskDetail!;
          taskDetail = TaskDetail(
            id: assignedEntity.task.id,
            deadLine: assignedEntity.task.deadlineDate,
            title: assignedEntity.task.heading,
            description: assignedEntity.task.description,
            location: assignedEntity.task.location,
            mediaHouseId: assignedEntity.task.mediaHouse.id,
            mediaHouseImage: assignedEntity.task.mediaHouse.profileImage,
            mediaHouseName:
                "${assignedEntity.task.mediaHouse.firstName} ${assignedEntity.task.mediaHouse.lastName}",
            latitude:
                (assignedEntity.task.addressLocation.coordinates.length >= 2)
                    ? assignedEntity.task.addressLocation.coordinates[1]
                    : 0.0,
            longitude:
                (assignedEntity.task.addressLocation.coordinates.isNotEmpty)
                    ? assignedEntity.task.addressLocation.coordinates[0]
                    : 0.0,
            status: assignedEntity.task.status,
            paidStatus: assignedEntity.task.paidStatus,
            createdAt: assignedEntity.task.createdAt.toIso8601String(),
            // Map actual requirements from the entity
            isNeedPhoto: assignedEntity.task.isNeedPhoto,
            isNeedVideo: assignedEntity.task.isNeedVideo,
            isNeedInterview: assignedEntity.task.isNeedInterview,
            photoPrice: assignedEntity.task.photoPrice,
            videoPrice: assignedEntity.task.videoPrice,
            interviewPrice: assignedEntity.task.interviewPrice,
            currency: assignedEntity.task.currency,
            currencySymbol: assignedEntity.task.currencySymbol,
            hopperInfo: assignedEntity.task.hopperInfo
                .map((e) => {
                      "id": e.id,
                      "type": e.type,
                      "count": e.count,
                      "hours": e.hours
                    })
                .toList(),
            hopperTaskAmount: assignedEntity.task.hopperTaskAmount,
            acceptedBy: assignedEntity.task.acceptedHoppers,
            specialReq: assignedEntity.task.specialRequirements,
            preferences: assignedEntity.task.preferences,
            activeHoppersCount: assignedEntity.task.activeHoppersCount,
            activeHoppersLocations: assignedEntity.task.activeHoppersLocations,
          );
          if (taskDetail != null) {
            _updateGoogleMap(
                LatLng(taskDetail!.latitude, taskDetail!.longitude));
            if (_latLng != null) {
              getEstimateTime();
            }
            context
                .read<TaskBloc>()
                .add(GetHopperAcceptedCountEvent(taskDetail!.id));

            // Load hopper avatars for markers
            loadHopperAvatars(taskDetail!.activeHoppersLocations, setState);

            if (widget.autoAction != null) {
              if (widget.autoAction == 'accept') {
                _isAccepted = true;
                _hasSubmittedAction = true;
                if (player.state == PlayerState.playing) {
                  player.stop();
                }
                callAcceptRejectApi();
              } else if (widget.autoAction == 'decline') {
                _isAccepted = false;
                _hasSubmittedAction = true;
                if (player.state == PlayerState.playing) {
                  player.stop();
                }
                callAcceptRejectApi();
              }
              widget.autoAction = null;
            }
          }
        }

        // Handle hopper accepted count update
        if (state.hopperAcceptedCount != null) {
          _hopperAcceptedCount = state.hopperAcceptedCount!;
        }

        // Handle errors
        if (state.errorMessage != null) {
          if (state.actionStatus == TaskStatus.failure) {
            _hasSubmittedAction = false;
          }
          // showSnackBar("Error", state.errorMessage!, Colors.red);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: taskDetail == null ? SizedBox() : _body(size, state),
        );
      },
    );
  }

  Widget _googleMap(Size size) {
    return SizedBox(
      height: size.height / 2,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(size.width * AppDimensions.numD06),
            bottomRight: Radius.circular(size.width * AppDimensions.numD06)),

        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
                taskDetail?.latitude != 0.0 && taskDetail?.latitude != null
                    ? taskDetail!.latitude
                    : 51.520412,
                taskDetail?.longitude != 0.0 && taskDetail?.longitude != null
                    ? taskDetail!.longitude
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
            if (mapIcon != null)
              Marker(
                markerId: const MarkerId("task_location"),
                position: LatLng(
                    taskDetail?.latitude != 0.0 && taskDetail?.latitude != null
                        ? taskDetail!.latitude
                        : 51.520412,
                    taskDetail?.longitude != 0.0 &&
                            taskDetail?.longitude != null
                        ? taskDetail!.longitude
                        : -0.158022),
                anchor: const Offset(0.5, 0.5),
                zIndex: 0.0,
                icon: mapIcon!,
              ),
            // if (taskDetail != null)
            //   ...taskDetail!.activeHoppersLocations.map((hopper) {
            //     return Marker(
            //       markerId: MarkerId(hopper.id.isNotEmpty
            //           ? hopper.id
            //           : "${hopper.latitude}_${hopper.longitude}"),
            //       position: LatLng(hopper.latitude, hopper.longitude),
            //       anchor: const Offset(0.5, 0.5),
            //       zIndex: 1.0,
            //       icon: hopperAvatarIcons[hopper.avatar] ?? mapIcon!,
            //     );
            //   }).toSet(),
          },
        ),
        // child: GoogleMap(
        //   zoomControlsEnabled: false,
        //   myLocationEnabled: true,
        //   myLocationButtonEnabled: false,
        //   mapType: MapType.normal,
        //   initialCameraPosition: CameraPosition(
        //     target: LatLng(taskDetail?.latitude ?? latitude,
        //         taskDetail?.longitude ?? longitude),
        //     zoom: 14.4746,
        //   ),
        //   onMapCreated: (controller) {
        //     if (!_controller.isCompleted) {
        //       _controller.complete(controller);
        //     }
        //     if (taskDetail != null) {
        //       _updateGoogleMap(
        //           LatLng(taskDetail!.latitude, taskDetail!.longitude));
        //     }
        //   },
        //   markers: Set<Marker>.of(marker),
        // ),
      ),
    );
  }

  Widget _body(Size size, TaskState state) {
    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.zero,
          children: [
            _googleMap(size),
            Container(
              margin: EdgeInsets.only(
                left: size.width * AppDimensions.numD02,
                right: size.width * AppDimensions.numD02,
                top: size.width * AppDimensions.numD03,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * AppDimensions.numD02,
                        vertical: size.width * AppDimensions.numD02),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(
                          size.width * AppDimensions.numD04),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.my_location,
                            ),
                            SizedBox(
                              width: size.width * AppDimensions.numD02,
                            ),
                            SizedBox(
                              width: size.width * 0.426,
                              child: Text(
                                "$_hopperAcceptedCount Hoppers",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize:
                                        size.width * AppDimensions.numD035,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal),
                              ),
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
                              Icons.location_on_sharp,
                            ),
                            SizedBox(
                              width: size.width * 0.023,
                            ),
                            Text(
                              _distance,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                            ),
                            const Spacer(),
                            // Container(
                            //   width: 1,
                            //   height: size.width * AppDimensions.numD04,
                            //   color: Colors.grey,
                            // ),
                          ],
                        ),
                        SizedBox(
                          height: size.width * AppDimensions.numD02,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.directions_walk,
                            ),
                            SizedBox(
                              width: size.width * AppDimensions.numD01,
                            ),
                            SizedBox(
                              width: size.width * AppDimensions.numD44,
                              child: Text(
                                _walkingEstTime,
                                overflow: TextOverflow.ellipsis,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize:
                                        size.width * AppDimensions.numD035,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal),
                              ),
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
                            ),
                            SizedBox(
                              width: size.width * AppDimensions.numD01,
                            ),
                            Text(
                              _drivingEstTime,
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD03,
                  ),

                  Row(
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(
                              size.width * AppDimensions.numD04),
                          child: Image.network(
                            taskDetail!.mediaHouseImage,
                            height: size.width * AppDimensions.numD12,
                            width: size.width * AppDimensions.numD12,
                            fit: BoxFit.cover,
                            errorBuilder: (context, object, stacktrace) {
                              return Padding(
                                padding: EdgeInsets.all(
                                    size.width * AppDimensions.numD02),
                                child: Image.asset(
                                  "${commonImagePath}rabbitLogo.png",
                                  height: size.width * AppDimensions.numD07,
                                  width: size.width * AppDimensions.numD07,
                                ),
                              );
                            },
                          )),
                      SizedBox(
                        width: size.width * AppDimensions.numD03,
                      ),
                      Text(
                        taskDetail!.mediaHouseName.toUpperCase(),
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD04,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),

                  /// News Company Name

                  SizedBox(
                    height: size.width * AppDimensions.numD05,
                  ),

                  /// News Headline
                  Text(
                    taskDetail!.title,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * AppDimensions.numD04,
                        color: Colors.black,
                        lineHeight: 1.5,
                        fontWeight: FontWeight.w600),
                  ),

                  SizedBox(
                    height: size.width * AppDimensions.numD02,
                  ),

                  /// News Description
                  Text(
                    taskDetail!.description,
                    style: commonTextStyle(
                      size: size,
                      fontSize: size.width * AppDimensions.numD03,
                      color: Colors.black,
                      lineHeight: 1.8,
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.justify,
                  ),

                  if (taskDetail!.specialReq.isNotEmpty) ...[
                    SizedBox(height: size.width * AppDimensions.numD05),
                    Text(
                      "SPECIAL REQUIREMENTS",
                      style: commonTextStyle(
                        size: size,
                        fontSize: size.width * AppDimensions.numD035,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: size.width * AppDimensions.numD02),
                    Text(
                      taskDetail!.specialReq,
                      style: commonTextStyle(
                        size: size,
                        fontSize: size.width * AppDimensions.numD03,
                        color: Colors.black,
                        lineHeight: 1.8,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],

                  if (taskDetail?.preferences != null &&
                      ((taskDetail?.preferences?["pictureStyle"]?.isNotEmpty ==
                              true) ||
                          (taskDetail
                                  ?.preferences?["videoLength"]?.isNotEmpty ==
                              true) ||
                          (taskDetail?.preferences?["distance"]?.isNotEmpty ==
                              true))) ...[
                    SizedBox(height: size.width * AppDimensions.numD05),
                    Text(
                      "Capture in ${_getPrefText(taskDetail?.preferences?["pictureStyle"], "Landscape")} format, "
                      "record a ${_getPrefText(taskDetail?.preferences?["videoLength"], "40-50s")} video, "
                      "and keep a distance of approximately ${_getPrefText(taskDetail?.preferences?["distance"], "15-20m")}.",
                      style: commonTextStyle(
                        size: size,
                        fontSize: size.width * AppDimensions.numD03,
                        color: Colors.black,
                        lineHeight: 1.8,
                        fontWeight: FontWeight.normal,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],

                  /// Divider
                  const Divider(
                    thickness: 1,
                    color: AppColorTheme.colorLightGrey,
                  ),

                  Container(
                    margin: EdgeInsets.only(
                      top: size.width * AppDimensions.numD04,
                      bottom: size.width * AppDimensions.numD05,
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: size.width * AppDimensions.numD03,
                                horizontal: size.width * AppDimensions.numD02),
                            decoration: BoxDecoration(
                                color: AppColorTheme.colorLightGrey,
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD03)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      "${iconsPath}ic_yearly_calendar.png",
                                      width: size.width * AppDimensions.numD035,
                                      color: Colors.black,
                                    ),
                                    SizedBox(
                                        width:
                                            size.width * AppDimensions.numD02),
                                    Text(
                                      dateTimeFormatter(
                                        dateTime:
                                            taskDetail?.createdAt.toString() ??
                                                '',
                                        format: "dd MMM yyyy",
                                      ),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            size.width * AppDimensions.numD03,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: size.height * AppDimensions.numD005,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: size.width * AppDimensions.numD035,
                                      color: Colors.black54,
                                    ),
                                    SizedBox(
                                        width:
                                            size.width * AppDimensions.numD02),
                                    Text(
                                      "From : ${dateTimeFormatter(dateTime: taskDetail?.createdAt ?? "", format: "hh:mm a")}",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize:
                                            size.width * AppDimensions.numD028,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: size.height * AppDimensions.numD003,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: size.width * AppDimensions.numD035,
                                      color: Colors.black54,
                                    ),
                                    SizedBox(
                                        width:
                                            size.width * AppDimensions.numD02),
                                    Text(
                                      "To      : ${dateTimeFormatter(dateTime: taskDetail?.deadLine.toString() ?? '', format: "hh:mm a")}",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize:
                                            size.width * AppDimensions.numD028,
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
                          width: size.width * AppDimensions.numD05,
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: size.width * AppDimensions.numD03,
                                horizontal: size.width * AppDimensions.numD02),
                            decoration: BoxDecoration(
                                color: AppColorTheme.colorLightGrey,
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD03)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      "${iconsPath}ic_location.png",
                                      width: size.width * AppDimensions.numD03,
                                    ),
                                    SizedBox(
                                      width: size.width * AppDimensions.numD01,
                                    ),
                                    Text(
                                      AppStrings.locationText.toUpperCase(),
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize:
                                              size.width * AppDimensions.numD03,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: size.width * AppDimensions.numD01,
                                    top: size.width * AppDimensions.numD01,
                                  ),
                                  child: Text(
                                    taskDetail!.location,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD03,
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
                ),

                  priceOfferWidget(),

                  SizedBox(
                    height: size.width * AppDimensions.numD1,
                  ),

                  /// Button
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * AppDimensions.numD08,
                          vertical: size.width * AppDimensions.numD04),
                      decoration: BoxDecoration(
                          color: taskDetail!.deadLine.isBefore(DateTime.now())
                              ? AppColorTheme.colorLightGrey
                              : AppColorTheme.colorThemePink,
                          borderRadius: BorderRadius.circular(
                              size.width * AppDimensions.numD04)),
                      child: GestureDetector(
                        onTap: taskDetail!.deadLine.isBefore(DateTime.now())
                            ? () {
                                // showSnackBar(
                                //     "Task Expired",
                                //     "The deadline for this task has passed and it can no longer be accepted.",
                                //     Colors.red);
                              }
                            : () {
                                if (_hasSubmittedAction) {
                                  // showSnackBar(
                                  //     "Action already submitted",
                                  //     "You have already performed an action on this task.",
                                  //     Colors.red);
                                  return;
                                }

                                if (state.actionStatus == TaskStatus.loading) {
                                  return;
                                }

                                if (sharedPreferences != null &&
                                    taskDetail!.acceptedBy.contains(
                                        sharedPreferences!.getString(
                                                SharedPreferencesKeys
                                                    .hopperIdKey) ??
                                            "")) {
                                  // showSnackBar(
                                  //     "Already Accepted",
                                  //     "You have already accepted this task.",
                                  //     Colors.red);
                                  return;
                                }

                                _isAccepted = true;
                                if (player.state == PlayerState.playing) {
                                  player.stop();
                                }
                                _hasSubmittedAction = true;
                                callAcceptRejectApi();

                                debugPrint("accepted====>");
                                if (mounted) {
                                  setState(() {});
                                }
                              },
                        child: state.actionStatus == TaskStatus.loading
                            ? SizedBox(
                                height: size.width * AppDimensions.numD05,
                                width: size.width * AppDimensions.numD05,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                taskDetail!.deadLine.isBefore(DateTime.now())
                                    ? "Too Late!"
                                    : "Accept $currencySymbol${formatDouble(double.tryParse(taskDetail!.hopperTaskAmount) ?? 0.0)}",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * AppDimensions.numD04,
                                    color: taskDetail!.deadLine
                                            .isBefore(DateTime.now())
                                        ? Colors.black
                                        : Colors.white,
                                    fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: size.height * AppDimensions.numD07,
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
                context.pop();
              },
              child: Container(
                margin: EdgeInsets.only(
                    top: size.width * AppDimensions.numD14,
                    left: size.width * AppDimensions.numD04),
                padding: EdgeInsets.all(size.width * AppDimensions.numD02),
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: Image.asset(
                  "${iconsPath}ic_arrow_left.png",
                  height: size.width * AppDimensions.numD06,
                  width: size.width * AppDimensions.numD06,
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                debugPrint("🚀 Share button tapped");
                try {
                  final String firstName = sharedPreferences
                          ?.getString(SharedPreferencesKeys.firstNameKey) ??
                      "";
                  final String lastName = sharedPreferences
                          ?.getString(SharedPreferencesKeys.lastNameKey) ??
                      "";
                  final String appUrl = ApiConstantsNew.config.appUrl;

                  String shareText =
                      "${taskDetail?.title ?? ""}\n ${taskDetail?.description ?? ""}.\n\n"
                      "Hi there, $firstName $lastName has shared a task priced from "
                      "$currencySymbol${taskDetail?.minimumPriceRange ?? ""} to "
                      "$currencySymbol${taskDetail?.maximumPriceRange ?? ""} with you. "
                      "Please click this $appUrl to download PressHop and review the task. Cheers";

                  debugPrint("🚀 Sharing text: $shareText");
                  final RenderBox? box = context.findRenderObject() as RenderBox?;
                  await Share.share(
                    shareText,
                    sharePositionOrigin:
                        box!.localToGlobal(Offset.zero) & box.size,
                  );
                } catch (e) {
                  debugPrint("❌ Share Error: $e");
                }
              },
              child: Container(
                margin: EdgeInsets.only(
                    top: size.width * AppDimensions.numD14,
                    left: size.width * AppDimensions.numD04),
                padding: EdgeInsets.all(size.width * AppDimensions.numD02),
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: Image.asset(
                  "${iconsPath}ic_share_now.png",
                  height: size.width * AppDimensions.numD06,
                  width: size.width * AppDimensions.numD06,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  // /// show-share-bottom-sheet

  /// Price Offer widget
  Widget priceOfferWidget() {
    return Column(
      children: [
        const Divider(),
        // SizedBox(height: size.width * AppDimensions.numD02),
        // /// Illustration
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
        //             "${taskDetail!.currencySymbol.isNotEmpty ? taskDetail!.currencySymbol : currencySymbol}${taskDetail!.hopperTaskAmount} ",
        //         style: TextStyle(
        //           color: Colors.black,
        //           fontSize: size.width * AppDimensions.numD07,
        //           fontWeight: FontWeight.w800,
        //         ),
        //       ),
        //       TextSpan(
        //         text:
        //             "for ${taskDetail!.hopperInfo.isNotEmpty ? taskDetail!.hopperInfo.first["hours"] : "0"} hours",
        //         style: TextStyle(
        //           color: Colors.black,
        //           fontSize: size.width * AppDimensions.numD04,
        //           fontWeight: FontWeight.w600,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),

        Container(
          margin: EdgeInsets.symmetric(
              horizontal: size.width * AppDimensions.numD04),
          height: size.width * 0.5,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(size.width * AppDimensions.numD03),
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(size.width * AppDimensions.numD03),
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                        taskDetail?.latitude != 0.0 &&
                                taskDetail?.latitude != null
                            ? taskDetail!.latitude
                            : 51.520412,
                        taskDetail?.longitude != 0.0 &&
                                taskDetail?.longitude != null
                            ? taskDetail!.longitude
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
                    if (mapIcon != null)
                      Marker(
                        markerId: const MarkerId("task_location"),
                        position: LatLng(
                            taskDetail?.latitude != 0.0 &&
                                    taskDetail?.latitude != null
                                ? taskDetail!.latitude
                                : 51.520412,
                            taskDetail?.longitude != 0.0 &&
                                    taskDetail?.longitude != null
                                ? taskDetail!.longitude
                                : -0.158022),
                        anchor: const Offset(0.5, 0.5),
                        zIndex: 0.0,
                        icon: mapIcon!,
                      ),
                    if (taskDetail != null)
                      ...taskDetail!.activeHoppersLocations.map((hopper) {
                        return Marker(
                          markerId: MarkerId(hopper.id.isNotEmpty
                              ? hopper.id
                              : "${hopper.latitude}_${hopper.longitude}"),
                          position: LatLng(hopper.latitude, hopper.longitude),
                          anchor: const Offset(0.5, 0.5),
                          zIndex: 1.0,
                          icon: hopperAvatarIcons[hopper.avatar] ?? mapIcon!,
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
                        horizontal: size.width * AppDimensions.numD03,
                        vertical: size.width * AppDimensions.numD03),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                          size.width * AppDimensions.numD02),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text:
                            "${taskDetail?.activeHoppersCount ?? 0} active Hoppers nearby. ",
                        style: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD03,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: "Grab it before it's gone.",
                            style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD03,
                              color: AppColorTheme.colorThemePink,
                              fontWeight: FontWeight.w500,
                            ),
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
          topLeft: Radius.circular(size.width * AppDimensions.numD085),
          topRight: Radius.circular(size.width * AppDimensions.numD085),
        )),
        builder: (context) {
          return StatefulBuilder(builder: (context, stateSetter) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// Heading
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * AppDimensions.numD05,
                  ).copyWith(
                    top: size.width * AppDimensions.numD05,
                    bottom: size.width * AppDimensions.numD02,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          context.pop();
                          context.pop();
                        },
                        splashRadius: size.width * AppDimensions.numD05,
                        icon: Icon(
                          Icons.close,
                          color: Colors.black,
                          size: size.width * AppDimensions.numD06,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Share the task",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD045,
                                color: Colors.black,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),

                      /*    /// Share Button
                      isMultipleContact
                          ? commonElevatedButton(
                              AppStrings.shareText,
                              size,
                              commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                              commonButtonStyle(size, AppColorTheme.colorThemePink),
                              () {})
                          : Container(),*/
                    ],
                  ),
                ),

                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * AppDimensions.numD04,
                      vertical: size.width * AppDimensions.numD04,
                    ),
                    children: [
                      /// Share Sub Text
                      Text(
                        AppStrings.boardCastShareSubText,
                        textAlign: TextAlign.center,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD03,
                      ),

                      /// Search
                      TextFormField(
                        controller: contactSearchController,
                        cursorColor: AppColorTheme.colorTextFieldIcon,
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
                          fillColor: AppColorTheme.colorLightGrey,
                          isDense: true,
                          filled: true,
                          hintText: AppStrings.searchHintText,
                          hintStyle: TextStyle(
                              color: AppColorTheme.colorHint,
                              fontSize: size.width * AppDimensions.numD04),
                          disabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.03),
                              borderSide: const BorderSide(
                                  width: 0,
                                  color: AppColorTheme.colorLightGrey)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.03),
                              borderSide: const BorderSide(
                                  width: 0,
                                  color: AppColorTheme.colorLightGrey)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.03),
                              borderSide: const BorderSide(
                                  width: 0,
                                  color: AppColorTheme.colorLightGrey)),
                          errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.03),
                              borderSide: const BorderSide(
                                  width: 0,
                                  color: AppColorTheme.colorLightGrey)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.03),
                              borderSide: const BorderSide(
                                  width: 0,
                                  color: AppColorTheme.colorLightGrey)),
                          suffixIcon: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * AppDimensions.numD02),
                            child: Image.asset(
                              "${iconsPath}ic_search.png",
                              color: Colors.black,
                            ),
                          ),
                          suffixIconConstraints: BoxConstraints(
                              maxHeight: size.width * AppDimensions.numD06),
                        ),
                        textAlignVertical: TextAlignVertical.center,
                      ),

                      /// User List
                      contactsDataList.isNotEmpty
                          ? ListView.separated(
                              padding: EdgeInsets.symmetric(
                                  vertical: size.width * AppDimensions.numD06),
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
                                    padding: EdgeInsets.all(
                                        size.width * AppDimensions.numD02),
                                    color: item.isContactSelected
                                        ? AppColorTheme.colorLightGrey
                                        : Colors.transparent,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              height: size.width *
                                                  AppDimensions.numD15,
                                              width: size.width *
                                                  AppDimensions.numD15,
                                              padding: EdgeInsets.all(
                                                  size.width *
                                                      AppDimensions.numD01),
                                              decoration: const BoxDecoration(
                                                  color: AppColorTheme
                                                      .colorThemePink,
                                                  shape: BoxShape.circle),
                                              child: ClipOval(
                                                child: item.avatar != null
                                                    ? Image.memory(
                                                        item.avatar!,
                                                        height: size.width *
                                                            AppDimensions
                                                                .numD09,
                                                        width: size.width *
                                                            AppDimensions
                                                                .numD09,
                                                        fit: BoxFit.contain,
                                                        errorBuilder:
                                                            (context, dd, v) {
                                                          return Center(
                                                              child: Text(
                                                            item.displayName![0]
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontSize: size
                                                                        .width *
                                                                    AppDimensions
                                                                        .numD05,
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
                                                              fontSize: size
                                                                      .width *
                                                                  AppDimensions
                                                                      .numD05,
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
                                              width: size.width *
                                                  AppDimensions.numD025,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: size.width *
                                                      AppDimensions.numD30,
                                                  child: Text(
                                                    item.displayName.toString(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: commonTextStyle(
                                                        size: size,
                                                        fontSize: size.width *
                                                            AppDimensions
                                                                .numD037,
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
                                                      fontSize: size.width *
                                                          AppDimensions.numD035,
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
                                                            '${taskDetail!.title}\n${taskDetail!.description}\nHi ${item.displayName}, ${sharedPreferences!.getString(SharedPreferencesKeys.firstNameKey).toString()} ${sharedPreferences!.getString(SharedPreferencesKeys.lastNameKey).toString()} has shared a task priced from $currencySymbol${taskDetail!.minimumPriceRange} to $currencySymbol${taskDetail!.maximumPriceRange} with you. Please click this ${Uri.parse(ApiConstantsNew.config.appUrl)} to download PressHop and review the task.Cheers'
                                                      });
                                                  if (await canLaunchUrl(uri)) {
                                                    await launchUrl(uri);
                                                  } else {
                                                    // showSnackBar(
                                                    //     'PressHop',
                                                    //     AppStrings.errorOpenSMS,
                                                    //     Colors.black);
                                                    // Handle the case when the URL can't be launched.
                                                    throw 'Error launching Sms';
                                                  }
                                                },
                                                splashRadius: size.width *
                                                    AppDimensions.numD05,
                                                icon: Image.asset(
                                                  "${iconsPath}message_icon.png",
                                                  height: size.width *
                                                      AppDimensions.numD06,
                                                )),
                                            IconButton(
                                                splashRadius: size.width *
                                                    AppDimensions.numD05,
                                                onPressed: () async {
                                                  /*Uri whatsappUrl = Uri.parse(
                                                      "whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent("${taskDetail!.title}\n\n ${taskDetail!.description}"
                                                          "\n\n ${Uri.parse(appUrl)}")}"); */

                                                  Share.share(Uri.encodeComponent(
                                                      "${taskDetail!.title}\n ${taskDetail!.description}\n\n Hi ${item.displayName}, ${sharedPreferences!.getString(SharedPreferencesKeys.firstNameKey).toString()} ${sharedPreferences!.getString(SharedPreferencesKeys.lastNameKey).toString()} has shared a task priced from $currencySymbol${taskDetail!.minimumPriceRange} to $currencySymbol${taskDetail!.maximumPriceRange} with you. Please click this ${Uri.parse(ApiConstantsNew.config.appUrl)} to download PressHop and review the task. Cheers"));
                                                },
                                                icon: Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: size.width *
                                                          AppDimensions
                                                              .numD006),
                                                  child: Image.asset(
                                                    "${iconsPath}whatsapp_icon.png",
                                                    height: size.width *
                                                        AppDimensions.numD058,
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
                                  height: size.width * AppDimensions.numD04,
                                );
                              },
                              itemCount: contactSearchController.text.isNotEmpty
                                  ? contactSearch.length
                                  : contactsDataList.length)
                          : Center(
                              child: Padding(
                                padding: EdgeInsets.all(
                                    size.width * AppDimensions.numD05),
                                child: const Text("Not Contact Available"),
                              ),
                            ),

                      /* /// Share Button
                      contactsDataList != null
                          ? Container(
                        width: size.width,
                        height: size.width * AppDimensions.numD14,
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * AppDimensions.numD08,
                        ),
                        margin: EdgeInsets.only(
                          top: size.width * AppDimensions.numD06,
                          bottom: size.width * AppDimensions.numD08,
                        ),
                        child: commonElevatedButton(
                            AppStrings.shareText,
                            size,
                            commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD035,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                            commonButtonStyle(size, AppColorTheme.colorThemePink),
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
    marker.clear();
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
      // showSnackBar(
      //     "Permission Denied", "Please Allow Loction permission", Colors.red);
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
  Future<void> getEstimateTime() async {
    if (_latLng == null || taskDetail == null) return;

    final origin = "${_latLng!.latitude},${_latLng!.longitude}";
    final destination = "${taskDetail!.latitude},${taskDetail!.longitude}";

    final apiKey = ApiConstantsNew.config.appleMapApiKey;

    final url = "https://maps.googleapis.com/maps/api/distancematrix/json"
        "?origins=$origin"
        "&destinations=$destination"
        "&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data["rows"].isNotEmpty) {
        final element = data["rows"][0]["elements"][0];

        setState(() {
          _distance = element["distance"]["text"]; // e.g. "5.2 km"
          _drivingEstTime = element["duration"]["text"]; // driving
        });
      }

      // Walking time API call
      final walkUrl = "https://maps.googleapis.com/maps/api/distancematrix/json"
          "?origins=$origin"
          "&destinations=$destination"
          "&mode=walking"
          "&key=$apiKey";

      final walkResponse = await http.get(Uri.parse(walkUrl));
      final walkData = json.decode(walkResponse.body);

      if (walkData["rows"].isNotEmpty) {
        final walkElement = walkData["rows"][0]["elements"][0];

        setState(() {
          _walkingEstTime = walkElement["duration"]["text"];
        });
      }
    } catch (e) {
      debugPrint("Distance API Error: $e");
    }
  }
  // void getEstimateTime() {
  //   debugPrint("::: Inside estimate Time Fuc ::::");
  //   dynamic mapKey;
  //   if (Platform.isIOS) {
  //     mapKey = ApiConstantsNew.config.appleMapApiKey;
  //   } else {
  //     mapKey = ApiConstantsNew.config.googleMapApiKey;
  //   }

  //   String drivingMode =
  //       "https://maps.googleapis.com/maps/api/distancematrix/json?origins="
  //       "${_latLng!.latitude},${_latLng!.longitude}&&destinations="
  //       "${taskDetail!.latitude},${taskDetail!.longitude}"
  //       "&mode=driving&key=$mapKey";

  //   String walkingMode =
  //       "https://maps.googleapis.com/maps/api/distancematrix/json?origins="
  //       "${_latLng!.latitude},${_latLng!.longitude}&destinations="
  //       "${taskDetail!.latitude},${taskDetail!.longitude}&mode=walking&key=$mapKey";

  //   debugPrint("drivingMode : $drivingMode");
  //   debugPrint("walkingMode : $walkingMode");

  // }

  // /// Accept Reject Api
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

  String _getPrefText(dynamic value, String defaultValue) {
    if (value == null || value.toString().isEmpty) {
      return defaultValue;
    }
    return value.toString();
  }

  @override
  // TODO: implement pageName
  String get pageName => "BroardcastScreen";
}

class ContactListModel {
  ContactListModel(
      {required this.displayName,
      required this.givenName,
      required this.middleName,
      required this.phones,
      required this.avatar,
      required this.isContactSelected});
  String? identifier, displayName, givenName, middleName;
  List<Phone>? phones = [];
  Uint8List? avatar;
  bool isContactSelected = false;
}

/// Show loader dialog
// Future<void> _showLoaderDialog(BuildContext context) async {
//   // Show the dialog and wait for it to be fully rendered
//   showDialog(
//     barrierDismissible: false,
//     barrierColor: Colors.white.withOpacity(0),
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         elevation: 0,
//         backgroundColor: Colors.white.withOpacity(0),
//         content: Center(child: showLoader()),
//       );
//     },
//   );
// }
