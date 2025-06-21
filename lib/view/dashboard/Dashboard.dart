import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonModel.dart';
import 'package:presshop/utils/CommonSharedPrefrence.dart';
import 'package:presshop/utils/dashboardInterface.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:presshop/view/boardcastScreen/BroardcastScreen.dart';
import 'package:presshop/view/locationErrorScreen.dart';
import 'package:presshop/view/menuScreen/MenuScreen.dart';
import 'package:presshop/view/menuScreen/MyContentScreen.dart';
import 'package:presshop/view/menuScreen/MyTaskScreen.dart';
import '../../main.dart';
import '../../utils/CommonWigdets.dart';
import '../../utils/commonEnums.dart';
import '../../utils/location_service.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../cameraScreen/CameraScreen.dart';
import 'package:location/location.dart' as lc;
import 'package:permission_handler/permission_handler.dart';

import '../chatBotScreen/chatBotScreen.dart';

class Dashboard extends StatefulWidget {
  int initialPosition = 2;
  String? broadCastId;
  String? taskStatus = "";

  Dashboard({
    super.key,
    required this.initialPosition,
    this.broadCastId,
    this.taskStatus,
  });

  @override
  State<StatefulWidget> createState() {
    return DashboardState();
  }
}

class DashboardState extends State<Dashboard> implements NetworkResponse {
  int currentIndex = 2;
  String fcmToken = "";
  String deviceId = "";
  StreamSubscription? _sub;
  static DashBoardInterface? dashBoardInterface;

  /// Prince
  lc.LocationData? locationData;
  late LocationService _locationService;
  String mediaAddress = "", mediaDate = "", country = "", state = "", city = "";
  int totalEntitiesCount = 0;
  double x = 0, y = 0, latitude = 22.5744, longitude = 88.3629;

  int page = 0;

  bool isGetLatLong = false;

  List<AdminDetailModel> adminList = [];
  List<String> adminIDList = [];
  DateTime? currentTime;
  final bottomNavigationScreens = <Widget>[
    MyContentScreen(hideLeading: true),
    MyTaskScreen(hideLeading: true),
    const CameraScreen(
      picAgain: false,
      previousScreen: ScreenNameEnum.dashboardScreen,
    ),
    ChatBotScreen(),
    //ChatListingScreen(hideLeading: true),
    const MenuScreen()
  ];
  late AppLinks linkStream;

  @override
  void initState() {
    /// Light statusBar mode-->
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _locationService = LocationService();
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
    isGetLatLong = true;
    requestLocationPermissions();
    super.initState();
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

      ///if (initialLink != null) initialUri = Uri.parse(initialLink);
    } catch (e) {
      debugPrint('exception -----> $e');
    }

    if (!mounted) return;
    setState(() {});
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
                    AssetImage("${iconsPath}ic_chat.png"),
                  ),
                  label: chatText),
              BottomNavigationBarItem(
                  icon: ImageIcon(
                    AssetImage("${iconsPath}ic_menu.png"),
                  ),
                  label: menuText),
            ],
          ),
          body: Visibility(
            visible: !isGetLatLong,
            replacement: showLoader(isForLocation: true),
            child: bottomNavigationScreens[currentIndex],
            //  )
          )),
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

    localNotificationService.flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails()
        .then((notificationDetail) async {
      await Future.delayed(const Duration(seconds: 1));
      if (notificationDetail != null &&
          notificationDetail.didNotificationLaunchApp &&
          context.mounted) {
        if (notificationDetail.notificationResponse != null &&
            notificationDetail.notificationResponse!.payload != null) {
          var taskDetail =
              jsonDecode(notificationDetail.notificationResponse!.payload!);
          if (taskDetail["notification_type"].toString() ==
              "media_house_tasks") {
            callTaskDetailApi(taskDetail["broadCast_id"].toString());
          }
        }
      }
    });

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint("Fi1rebaseMessage: ${message.data}");

      if (message.data.isNotEmpty &&
          message.data["notification_type"].toString() == "media_house_tasks") {
        debugPrint("Inside Task Assigned notification");
        localNotificationService.showFlutterNotificationWithSound(message);

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
        localNotificationService.showFlutterNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        if (mounted) {
          setState(() {});
        }
        debugPrint("FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.data.isNotEmpty &&
            message.data["notification_type"].toString() ==
                "media_house_tasks") {
          debugPrint("Inside Task Assigned notification");
          if (mounted) {
            callTaskDetailApi(message.data["broadCast_id"]);
          }
        } else {
          localNotificationService.showFlutterNotification(message);
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

  requestLocationPermissions() async {
    try {
      locationData = await _locationService.getCurrentLocation(context);
      debugPrint("GettingLocation ==> $locationData");
      if (locationData != null) {
        proceedWithLocation(locationData);
      } else {
        debugPrint("Null-ll");
        goToLocationErrorScreen();
      }
    } on Exception catch (e) {
      goToLocationErrorScreen();
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
        GeoData data = await Geocoder2.getDataFromCoordinates(
            latitude: latitude,
            longitude: longitude,
            googleMapApiKey: Platform.isIOS ? appleMapAPiKey : googleMapAPiKey);

        debugPrint("address=====> ${data.address}");
        sharedPreferences!.setDouble(currentLat, latitude);
        sharedPreferences!.setDouble(currentLon, longitude);
        sharedPreferences!.setString(currentAddress, data.address);
        sharedPreferences!.setString(currentCountry, data.country);
        sharedPreferences!.setString(currentState, data.state);
        sharedPreferences!.setString(currentCity, data.city);
        debugPrint(
            "currentAddress: ${sharedPreferences!.getString(currentAddress)}");

        isGetLatLong = false;
        callUpdateCurrentData();
        setState(() {});
        if (alertDialog != null) {
          alertDialog = null;
          Navigator.of(navigatorKey.currentContext!).pop();
        }
      }
    } else {
      debugPrint("Null-ll");
      showSnackBar("Location Error", "nullLocationText", Colors.black);
    }
  }

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
    currentIndex = index;
    setState(() {});
  }

  void callUpdateCurrentData() {
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

        case addDeviceUrlRequest:
          debugPrint("AddDeviceError: $response");
          break;
      }
    } on Exception catch (e) {
      debugPrint("Exception: $e");
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case addDeviceUrlRequest:
          debugPrint("AddDeviceSuccess: $response");
          break;

        /// Get BroadCast task Detail
        case taskDetailUrlRequest:
          debugPrint("taskDetailUrlRequest: 1  $response");
          var map = jsonDecode(response);
          if (map["code"] == 200 && map["task"] != null) {
            var broadCastedData = TaskDetailModel.fromJson(map["task"]);
            debugPrint("taskDetailUrlRequest: 2 $broadCastedData");
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
