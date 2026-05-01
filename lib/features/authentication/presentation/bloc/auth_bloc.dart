import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/login_user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

import '../../domain/usecases/check_email.dart';
import '../../domain/usecases/social_login_user.dart';
import '../../domain/usecases/forgot_password.dart';
import '../../domain/usecases/verify_forgot_password_otp.dart';
import '../../domain/usecases/reset_password.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/utils/app_logger.dart';
import 'package:presshop/core/analytics/analytics_constants.dart';
import 'package:presshop/core/utils/current_user.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {

  AuthBloc({
    required this.loginUser,
    required this.socialLoginUser,
    required this.checkEmail,
    required this.forgotPassword,
    required this.verifyForgotPasswordOtp,
    required this.resetPassword,
  }) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await loginUser(LoginParams(
        username: event.username,
        password: event.password,
      ));
      result.fold(
        (failure) {
          AppLogger.error("Login failed: ${failure.message}",
              trackAnalytics: true);
          emit(AuthError(message: failure.message));
        },
        (user) {
          AppLogger.setUserIdentity(
            userId: user.id,
            email: user.email,
            name: "${user.firstName} ${user.lastName}",
          );
          AppLogger.trackEvent(EventNames.userLogin, parameters: {
            'method': 'email',
            'user_id': user.id,
          });
          CurrentUser.user = user;
          emit(AuthAuthenticated(user: user));
        },
      );
    });

    on<SocialLoginRequested>((event, emit) async {
      emit(AuthLoading());

      debugPrint("DEBUG: [AuthBloc] SocialLoginRequested for email: ${event.email}");

      // STEP 1: Check if user exists by email first (Very reliable for new users)
      final checkResult = await checkEmail(event.email);
      
      bool isNewUser = false;
      checkResult.fold(
        (failure) {
          debugPrint("DEBUG: [AuthBloc] checkEmail failed: ${failure.message}. Proceeding to socialLogin as fallback.");
        },
        (isAvailable) {
          if (isAvailable) {
            // isAvailable == true means email is NOT in DB -> New User
            isNewUser = true;
          }
        },
      );

      if (isNewUser) {
        debugPrint("DEBUG: [AuthBloc] New user confirmed by email check. Redirecting to SocialSignUp.");
        emit(AuthSocialSignUpRequired(
          socialType: event.socialType,
          socialId: event.socialId,
          email: event.email,
          name: event.name,
          photoUrl: event.photoUrl,
        ));
        return;
      }

      // STEP 2: Proceed with social login for existing (or potentially existing) users
      final result = await socialLoginUser(SocialLoginParams(
        socialType: event.socialType,
        socialId: event.socialId,
        email: event.email,
        name: event.name,
        photoUrl: event.photoUrl,
      ));

      result.fold(
        (failure) {
          if (failure is UserNotRegisteredFailure) {
            debugPrint("DEBUG: [AuthBloc] Social login confirmed registration required.");
            emit(AuthSocialSignUpRequired(
              socialType: event.socialType,
              socialId: event.socialId,
              email: event.email,
              name: event.name,
              photoUrl: event.photoUrl,
            ));
          } else {
            debugPrint("DEBUG: [AuthBloc] Social login failed with error: ${failure.message}");
            emit(AuthError(message: failure.message));
          }
        },
        (user) {
          debugPrint("DEBUG: [AuthBloc] Social login success for user: ${user.id}");
          AppLogger.setUserIdentity(
            userId: user.id,
            email: user.email,
            name: "${user.firstName} ${user.lastName}",
          );
          AppLogger.trackEvent(EventNames.userLogin, parameters: {
            'method': event.socialType,
            'user_id': user.id,
          });
          CurrentUser.user = user;
          emit(AuthAuthenticated(user: user));
        },
      );
    });

    on<ForgotPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await forgotPassword(event.email);
      result.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (otp) {
          emit(ForgotPasswordSent(otp: otp));
        },
      );
    });

    on<VerifyForgotPasswordOtpRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await verifyForgotPasswordOtp(
          VerifyForgotPasswordOtpParams(email: event.email, otp: event.otp));
      result.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (success) {
          if (success) {
            emit(ForgotPasswordOtpVerified());
          } else {
            emit(const AuthError(message: "Invalid OTP"));
          }
        },
      );
    });

    on<ResetPasswordSubmitted>((event, emit) async {
      emit(AuthLoading());
      final result = await resetPassword(
          ResetPasswordParams(email: event.email, password: event.password));
      result.fold((failure) => emit(AuthError(message: failure.message)),
          (success) {
        if (success) {
          emit(ResetPasswordSuccess());
        } else {
          emit(const AuthError(message: "Failed to reset password"));
        }
      });
    });
  }
  final LoginUser loginUser;
  final SocialLoginUser socialLoginUser;
  final CheckEmail checkEmail;
  final ForgotPassword forgotPassword;
  final VerifyForgotPasswordOtp verifyForgotPasswordOtp;
  final ResetPassword resetPassword;
}
