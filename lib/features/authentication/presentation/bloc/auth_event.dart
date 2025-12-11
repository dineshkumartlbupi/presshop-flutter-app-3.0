import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;

  const LoginRequested({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];
}

class SocialLoginRequested extends AuthEvent {
  final String socialType;
  final String socialId;
  final String email;
  final String name;
  final String photoUrl;

  const SocialLoginRequested({
    required this.socialType,
    required this.socialId,
    required this.email,
    required this.name,
    required this.photoUrl,
  });

  @override
  List<Object> get props => [socialType, socialId, email, name, photoUrl];
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  const ForgotPasswordRequested(this.email);
  @override
  List<Object> get props => [email];
}

class VerifyForgotPasswordOtpRequested extends AuthEvent {
  final String email;
  final String otp;
  const VerifyForgotPasswordOtpRequested({required this.email, required this.otp});
   @override
  List<Object> get props => [email, otp];
}

class ResetPasswordSubmitted extends AuthEvent {
  final String email;
  final String password;
  const ResetPasswordSubmitted({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}
