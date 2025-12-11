import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:app_version_update/app_version_update.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/common_models_export.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:presshop/features/dashboard/presentation/utils/dashboard_interface.dart';
import 'package:presshop/core/api/network_response.dart';
import 'package:presshop/features/task/presentation/pages/broadcast/BroardcastScreen.dart';
import 'package:presshop/features/chat/presentation/pages/ChatScreen.dart';
import 'package:presshop/features/dashboard/presentation/pages/version_checker.dart';
import 'package:presshop/core/widgets/error/location_error_screen.dart';

import 'package:presshop/features/menu/presentation/pages/menu_screen.dart';
import 'package:presshop/features/content/presentation/pages/my_content_page.dart';
import 'package:presshop/features/profile/presentation/pages/my_profile_screen.dart';
import 'package:presshop/features/task/presentation/pages/my_task_screen.dart';
import 'package:presshop/features/feed/presentation/pages/FeedScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/analytics/analytics_constants.dart';
import 'package:presshop/core/analytics/analytics_mixin.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import '../../../../utils/commonEnums.dart';
import '../../../../utils/location_service.dart';
import 'package:presshop/features/camera/presentation/pages/CameraScreen.dart';
import 'package:location/location.dart' as lc;

import 'package:presshop/features/chatbot/presentation/pages/chatBotScreen.dart';
import 'package:presshop/features/notification/presentation/pages/MyNotifications.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import 'package:presshop/core/di/injection_container.dart';
import '../../../dashboard/domain/entities/admin_detail.dart' as entity_admin;
import '../../../dashboard/domain/entities/task_detail.dart' as entity_task;


class Dashboard extends StatefulWidget {
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

  @override
  State<StatefulWidget> createState() {
    return DashboardState();
  }
}

