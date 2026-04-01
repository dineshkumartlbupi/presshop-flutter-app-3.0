import 'dart:async';
import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/global_loader.dart';
import 'package:presshop/features/camera/presentation/pages/camera_screen.dart';
import 'package:presshop/features/content/presentation/pages/content_page.dart';
import 'package:presshop/features/map/presentation/pages/map_page.dart';

import 'package:presshop/features/menu/presentation/pages/menu_screen.dart';
import 'package:presshop/features/task/presentation/pages/task_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:location/location.dart' as lc;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/features/content/presentation/bloc/content_bloc.dart';
import 'package:presshop/features/content/presentation/bloc/content_event.dart';
import 'package:presshop/features/task/presentation/bloc/task_bloc.dart';
import 'package:presshop/features/task/presentation/bloc/task_event.dart'
    hide FetchTaskDetailEvent;
import 'package:presshop/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:presshop/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:presshop/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/features/dashboard/presentation/widgets/student_beans_dialog.dart';
import 'package:presshop/features/dashboard/presentation/utils/dashboard_notification_mixin.dart';
import 'package:presshop/features/dashboard/presentation/utils/dashboard_location_mixin.dart';
import 'package:presshop/features/dashboard/presentation/utils/dashboard_deeplink_mixin.dart';
import 'package:presshop/core/services/background_location_service.dart';
import 'package:presshop/features/dashboard/presentation/widgets/dashboard_bottom_nav.dart';

// ignore: must_be_immutable
class Dashboard extends StatefulWidget {
  Dashboard(
      {super.key,
      required this.initialPosition,
      this.openChatScreen = false,
      this.openNotification = false,
      this.openBeansActivation = false,
      this.broadCastId,
      this.taskStatus,
      this.sourceDataType = "",
      this.sourceDataIsOpened = false,
      this.sourceDataUrl = "",
      this.sourceDataHeading = "",
      this.sourceDataDescription = "",
      this.isClick = false});
  int initialPosition = 2;
  String? broadCastId;
  String? taskStatus = "";
  bool openChatScreen = false;
  bool openNotification = false;
  bool openBeansActivation = false;
  String? sourceDataType = "";
  bool? sourceDataIsOpened = false;
  String? sourceDataUrl = "";
  String? sourceDataHeading = "";
  String? sourceDataDescription = "";
  bool? isClick = false;

  @override
  State<StatefulWidget> createState() {
    return DashboardState();
  }
}

