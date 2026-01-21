import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:force_update_helper/force_update_helper.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:presshop/core/analytics/analytics_helper.dart';
import 'package:presshop/core/analytics/analytics_mixin.dart';
import 'package:presshop/core/services/force_update_service.dart';
import 'package:presshop/features/splash/data/repositories/force_update_repositor.dart';
import 'package:presshop/features/splash/presentation/pages/splash_screen.dart';
import 'package:presshop/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/features/task/presentation/bloc/task_bloc.dart';
import 'package:presshop/features/earning/presentation/bloc/earning_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl<TaskBloc>()),
          BlocProvider(create: (_) => sl<EarningBloc>()),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          builder: (context, child) {
            return ForceUpdateWidget(
              navigatorKey: navigatorKey,
              forceUpdateClient: ForceUpdateClient(
                fetchRequiredVersion: _fetchRequiredVersion,
                iosAppStoreId: '6744651614',
              ),
              allowCancel: false,
              showForceUpdateAlert: ForceUpdateService.showForceUpdateDialog,
              showStoreListing: (Uri storeUrl) async {},
              child: ConnectivityWrapper(child: child ?? const SizedBox()),
            );
          },
          debugShowCheckedModeBanner: false,
          navigatorObservers: [
            AnalyticsHelper.observer,
            AnalyticsRouteObserver(),
          ],
          theme: ThemeData(
            fontFamily: "AirbnbCereal",
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: false,
          ),
          home: const SplashScreen(),
        ),
      ),
    );
  }

  Future<String> _fetchRequiredVersion() async {
    try {
      final force = await ForceUpdateRepository.checkForceUpdate();
      debugPrint("Force update check: $force");

      if (force) return "999.0.0";

      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (e) {
      debugPrint("Force update check failed: $e");

      final info = await PackageInfo.fromPlatform();
      return info.version;
    }
  }
}

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    Connectivity().checkConnectivity().then((results) {
      debugPrint("ConnectivityWrapper: Initial check: $results");
      _checkConnectivity(results);
    });

    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      debugPrint("ConnectivityWrapper: Status changed: $results");
      _checkConnectivity(results);
    });
  }

  Future<void> _checkConnectivity(List<ConnectivityResult> results) async {
    bool isDeviceOffline = results.contains(ConnectivityResult.none);

    debugPrint(
        "ConnectivityWrapper: isDeviceOffline: $isDeviceOffline, DialogShowing: $_isDialogShowing");

    if (isDeviceOffline) {
      bool hasConnection = await InternetConnectionChecker().hasConnection;
      if (!hasConnection) {
        _showOfflineDialog();
      } else {
        _dismissOfflineDialog();
      }
    } else {
      _dismissOfflineDialog();
    }
  }

  void _showOfflineDialog() {
    if (_isDialogShowing) return;
    _isDialogShowing = true;

    debugPrint("ConnectivityWrapper: Showing offline dialog");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigatorKey.currentContext == null) {
        debugPrint("ConnectivityWrapper: Navigator context is null!");
        _isDialogShowing = false;
        return;
      }

      commonErrorDialogDialog(
        MediaQuery.of(navigatorKey.currentContext!).size,
        "No Internet Connection",
        "Offline",
        () {
          debugPrint("ConnectivityWrapper: Retry clicked");
          _checkConnection();
        },
        actionButton: "Retry",
        isFromNetworkError: true,
        shouldShowClosedButton: false,
      );
    });
  }

  Future<void> _checkConnection() async {
    bool hasConnection = await InternetConnectionChecker().hasConnection;
    debugPrint(
        "ConnectivityWrapper: Retry check hasConnection: $hasConnection");

    if (hasConnection) {
      _dismissOfflineDialog();
    } else {
      _isDialogShowing = false;
      _showOfflineDialog();
    }
  }

  void _dismissOfflineDialog() {
    if (_isDialogShowing) {
      debugPrint("ConnectivityWrapper: Dismissing offline dialog");
      if (navigatorKey.currentState?.canPop() ?? false) {
        navigatorKey.currentState?.pop();
      }
      _isDialogShowing = false;
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
