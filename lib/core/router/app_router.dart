import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/features/splash/presentation/pages/splash_screen.dart';
import 'package:presshop/main.dart'; // To access navigatorKey
import 'package:presshop/core/analytics/analytics_helper.dart';
import 'package:presshop/core/analytics/analytics_mixin.dart';
import 'package:presshop/features/authentication/presentation/pages/LoginScreen.dart';
import 'package:presshop/features/authentication/presentation/pages/SignUpScreen.dart';
import 'package:presshop/features/authentication/presentation/pages/WelcomeScreen.dart';
import 'package:presshop/features/dashboard/presentation/pages/dashboard.dart';
import 'package:presshop/features/onboarding/presentation/pages/WalkThrough.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/features/authentication/presentation/bloc/signup_bloc.dart';
import 'package:presshop/core/router/router_constants.dart';
import 'package:presshop/features/authentication/presentation/bloc/signup_event.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey, // Use existing navigator key for legacy support
    initialLocation: '/',
    observers: [
      AnalyticsHelper.observer,
      AnalyticsRouteObserver(),
    ],
    routes: [
      GoRoute(
        path: AppRoutes.splashPath,
        name: AppRoutes.splashName,
        builder: (context, state) => const SplashScreen(),
      ),
      // Future routes will be added here
      GoRoute(
        path: AppRoutes.welcomePath,
        name: AppRoutes.welcomeName,
        builder: (context, state) => WelcomeScreen(
          hideLeading: true,
          screenType: state.pathParameters['type'] ?? 'welcome',
        ),
      ),
      GoRoute(
        path: AppRoutes.walkthroughPath,
        name: AppRoutes.walkthroughName,
        builder: (context, state) => const Walkthrough(),
      ),
      GoRoute(
        path: AppRoutes.loginPath,
        name: AppRoutes.loginName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signupPath,
        name: AppRoutes.signupName,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<SignUpBloc>()..add(FetchAvatarsEvent()),
          child: SignUpScreen(
            socialLogin: false,
            socialId: "",
            email: "",
            name: "",
            phoneNumber: "",
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.dashboardPath,
        name: AppRoutes.dashboardName,
        builder: (context, state) {
          int initialPos = 2; // Default
          if (state.extra is Map<String, dynamic>) {
            final args = state.extra as Map<String, dynamic>;
            initialPos = args['initialPosition'] ?? 2;
          }
          return Dashboard(initialPosition: initialPos);
        },
      ),
    ],
    // Error handler or redirect logic can go here
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
}
