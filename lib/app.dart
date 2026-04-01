import 'dart:async';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:force_update_helper/force_update_helper.dart';
import 'package:presshop/core/services/force_update_service.dart';
import 'package:presshop/features/splash/data/repositories/force_update_repositor.dart';
import 'package:presshop/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/features/task/presentation/bloc/task_bloc.dart';
import 'package:presshop/features/earning/presentation/bloc/earning_bloc.dart';
import 'package:presshop/features/content/presentation/bloc/content_bloc.dart';
import 'package:presshop/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:presshop/core/router/app_router.dart';
import 'package:presshop/core/analytics/analytics_constants.dart';
import 'package:presshop/core/utils/app_logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<TaskBloc>()),
        BlocProvider(create: (_) => sl<EarningBloc>()),
        BlocProvider(create: (_) => sl<ContentBloc>()),
        BlocProvider(create: (_) => sl<AuthBloc>()),
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        builder: (context, child) {
          return ForceUpdateWidget(
            navigatorKey: navigatorKey,
            forceUpdateClient: ForceUpdateClient(
              fetchRequiredVersion: _fetchRequiredVersion,
              iosAppStoreId: '6744651614',
            ),
            allowCancel: false,
            showForceUpdateAlert: ForceUpdateService.showForceUpdateDialog,
            showStoreListing: (storeUrl) async {},
            child: ConnectivityWrapper(child: child ?? const SizedBox()),
          );
        },
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: "AirbnbCereal",
          scaffoldBackgroundColor: Colors.white,
          useMaterial3: false,
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
  const ConnectivityWrapper({super.key, required this.child});
  final Widget child;

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper>
    with WidgetsBindingObserver {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Connectivity().checkConnectivity().then((results) {
      debugPrint("ConnectivityWrapper: Initial check: $results");
      _checkConnectivity(results);
    });

    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      debugPrint("ConnectivityWrapper: Status changed: $results");
      _checkConnectivity(results);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      AppLogger.trackEvent(EventNames.appBackground);
    } else if (state == AppLifecycleState.resumed) {
      AppLogger.trackEvent(EventNames.appForeground);
    }
  }

  Future<void> _checkConnectivity(List<ConnectivityResult> results) async {
    bool isDeviceOffline = results.contains(ConnectivityResult.none);

    debugPrint(
        "ConnectivityWrapper: isDeviceOffline: $isDeviceOffline, DialogShowing: $_isDialogShowing");

    if (isDeviceOffline) {
      bool hasConnection = await InternetConnectionChecker().hasConnection;
      if (!hasConnection) {
        AppLogger.trackEvent(EventNames.networkError);
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
      _showOfflineDialog();
    }
  }

  void _dismissOfflineDialog() {
    if (_isDialogShowing) {
      debugPrint("ConnectivityWrapper: Dismissing offline dialog");
      try {
        if (navigatorKey.currentContext != null) {
          Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
        }
      } catch (e) {
        debugPrint("ConnectivityWrapper: Error dismissing dialog: $e");
      }
      _isDialogShowing = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
