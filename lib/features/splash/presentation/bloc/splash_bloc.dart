import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../../../authentication/domain/usecases/check_auth_status.dart';
import '../../../authentication/domain/usecases/get_profile.dart';
import '../../../authentication/domain/usecases/check_onboarding_status.dart';
import '../../domain/usecases/check_splash_version.dart';
import 'splash_event.dart';
import 'splash_state.dart';
import 'package:presshop/core/utils/current_user.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {

  SplashBloc({
    required this.checkAuthStatus,
    required this.getProfile,
    required this.checkAppVersion,
    required this.checkOnboardingStatus,
  }) : super(SplashInitial()) {
    on<AppStarted>(_onAppStarted);
  }
  final CheckAuthStatus checkAuthStatus;
  final GetProfile getProfile;
  final CheckSplashVersion checkAppVersion;
  final CheckOnboardingStatus checkOnboardingStatus;

  Future<void> _onAppStarted(
      AppStarted event, Emitter<SplashState> emit) async {
    emit(SplashLoading());

    // Check App Version
    final versionResult = await checkAppVersion(NoParams());
    bool shouldForce = false;

    await versionResult.fold((failure) async {
      emit(SplashError(
          message:
              failure.message.isNotEmpty ? failure.message : "Server Error"));
    }, (version) async {
      if (version.forceUpdate) {
        shouldForce = true;
      }
    });

    if (state is SplashError) return;

    if (shouldForce) {
      emit(SplashForceUpdate());
      return;
    }

    final result = await checkAuthStatus(NoParams());
    debugPrint("🔍 SplashBloc: CheckAuthStatus Result: $result");
    await result.fold(
      (failure) async {
        debugPrint("❌ SplashBloc: CheckAuthStatus Failed: $failure");
        emit(SplashUnauthenticated());
      },
      (isLoggedIn) async {
        debugPrint("🔍 SplashBloc: Is Logged In: $isLoggedIn");
        if (isLoggedIn) {
          final profileResult = await getProfile(NoParams());
          profileResult.fold(
            (failure) {
              debugPrint("❌ SplashBloc: Failed to fetch profile: $failure");
              emit(
                  SplashAuthenticated()); // Proceed anyway, Dashboard will retry
            },
            (user) {
              CurrentUser.user = user;
              debugPrint("✅ SplashBloc: CurrentUser set: ${user.id}");
              emit(SplashAuthenticated());
            },
          );
        } else {
          final onboardingResult = await checkOnboardingStatus(NoParams());
          debugPrint("🔍 SplashBloc: Onboarding Status: $onboardingResult");
          onboardingResult.fold(
            (failure) {
              debugPrint(
                  "⚠️ SplashBloc: Onboarding check failed, navigating to Onboarding");
              emit(SplashNavigateToOnboarding());
            },
            (seen) {
              if (seen) {
                debugPrint(
                    "✅ SplashBloc: Onboarding seen, navigating to Unauthenticated");
                emit(SplashUnauthenticated());
              } else {
                debugPrint(
                    "❌ SplashBloc: Onboarding NOT seen, navigating to Onboarding");
                emit(SplashNavigateToOnboarding());
              }
            },
          );
        }
      },
    );
  }
}
