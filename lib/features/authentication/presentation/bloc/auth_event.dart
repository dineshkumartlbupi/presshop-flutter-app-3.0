import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {

  const LoginRequested({required this.username, required this.password});
  final String username;
  final String password;

  @override
  List<Object> get props => [username, password];
}

class SocialLoginRequested extends AuthEvent {

  const SocialLoginRequested({
    required this.socialType,
    required this.socialId,
    required this.email,
    required this.name,
    required this.photoUrl,
  });
  final String socialType;
  final String socialId;
  final String email;
  final String name;
  final String photoUrl;

  @override
  List<Object> get props => [socialType, socialId, email, name, photoUrl];
}

class ForgotPasswordRequested extends AuthEvent {
  const ForgotPasswordRequested(this.email);
  final String email;
  @override
  List<Object> get props => [email];
}

class VerifyForgotPasswordOtpRequested extends AuthEvent {
  const VerifyForgotPasswordOtpRequested({required this.email, required this.otp});
  final String email;
  final String otp;
   @override
  List<Object> get props => [email, otp];
}

class ResetPasswordSubmitted extends AuthEvent {
  const ResetPasswordSubmitted({required this.email, required this.password});
  final String email;
  final String password;
  @override
  List<Object> get props => [email, password];
}
