import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:presshop/main.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonSharedPrefrence.dart';
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
    implements NetworkResponse {
  var openChatScreen = false;
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
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      // Handle data from the initial message here
      if (initialMessage.data.isNotEmpty &&
          initialMessage.data["notification_type"].toString() ==
              "initiate_admin_chat") {
        openChatScreen = true;
      }
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

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case myProfileUrlRequest:
          var map = jsonDecode(response);
          debugPrint("MyProfileError:$map");
          if (map['body'] == "Unauthorized") {
            rememberMe = false;
            sharedPreferences!.clear();
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false);
          } else {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Walkthrough()),
                (route) => false);
          }
          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case myProfileUrlRequest:
          var map = jsonDecode(response);
          debugPrint("MyProfileSuccess:$map");

          if (map["code"] == 200) {
            sharedPreferences!
                .setString(referralCode, map['userData'][referralCode]);
            sharedPreferences!.setString(
                totalHopperArmy, map['userData'][totalHopperArmy].toString());
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => Dashboard(
                          initialPosition: 2,
                          openChatScreen: openChatScreen,
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
