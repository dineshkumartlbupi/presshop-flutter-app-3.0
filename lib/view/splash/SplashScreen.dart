import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:presshop/main.dart';
import 'package:presshop/utils/AnalyticsConstants.dart';
import 'package:presshop/utils/AnalyticsMixin.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonSharedPrefrence.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/networkOperations/NetworkClass.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:presshop/view/dashboard/Dashboard.dart';
import 'package:presshop/view/walkThrough/WalkThrough.dart';
import '../authentication/LoginScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with AnalyticsPageMixin
    implements NetworkResponse {
  // Analytics Mixin Requirements
  @override
  String get pageName => PageNames.splash;

  var openChatScreen = false;
  var openNotification = false;

  @override
  void initState() {
    super.initState();

    _checkInitialMessage();

    debugPrint("rememberMe: $rememberMe");
    if (rememberMe) {
      Future.delayed(Duration.zero, () {
        myProfileApi();
      });
    } else {
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Walkthrough()),
            (route) => false);
      });
    }
  }

  Future<void> _checkInitialMessage() async {
    // Check for initial message when app was terminated
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Listen for messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    // Listen for messages when app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message);
    });
  }

  void _handleMessage(RemoteMessage message) {
    // Handle data from the message here
    if (message.data.isNotEmpty &&
        message.data["notification_type"].toString() == "initiate_admin_chat") {
      openChatScreen = true;
      openNotification = false;
    } else if (message.data.isNotEmpty &&
        message.data["image"] != null &&
        message.data["image"].isNotEmpty) {
      openNotification = true;
      openChatScreen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * numD15),
        child: Image.asset(
          '${commonImagePath}ic_splash.png',
        ),
      ),
    );
  }

  ///-------ApisSection-----------
  void myProfileApi() {
    NetworkClass(myProfileUrl, this, myProfileUrlRequest)
        .callRequestServiceHeader(false, "get", null);
  }

  void refreshToken() {
    NetworkClass(appRefreshTokenUrl, this, appRefreshTokenReq)
        .callRequestServiceHeaderForRefreshToken("get");
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case myProfileUrlRequest:
          var map = jsonDecode(response);
          debugPrint("MyProfileError:$map");
          if (map['body'] == "Unauthorized") {
            refreshToken();
            // rememberMe = false;
            // sharedPreferences!.clear();
            // Navigator.of(context).pushAndRemoveUntil(
            //     MaterialPageRoute(builder: (context) => const LoginScreen()),
            //     (route) => false);
          } else {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Walkthrough()),
                (route) => false);
          }
          break;
        case appRefreshTokenReq:
          rememberMe = false;
          sharedPreferences!.clear();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false);
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case appRefreshTokenReq:
          var map = jsonDecode(response);
          debugPrint("RefreshTokenSuccess:$map");
          sharedPreferences!.setString(tokenKey, map[tokenKey]);
          sharedPreferences!.setString(refreshtokenKey, map[refreshtokenKey]);
          myProfileApi();
          break;
        case myProfileUrlRequest:
          var map = jsonDecode(response);
          debugPrint("MyProfileSuccess:$map");

          if (map["code"] == 200) {
            try {
              sharedPreferences!.setString(currencySymbolKey,
                  map['userData'][currencySymbolKey]['symbol']);
            } catch (e) {
              sharedPreferences!.setString(currencySymbolKey, "£");
            }
            currencySymbol =
                sharedPreferences!.getString(currencySymbolKey) ?? "£";
            sharedPreferences!
                .setString(referralCode, map['userData'][referralCode]);
            sharedPreferences!.setString(
                totalHopperArmy, map['userData'][totalHopperArmy].toString());
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => Dashboard(
                          initialPosition: 2,
                          openChatScreen: openChatScreen,
                          openNotification: openNotification,
                        )),
                (route) => false);
          }
          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }
}
