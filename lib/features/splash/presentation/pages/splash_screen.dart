import 'dart:async';

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/core_export.dart';
import 'package:go_router/go_router.dart';
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
  bool showError = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FirebaseCrashlytics.instance.log("SplashScreen -> initState()");
    AppLogger.trackEvent(EventNames.splashOpened);
    getFcmToken();
    _checkInitialMessage();
  }

  Future<void> _checkInitialMessage() async {
    RemoteMessage? message =
        await FirebaseMessaging.instance.getInitialMessage();
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
      AppLogger.trackAction(
        ActionNames.notificationReceived,
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
            context.goNamed(AppRoutes.dashboardName);
          } else if (state is SplashUnauthenticated) {
            // context.go(AppRoutes.loginPath);
            context.go(AppRoutes.walkthroughPath);
          } else if (state is SplashNavigateToOnboarding) {
            context.go(AppRoutes.walkthroughPath);
          } else if (state is SplashForceUpdate) {
            setState(() {
              mustForceUpdate = true;
            });
          } else if (state is SplashError) {
            setState(() {
              showError = true;
              errorMessage = state.message;
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
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * AppDimensions.numD15),
                    child: Image.asset('assets/logo/cmplogo2.png'),
                  ),
                ),
                if (showError)
                  ConnectionErrorOverlay(
                    message: errorMessage,
                    onRetry: () {
                      setState(() {
                        showError = false;
                        errorMessage = "";
                      });
                      context.read<SplashBloc>().add(AppStarted());
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {}
  }

  Future<void> getFcmToken() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String fcmToken = await FirebaseMessaging.instance.getToken() ?? "";
    debugPrint("FCM Token:::: $fcmToken");

    String deviceId = "";
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      debugPrint('Running on ${androidInfo.model}');
      deviceId = androidInfo.id;
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      debugPrint('Running on ${iosInfo.utsname.machine}');
      deviceId = iosInfo.identifierForVendor!;
    }
    debugPrint("Device ID: $deviceId");
  }
}
