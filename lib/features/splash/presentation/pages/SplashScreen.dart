import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/analytics/analytics_constants.dart';
import 'package:presshop/core/analytics/analytics_mixin.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/features/authentication/presentation/pages/LoginScreen.dart' hide Navigator;
import 'package:presshop/features/dashboard/presentation/pages/Dashboard.dart';
import 'package:presshop/features/onboarding/presentation/pages/WalkThrough.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:presshop/core/di/injection_container.dart';
import '../bloc/splash_bloc.dart';
import '../bloc/splash_event.dart';
import '../bloc/splash_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with AnalyticsPageMixin, WidgetsBindingObserver {
  @override
  String get pageName => PageNames.splash;

  bool mustForceUpdate = false;
  bool openChatScreen = false;
  bool openNotification = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FirebaseCrashlytics.instance.log("SplashScreen -> initState()");
    FirebaseAnalytics.instance.logEvent(name: "splash_opened");
    _checkInitialMessage();
    // AppStarted is dispatched in BlocProvider create
  }

  Future<void> _checkInitialMessage() async {
    RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) _handleMessage(message);
    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (!mounted) return;
    try {
      final data = message.data;
      if (data.isEmpty) return;
      final type = data["notification_type"]?.toString() ?? "";
      final image = data["image"]?.toString() ?? "";
      if (type == "initiate_admin_chat") {
        openChatScreen = true;
        openNotification = false;
      } else if (image.isNotEmpty) {
        openNotification = true;
        openChatScreen = false;
      }
      FirebaseAnalytics.instance.logEvent(
        name: "notification_received",
        parameters: {"type": type},
      );
    } catch (e, st) {
      FirebaseCrashlytics.instance.recordError(e, st);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => sl<SplashBloc>()..add(AppStarted()),
      child: BlocConsumer<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashAuthenticated) {
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
          } else if (state is SplashUnauthenticated) {
             Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          } else if (state is SplashNavigateToOnboarding) {
             Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const Walkthrough()),
              (route) => false,
            );
          }
 else if (state is SplashForceUpdate) {
            setState(() {
              mustForceUpdate = true;
            });
          }
        },
        builder: (context, state) {
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
        },
      ),
    );
  }

  Widget _forceUpdateOverlay(Size size) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(
          child: Container(
            width: size.width * 0.85,
            padding: EdgeInsets.all(size.width * 0.05),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
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
      showSnackBar("Error", "Could not open store", Colors.red);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // In a real BLoC implementation, we would dispatch a CheckVersionEvent here
      // causing the BLoC to re-check and emit SplashForceUpdate if needed.
      // For now, to keep it simple and consistent with previous refactor without adding new events:
      // We rely on the initial check. If detailed resume check is needed, we should add CheckVersionEvent to Bloc.
    }
  }
}
