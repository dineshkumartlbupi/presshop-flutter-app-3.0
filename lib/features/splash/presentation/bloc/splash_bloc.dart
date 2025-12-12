import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../../../authentication/domain/usecases/check_auth_status.dart';
import '../../../authentication/domain/usecases/get_profile.dart'; 
import '../../../authentication/domain/usecases/check_onboarding_status.dart';
import '../../../dashboard/domain/usecases/check_app_version.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final CheckAuthStatus checkAuthStatus;
  final GetProfile getProfile;
  final CheckAppVersion checkAppVersion;
  final CheckOnboardingStatus checkOnboardingStatus;

  SplashBloc({
    required this.checkAuthStatus,
    required this.getProfile,
    required this.checkAppVersion,
    required this.checkOnboardingStatus,
  }) : super(SplashInitial()) {
    on<AppStarted>(_onAppStarted);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<SplashState> emit) async {
    emit(SplashLoading());
    await Future.delayed(const Duration(seconds: 2));

    // Check App Version
    final versionResult = await checkAppVersion(NoParams());
    bool shouldForce = false;
    
    await versionResult.fold(
      (failure) async {}, 
      (map) async {
         if (map["code"] == 200) {
           if (Platform.isAndroid && map["data"]["aOSshouldForceUpdate"] == true) shouldForce = true;
           if (Platform.isIOS && map["data"]["iOSshouldForceUpdate"] == true) shouldForce = true;
         }
      }
    );

    if (shouldForce) {
      emit(SplashForceUpdate());
      return;
    }

    final result = await checkAuthStatus(NoParams());
    await result.fold(
      (failure) async => emit(SplashUnauthenticated()), 
      (isLoggedIn) async {
        if (isLoggedIn) {
           final profileResult = await getProfile(NoParams());
           profileResult.fold(
             (failure) => emit(SplashUnauthenticated()),
             (user) => emit(SplashAuthenticated()),
           );
        } else {
           // Check if Onboarding Seen
           final onboardingResult = await checkOnboardingStatus(NoParams());
           onboardingResult.fold(
             (failure) => emit(SplashNavigateToOnboarding()), // Default to onboarding if fail
             (seen) {
               if (seen) {
                 emit(SplashUnauthenticated());
               } else {
                 emit(SplashNavigateToOnboarding());
               }
             }
           );
        }
      },
    );
  }
}
