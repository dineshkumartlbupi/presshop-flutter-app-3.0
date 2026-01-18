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
import 'package:presshop/features/splash/data/repositories/force_update_repository.dart';
import 'package:presshop/features/splash/presentation/pages/SplashScreen.dart';
import 'package:presshop/main.dart';

/// Main application widget with force update functionality
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
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
    );
  }

  /// Fetch the required app version for force update check
  Future<String> _fetchRequiredVersion() async {
    try {
      final force = await ForceUpdateRepository.checkForceUpdate();
      debugPrint("Force update check: $force");

      if (force) return "999.0.0";

      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (e) {
      debugPrint("Force update check failed: $e");

      // Return current version as fallback
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
    // Check initial state
    Connectivity().checkConnectivity().then((results) {
      debugPrint("ConnectivityWrapper: Initial check: $results");
      _checkConnectivity(results);
    });

    // Listen to connectivity changes
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      debugPrint("ConnectivityWrapper: Status changed: $results");
      _checkConnectivity(results);
    });
  }

  Future<void> _checkConnectivity(List<ConnectivityResult> results) async {
    // If list contains none, we might be offline.
    bool isDeviceOffline = results.contains(ConnectivityResult.none);

    debugPrint(
        "ConnectivityWrapper: isDeviceOffline: $isDeviceOffline, DialogShowing: $_isDialogShowing");

    if (isDeviceOffline) {
      // Double check with actual internet connection check to avoid false positives
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
      // Ensure navigator is ready
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
    // For retry, we can use the more robust check
    bool hasConnection = await InternetConnectionChecker().hasConnection;
    debugPrint(
        "ConnectivityWrapper: Retry check hasConnection: $hasConnection");

    if (hasConnection) {
      _dismissOfflineDialog();
    } else {
      // If still offline, the dialog was popped by the button press in commonErrorDialogDialog.
      // We need to show it again.
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
