import 'package:flutter/material.dart';
import 'package:presshop/core/analytics/analytics_helper.dart';

mixin AnalyticsPageMixin<T extends StatefulWidget> on State<T> {
  /// Override this to provide the page name
  String get pageName;

  /// Override this to provide the page class name (optional)
  String? get pageClass => runtimeType.toString();

  /// Override this to provide additional page parameters (optional)
  Map<String, Object>? get pageParameters => null;

  /// Page entry timestamp
  DateTime? _pageEntryTime;

  @override
  void initState() {
    super.initState();
    _pageEntryTime = DateTime.now();

    // Track page visit when widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackPageVisit();
    });
  }

  @override
  void dispose() {
    // Track page exit with duration
    if (_pageEntryTime != null) {
      final duration = DateTime.now().difference(_pageEntryTime!);
      _trackPageExit(duration);
    }
    super.dispose();
  }

  /// Track page visit
  void _trackPageVisit() {
    AnalyticsHelper.trackPageVisit(
      pageName,
      className: pageClass,
      parameters: {
        'page_entry_time': _pageEntryTime?.toIso8601String() ?? '',
        ...?pageParameters,
      },
    );
  }

  /// Track page exit with duration
  void _trackPageExit(Duration duration) {
    AnalyticsHelper.trackEvent(
      'page_exit',
      parameters: {
        'page_name': pageName,
        'page_class': pageClass ?? '',
        'duration_seconds': duration.inSeconds,
        'duration_minutes': duration.inMinutes,
        'page_exit_time': DateTime.now().toIso8601String(),
        ...?pageParameters,
      },
    );
  }

  /// Helper method to track user actions on this page
  void trackAction(String action, {Map<String, Object>? parameters}) {
    AnalyticsHelper.trackUserAction(
      action,
      parameters: {
        'source_page': pageName,
        'page_class': pageClass ?? '',
        ...?parameters,
      },
    );
  }

  /// Helper method to track custom events on this page
  void trackEvent(String eventName, {Map<String, Object>? parameters}) {
    AnalyticsHelper.trackEvent(
      eventName,
      parameters: {
        'source_page': pageName,
        'page_class': pageClass ?? '',
        ...?parameters,
      },
    );
  }
}

/// Analytics Widget Wrapper
///
/// A wrapper widget that automatically tracks page visits for any child widget
///
/// Usage:
/// ```dart
/// AnalyticsWrapper(
///   pageName: PageNames.dashboard,
///   child: DashboardContent(),
/// )
/// ```
class AnalyticsWrapper extends StatefulWidget {
  final String pageName;
  final String? pageClass;
  final Map<String, Object>? parameters;
  final Widget child;

  const AnalyticsWrapper({
    super.key,
    required this.pageName,
    this.pageClass,
    this.parameters,
    required this.child,
  });

  @override
  State<AnalyticsWrapper> createState() => _AnalyticsWrapperState();
}

class _AnalyticsWrapperState extends State<AnalyticsWrapper>
    with AnalyticsPageMixin {
  @override
  String get pageName => widget.pageName;

  @override
  String? get pageClass => widget.pageClass;

  @override
  Map<String, Object>? get pageParameters => widget.parameters;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Analytics Route Observer
///
/// Automatically tracks route changes in your app
/// Add this to your MaterialApp's navigatorObservers
///
/// Usage:
/// ```dart
/// MaterialApp(
///   navigatorObservers: [
///     AnalyticsRouteObserver(),
///     FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
///   ],
/// )
/// ```
class AnalyticsRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackRouteChange('push', route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _trackRouteChange('replace', newRoute, oldRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _trackRouteChange('pop', previousRoute, route);
  }

  void _trackRouteChange(String action, Route<dynamic>? currentRoute,
      Route<dynamic>? previousRoute) {
    if (currentRoute is PageRoute) {
      final String currentRouteName = currentRoute.settings.name ?? 'unknown';
      final String previousRouteName =
          previousRoute?.settings.name ?? 'unknown';

      AnalyticsHelper.trackNavigation(
        previousRouteName,
        currentRouteName,
        method: action,
        parameters: {
          'route_action': action,
          'current_route': currentRouteName,
          'previous_route': previousRouteName,
        },
      );
    }
  }
}
