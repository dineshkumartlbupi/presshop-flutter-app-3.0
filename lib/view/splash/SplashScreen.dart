import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
import 'package:presshop/view/dashboard/Dashboard.dart';
import 'package:presshop/view/dashboard/version_checker.dart';
import 'package:presshop/view/splash/repository/force_update_repository.dart';
import 'package:presshop/view/walkThrough/WalkThrough.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with AnalyticsPageMixin, WidgetsBindingObserver
    implements NetworkResponse {
  @override
  String get pageName => PageNames.splash;

  bool mustForceUpdate = false;
  bool checkingVersion = true;

  bool openChatScreen = false;
  bool openNotification = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    FirebaseCrashlytics.instance.log("SplashScreen -> initState()");
    FirebaseAnalytics.instance.logEvent(name: "splash_opened");

    // Start the splash flow
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initSplash(); // ensure this runs after first frame & system dialogs
    });
  }

  Future<void> _initSplash() async {
    print("Splash init started");
    try {
      // final force = await ForceUpdateRepository.checkForceUpdate();
      // print("force = $force");
      // if (!mounted) return;

      // if (force) {
      //   setState(() => mustForceUpdate = true);
      //   return;
      // }

      await _checkInitialMessage();

      if (rememberMe) {
        print("RememberMe true, loading profile...");
        myProfileApi();
      } else {
        print("RememberMe false, going to Walkthrough in 3s...");
        await Future.delayed(const Duration(seconds: 3));
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => Walkthrough()),
          (route) => false,
        );
      }
    } catch (e, st) {
      print("Splash error: $e $st");
      showSnackBar("Error", "Splash init failed: $e", Colors.red);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => Walkthrough()),
        (route) => false,
      );
    }
  }

