import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

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
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver _observer =
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// Get the Firebase Analytics Observer for routing
  static FirebaseAnalyticsObserver get observer => _observer;

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
    try {
      final Map<String, Object> eventParams = {
        'screen_name': pageName,
        'screen_class': className ?? pageName,
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      };

      await _analytics.logScreenView(
        screenName: pageName,
        screenClass: className ?? pageName,
        parameters: eventParams,
      );

      if (kDebugMode) {
        print('📊 Analytics: Page Visit - $pageName');
        print('📊 Parameters: $eventParams');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Analytics Error (Page Visit): $e');
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
    try {
      final Map<String, Object> eventParams = {
        'action_type': action,
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      };

      await _analytics.logEvent(
        name: 'user_action',
        parameters: eventParams,
      );

      if (kDebugMode) {
        print('📊 Analytics: User Action - $action');
        print('📊 Parameters: $eventParams');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Analytics Error (User Action): $e');
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
    try {
      final Map<String, Object> eventParams = {
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      };

      await _analytics.logEvent(
        name: eventName,
        parameters: eventParams,
      );

      if (kDebugMode) {
        print('📊 Analytics: Custom Event - $eventName');
        print('📊 Parameters: $eventParams');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Analytics Error (Custom Event): $e');
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
    try {
      final Map<String, Object> eventParams = {
        'content_type': contentType,
        'content_action': action,
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      };

      await _analytics.logEvent(
        name: 'content_interaction',
        parameters: eventParams,
      );

      if (kDebugMode) {
        print('📊 Analytics: Content Event - $contentType:$action');
        print('📊 Parameters: $eventParams');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Analytics Error (Content Event): $e');
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
    try {
      final Map<String, Object> eventParams = {
        'task_type': taskType,
        'task_action': action,
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      };

      await _analytics.logEvent(
        name: 'task_interaction',
        parameters: eventParams,
      );

      if (kDebugMode) {
        print('📊 Analytics: Task Event - $taskType:$action');
        print('📊 Parameters: $eventParams');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Analytics Error (Task Event): $e');
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
    try {
      final Map<String, Object> eventParams = {
        'chat_action': action,
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      };

      await _analytics.logEvent(
        name: 'chat_interaction',
        parameters: eventParams,
      );

      if (kDebugMode) {
        print('📊 Analytics: Chat Event - $action');
        print('📊 Parameters: $eventParams');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Analytics Error (Chat Event): $e');
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
    try {
      final Map<String, Object> eventParams = {
        'navigation_from': from,
        'navigation_to': to,
        'navigation_method': method,
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      };

      await _analytics.logEvent(
        name: 'navigation',
        parameters: eventParams,
      );

      if (kDebugMode) {
        print('📊 Analytics: Navigation - $from → $to ($method)');
        print('📊 Parameters: $eventParams');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Analytics Error (Navigation): $e');
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
    try {
      final Map<String, Object> eventParams = {
        'auth_method': method,
        'auth_success': success,
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      };

      await _analytics.logEvent(
        name: success ? 'login_success' : 'login_failed',
        parameters: eventParams,
      );

      if (kDebugMode) {
        print(
            '📊 Analytics: Auth Event - $method (${success ? 'Success' : 'Failed'})');
        print('📊 Parameters: $eventParams');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Analytics Error (Auth Event): $e');
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
    try {
      final Map<String, Object> eventParams = {
        'error_message': error,
        'error_page': page,
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      };

      await _analytics.logEvent(
        name: 'app_error',
        parameters: eventParams,
      );

      if (kDebugMode) {
        print('📊 Analytics: Error Event - $error on $page');
        print('📊 Parameters: $eventParams');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Analytics Error (Error Tracking): $e');
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
    try {
      if (userId != null) {
        await _analytics.setUserId(id: userId);
      }

      if (properties != null) {
        for (final entry in properties.entries) {
          await _analytics.setUserProperty(
            name: entry.key,
            value: entry.value,
          );
        }
      }

      if (kDebugMode) {
        print('📊 Analytics: User Properties Set');
        print('📊 User ID: $userId');
        print('📊 Properties: $properties');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Analytics Error (User Properties): $e');
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
    try {
      final Map<String, Object> eventParams = {
        'lifecycle_event': event,
        'timestamp': DateTime.now().toIso8601String(),
        ...?parameters,
      };

      await _analytics.logEvent(
        name: 'app_lifecycle',
        parameters: eventParams,
      );

      if (kDebugMode) {
        print('📊 Analytics: Lifecycle Event - $event');
        print('📊 Parameters: $eventParams');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Analytics Error (Lifecycle): $e');
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
