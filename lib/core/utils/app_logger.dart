import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:presshop/core/analytics/analytics_helper.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/core/services/appsflyer_service.dart';

class AppLogger {
  static FirebaseAnalytics get _analytics => sl<FirebaseAnalytics>();
  static FirebaseCrashlytics get _crashlytics => sl<FirebaseCrashlytics>();

  // Toggle this to manually control crashlytics in dev
  static bool isCrashlyticsEnabled = !kDebugMode;

  /// Log an informative message (Console + Crashlytics)
  static void info(String message, {Map<String, dynamic>? data}) {
    final formattedMessage =
        "ℹ️ [INFO] $message ${data != null ? data.toString() : ""}";

    if (kDebugMode) {
      debugPrint(formattedMessage);
    }

    if (isCrashlyticsEnabled) {
      _crashlytics.log(formattedMessage);
    }
  }

  static void warning(String message, {Map<String, dynamic>? data}) {
    final formattedMessage =
        "⚠️ [WARN] $message ${data != null ? data.toString() : ""}";

    if (kDebugMode) {
      debugPrint(formattedMessage);
    }

    if (isCrashlyticsEnabled) {
      _crashlytics.log(formattedMessage);
    }
  }

  static void error(String message,
      {Object? error,
      StackTrace? stackTrace,
      bool trackAnalytics = false,
      String? eventName}) {
    final formattedMessage = "❌ [ERROR] $message";

    if (kDebugMode) {
      debugPrint(formattedMessage);
      if (error != null) debugPrint("Error detail: $error");
    }

    if (isCrashlyticsEnabled) {
      _crashlytics.recordError(error ?? message, stackTrace, reason: message);
    }

    if (trackAnalytics) {
      if (eventName != null) {
        AnalyticsHelper.trackEvent(eventName, parameters: {
          'message': message,
          'error': error?.toString() ?? 'N/A',
        });
      } else {
        AnalyticsHelper.trackError(message, 'app_logger');
      }
    }
  }

  /// Track a user event (Analytics + Crashlytics log)
  static void trackEvent(String eventName, {Map<String, Object>? parameters}) {
    info("Tracking Event: $eventName", data: parameters);
    AnalyticsHelper.trackEvent(eventName, parameters: parameters);
  }

  /// Track a user action (Analytics + Crashlytics log)
  static void trackAction(String action, {Map<String, Object>? parameters}) {
    info("Tracking Action: $action", data: parameters);
    AnalyticsHelper.trackUserAction(action, parameters: parameters);
  }

  /// Track a page visit (Analytics + Crashlytics log)
  static void trackPage(String pageName,
      {String? className, Map<String, Object>? parameters}) {
    info("Tracking Page: $pageName", data: parameters);
    AnalyticsHelper.trackPageVisit(pageName,
        className: className, parameters: parameters);
  }

  /// Set user identity across all services
  static void setUserIdentity(
      {required String userId, String? email, String? name}) {
    info("Setting User Identity: $userId");

    _analytics.setUserId(id: userId);
    AppsFlyerService.instance.setCustomerUserId(userId);
    
    if (isCrashlyticsEnabled) {
      _crashlytics.setUserIdentifier(userId);
    }

    if (email != null) {
      _analytics.setUserProperty(name: 'email', value: email);
      if (isCrashlyticsEnabled) {
        _crashlytics.setCustomKey('email', email);
      }
    }

    if (name != null) {
      _analytics.setUserProperty(name: 'full_name', value: name);
      if (isCrashlyticsEnabled) {
        _crashlytics.setCustomKey('name', name);
      }
    }
  }

  /// Clear user identity (on Logout)
  static void clearUserIdentity() {
    info("Clearing User Identity");
    _analytics.setUserId(id: null);
    AppsFlyerService.instance.setCustomerUserId("");
    if (isCrashlyticsEnabled) {
      _crashlytics.setUserIdentifier("");
    }
  }
}