// --------------------------------------------------------------
// APP RESUME: check force update again
// --------------------------------------------------------------

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) async {
  //   if (state == AppLifecycleState.resumed) {
  //     bool shouldForce = await forceUpdateCheck();
  //     if (shouldForce) {
  //       setState(() => mustForceUpdate = true);
  //     }
  //   }
  // }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      FirebaseCrashlytics.instance
          .log("App resumed -> checking force update again");
      FirebaseAnalytics.instance.logEvent(name: "resume_force_update_check");

      bool shouldForce = await forceUpdateCheck();

      if (shouldForce) {
        setState(() {
          mustForceUpdate = true;
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // --------------------------------------------------------------
  // FORCE UPDATE CHECK API
  // --------------------------------------------------------------
  Future<bool> forceUpdateCheck() async {
    final completer = Completer<bool>();

    NetworkClass.fromNetworkClass(
      getLatestVersionUrl,
      _ForceUpdateResponse(completer),
      getLatestVersionReq,
      null,
    ).callRequestServiceHeader(false, "get", null);

    return completer.future;
  }

// Create a helper class to handle API response
// / --------------------------------------------------------------
  // FIREBASE MESSAGE HANDLING
  // --------------------------------------------------------------
  Future<void> _checkInitialMessage() async {
    RemoteMessage? message =
        await FirebaseMessaging.instance.getInitialMessage();

    if (message != null) _handleMessage(message);

    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data["notification_type"] == "initiate_admin_chat") {
      openChatScreen = true;
      openNotification = false;
    } else if (message.data["image"] != null &&
        message.data["image"].isNotEmpty) {
      openNotification = true;
      openChatScreen = false;
    }

    //🔥 Added
    FirebaseAnalytics.instance.logEvent(
      name: "notification_received",
      parameters: {"type": message.data["notification_type"]},
    );
  }

  // --------------------------------------------------------------
  // UI
  // --------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * numD15),
              child: Image.asset('${commonImagePath}ic_splash.png'),
            ),
          ),
          if (mustForceUpdate) _forceUpdateOverlay(size),
        ],
      ),
    );
  }

  // Widget _forceUpdateOverlay() {
  //   return WillPopScope(
  //     onWillPop: () async => false,
  //     child: Container(
  //       width: double.infinity,
  //       height: double.infinity,
  //       color: Colors.white.withOpacity(0.95),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           const Icon(Icons.system_update, size: 80, color: Colors.red),
  //           const SizedBox(height: 20),
  //           const Text(
  //             "Update Required",
  //             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  //           ),
  //           const SizedBox(height: 12),
  //           const Text(
  //             "A newer version of PressHop is available.\nPlease update to continue.",
  //             textAlign: TextAlign.center,
  //             style: TextStyle(fontSize: 16),
  //           ),
  //           const SizedBox(height: 25),
  //           ElevatedButton(
  //             onPressed: _openStore,
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.red,
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
  //             ),
  //             child: const Text("Update Now",
  //                 style: TextStyle(color: Colors.white, fontSize: 18)),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _forceUpdateOverlay(Size size) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        color: Colors.black.withOpacity(0.3), // semi-transparent background
        child: Center(
          child: Container(
            width: size.width * 0.85, // smaller than full width
            padding: EdgeInsets.all(size.width * 0.05),
            decoration: BoxDecoration(
              color:
                  Colors.white.withOpacity(0.95), // semi-transparent background
              borderRadius: BorderRadius.circular(size.width * 0.04),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Heading
                Row(
                  children: [
                    Text(
                      "Update Required",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: size.width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                SizedBox(height: size.width * 0.02),

                const Divider(color: Colors.black26, thickness: 0.5),

                SizedBox(height: size.width * 0.03),

                // Image + Message
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(size.width * 0.03),
                      child: Image.asset(
                        "${commonImagePath}dog.png",
                        height: size.width * 0.25,
                        width: size.width * 0.35,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: size.width * 0.04),
                    Expanded(
                      child: Text(
                        "A newer version of PressHop is available. Please update the app to continue using all features smoothly.",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: size.width * 0.035,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: size.width * 0.08),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: commonElevatedButton(
                    "Update Now",
                    size,
                    commonButtonTextStyle(size),
                    commonButtonStyle(size, colorThemePink),
                    _openStore,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openStore() async {
    FirebaseCrashlytics.instance.log("User clicked Update Now");
    FirebaseAnalytics.instance.logEvent(name: "user_update_now_click");

    final url = Platform.isAndroid
        ? 'https://play.google.com/store/apps/details?id=com.presshop.app'
        : 'https://apps.apple.com/app/id6744651614';

    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      FirebaseAnalytics.instance.logEvent(
        name: "store_launch_error",
        parameters: {"error": e.toString()},
      );
      showSnackBar("Error", "Could not open store", Colors.red);
    }
  }

  // --------------------------------------------------------------
  // API RESPONSES
  // --------------------------------------------------------------

  void onError({required int requestCode, required String response}) async {
    print("on error1234543");
    try {
      switch (requestCode) {
        case getLatestVersionReq:
          checkingVersion = false;
          FirebaseCrashlytics.instance.recordError(
            "Force update API failed",
            StackTrace.current,
          );
          FirebaseAnalytics.instance.logEvent(
            name: "latest_version_api_error",
            parameters: {"response": response},
          );
          return;
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
            debugPrint(
                "Profile API failed, but keeping user logged in and retrying...");

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
  Future<void> onResponse(
      {required int requestCode, required String response}) async {
    switch (requestCode) {
      // case getLatestVersionReq:
      //   final map = jsonDecode(response);

      //   bool shouldForce = false;
      //   bool updateAvailable = await VersionService.isUpdateAvailable(
      //     androidPackage: 'com.presshop.app',
      //     iosAppId: '6744651614',
      //   );

      //   print("updateAvailable = $updateAvailable");
      //   print("before_apirequestforforceupdate $map");

      //   if (map["code"] == 200) {
      //     print("after_apirequestforforceupdate $map");
      //     print("Platform Android ${Platform.isAndroid}");
      //     print("Platform Ios ${Platform.isIOS}");
      //     print("updateAvailable = $updateAvailable");

      //     if (Platform.isAndroid &&
      //         map["data"]["aOSshouldForceUpdate"] == true &&
      //         updateAvailable) {
      //       shouldForce = true;
      //     }

      //     if (Platform.isIOS &&
      //         map["data"]["iOSshouldForceUpdate"] == true &&
      //         updateAvailable) {
      //       shouldForce = true;
      //     }
      //   }
      //   print("shouldForce123 $shouldForce");

      //   if (shouldForce) {
      //     FirebaseCrashlytics.instance.log("Force update required = TRUE");
      //     FirebaseAnalytics.instance.logEvent(name: "force_update_required");

      //     setState(() => mustForceUpdate = true);
      //     return;
      //   }
      //   print("mustForceUpdate1234 = $mustForceUpdate");

      //   setState(() => mustForceUpdate = false);
      //   break;
      case myProfileUrlRequest:
        return _handleProfileResponse(response);

      case appRefreshTokenReq:
        return _handleRefreshTokenResponse(response);
    }
  }

  void refreshToken() {
    print("Splash Screen111 refresh 555");
    NetworkClass(appRefreshTokenUrl, this, appRefreshTokenReq)
        .callRequestServiceHeaderForRefreshToken("get");
  }

  // --------------------------------------------------------------
  // PROFILE API
  // --------------------------------------------------------------
  Future<void> _handleProfileResponse(String response) async {
    final map = jsonDecode(response);

    FirebaseAnalytics.instance.logEvent(name: "profile_api_success");
    FirebaseCrashlytics.instance.log("Profile API success");

    if (map["code"] == 200) {
      try {
        sharedPreferences!.setString(
          currencySymbolKey,
          map['userData'][currencySymbolKey]['symbol'],
        );
      } catch (_) {
        sharedPreferences!.setString(currencySymbolKey, "£");
      }

      currencySymbol = sharedPreferences!.getString(currencySymbolKey) ?? "£";

      sharedPreferences!.setString(referralCode, map['userData'][referralCode]);
      sharedPreferences!.setString(
          totalHopperArmy, map['userData'][totalHopperArmy].toString());

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => Dashboard(
            initialPosition: 2,
            openChatScreen: openChatScreen,
            openNotification: openNotification,
          ),
        ),
        (route) => false,
      );
    }
  }

  // --------------------------------------------------------------
  // REFRESH TOKEN
  // --------------------------------------------------------------
  Future<void> _handleRefreshTokenResponse(String response) async {
    final map = jsonDecode(response);

    FirebaseAnalytics.instance.logEvent(name: "refresh_token_success");
    FirebaseCrashlytics.instance.log("Refresh Token success");

    sharedPreferences!.setString(tokenKey, map[tokenKey]);
    sharedPreferences!.setString(refreshtokenKey, map[refreshtokenKey]);

    myProfileApi();
  }

  void myProfileApi() {
    FirebaseCrashlytics.instance.log("Calling Profile API");
    FirebaseAnalytics.instance.logEvent(name: "profile_api_called");

    NetworkClass(myProfileUrl, this, myProfileUrlRequest)
        .callRequestServiceHeader(false, "get", null);
  }
}

class _ForceUpdateResponse implements NetworkResponse {
  final Completer<bool> completer;
  _ForceUpdateResponse(this.completer);

  @override
  void onError({required int requestCode, required String response}) {
    // API failed → no force update
    completer.complete(false);
  }

  @override
  void onResponse({required int requestCode, required String response}) async {
    final map = jsonDecode(response);
    bool shouldForce = false;

    bool updateAvailable = await VersionService.isUpdateAvailable(
      androidPackage: 'com.presshop.app',
      iosAppId: '6744651614',
    );
    print("sldjfksdfjsldf");
    print(map["data"]["aOSshouldForceUpdate"]);
    print(map["data"]["iOSshouldForceUpdate"]);
    print(Platform.isAndroid);
    print(updateAvailable);

    if (map["code"] == 200) {
      if (Platform.isAndroid &&
          map["data"]["aOSshouldForceUpdate"] == false &&
          updateAvailable) {
        shouldForce = true;
      }
      if (Platform.isIOS &&
          map["data"]["iOSshouldForceUpdate"] == true &&
          updateAvailable) {
        shouldForce = true;
      }
    }

    completer.complete(shouldForce);
  }
}
