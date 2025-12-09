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
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonModel.dart';
import 'package:presshop/utils/CommonSharedPrefrence.dart';
import 'package:presshop/utils/dashboardInterface.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:presshop/view/boardcastScreen/BroardcastScreen.dart';
import 'package:presshop/view/chatScreens/ChatScreen.dart';
import 'package:presshop/view/dashboard/version_checker.dart';
import 'package:presshop/view/locationErrorScreen.dart';
import 'package:presshop/view/menuScreen/AllTaskDemo.dart';
import 'package:presshop/view/menuScreen/MenuScreen.dart';
import 'package:presshop/view/menuScreen/MyContentScreen.dart';
import 'package:presshop/view/menuScreen/MyProfile.dart';
import 'package:presshop/view/menuScreen/MyTaskScreen.dart';
import 'package:presshop/view/menuScreen/feedScreen/FeedScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../main.dart';
import '../../utils/AnalyticsConstants.dart';
import '../../utils/AnalyticsMixin.dart';
import '../../utils/CommonWigdets.dart';
import '../../utils/commonEnums.dart';
import '../../utils/location_service.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../cameraScreen/CameraScreen.dart';
import 'package:location/location.dart' as lc;

import '../chatBotScreen/chatBotScreen.dart';
import '../menuScreen/Notification/MyNotifications.dart';

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
    with AnalyticsPageMixin
    implements NetworkResponse {
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
  //   MyContentScreen(hideLeading: true),
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
  void initState() {
    setIsClickForBeansActivation();

    print("attottotot");
    print("slkjfsldkjflksdfjsldkjflk $studentBeansResponseUrlGlobal");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUpdateAndShowPopup();
    });
    bottomNavigationScreens = <Widget>[
      MyContentScreen(hideLeading: true),
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

    forceUpdateCheck();

    callGetRoomIdApi();

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
        callTaskDetailApi(widget.broadCastId!);
      }
      getFcmToken();
      fireBaseMessaging();
    }
    if (sharedPreferences!.getString(adminRoomIdKey) == null) {
      callGetActiveAdmin();
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
    NetworkClass(myProfileUrl, this, myProfileUrlRequest)
        .callRequestServiceHeader(false, "get", null);
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
  void callGetRoomIdApi() {
    Map<String, String> map = {
      //Need to pass receiver id
      "receiver_id": sharedPreferences!.getString(adminIdKey).toString(),
      "room_type": "HoppertoAdmin",
    };
    debugPrint("Map : $map");
    NetworkClass.fromNetworkClass(getRoomIdUrl, this, getRoomIdReq, map)
        .callRequestServiceHeader(false, "post", null);
  }

  Future<String?> setIsClickForBeansActivation() async {
    _studentBeansCompleter = Completer<String?>();

    NetworkClass.fromNetworkClass(
      studentBeansActivationUrl,
      this,
      studentBeansActivationRequest,
      null,
    ).callRequestServiceHeader(false, "post", null);

    return _studentBeansCompleter!.future;
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
              builder: (context) => MyContentScreen(hideLeading: false)),
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
                              // Expanded(
                              //     child: SizedBox(
                              //   height: size.width * numD12,
                              //   child: commonElevatedButton(
                              //       logoutText,
                              //       size,
                              //       commonButtonTextStyle(size),
                              //       commonButtonStyle(size, Colors.black), () {
                              //     Navigator.pop(context);
                              //     // callRemoveDeviceApi();
                              //   }),
                              // )),
                              // SizedBox(
                              //   width: size.width * numD04,
                              // ),
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
                                          await setIsClickForBeansActivation();

                                      if (url == null || url.isEmpty) {
                                        debugPrint("URL is empty");
                                        return;
                                      }

                                      final uri = Uri.parse(url);
                                      final launched = await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );

                                      sharedPreferences!
                                          .setBool(sourceDataIsClickKey, true);
                                      sharedPreferences!
                                          .setBool(sourceDataIsOpenedKey, true);
                                      Navigator.pop(context);

                                      if (!launched)
                                        debugPrint(
                                            "Could not launch URL: $url");
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
    return WillPopScope(
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
    currentIndex = index;
    setState(() {});
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

    NetworkClass.fromNetworkClass(
            updateLocation, this, updateLocationRequest, params)
        .callRequestServiceHeader(false, "post", null);
  }

  void callAddDeviceApi(String deviceId, String deviceType, String fcmToken) {
    Map<String, String> params = {
      "device_id": deviceId,
      "type": deviceType,
      "device_token": fcmToken,
    };
    debugPrint('map: $params');

    NetworkClass.fromNetworkClass(
            addDeviceUrl, this, addDeviceUrlRequest, params)
        .callRequestServiceHeader(false, "post", null);
  }

  void forceUpdateCheck() {
    NetworkClass.fromNetworkClass(
            getLatestVersionUrl, this, getLatestVersionReq, null)
        .callRequestServiceHeader(false, "get", null);
  }

  /// Get BroadCast task Detail
  void callTaskDetailApi(String id) {
    NetworkClass("$taskDetailUrl$id", this, taskDetailUrlRequest)
        .callRequestServiceHeader(false, "get", null);
  }

  void callGetActiveAdmin() {
    NetworkClass(getAdminListUrl, this, getAdminListReq)
        .callRequestServiceHeader(false, "get", null);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        /// Get BroadCast task Detail
        case taskDetailUrlRequest:
          debugPrint("BroadcastData::::Error");
          break;
        case studentBeansActivationRequest:
          debugPrint("BroadcastData::::Error $response");
          break;

        case addDeviceUrlRequest:
          debugPrint("AddDeviceError: $response");
          break;
      }
    } on Exception catch (e) {
      debugPrint("Exception: $e");
    }
  }

  void forceUpdateCheck1() async {
    bool needsUpdate = await VersionService.isUpdateAvailable(
      androidPackage: 'com.presshop.app',
      iosAppId: '6744651614',
    );

    if (needsUpdate && mounted) {
      commonErrorDialogDialog(
        shouldShowClosedButton: false,
        isFromNetworkError: false,
        MediaQuery.of(context).size,
        "To keep enjoying all the latest features and improvements, please update your PressHop app now.",
        "Update required",
        actionButton: "Update Now",
        () async {
          final appUrl = Platform.isAndroid
              ? 'https://play.google.com/store/apps/details?id=com.presshop.app'
              : 'https://apps.apple.com/app/id6744651614';
          final Uri uri = Uri.parse(appUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
      );
    }
  }

  // void _verifyVersion() async {
  //   forceUpdateCheck1();
  //   await AppVersionUpdate.checkForUpdates(
  //     appleId: '6744651614',
  //     playStoreId: 'com.presshop.app',
  //   ).then((result) async {
  //     print("verify version");
  //     print(result.canUpdate);
  //     // print("Current Installed Version: ${result.appVersion}");

  //     print("store Version: ${result.storeVersion}");

  //     print("relevent store url  ${result.storeUrl}");

  //     print(" apple id  ${result.appleId}");
  //     print(" playstore id  ${result.playStoreId}");
  //     print(" apple id  ${result.platform}");

  //     print("Can Update: ${result.canUpdate}");
  //     if (result.canUpdate!) {
  //       commonErrorDialogDialog(
  //           shouldShowClosedButton: false,
  //           isFromNetworkError: false,
  //           MediaQuery.of(context).size,
  //           "To keep enjoying all the latest features and improvements, please update your PressHop app now. It only takes a moment!",
  //           "Update required",
  //           actionButton: "Update Now", () async {
  //         // await launchUrl(Uri.parse(appUrl),
  //         //     mode: LaunchMode.externalApplication);

  //         try {
  //           final Uri uri = Uri.parse(appUrl);

  //           if (await canLaunchUrl(uri)) {
  //             await launchUrl(uri, mode: LaunchMode.externalApplication);
  //           } else {
  //             print('Could not launch $uri');
  //           }
  //         } catch (e) {
  //           print('Error launching URL: $e');
  //         }
  //       });
  //     }
  //   });
  // }

  @override
  void onResponse({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case myProfileUrlRequest:
          var map = jsonDecode(response);
          debugPrint("MyProfileSuccess:$map");
          print("MyProfileSuccess11:$response");

          if (map["code"] == 200) {
            var myProfileData = MyProfileData.fromJson(map["userData"]);

            // sharedPreferences!.setString(
            //     latitudeKey, map["userData"][latitudeKey].toString());
            // sharedPreferences!.setString(
            //     longitudeKey, map["userData"][longitudeKey].toString());
            // sharedPreferences!.setString(
            //     avatarIdKey, map["userData"][avatarIdKey].toString());
            // sharedPreferences!.setString(
            //     totalIncomeKey, map["userData"]["totalEarnings"].toString());

            if (map["userData"]['avatarData'] != null) {
              sharedPreferences!.setString(
                  avatarKey, map["userData"]['avatarData'][avatarKey]);
            }

            // var sourceDataIsOpened = true;
            // var sourceDataType = "student_beans";
            // var sourceDataUrl = src?["url"] ?? "";
            final src1 = map["userData"]["source"];
            print("source ===> $src1");

// source fields
            final sourceDataIsOpened = src1?["is_opened"] ?? false;
            final sourceDataType = src1?["type"] ?? "";
            final sourceDataUrl = src1?["url"] ?? "";
            final sourceDataHeading = src1?["heading"] ?? "";
            final sourceDataDescription = src1?["description"] ?? "";
            final isClick = src1?["is_clicked"] ?? false;

            print("print new data data data ");
            print("sourceDataIsOpened = $sourceDataIsOpened");
            print("sourceDataType $sourceDataType");
            print("sourceDataType $sourceDataUrl");
            print("sourceDataHeading $sourceDataHeading");
            print("sourceDataDescription $sourceDataDescription");
            print("isClick $isClick");

            // sharedPreferences!.setBool(sourceDataIsClickKey, false);
            // sharedPreferences!.setBool(sourceDataIsOpenedKey, false);
            // sharedPreferences!.setString(sourceDataTypeKey, "studentbeans");

            if ((sourceDataType ?? '').toLowerCase() == 'studentbeans' &&
                (sourceDataIsOpened == false) &&
                isClick == false) {
              // if (true) {
              final size =
                  MediaQuery.of(navigatorKey.currentState!.context).size;
              _showForceUpdateDialog(size,
                  sourceDataHeading: sourceDataHeading,
                  sourceDataDescription: sourceDataDescription);
            }

            setState(() {});
          }
          break;
        case addDeviceUrlRequest:
          debugPrint("AddDeviceSuccess: $response");
          break;
        case studentBeansActivationRequest:
          debugPrint("studentBeansActivationRequest32434: $response");
          try {
            var map = jsonDecode(response);
            var studentBeansResponseUrl = map["url"];
            studentBeansResponseUrlGlobal = studentBeansResponseUrl;

            // Complete the completer if someone is waiting
            print(
                "studentBeansResponseUrlGlobal$studentBeansResponseUrlGlobal");
            if (_studentBeansCompleter != null &&
                !_studentBeansCompleter!.isCompleted) {
              _studentBeansCompleter!.complete(studentBeansResponseUrlGlobal);
            }
          } catch (e) {
            debugPrint("Error parsing studentBeans response: $e");
            if (_studentBeansCompleter != null &&
                !_studentBeansCompleter!.isCompleted) {
              _studentBeansCompleter!.complete(null);
            }
          }
          break;

        case getRoomIdReq:
          var data = jsonDecode(response);
          debugPrint("getRoomIdReq Success : $data");
          if (data["details"] != null) {
            var roomId = data["details"]["room_id"] ?? "";
            sharedPreferences!.setString(adminRoomIdKey, roomId);
            debugPrint("Room Id : $roomId");
          }
          break;
        case getLatestVersionReq:
          debugPrint("getLatestVersionReq: $response");
          var map = jsonDecode(response);
          if (map["code"] == 200) {
            var versionData = map["data"];
            sharedPreferences!
                .setInt(videoLimitKey, (versionData['video_limit'] ?? 2) * 60);

            if (Platform.isAndroid) {
              if (versionData['aOSshouldForceUpdate']) {
                forceUpdateCheck1();
              }
            } else {
              if (versionData['iOSshouldForceUpdate']) {
                forceUpdateCheck1();
              }
            }
          } else {
            showSnackBar(map["message"], "error", Colors.red);
          }
          break;

        /// Get BroadCast task Detail
        case taskDetailUrlRequest:
          debugPrint("taskDetailUrlRequest: 1  $response");
          var map = jsonDecode(response);
          if (map["code"] == 200 && map["task"] != null) {
            var broadCastedData = TaskDetailModel.fromJson(map["task"]);
            debugPrint("taskDetailUrlRequest: 2 $broadCastedData");
            player.play(
              AssetSource('audio/task_sound.mp3'),
              volume: 1,
            );
            broadcastDialog(
              size: MediaQuery.of(context).size,
              taskDetail: broadCastedData,
              onTapView: () {
                /// --------------------------------------------------------------------
                /// --------------------------------------------------------------------
                /// SAVE THE CURRENT PUBLISH CONTENT DATA IN DRAFTS IF DIALOG SHOWS SO USER CAN CONTINUE EDITING IT IN FUTURE
                if (mounted) {
                  if (dashBoardInterface != null) {
                    dashBoardInterface!.saveDraft();
                  }
                } else {
                  debugPrint('Unmounted:::::dashBoardInterface');
                }
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
          setState(() {});
          break;
        case getAdminListReq:
          var data = jsonDecode(response);
          debugPrint("getAdminListReq Success: $data");
          var dataModel = data["data"] as List;

          adminList =
              dataModel.map((e) => AdminDetailModel.fromJson(e)).toList();
          if (adminList.isNotEmpty) {
            sharedPreferences?.setString('adminIdKey', adminList.first.id);
            sharedPreferences?.setString(
                'adminRoomIdKey', adminList.first.roomId);
            sharedPreferences?.setString(
                'adminImageKey', adminList.first.profilePic);
            sharedPreferences?.setString('adminNameKey', adminList.first.name);
          }
          /*for (var id in adminIDList) {
            adminList.removeWhere((element) => element.id == id);
          }*/
          debugPrint("adminListLengthResponse=========> ${adminList.length}");
          setState(() {});
          break;
      }
    } on Exception catch (e) {
      debugPrint("Exception: $e");
    }
  }
}
