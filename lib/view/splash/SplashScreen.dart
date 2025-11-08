import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
import 'package:presshop/utils/networkOperations/TokenRefreshManager.dart';
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
  @override
  String get pageName => PageNames.splash;

  var openChatScreen = false;
  var openNotification = false;

  @override
  void initState() {
    super.initState();
    print("Splash Screen111");

    _checkInitialMessage();

    debugPrint("rememberMe: $rememberMe");
    if (rememberMe) {
      print("Splash Screen222");
      Future.delayed(Duration.zero, () {
        myProfileApi();
      });
      print("Splash Screen7777");
    } else {
      print("Splash Screen111222");

      Future.delayed(const Duration(seconds: 3), () {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Walkthrough()),
            (route) => false);
      });
    }

    print("Splash Screen888");
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

  void myProfileApi() async {
    try {
      print("Splash Screen111 refresh myProfileApi");

      await FirebaseAnalytics.instance.logEvent(
        name: 'profile_api_call',
        parameters: {
          'page': 'splash',
          'rememberMe': rememberMe ? 'true' : 'false',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      FirebaseCrashlytics.instance
          .log("myProfileApi() called from SplashScreen");

      NetworkClass(myProfileUrl, this, myProfileUrlRequest)
          .callRequestServiceHeader(false, "get", null);

      print("Splash2222 Screen222 refresh myProfileApi");
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance
          .recordError(e, stackTrace, reason: 'Profile API failed');

      debugPrint("Profile API Exception: $e");

      await FirebaseAnalytics.instance.logEvent(
        name: 'profile_api_failed',
        parameters: {
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
  }

  void refreshToken() {
    print("Splash Screen111 refresh 555");
    NetworkClass(appRefreshTokenUrl, this, appRefreshTokenReq)
        .callRequestServiceHeaderForRefreshToken("get");
  }

  // @override
  // void onError({required int requestCode, required String response}) {
  //   print("on error1234543");
  //   try {
  //     switch (requestCode) {
  //       case myProfileUrlRequest:
  //         var map = jsonDecode(response);
  //         debugPrint("MyProfileError:$map");

  //         if (map['body'] == "Unauthorized" ||
  //             map['code'] == 401 ||
  //             requestCode == 401) {
  //           print("Splash Screen333");
  //           refreshToken();

  //           // rememberMe = false;
  //           // sharedPreferences!.clear();

  //           // Navigator.of(context).pushAndRemoveUntil(
  //           //     MaterialPageRoute(builder: (context) => const LoginScreen()),
  //           //     (route) => false);
  //         }
  //         // cause of issue to auto logout on profile api error
  //         else {
  //           print("Splash Screen444");
  //           showSnackBar(
  //               "Auto logout error ",
  //               "Session expired. Please login again.",
  //               const Color.fromARGB(255, 56, 1, 255));
  //           debugPrint("Auto logout error");

  //           showSnackBar("Profile error",
  //               "Could not fetch profile. Retrying...", Colors.red);
  //           Future.delayed(const Duration(seconds: 2), myProfileApi);

  //           // rajesh
  //           // Navigator.of(context).pushAndRemoveUntil(
  //           //     MaterialPageRoute(builder: (context) => Walkthrough()),
  //           //     (route) => false);
  //         }
  //         break;
  //       case appRefreshTokenReq:
  //         // rajesh
  //         // rememberMe = false;
  //         // sharedPreferences!.clear();
  //         debugPrint("RefreshTokenError and also you are logout:$response");
  //         showSnackBar(
  //             "auto logout error",
  //             "Session expired. Please login again.",
  //             const Color.fromARGB(255, 56, 1, 255));

  //         Navigator.of(context).pushAndRemoveUntil(
  //             MaterialPageRoute(builder: (context) => const LoginScreen()),
  //             (route) => false);
  //     }
  //   } on Exception catch (e) {
  //     debugPrint("exception 3434$e");
  //     showSnackBar(
  //         "Auto logout error $e",
  //         "Session expired. Please login again.",
  //         const Color.fromARGB(255, 56, 1, 255));
  //   }
  // }

  void onError({required int requestCode, required String response}) async {
    print("on error1234543");
    try {
      switch (requestCode) {
        case myProfileUrlRequest:
          var map = jsonDecode(response);
          debugPrint("MyProfileError:$map");

          await FirebaseAnalytics.instance.logEvent(
            name: 'profile_api_error',
            parameters: {
              'request_code': requestCode.toString(),
              'error_code': map['code']?.toString() ?? 'unknown',
              'error_body': map['body']?.toString() ?? 'empty',
              'timestamp': DateTime.now().toIso8601String(),
            },
          );

          if (map['body'] == "Unauthorized" ||
              map['code'] == 401 ||
              requestCode == 401) {
            print("Splash Screen333");

            await FirebaseAnalytics.instance.logEvent(
              name: 'profile_api_unauthorized',
              parameters: {
                'action': 'refresh_token_called',
                'timestamp': DateTime.now().toIso8601String(),
              },
            );

            refreshToken();
          } else {
            print("Splash Screen444");
            
            // NEVER logout automatically - keep user logged in
            // Just retry the profile API
            debugPrint("Profile API failed, but keeping user logged in and retrying...");

            showSnackBar("Profile error",
                "Could not fetch profile. Retrying...", Colors.red);

            await FirebaseAnalytics.instance.logEvent(
              name: 'profile_api_retry',
              parameters: {
                'action': 'retrying_myProfileApi',
                'timestamp': DateTime.now().toIso8601String(),
              },
            );

            Future.delayed(const Duration(seconds: 2), myProfileApi);
          }
          break;

        case appRefreshTokenReq:
          debugPrint("RefreshTokenError and also you are logout:$response");

          await FirebaseAnalytics.instance.logEvent(
            name: 'refresh_token_error',
            parameters: {
              'request_code': requestCode.toString(),
              'response': response,
              'timestamp': DateTime.now().toIso8601String(),
            },
          );

          // NEVER logout automatically - keep user logged in
          // Just show a message and let user retry
          debugPrint("Refresh token API failed, but keeping user logged in");
          showSnackBar(
              "Session Error",
              "Unable to refresh session. Please try again later.",
              const Color.fromARGB(255, 255, 1, 1));
      }
    } on Exception catch (e) {
      debugPrint("exception 3434$e");
      showSnackBar(
          "Auto logout error $e",
          "Session expired. Please login again.",
          const Color.fromARGB(255, 56, 1, 255));

      await FirebaseAnalytics.instance.logEvent(
        name: 'profile_api_exception',
        parameters: {
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    print("on response 1234543");
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
          debugPrint("remember me:$rememberMe");
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
