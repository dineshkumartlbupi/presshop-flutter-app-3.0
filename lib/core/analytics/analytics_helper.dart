import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/core/services/appsflyer_service.dart';

/// Firebase Analytics Helper Class
///
/// This class provides a structured and easy-to-use interface for tracking
/// page visits, user interactions, and custom events throughout the Presshop app.
///
/// Usage:
/// ```dart
/// // Track page visit
/// AnalyticsHelper.trackPageVisit('Dashboard');
///
/// // Track user action
/// AnalyticsHelper.trackUserAction('button_click', {'button_name': 'login'});
///
/// // Track custom event
/// AnalyticsHelper.trackEvent('content_published', {'content_type': 'photo'});
/// ```
class AnalyticsHelper {
  /// Global toggle for analytics tracking.
  /// By default, tracking is DISABLED in debug mode and ENABLED in release mode.
  static bool isTrackingEnabled = !kDebugMode;

  static FirebaseAnalytics? get _analytics {
    if (!isTrackingEnabled) return null;
    try {
      return sl<FirebaseAnalytics>();
    } catch (_) {
      return null;
    }
  }

  /// Get the Firebase Analytics Observer for routing
  static NavigatorObserver get observer {
    final analytics = _analytics;
    if (analytics == null) {
      return RouteObserver<PageRoute<dynamic>>();
    }
    return FirebaseAnalyticsObserver(analytics: analytics);
  }

  /// Track page/screen visits
  ///
  /// [pageName] - Name of the page/screen (use PageNames constants)
  /// [className] - Optional class name for debugging
  /// [parameters] - Additional parameters to track
  static Future<void> trackPageVisit(
    String pageName, {
    String? className,
    Map<String, Object>? parameters,
  }) async {
    if (!isTrackingEnabled) return;
    try {
      final Map<String, Object> eventParams = {
        'screen_name': pageName,
        'screen_class': className ?? pageName,
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      };

      final analytics = _analytics;
      if (analytics != null) {
        await analytics.logScreenView(
          screenName: pageName,
          screenClass: className ?? pageName,
          parameters: eventParams,
        );
      }

      // Track in AppsFlyer
      await AppsFlyerService.logEvent(
          'af_page_visit', Map<String, dynamic>.from(eventParams));

      if (kDebugMode) {
        debugPrint('📊 Analytics: Page Visit - $pageName');
        debugPrint('📊 Parameters: $eventParams');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Analytics Error (Page Visit): $e');
      }
    }
  }

  /// Track user actions/interactions
  ///
  /// [action] - Action name (e.g., 'button_click', 'swipe', 'scroll')
  /// [parameters] - Action-specific parameters
  static Future<void> trackUserAction(
    String action, {
    Map<String, Object>? parameters,
  }) async {
    if (!isTrackingEnabled) return;
    try {
      final Map<String, Object> eventParams = {
        'action_type': action,
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      };

      final analytics = _analytics;
      if (analytics != null) {
        await analytics.logEvent(
          name: 'user_action',
          parameters: eventParams,
        );
      }

      // Track in AppsFlyer
      await AppsFlyerService.logEvent(
          action, Map<String, dynamic>.from(eventParams));

      if (kDebugMode) {
        debugPrint('📊 Analytics: User Action - $action');
        debugPrint('📊 Parameters: $eventParams');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Analytics Error (User Action): $e');
      }
    }
  }

  /// Track custom events specific to Presshop
  ///
  /// [eventName] - Custom event name
  /// [parameters] - Event parameters
  static Future<void> trackEvent(
    String eventName, {
    Map<String, Object>? parameters,
  }) async {
    if (!isTrackingEnabled) return;
    try {
      final Map<String, Object> eventParams = {
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      };

      final analytics = _analytics;
      if (analytics != null) {
        await analytics.logEvent(
          name: eventName,
          parameters: eventParams,
        );
      }

      // Track in AppsFlyer
      await AppsFlyerService.logEvent(
          eventName, Map<String, dynamic>.from(eventParams));

      if (kDebugMode) {
        debugPrint('📊 Analytics: Custom Event - $eventName');
        debugPrint('📊 Parameters: $eventParams');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Analytics Error (Custom Event): $e');
      }
    }
  }