class DashboardState extends State<Dashboard>
    with
        AnalyticsPageMixin,
        WidgetsBindingObserver,
        DashboardNotificationMixin,
        DashboardLocationMixin,
        DashboardDeepLinkMixin {
  late Size size;
  late DashboardBloc _dashboardBloc;
  int currentIndex = 2;
  String fcmToken = "";
  String deviceId = "";
  static DashBoardInterface? dashBoardInterface;
  final GlobalKey<CameraScreenState> _cameraKey =
      GlobalKey<CameraScreenState>();
  final GlobalKey<MyContentViewState> _contentKey =
      GlobalKey<MyContentViewState>();
  final GlobalKey<MyTaskScreenState> _taskKey = GlobalKey<MyTaskScreenState>();

  final player = AudioPlayer();

  String? savedSourceDataHeading = "";
  String? savedSourceDataDescription = "";

  lc.LocationData? locationData;
  late LocationService _locationService;
  String mediaAddress = "", mediaDate = "", country = "", state = "", city = "";
  int totalEntitiesCount = 0;
  double x = 0, y = 0, latitude = 22.5744, longitude = 88.3629;

  int page = 0;
  Completer<String?>? _studentBeansCompleter;

  bool isGetLatLong = false;
  String? studentBeansResponseUrlGlobal = "";

  List<AdminDetailModel> adminList = [];
  List<String> adminIDList = [];
  DateTime? currentTime;
  late List<Widget> bottomNavigationScreens;
  final Set<int> _loadedIndices = {};
  DateTime? _lastLocationUpdateTime;

  late AppLinks linkStream;

  @override
  String get pageName => PageNames.dashboard;

  @override
  Map<String, Object>? get pageParameters => {
        'initial_position': widget.initialPosition.toString(),
        'user_id':
            sharedPreferences?.getString(SharedPreferencesKeys.hopperIdKey) ??
                'unknown',
        'current_tab': currentIndex.toString(),
      };

  @override
  void initState() {
    GlobalLoader.forceHide();
    _dashboardBloc = sl<DashboardBloc>();
    myProfileApi();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUpdateAndShowPopup();
    });
    _handlePermissionSequence();
    _updateBottomNavigationScreens();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _locationService = sl<LocationService>();

    _dashboardBloc.add(CheckAppVersionEvent());

    Map<String, dynamic> roomParams = {
      "participants": ["hopper_id_1", "media_house_id_1"],
      "type": "content_negotiation",
      "content_id": "content_123"
    };
    _dashboardBloc.add(FetchRoomIdEvent(roomParams));

    currentIndex = 2;
    _loadedIndices.add(currentIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ContentBloc>()
          .add(const FetchMyContentEvent(type: 'all', page: 1, limit: 10));
      context
          .read<ContentBloc>()
          .add(const FetchMyContentEvent(type: 'my', page: 1, limit: 10));

      context.read<TaskBloc>().add(const FetchAllTasksEvent(offset: 0));
      context.read<TaskBloc>().add(const FetchLocalTasksEvent());
    });

    if (widget.taskStatus != 'rejected') {
      if (widget.broadCastId != null) {
        _dashboardBloc.add(FetchTaskDetailEvent(widget.broadCastId!));
      }
      getFcmToken();

      initFirebaseMessaging(
        onTaskAssigned: (broadCastId) {
          if (mounted) {
            if (dashBoardInterface != null) {
              dashBoardInterface!.saveDraft();
            }
            callTaskDetailApi(broadCastId);
          }
        },
        onProfileUpdate: () => myProfileApi(),
      );
    }

    if (sharedPreferences!.getString(SharedPreferencesKeys.adminRoomIdKey) ==
            null ||
        sharedPreferences!
            .getString(SharedPreferencesKeys.adminRoomIdKey)!
            .isEmpty) {
      _dashboardBloc.add(FetchActiveAdmins());
    }

    isGetLatLong = false;
    if (widget.openChatScreen) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.pushNamed(AppRoutes.chatName,
              extra: {'hideLeading': false, 'message': ''});
        }
      });
    } else if (widget.openNotification) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.pushNamed(AppRoutes.notificationsName, extra: {'count': 1});
        }
      });
    } else if (widget.openBeansActivation) {
      Future.delayed(const Duration(seconds: 2), () {
        _dashboardBloc.add(ActivateStudentBeansEvent());
      });
    } else {
      _dashboardBloc.add(DashboardCheckStudentBeansEvent());
    }
    initDeepLinks(sl<AppLinks>());
    super.initState();
  }

  @override
  void dispose() {
    player.dispose();
    _dashboardBloc.close();
    super.dispose();
  }

  void _updateBottomNavigationScreens() {
    bottomNavigationScreens = <Widget>[
      MyContentPage(
          contentKey: _contentKey,
          hideLeading: true,
          showAppBar: false,
          fromMenu: false),
      MyTaskScreen(key: _taskKey, hideLeading: true, showAppBar: false),
      CameraScreen(
        key: _cameraKey,
        picAgain: false,
        previousScreen: ScreenNameEnum.dashboardScreen,
      ),
      // BlocProvider(
      //   create: (context) => sl<NewsBloc>()..add(const GetAllNewsEvent()),
      //   child: const NewsPage(
      //     hideLeading: true,
      //     showAppBar: false,
      //   ),
      // ),
      MapPage(hideLeading: true, showAppBar: false),
      // OptimisedMapPage2(),

      MenuScreen()
    ];
  }

  void myProfileApi() {
    _dashboardBloc.add(FetchMyProfileEvent());
  }

  void _checkUpdateAndShowPopup() async {
    final String? savedSourceDataType =
        sharedPreferences?.getString(SharedPreferencesKeys.sourceDataTypeKey);
    savedSourceDataHeading = sharedPreferences
        ?.getString(SharedPreferencesKeys.sourceDataHeadingKey);
    savedSourceDataDescription = sharedPreferences
        ?.getString(SharedPreferencesKeys.sourceDataDescriptionKey);
    final bool? savedSourceDataIsOpened =
        sharedPreferences?.getBool(SharedPreferencesKeys.sourceDataIsOpenedKey);
    final bool? savedSourceDataIsClickKey =
        sharedPreferences?.getBool(SharedPreferencesKeys.sourceDataIsClickKey);

    debugPrint('savedSourceDataTypeghgg: $savedSourceDataType');
    debugPrint('savedSourceDataHeading: $savedSourceDataHeading');
    debugPrint('savedSourceDataDescription: $savedSourceDataDescription');
    debugPrint('savedSourceDataIsOpened: $savedSourceDataIsOpened');
    debugPrint('savedSourceDataIsClickKey: $savedSourceDataIsClickKey');

    bool checkFromLocalStorage =
        (savedSourceDataType ?? '').toLowerCase() == 'studentbeans' &&
            (savedSourceDataIsOpened == false) &&
            savedSourceDataIsClickKey == false;

    if (checkFromLocalStorage) {
      final size = MediaQuery.of(navigatorKey.currentState!.context).size;
      _showStudentBeansDialog(
        size,
      );
    }
  }

  void _showStudentBeansDialog(Size size,
      {String? sourceDataHeading, String? sourceDataDescription}) {
    showDialog(
      barrierDismissible: false,
      context: navigatorKey.currentState!.context,
      builder: (context) => StudentBeansDialog(
        size: size,
        heading: sourceDataHeading,
        description: sourceDataDescription,
        onConfirm: () async {
          try {
            context.pop();
          } catch (e) {
            debugPrint("Error launching URL: $e");
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocProvider.value(
        value: _dashboardBloc,
        child: BlocListener<DashboardBloc, dynamic>(
            listener: _handleDashboardState,
            child: PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) return;
                DateTime now = DateTime.now();
                if (currentTime == null ||
                    now.difference(currentTime!) > const Duration(seconds: 2)) {
                  currentTime = now;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Press again to exit'),
                    ),
                  );
                } else {
                  SystemNavigator.pop();
                  exit(0);
                }
              },
              child: Scaffold(
                // appBar: _buildDashboardAppBar(size),
                bottomNavigationBar: DashboardBottomNavBar(
                  size: size,
                  currentIndex: currentIndex,
                  onTap: _onBottomBarItemTapped,
                ),
                body: Stack(
                  children: [
                    const Center(
                        child: Text("This is the center Text for popup")),
                    Visibility(
                      visible: !isGetLatLong,
                      replacement: showLoader(isForLocation: false),
                      child: IndexedStack(
                        index: currentIndex,
                        children: List.generate(bottomNavigationScreens.length,
                            (index) {
                          if (_loadedIndices.contains(index)) {
                            return bottomNavigationScreens[index];
                          }
                          return const SizedBox();
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }

  void _handleDashboardState(BuildContext context, dynamic state) {
    if (state is DashboardActiveAdminsLoaded) {
      setState(() {
        adminList = state.admins
            .map((e) => AdminDetailModel(
                  id: e.id,
                  name: e.name,
                  profilePic: e.profilePic,
                  lastMessageTime: e.lastMessageTime,
                  lastMessage: e.lastMessage,
                  roomId: e.roomId,
                  senderId: e.senderId,
                  receiverId: e.receiverId,
                  roomType: e.roomType,
                ))
            .toList();

        debugPrint(":::: DashboardActiveAdminsLoaded :::::");
        debugPrint("Admins Count: ${adminList.length}");
        if (adminList.isNotEmpty) {
          debugPrint(
              "First Admin: ${adminList.first.id}, Room: ${adminList.first.roomId}");
          sharedPreferences?.setString(
              SharedPreferencesKeys.adminIdKey, adminList.first.id);
          sharedPreferences?.setString(
              SharedPreferencesKeys.adminRoomIdKey, adminList.first.roomId);
          sharedPreferences?.setString(
              SharedPreferencesKeys.adminImageKey, adminList.first.profilePic);
          sharedPreferences?.setString(
              SharedPreferencesKeys.adminNameKey, adminList.first.name);
        } else {
          debugPrint(":::: Admin List is EMPTY! :::::");
        }
      });
    } else if (state is DashboardRoomIdLoaded) {
      var data = state.roomData;
      debugPrint("📦 Dashboard Received Room Data: $data");

      String roomId = "";
      if (data.containsKey("_id")) {
        roomId = data["_id"];
      } else if (data["details"] != null) {
        roomId = data["details"]["room_id"] ?? "";
      }

      if (roomId.isNotEmpty) {
        sharedPreferences!
            .setString(SharedPreferencesKeys.adminRoomIdKey, roomId);
        debugPrint("✅ Room Id Saved: $roomId");
      } else {
        debugPrint("❌ Room Id NOT found in response");
      }
    } else if (state is DashboardAppVersionChecked) {
      var map = state.versionData;
      // Handle both full response and unwrapped data from CheckAppVersionEvent
      var versionData = (map["code"] == 200) ? map["data"] : map;

      if (versionData != null) {
        try {
          sharedPreferences!.setInt(SharedPreferencesKeys.videoLimitKey,
              (versionData['video_limit'] ?? 2) * 60);

          bool shouldUpdate = Platform.isAndroid
              ? (versionData['aOSshouldForceUpdate'] ?? false)
              : (versionData['iOSshouldForceUpdate'] ?? false);

          // Correctly extract and save nested referral data
          if (versionData.containsKey('referral_data') &&
              versionData['referral_data'] is Map) {
            final referralData = versionData['referral_data'] as Map;

            if (referralData.containsKey('referral_friend_earning_amount')) {
              sharedPreferences!.setDouble(
                  SharedPreferencesKeys.referralFriendEarningKey,
                  (referralData['referral_friend_earning_amount'] as num)
                      .toDouble());
            }
            if (referralData.containsKey('referral_user_earning_amount')) {
              sharedPreferences!.setDouble(
                  SharedPreferencesKeys.referralUserEarningKey,
                  (referralData['referral_user_earning_amount'] as num)
                      .toDouble());
            }
            if (referralData.containsKey('referral_currency_symbol')) {
              sharedPreferences!.setString(
                  SharedPreferencesKeys.referralCurrencyKey,
                  referralData['referral_currency_symbol'].toString());
            }
          }

          if (shouldUpdate) forceUpdateCheck();

          String? liveLocationHeading =
              versionData['liveLocationHeading'] as String?;
          double? liveLocationDistance =
              (versionData['liveLocationDistance'] is int)
                  ? (versionData['liveLocationDistance'] as int).toDouble()
                  : versionData['liveLocationDistance'] as double?;
          String? liveLocationDescription =
              versionData['liveLocationDescription'] as String?;

          bool isCustomLocationPopup =
              versionData['is_custom_location_popup'] ?? false;
          String customLocationHeading =
              versionData['custom_location_heading'] ?? "";
          String customLocationDescription =
              versionData['custom_location_description'] ?? "";
          String customPopupImage = versionData['custom_popup_image'] ?? "";
          String locationSharingDescription =
              versionData['location_sharing_description'] ?? "";

          sharedPreferences?.setString(
              SharedPreferencesKeys.customLocationHeadingKey,
              customLocationHeading);
          sharedPreferences?.setString(
              SharedPreferencesKeys.customLocationDescriptionKey,
              customLocationDescription);
          sharedPreferences?.setString(
              SharedPreferencesKeys.customPopupImageKey, customPopupImage);
          sharedPreferences?.setString(
              SharedPreferencesKeys.locationSharingDescriptionKey,
              locationSharingDescription);
          sharedPreferences?.setBool(
              SharedPreferencesKeys.isCustomLocationPopupKey,
              isCustomLocationPopup);

          bool isManuallyStopped = sharedPreferences
                  ?.getBool(SharedPreferencesKeys.manuallyStoppedServiceKey) ??
              false;

          BackgroundLocationService.service
              .isRunning()
              .then((isServiceRunning) {
            if (isServiceRunning && !isManuallyStopped) {
              sharedPreferences?.setBool(
                  SharedPreferencesKeys.isTaskGrabbingActiveKey, true);
            }

            bool isTaskGrabbingActive = sharedPreferences
                    ?.getBool(SharedPreferencesKeys.isTaskGrabbingActiveKey) ??
                false;

            if (!isManuallyStopped) {
              BackgroundLocationService.initService(
                notificationTitle: liveLocationHeading,
                notificationContent: liveLocationDescription,
                distanceFilter: liveLocationDistance,
                context: context,
                showPrePermissionDialog: isCustomLocationPopup &&
                    !isTaskGrabbingActive &&
                    !isServiceRunning,
                dialogTitle: customLocationHeading,
                dialogContent: customLocationDescription,
                dialogImage: customPopupImage,
              ).then((started) {
                if (started) {
                  sharedPreferences?.setBool(
                      SharedPreferencesKeys.isTaskGrabbingActiveKey, true);
                  sharedPreferences?.setBool(
                      SharedPreferencesKeys.manuallyStoppedServiceKey, false);
                }
              });
            }
          });
        } catch (e) {
          debugPrint("Error initializing background service: $e");
        }
      } else {
        debugPrint("Version check failed: ${map["message"]}");
      }
    } else if (state is DashboardTaskDetailLoaded) {
      var task = state.taskDetail;
      player.play(
        AssetSource('audio/task_sound.mp3'),
        volume: 1,
      );
      broadcastDialog(
        size: MediaQuery.of(context).size,
        taskDetail: task,
        onTapViewDetails: () {
          if (mounted) {
            if (dashBoardInterface != null) {
              dashBoardInterface!.saveDraft();
            }
          }
          context.pop();
          context.pushNamed(
            AppRoutes.broadcastName,
            extra: {
              'taskId': task.task.id,
              'mediaHouseId': task.task.mediaHouse.id,
            },
          );
        },
      );
    } else if (state is StudentBeansActivated) {
      var map = state.data;
      var studentBeansResponseUrl = map["url"];

      if (studentBeansResponseUrl != null &&
          studentBeansResponseUrl.isNotEmpty) {
        _launchStudentBeansUrl(studentBeansResponseUrl);
      }

      if (_studentBeansCompleter != null &&
          !_studentBeansCompleter!.isCompleted) {
        _studentBeansCompleter!.complete(studentBeansResponseUrl);
      }
    } else if (state is DashboardStudentBeansInfoLoaded) {
      final info = state.info;
      if (info.shouldShow) {
        final size = MediaQuery.of(navigatorKey.currentState!.context).size;
        _showStudentBeansDialog(size,
            sourceDataHeading: info.heading,
            sourceDataDescription: info.description);
      }
    } else if (state is DashboardMarkStudentBeansVisitedLoaded) {
    } else if (state is DashboardMyProfileLoaded) {
      var user = state.user;
      if (user.avatar != null && user.avatar!.isNotEmpty) {
        sharedPreferences!
            .setString(SharedPreferencesKeys.avatarKey, user.avatar!);
      }
      setState(() {});
    } else if (state is DashboardTabChanged) {
      setState(() {
        currentIndex = state.index;
        _loadedIndices.add(currentIndex);
      });
    } else if (state is DashboardError) {}
  }

  Future<void> getFcmToken() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    fcmToken = await FirebaseMessaging.instance.getToken() ?? "";
    debugPrint("FCM Token:::: $fcmToken");

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      debugPrint('Running on ${androidInfo.model}');
      deviceId = androidInfo.id;
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      debugPrint('Running on ${iosInfo.utsname.machine}');
      deviceId = iosInfo.identifierForVendor!;
    }
    callAddDeviceApi(
        deviceId, Platform.isAndroid ? "android" : "ios", fcmToken);
  }

  Future<void> updateLocationData() async {
    final now = DateTime.now();
    if (_lastLocationUpdateTime != null &&
        now.difference(_lastLocationUpdateTime!).inSeconds < 10) {
      // Avoid calling location continuously within 10 seconds (debouncing)
      return;
    }
    _lastLocationUpdateTime = now;

    locationData = await _locationService.getCurrentLocation(context,
        shouldShowSettingPopup: false);
    if (locationData != null) {
      proceedWithLocation(locationData);
    }
  }

  void goToLocationErrorScreen() {
    handleGoToLocationErrorScreen((lc.LocationData data) {
      proceedWithLocation(data);
    });
  }

  void proceedWithLocation(lc.LocationData? locationData) async {
    handleProceedWithLocation(
      locationData: locationData,
      onLocationUpdated: (lat, lng, address) {
        latitude = lat;
        longitude = lng;

        sharedPreferences!
            .setDouble(SharedPreferencesKeys.currentLat, latitude);
        sharedPreferences!
            .setDouble(SharedPreferencesKeys.currentLon, longitude);
        sharedPreferences!
            .setString(SharedPreferencesKeys.currentAddress, address);

        isGetLatLong = false;
        callUpdateCurrentData1();
        setState(() {});
      },
    );
  }

  void _onBottomBarItemTapped(int index) {
    if (currentIndex == index) return;

    if (currentIndex == 2 && index != 2) {
      _cameraKey.currentState?.closeCamera();
    } else if (currentIndex != 2 && index == 2) {
      _cameraKey.currentState?.clearCapturedMedia();
      _cameraKey.currentState?.resumeCamera();
    }

    trackAction(ActionNames.tabSwitch, parameters: {
      'from_tab': currentIndex.toString(),
      'to_tab': index.toString(),
      'tab_name': _getTabName(index),
    });

    if (index != 2) {
      updateLocationData();
    }

    setState(() {
      currentIndex = index;
      _loadedIndices.add(currentIndex);
    });
  }

  void _launchStudentBeansUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        sharedPreferences!
            .setBool(SharedPreferencesKeys.sourceDataIsClickKey, true);
        sharedPreferences!
            .setBool(SharedPreferencesKeys.sourceDataIsOpenedKey, true);
        _dashboardBloc.add(DashboardMarkStudentBeansVisitedEvent());
      } else {
        debugPrint("Could not launch URL: $url");
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }

  String _getTabName(int index) {
    switch (index) {
      case 0:
        return 'my_content';
      case 1:
        return 'my_tasks';
      case 2:
        return 'camera';
      case 3:
        return 'chat_bot';
      case 4:
        return 'menu';
      default:
        return 'unknown';
    }
  }

  void callUpdateCurrentData1() {
    Map<String, String> params = {
      "hopper_id": sharedPreferences!
          .getString(SharedPreferencesKeys.hopperIdKey)
          .toString(),
      "longitude": longitude.toString(),
      "latitude": latitude.toString()
    };

    debugPrint('map: $params');
    _dashboardBloc.add(UpdateLocationEvent(params));
  }

  void callAddDeviceApi(String deviceId, String deviceType, String fcmToken) {
    Map<String, String> params = {
      "device_id": deviceId,
      "type": deviceType,
      "device_token": fcmToken,
    };
    debugPrint('map: $params');
    _dashboardBloc.add(AddDeviceEvent(params));
  }

  void forceUpdateCheck() {
    _dashboardBloc.add(CheckAppVersionEvent());
  }

  void callTaskDetailApi(String id) {
    _dashboardBloc.add(FetchTaskDetailEvent(id));
  }

  void callGetActiveAdmin() {
    _dashboardBloc.add(FetchActiveAdmins());
  }

  Future<void> _handlePermissionSequence() async {
    debugPrint("Starting Permission Sequence...");

    await [
      Permission.camera,
      Permission.microphone,
    ].request();

    debugPrint("Camera/Mic Permissions handled.");

    forceUpdateCheck();

    if (widget.initialPosition == 2) {
      if (mounted) {
        final delay = Platform.isIOS ? 1200 : 500;
        await Future.delayed(Duration(milliseconds: delay));
        if (_cameraKey.currentState != null) {
          debugPrint("Resuming Camera after permissions...");
          _cameraKey.currentState!.resumeCamera();
        }
      }
    }
  }
}