class DashboardState extends State<Dashboard>
    with AnalyticsPageMixin, WidgetsBindingObserver {
  late Size size;
  late DashboardBloc _dashboardBloc;
  int currentIndex = 2;
  String fcmToken = "";
  String deviceId = "";
  StreamSubscription? _sub;
  static DashBoardInterface? dashBoardInterface;
  final GlobalKey<CameraScreenState> _cameraKey =
      GlobalKey<CameraScreenState>();

  String? savedSourceDataHeading = "";
  String? savedSourceDataDescription = "";

  /// Prince
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

  // final bottomNavigationScreens = <Widget>[
  //   MyContentPage(hideLeading: true),
  //   MyTaskScreen(hideLeading: true),
  //   CameraScreen(
  //     key: _cameraKey,
  //     picAgain: false,
  //     previousScreen: ScreenNameEnum.dashboardScreen,
  //   ),
  //   ChatBotScreen(),
  //   //ChatListingScreen(hideLeading: true),
  //   const MenuScreen()
  // ];
  late AppLinks linkStream;

  // Analytics Mixin Requirements
  @override
  String get pageName => PageNames.dashboard;

  @override
  Map<String, Object>? get pageParameters => {
        'initial_position': widget.initialPosition.toString(),
        'user_id': sharedPreferences?.getString(hopperIdKey) ?? 'unknown',
        'current_tab': currentIndex.toString(),
      };

  @override
  @override
  void initState() {
    _dashboardBloc = sl<DashboardBloc>();
    setIsClickForBeansActivation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUpdateAndShowPopup();
    });
    bottomNavigationScreens = <Widget>[
      MyContentPage(hideLeading: true),
      // AllTaskDemo(),
      MyTaskScreen(hideLeading: true),
      CameraScreen(
        key: _cameraKey,
        picAgain: false,
        previousScreen: ScreenNameEnum.dashboardScreen,
        autoInitialize: widget.initialPosition == 2,
      ),
      // ChatBotScreen(),
      FeedScreen(),
      const MenuScreen()
      // MarketplaceScreen()
    ];

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _locationService = LocationService();

    // forceUpdateCheck();
    _dashboardBloc.add(CheckAppVersionEvent());

    // callGetRoomIdApi();
    _dashboardBloc.add(FetchRoomIdEvent());

    facebookAppEvents.logEvent(
      name: "dashboard_open",
      parameters: {
        "app_name": "Presshop",
        "platform": Platform.operatingSystem,
        "version": Platform.version,
      },
    );
    currentIndex = widget.initialPosition;

    if (widget.taskStatus == 'rejected') {
    } else {
      if (widget.broadCastId != null) {
        // callTaskDetailApi(widget.broadCastId!);
        _dashboardBloc.add(FetchTaskDetailEvent(widget.broadCastId!));
      }
      getFcmToken();
      fireBaseMessaging();
    }
    if (sharedPreferences!.getString(adminRoomIdKey) == null) {
      // callGetActiveAdmin();
      _dashboardBloc.add(FetchActiveAdmins());
    }
    isGetLatLong = false;
    if (widget.openChatScreen) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConversationScreen(
                hideLeading: false,
                message: '',
              ),
            ),
          );
        }
      });
    } else if (widget.openNotification) {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyNotificationScreen(
              count: 1,
            ),
          ),
        );
      });
    } else if (widget.openBeansActivation) {
      Future.delayed(const Duration(seconds: 2), () {
        setIsClickForBeansActivation();
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _dashboardBloc.close();
    super.dispose();
  }

  // Future<String?> fetchStudentBeansUrl(
  //     {Duration timeout = const Duration(seconds: 10)}) async {
  //   // If a previous completer is still pending, return its future
  //   if (_studentBeansCompleter != null &&
  //       !_studentBeansCompleter!.isCompleted) {
  //     return _studentBeansCompleter!.future
  //         .timeout(timeout, onTimeout: () => null);
  //   }

  //   _studentBeansCompleter = Completer<String?>();

  //   try {
  //     NetworkClass.fromNetworkClass(
  //       studentBeansActivationUrl,
  //       this,
  //       studentBeansActivationRequest,
  //       null,
  //     ).callRequestServiceHeader(false, "post", null);
  //   } catch (e) {
  //     // Ensure completer completes on error
  //     if (!_studentBeansCompleter!.isCompleted) {
  //       _studentBeansCompleter!.complete(null);
  //     }
  //     return null;
  //   }

  //   // Wait for onResponse to complete the completer (or timeout -> null)
  //   try {
  //     return await _studentBeansCompleter!.future
  //         .timeout(timeout, onTimeout: () => null);
  //   } catch (_) {
  //     return null;
  //   }
  // }

  void myProfileApi() {
    _dashboardBloc.add(FetchMyProfileEvent());
  }

  void _checkUpdateAndShowPopup() async {
    final String? savedSourceDataType =
        sharedPreferences?.getString(sourceDataTypeKey);
    // final String? savedSourceDataUrl =
    //     sharedPreferences?.getString(sourceDataUrlKey);
    savedSourceDataHeading = sharedPreferences?.getString(sourceDataHeadingKey);
    savedSourceDataDescription =
        sharedPreferences?.getString(sourceDataDescriptionKey);
    final bool? savedSourceDataIsOpened =
        sharedPreferences?.getBool(sourceDataIsOpenedKey);
    final bool? savedSourceDataIsClickKey =
        sharedPreferences?.getBool(sourceDataIsClickKey);

    debugPrint('savedSourceDataTypeghgg: $savedSourceDataType');
    debugPrint('savedSourceDataHeading: $savedSourceDataHeading');
    debugPrint('savedSourceDataDescription: $savedSourceDataDescription');
    debugPrint('savedSourceDataIsOpened: $savedSourceDataIsOpened');
    debugPrint('savedSourceDataIsClickKey: $savedSourceDataIsClickKey');

    // sharedPreferences!.setBool(sourceDataIsClickKey, false);
    // sharedPreferences!.setBool(sourceDataIsOpenedKey, false);
    // sharedPreferences!.setString(sourceDataTypeKey, "studentbeans");

    bool checkFromLocalStorage =
        (savedSourceDataType ?? '').toLowerCase() == 'studentbeans' &&
            (savedSourceDataIsOpened == false) &&
            savedSourceDataIsClickKey == false;

    if (checkFromLocalStorage) {
      // if (true) {
      final size = MediaQuery.of(navigatorKey.currentState!.context).size;
      _showForceUpdateDialog(
        size,
      );
    }
  }

  /// An implementation using a link Amit
  initPlatformStateForStringUniLinks() async {
    debugPrint("initPlatformStateForStringUniLinks=======>Enter");

    ///Attach a listener to the links stream
    _sub = linkStream.uriLinkStream.listen((link) {
      if (!mounted) return;
      debugPrint('initPlatformStateForStringUniLinks  $link');
    }, onError: (err) {
      if (!mounted) return;
      debugPrint('exception $err');
    });

    /// Attach a second listener to the stream Note:
    /// The jump here should be when the APP is opened and cut to the background process.
    linkStream.uriLinkStream.listen((link) {
      debugPrint('linkStream index got? link: $link');
      jump2Screen(link.path);
    }, onError: (err) {
      debugPrint('got err: $err');
    });

    ///Get the latest link
    Uri? initialLink;

    ///Uri? initialUri;
    /// Platform messages may fail, so we use a try/catch PlatformException.
    try {
      initialLink = await linkStream.getInitialLink();
      debugPrint('initial link: $initialLink');
      jump2Screen(initialLink!.path);
    } catch (e) {
      debugPrint('exception -----> $e');
    }

    if (!mounted) return;
    setState(() {});
  }

  /// Get Room Id
  // Removed manual API call. Using Bloc event FetchRoomIdEvent in initState.

  void setIsClickForBeansActivation() {
    _dashboardBloc.add(ActivateStudentBeansEvent());
  }

  /// Navigate other screen using share link
  void jump2Screen(String link) async {
    debugPrint("dashboardDeepLiking-->$link");
    debugPrint("dashboardDeepLiking-->${link.split("&").last}");

    if (link.isNotEmpty) {
      debugPrint("link Enter::::::::::>");
      if (link.contains("shareLinkforUserid")) {
        String id = link.substring(link.lastIndexOf("?") + 1, link.length);
        String type = link.substring(link.lastIndexOf("&") + 1, link.length);
        debugPrint("type:::::$type");
        debugPrint("commonID-->$id");
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MyContentPage(hideLeading: false)),
        );
      } else if (link.split("&").last == "type=Group") {
        String groupId = link.substring(link.lastIndexOf("?") + 1, link.length);
        String id =
            groupId.replaceAll("group_id=", "").replaceAll("&type=Group", "");
        debugPrint(
            "groupId : ${groupId.replaceAll("group_id=", "").replaceAll("&type=Group", "")}");
      }
    }
  }

  void _showForceUpdateDialog(Size size,
      {String? sourceDataHeading, String? sourceDataDescription}) {
      // ... (existing implementation) ...
      showDialog(
        barrierDismissible: false,
        context: navigatorKey.currentState!.context,
        builder: (BuildContext context) {
          return AlertDialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              contentPadding: EdgeInsets.zero,
              insetPadding:
                  EdgeInsets.symmetric(horizontal: size.width * numD04),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(size.width * numD045)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: size.width * numD04),
                          child: Row(
                            children: [
                              Text(
                                (savedSourceDataHeading?.isNotEmpty == true
                                    ? savedSourceDataHeading
                                    : sourceDataHeading?.isNotEmpty == true
                                        ? sourceDataHeading
                                        : "Brains, beans, and breaking news!")!,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * numD04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.black,
                                    size: size.width * numD06,
                                  ))
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * numD04),
                          child: const Divider(
                            color: Colors.black,
                            thickness: 0.5,
                          ),
                        ),
                        SizedBox(
                          height: size.width * numD02,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * numD04),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 120, // fixed width
                                height: 120, // fixed height
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.black),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    "assets/rabbits/student_beans_rabbit2.png",
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: size.width * numD04,
                              ),
                              Expanded(
                                child: Text(
                                  (savedSourceDataDescription?.isNotEmpty ==
                                          true
                                      ? savedSourceDataDescription
                                      : sourceDataDescription?.isNotEmpty ==
                                              true
                                          ? sourceDataDescription
                                          : "Please confirm your student status to continue")!,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: size.width * numD035,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: size.width * numD02,
                        ),
                        SizedBox(
                          height: size.width * numD02,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * numD04,
                              vertical: size.width * numD04),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: size.width * numD12,
                                  child: commonElevatedButton(
                                      "Confirm",
                                      size,
                                      commonButtonTextStyle(size),
                                      commonButtonStyle(size, colorThemePink),
                                      () async {
                                    try {
                                      final url =
                                          setIsClickForBeansActivation();
                                      
                                      // Note: setIsClickForBeansActivation returns void because it calls Bloc.
                                      // The original code expected a URL return.
                                      // We need to wait for state change 'StudentBeansActivated' to get the URL.
                                      // However, this dialog logic is tricky.
                                      // To fix this without major refactor:
                                      // We can dispatch event, wait for state listener to handle URL launching.
                                      // OR just pop here and let listener handle it.
                                      // But original code tried to await it. 
                                      
                                      // For now, let's keep it simple: dispatch and close. 
                                      // We can't await a Bloc event outcome easily here without a Completer or Listener.
                                      // The BlocListener in build method handles StudentBeansActivated.
                                      
                                      Navigator.pop(context);
                                    } catch (e) {
                                      debugPrint("Error launching URL: $e");
                                    }
                                  }),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocProvider.value(
      value: _dashboardBloc,
      child: BlocListener<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardActiveAdminsLoaded) {
            setState(() {
              adminList = state.admins.map((e) => AdminDetailModel(
                id: e.id,
                name: e.name,
                profilePic: e.profilePic,
                lastMessageTime: e.lastMessageTime,
                lastMessage: e.lastMessage,
                roomId: e.roomId,
                senderId: e.senderId,
                receiverId: e.receiverId,
                roomType: e.roomType,
              )).toList();

              if (adminList.isNotEmpty) {
                sharedPreferences?.setString('adminIdKey', adminList.first.id);
                sharedPreferences?.setString('adminRoomIdKey', adminList.first.roomId);
                sharedPreferences?.setString('adminImageKey', adminList.first.profilePic);
                sharedPreferences?.setString('adminNameKey', adminList.first.name);
              }
            });
          } else if (state is DashboardRoomIdLoaded) {
            var data = state.roomData;
            if (data["details"] != null) {
              var roomId = data["details"]["room_id"] ?? "";
              sharedPreferences!.setString(adminRoomIdKey, roomId);
              debugPrint("Room Id : $roomId");
            }
          } else if (state is DashboardAppVersionChecked) {
             var map = state.versionData;
             if (map["code"] == 200) {
                 var versionData = map["data"];
                 sharedPreferences!.setInt(videoLimitKey, (versionData['video_limit'] ?? 2) * 60);
                 bool shouldUpdate = Platform.isAndroid ? versionData['aOSshouldForceUpdate'] : versionData['iOSshouldForceUpdate'];
                 if (shouldUpdate) forceUpdateCheck1();
             } else {
                 showSnackBar(map["message"], "error", Colors.red);
             }
          } else if (state is DashboardTaskDetailLoaded) {
             var task = state.taskDetail;
              var broadCastedData = TaskDetailModel(
                 id: task.id,
                 deadLine: task.deadLine,
                 mediaHouseId: task.mediaHouseId,
                 mediaHouseImage: task.mediaHouseImage,
                 mediaHouseName: task.mediaHouseName,
                 companyName: task.companyName,
                 title: task.title,
                 description: task.description,
                 acceptedBy: task.acceptedBy,
                 specialReq: task.specialReq,
                 location: task.location,
                 photoPrice: task.photoPrice,
                 videoPrice: task.videoPrice,
                 interviewPrice: task.interviewPrice,
                 receivedAmount: task.receivedAmount,
                 latitude: task.latitude,
                 longitude: task.longitude,
                 role: task.role,
                 categoryId: task.categoryId,
                 userId: task.userId,
                 createdAt: task.createdAt,
                 miles: task.miles,
                 byFeet: task.byFeet,
                 byCar: task.byCar,
              );

             player.play(
               AssetSource('audio/task_sound.mp3'),
               volume: 1,
             );
             broadcastDialog(
               size: MediaQuery.of(context).size,
               taskDetail: broadCastedData,
               onTapView: () {
                 if (mounted) {
                   if (dashBoardInterface != null) {
                     dashBoardInterface!.saveDraft();
                   }
                 }
                 Navigator.pop(context);
                 Navigator.pop(context);
                 Navigator.of(context).push(MaterialPageRoute(
                     builder: (context) => BroadCastScreen(
                           taskId: broadCastedData.id,
                           mediaHouseId: broadCastedData.mediaHouseId,
                         )));
               },
             );
          } else if (state is StudentBeansActivated) {
             var map = state.data;
              var studentBeansResponseUrl = map["url"];
              
              if (studentBeansResponseUrl != null && studentBeansResponseUrl.isNotEmpty) {
                 _launchStudentBeansUrl(studentBeansResponseUrl);
              }

              // Complete the completer if someone is waiting (legacy support)
              if (_studentBeansCompleter != null &&
                  !_studentBeansCompleter!.isCompleted) {
                _studentBeansCompleter!.complete(studentBeansResponseUrl);
              }
          } else if (state is DashboardMyProfileLoaded) {
             var user = state.user;
             var mapSource = user.source; 

            if (user.avatar != null && user.avatar!.isNotEmpty) {
               sharedPreferences!.setString(avatarKey, user.avatar!);
            }

            final src1 = mapSource;
            final sourceDataIsOpened = src1?["is_opened"] ?? false;
            final sourceDataType = src1?["type"] ?? "";
            final sourceDataHeading = src1?["heading"] ?? "";
            final sourceDataDescription = src1?["description"] ?? "";
            final isClick = src1?["is_clicked"] ?? false;

            if ((sourceDataType ?? '').toLowerCase() == 'studentbeans' &&
                (sourceDataIsOpened == false) &&
                isClick == false) {
              final size =
                  MediaQuery.of(navigatorKey.currentState!.context).size;
              _showForceUpdateDialog(size,
                  sourceDataHeading: sourceDataHeading,
                  sourceDataDescription: sourceDataDescription);
            }
            setState(() {});
          } else if (state is DashboardTabChanged) {
             setState(() {
                currentIndex = state.index;
             });
          } else if (state is DashboardError) {
             // Optional
          }
        },
        child: WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();
        if (currentTime == null ||
            now.difference(currentTime!) > const Duration(seconds: 2)) {
          currentTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press again to exit'),
            ),
          );
          return Future.value(false);
        } else {
          SystemNavigator.pop();
          exit(0);
        }
      },
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: currentIndex,
          showUnselectedLabels: true,
          showSelectedLabels: true,
          unselectedItemColor: Colors.black,
          selectedItemColor: colorThemePink,
          elevation: 0,
          iconSize: size.width * numD05,
          selectedFontSize: size.width * numD03,
          unselectedFontSize: size.width * numD03,
          type: BottomNavigationBarType.fixed,
          onTap: _onBottomBarItemTapped,
          items: const [
            BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage("${iconsPath}ic_content.png"),
                ),
                label: contentText),
            BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage("${iconsPath}ic_task.png"),
                ),
                label: taskText),
            BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage(
                    "${iconsPath}ic_camera.png",
                  ),
                ),
                label: cameraText),
            BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage("${iconsPath}ic_feed.png"),
                ),
                label: feedText),
            // BottomNavigationBarItem(
            //     icon: ImageIcon(
            //       AssetImage("${iconsPath}ic_chat.png"),
            //     ),
            //     label: chatText),
            BottomNavigationBarItem(
                icon: ImageIcon(
                  AssetImage("${iconsPath}ic_menu.png"),
                ),
                label: menuText),
          ],
        ),
        // body: Stack(
        //   children: [
        //     Center(child: Text("This is the center Text for popup")),
        //     Visibility(
        //       visible: !isGetLatLong,
        //       replacement: showLoader(isForLocation: false),
        //       child: bottomNavigationScreens[currentIndex],
        //       //  )
        //     ),
        //   ],
        // )),
        body: Stack(
          children: [
            // Background text (optional)
            const Center(child: Text("This is the center Text for popup")),

            // Show loader while getting location
            Visibility(
              visible: !isGetLatLong,
              replacement: showLoader(isForLocation: false),
              child: IndexedStack(
                index: currentIndex,
                children: bottomNavigationScreens,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// FireBase Notification Initialize
  void fireBaseMessaging() async {
    debugPrint("InsideFirebase");
/*
    FirebaseMessaging.instance.requestPermission(
      badge: true,
      alert: true,
    );
*/
    /* await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
*/
    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        debugPrint("FirebaseMessaging.instance.getInitialMessage");
        if (message != null) {
          debugPrint("New Notification");
        }
      },
    );

    // localNotificationService.flutterLocalNotificationsPlugin
    //     .getNotificationAppLaunchDetails()
    //     .then((notificationDetail) async {
    //   await Future.delayed(const Duration(seconds: 1));
    //   if (notificationDetail != null &&
    //       notificationDetail.didNotificationLaunchApp &&
    //       context.mounted) {
    //     if (notificationDetail.notificationResponse != null &&
    //         notificationDetail.notificationResponse!.payload != null) {
    //       var taskDetail =
    //           jsonDecode(notificationDetail.notificationResponse!.payload!);
    //       if (taskDetail["notification_type"].toString() ==
    //           "media_house_tasks") {
    //         callTaskDetailApi(taskDetail["broadCast_id"].toString());
    //       }
    //     }
    //   }
    // });

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint("Fi1rebaseMessage: ${message.data}");

      if (message.data.isNotEmpty &&
          message.data["notification_type"].toString() == "media_house_tasks") {
        debugPrint("Inside Task Assigned notification");
        // localNotificationService.showFlutterNotificationWithSound(message);

        /// --------------------------------------------------------------------
        /// --------------------------------------------------------------------
        /// SAVE THE CURRENT PUBLISH CONTENT DATA IN DRAFTS IF DIALOG SHOWS SO USER CAN CONTINUE EDITING IT IN FUTURE
        if (mounted) {
          if (dashBoardInterface != null) {
            dashBoardInterface!.saveDraft();
          }
          callTaskDetailApi(message.data["broadCast_id"]);
        } else {
          debugPrint('Unmounted:::::dashBoardInterface');
        }

        /// --------------------------------------------------------------------
        /// --------------------------------------------------------------------
        callTaskDetailApi(message.data["broadCast_id"]);
      } else {
        debugPrint("inside else------>");
        debugPrint("desensitising------>${message.notification!.android}");
        // localNotificationService.showFlutterNotificationWithSound(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        if (mounted) {
          setState(() {});
        }
        if (message.data.isNotEmpty &&
            message.data["notification_type"].toString() == "studentbeans") {
          myProfileApi();
          return;
        }
        debugPrint("FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.data.isNotEmpty &&
            message.data["notification_type"].toString() ==
                "media_house_tasks") {
          debugPrint("Inside Task Assigned notification");
          if (mounted) {
            callTaskDetailApi(message.data["broadCast_id"]);
          }
        } else if (message.data.isNotEmpty &&
            message.data["notification_type"].toString() ==
                "initiate_admin_chat") {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConversationScreen(
                    hideLeading: false,
                    message: '',
                  ),
                ),
              );
            }
          });
        } else if ((message.data.isNotEmpty &&
            message.data["image"] != null &&
            message.data["image"].isNotEmpty)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyNotificationScreen(
                count: 1,
              ),
            ),
          );
        }
        if (message.notification != null) {
          debugPrint(message.notification!.title);
          debugPrint(message.notification!.body);
          debugPrint("message.data22:::: ${message.data.toString()}");
        }
      },
    );
  }

  /// Not Use
  void showMediaTaskDialog(Map<String, dynamic> taskDetail) {
    var dis = calculateDistance(
            double.parse(taskDetail["lat"].toString()),
            double.parse(taskDetail["long"]),
            double.parse(sharedPreferences!.getString(latitudeKey)!),
            double.parse(sharedPreferences!.getString(longitudeKey)!)) *
        0.621371;
    debugPrint("DistanceNew: $dis");
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
    locationData = await _locationService.getCurrentLocation(context,
        shouldShowSettingPopup: false);
    if (locationData != null) {
      proceedWithLocation(locationData);
    }
  }

  void goToLocationErrorScreen() {
    Navigator.of(navigatorKey.currentContext!)
        .push(
      MaterialPageRoute(
        builder: (context) => LocationErrorScreen(),
      ),
    )
        .then((value) {
      if (value != null) {
        proceedWithLocation(value);
      } else {
        debugPrint("Location Error");
      }
    });
  }

  void proceedWithLocation(lc.LocationData? locationData) async {
    if (locationData != null) {
      debugPrint("NotNull");
      if (locationData.latitude != null) {
        latitude = locationData.latitude!;
        longitude = locationData.longitude!;

        try {
          // Get address details from coordinates
          List<Placemark> placemarks =
              await placemarkFromCoordinates(latitude, longitude);

          if (placemarks.isNotEmpty) {
            final place = placemarks.first;

            String fullAddress = [
              if (place.street?.isNotEmpty ?? false) place.street,
              if (place.locality?.isNotEmpty ?? false) place.locality,
              if (place.administrativeArea?.isNotEmpty ?? false)
                place.administrativeArea,
              if (place.country?.isNotEmpty ?? false) place.country,
            ].whereType<String>().join(", ");

            debugPrint("Address: $fullAddress");

            // Save in shared preferences
            sharedPreferences!.setDouble(currentLat, latitude);
            sharedPreferences!.setDouble(currentLon, longitude);
            sharedPreferences!.setString(currentAddress, fullAddress);
            sharedPreferences!.setString(currentCountry, place.country ?? "");
            sharedPreferences!
                .setString(currentState, place.administrativeArea ?? "");
            sharedPreferences!.setString(currentCity, place.locality ?? "");

            isGetLatLong = false;
            callUpdateCurrentData1();
            setState(() {});

            if (alertDialog != null) {
              alertDialog = null;
              Navigator.of(navigatorKey.currentContext!).pop();
            }
          } else {
            debugPrint("No placemarks found");
            showSnackBar("Error", "Unable to find address", Colors.black);
          }
        } catch (e) {
          debugPrint("Geocoding error: $e");
          showSnackBar("Error", "Failed to get address: $e", Colors.black);
        }
      }
    } else {
      debugPrint("Null-ll");
      showSnackBar("Location Error", "nullLocationText", Colors.black);
    }
  }