  /// Track content-related events
  ///
  /// [contentType] - Type of content (photo, video, document)
  /// [action] - Action performed (publish, edit, delete, view, etc.)
  /// [parameters] - Additional content parameters
  static Future<void> trackContentEvent(
    String contentType,
    String action, {
    Map<String, Object>? parameters,
  }) async {
    if (!isTrackingEnabled) return;
    try {
      final Map<String, Object> eventParams = {
        'content_type': contentType,
        'content_action': action,
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      };

      final analytics = _analytics;
      if (analytics != null) {
        await analytics.logEvent(
          name: 'content_interaction',
          parameters: eventParams,
        );
      }

      // Track in AppsFlyer
      await AppsFlyerService.logEvent(
          '${contentType}_$action', Map<String, dynamic>.from(eventParams));

      if (kDebugMode) {
        debugPrint('📊 Analytics: Content Event - $contentType:$action');
        debugPrint('📊 Parameters: $eventParams');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Analytics Error (Content Event): $e');
      }
    }
  }

  /// Track task-related events
  ///
  /// [taskType] - Type of task
  /// [action] - Action performed (accept, reject, complete, etc.)
  /// [parameters] - Task-specific parameters
  static Future<void> trackTaskEvent(
    String taskType,
    String action, {
    Map<String, Object>? parameters,
  }) async {
    if (!isTrackingEnabled) return;
    try {
      final Map<String, Object> eventParams = {
        'task_type': taskType,
        'task_action': action,
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      };

      final analytics = _analytics;
      if (analytics != null) {
        await analytics.logEvent(
          name: 'task_interaction',
          parameters: eventParams,
        );
      }

      // Track in AppsFlyer
      await AppsFlyerService.logEvent(
          '${taskType}_$action', Map<String, dynamic>.from(eventParams));

      if (kDebugMode) {
        debugPrint('📊 Analytics: Task Event - $taskType:$action');
        debugPrint('📊 Parameters: $eventParams');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Analytics Error (Task Event): $e');
      }
    }
  }

  /// Track chat/communication events
  ///
  /// [action] - Chat action (send_message, start_chat, etc.)
  /// [parameters] - Chat-specific parameters
  static Future<void> trackChatEvent(
    String action, {
    Map<String, Object>? parameters,
  }) async {
    if (!isTrackingEnabled) return;
    try {
      final Map<String, Object> eventParams = {
        'chat_action': action,
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      };

      final analytics = _analytics;
      if (analytics != null) {
        await analytics.logEvent(
          name: 'chat_interaction',
          parameters: eventParams,
        );
      }

      // Track in AppsFlyer
      await AppsFlyerService.logEvent(
          'chat_$action', Map<String, dynamic>.from(eventParams));

      if (kDebugMode) {
        debugPrint('📊 Analytics: Chat Event - $action');
        debugPrint('📊 Parameters: $eventParams');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Analytics Error (Chat Event): $e');
      }
    }
  }

  /// Track navigation events
  ///
  /// [from] - Source page/screen
  /// [to] - Destination page/screen
  /// [method] - Navigation method (tap, swipe, deep_link, etc.)
  static Future<void> trackNavigation(
    String from,
    String to, {
    String method = 'tap',
    Map<String, Object>? parameters,
  }) async {
    if (!isTrackingEnabled) return;
    try {
      final Map<String, Object> eventParams = {
        'navigation_from': from,
        'navigation_to': to,
        'navigation_method': method,
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      };

      final analytics = _analytics;
      if (analytics != null) {
        await analytics.logEvent(
          name: 'navigation',
          parameters: eventParams,
        );
      }

      // Track in AppsFlyer
      await AppsFlyerService.logEvent(
          'af_navigation', Map<String, dynamic>.from(eventParams));

      if (kDebugMode) {
        debugPrint('📊 Analytics: Navigation - $from → $to ($method)');
        debugPrint('📊 Parameters: $eventParams');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Analytics Error (Navigation): $e');
      }
    }
  }

