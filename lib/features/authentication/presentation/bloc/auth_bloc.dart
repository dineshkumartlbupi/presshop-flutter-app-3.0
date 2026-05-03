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

      debugPrint(
          "🚀 [AuthBloc] SocialLoginRequested for email: ${event.email}");

      // STEP 1: Check if user exists by email (The primary check)
      bool isExistingUser = false;

      if (event.email.isNotEmpty) {
        final checkResult = await checkEmail(event.email);
        checkResult.fold(
          (failure) {
            debugPrint(
                "⚠️ [AuthBloc] checkEmail API failed: ${failure.message}. Fallback to socialLogin.");
          },
          (isAvailable) {
            // isAvailable == true means email is NOT in DB -> New User
            // isAvailable == false means email IS in DB -> Existing User
            isExistingUser = !isAvailable;
            debugPrint(
                "🔍 [AuthBloc] CheckEmail Result: ${isExistingUser ? 'EXISTS' : 'NEW USER'}");
          },
        );
      }

      // STEP 2: Branch based on existence
      if (!isExistingUser) {
        debugPrint(
            "➡️ [AuthBloc] Emitting AuthSocialSignUpRequired for New User");
        emit(AuthSocialSignUpRequired(
          socialType: event.socialType,
          socialId: event.socialId,
          email: event.email,
          name: event.name,
          photoUrl: event.photoUrl,
        ));
        return;
      }

      // STEP 3: Proceed with social login for existing users
      debugPrint("➡️ [AuthBloc] Proceeding with socialLogin for Existing User");
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
            debugPrint(
                "⚠️ [AuthBloc] socialLogin failed (UserNotRegistered). Redirecting to SignUp.");
            emit(AuthSocialSignUpRequired(
              socialType: event.socialType,
              socialId: event.socialId,
              email: event.email,
              name: event.name,
              photoUrl: event.photoUrl,
            ));
          } else {
            debugPrint("❌ [AuthBloc] socialLogin Error: ${failure.message}");
            emit(AuthError(message: failure.message));
          }
        },
        (user) {
          debugPrint("✅ [AuthBloc] socialLogin Success for: ${user.email}");
          AppLogger.setUserIdentity(
            userId: user.id,
            email: user.email,
            name: "${user.firstName} ${user.lastName}",
          );
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