// rajesh
  // void proceedWithLocation(lc.LocationData? locationData) async {
  //   if (locationData != null) {
  //     debugPrint("NotNull");
  //     if (locationData.latitude != null) {
  //       latitude = locationData.latitude!;
  //       longitude = locationData.longitude!;
  //       GeoData data = await Geocoder2.getDataFromCoordinates(
  //           latitude: latitude,
  //           longitude: longitude,
  //           googleMapApiKey: Platform.isIOS ? appleMapAPiKey : googleMapAPiKey);

  //       debugPrint("address=====> ${data.address}");
  //       sharedPreferences!.setDouble(currentLat, latitude);
  //       sharedPreferences!.setDouble(currentLon, longitude);
  //       sharedPreferences!.setString(currentAddress, data.address);
  //       sharedPreferences!.setString(currentCountry, data.country);
  //       sharedPreferences!.setString(currentState, data.state);
  //       sharedPreferences!.setString(currentCity, data.city);

  //       isGetLatLong = false;
  //       callUpdateCurrentData();
  //       setState(() {});
  //       if (alertDialog != null) {
  //         alertDialog = null;
  //         Navigator.of(navigatorKey.currentContext!).pop();
  //       }
  //     }
  //   } else {
  //     debugPrint("Null-ll");
  //     showSnackBar("Location Error", "nullLocationText", Colors.black);
  //   }
  // }

