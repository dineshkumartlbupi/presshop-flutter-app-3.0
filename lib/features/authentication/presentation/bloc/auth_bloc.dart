import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

import '../../domain/usecases/social_login_user.dart';
import '../../domain/usecases/forgot_password.dart';
import '../../domain/usecases/verify_forgot_password_otp.dart';
import '../../domain/usecases/reset_password.dart';
import 'package:presshop/core/error/failures.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final SocialLoginUser socialLoginUser;
  final ForgotPassword forgotPassword;
  final VerifyForgotPasswordOtp verifyForgotPasswordOtp;
  final ResetPassword resetPassword;

  AuthBloc({
    required this.loginUser,
    required this.socialLoginUser,
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
        (failure) => emit(AuthError(message: failure.message)),
        (user) => emit(AuthAuthenticated(user: user)),
      );
    });

    on<SocialLoginRequested>((event, emit) async {
       emit(AuthLoading());
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
             emit(AuthSocialSignUpRequired(
               socialType: event.socialType,
               socialId: event.socialId,
               email: event.email,
               name: event.name,
               photoUrl: event.photoUrl,
             ));
           } else {
             emit(AuthError(message: failure.message));
           }
         },
         (user) => emit(AuthAuthenticated(user: user)),
       );
    });

    on<ForgotPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await forgotPassword(event.email);
      result.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (success) {
          if (success) {
            emit(ForgotPasswordSent());
          } else {
            emit(const AuthError(message: "Failed to send OTP"));
          }
        },
      );
    });

    on<VerifyForgotPasswordOtpRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await verifyForgotPasswordOtp(VerifyForgotPasswordOtpParams(email: event.email, otp: event.otp));
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
      final result = await resetPassword(ResetPasswordParams(email: event.email, password: event.password));
      result.fold(
        (failure) => emit(AuthError(message: failure.message)),
        (success) {
           if (success) {
             emit(ResetPasswordSuccess());
           } else {
             emit(const AuthError(message: "Failed to reset password"));
           }
        }
      );
    });
  }
}
