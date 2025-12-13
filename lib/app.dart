import 'package:flutter/material.dart';
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
            child: child ?? const SizedBox(),
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