/*  void _onBottomBarItemTapped(int index) {
    currentIndex = index;

    if(index==1){
      Fluttertoast.showToast(
        msg: "Launching soon",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: lightGrey,
        textColor: Colors.black,
        fontSize: 16.0,
      );
    }
    setState(() {});
  }*/

  void _onBottomBarItemTapped(int index) {
    /*  if (index == 1) {
      Fluttertoast.showToast(
        msg: "Launching soon",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: lightGrey,
        textColor: Colors.black,
        fontSize: 16.0,
      );
      return;
    }*/

// rajesh

    if (index == 2) {
      // Turn camera ON
      _cameraKey.currentState?.resumeCamera();
    } else {
      // Turn camera OFF
      _cameraKey.currentState?.closeCamera();
    }

/////

    // Track tab switches
    trackAction(ActionNames.tabSwitch, parameters: {
      'from_tab': currentIndex.toString(),
      'to_tab': index.toString(),
      'tab_name': _getTabName(index),
    });

    if (index != 2) {
      updateLocationData();
    }
    
    _dashboardBloc.add(ChangeDashboardTabEvent(index));
  }

  void _launchStudentBeansUrl(String url) async {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
           await launchUrl(uri, mode: LaunchMode.externalApplication);
           sharedPreferences!.setBool(sourceDataIsClickKey, true);
           sharedPreferences!.setBool(sourceDataIsOpenedKey, true);
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
      "hopper_id": sharedPreferences!.getString(hopperIdKey).toString(),
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

  /// Get BroadCast task Detail
  void callTaskDetailApi(String id) {
    _dashboardBloc.add(FetchTaskDetailEvent(id));
  }

  void callGetActiveAdmin() {
    _dashboardBloc.add(FetchActiveAdmins());
  }

/*
  // Legacy NetworkResponse methods removed. Refactored to Bloc.
  @override
  void onError({required int requestCode, required String response}) {}
  @override
  void onResponse({required int requestCode, required String response}) {}
*/
}