  /// Track user login/authentication events
  ///
  /// [method] - Login method (email, google, apple, etc.)
  /// [success] - Whether login was successful
  /// [parameters] - Additional auth parameters
  static Future<void> trackAuthEvent(
    String method,
    bool success, {
    Map<String, Object>? parameters,
  }) async {
    if (!isTrackingEnabled) return;
    try {
      final Map<String, Object> eventParams = {
        'auth_method': method,
        'auth_success': success,
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      };

      final analytics = _analytics;
      if (analytics != null) {
        await analytics.logEvent(
          name: success ? 'login_success' : 'login_failed',
          parameters: eventParams,
        );
      }

      // Track in AppsFlyer
      await AppsFlyerService.logEvent(
        success ? 'af_login_success' : 'af_login_failed',
        Map<String, dynamic>.from(eventParams),
      );

      if (kDebugMode) {
        debugPrint(
            '📊 Analytics: Auth Event - $method (${success ? 'Success' : 'Failed'})');
        debugPrint('📊 Parameters: $eventParams');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Analytics Error (Auth Event): $e');
      }
    }
  }

  /// Track error events
  ///
  /// [error] - Error message or type
  /// [page] - Page where error occurred
  /// [parameters] - Error-specific parameters
  static Future<void> trackError(
    String error,
    String page, {
    Map<String, Object>? parameters,
  }) async {
    if (!isTrackingEnabled) return;
    try {
      final Map<String, Object> eventParams = {
        'error_message': error,
        'error_page': page,
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      };

      final analytics = _analytics;
      if (analytics != null) {
        await analytics.logEvent(
          name: 'app_error',
          parameters: eventParams,
        );
      }

      // Track in AppsFlyer
      await AppsFlyerService.logEvent(
          'af_app_error', Map<String, dynamic>.from(eventParams));

      if (kDebugMode) {
        debugPrint('📊 Analytics: Error Event - $error on $page');
        debugPrint('📊 Parameters: $eventParams');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Analytics Error (Error Tracking): $e');
      }
    }
  }

  /// Set user properties for better analytics segmentation
  ///
  /// [userId] - User ID
  /// [properties] - User properties map
  static Future<void> setUserProperties({
    String? userId,
    Map<String, String>? properties,
  }) async {
    if (!isTrackingEnabled) return;
    try {
      final analytics = _analytics;
      if (userId != null && analytics != null) {
        await analytics.setUserId(id: userId);
      }

      if (properties != null && analytics != null) {
        for (final entry in properties.entries) {
          await analytics.setUserProperty(
            name: entry.key,
            value: entry.value,
          );
        }
      }

      if (kDebugMode) {
        debugPrint('📊 Analytics: User Properties Set');
        debugPrint('📊 User ID: $userId');
        debugPrint('📊 Properties: $properties');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Analytics Error (User Properties): $e');
      }
    }
  }

  /// Track app lifecycle events
  ///
  /// [event] - Lifecycle event (app_open, app_background, app_foreground, etc.)
  /// [parameters] - Additional parameters
  static Future<void> trackLifecycleEvent(
    String event, {
    Map<String, Object>? parameters,
  }) async {
    if (!isTrackingEnabled) return;
    try {
      final Map<String, Object> eventParams = {
        'lifecycle_event': event,
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      };

      final analytics = _analytics;
      if (analytics != null) {
        await analytics.logEvent(
          name: 'app_lifecycle',
          parameters: eventParams,
        );
      }

      // Track in AppsFlyer
      await AppsFlyerService.logEvent(
          'af_app_lifecycle', Map<String, dynamic>.from(eventParams));

      if (kDebugMode) {
        debugPrint('📊 Analytics: Lifecycle Event - $event');
        debugPrint('📊 Parameters: $eventParams');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Analytics Error (Lifecycle): $e');
      }
    }
  }

  /// Batch track multiple events (useful for complex interactions)
  ///
  /// [events] - List of events to track
  static Future<void> trackBatchEvents(
      List<Map<String, dynamic>> events) async {
    for (final event in events) {
      final String eventName = event['name'] ?? 'unknown_event';
      final Map<String, Object>? parameters = event['parameters'];

      await trackEvent(eventName, parameters: parameters);
    }
  }
}
