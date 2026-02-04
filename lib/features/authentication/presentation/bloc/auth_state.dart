import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {

  const AuthAuthenticated({required this.user});
  final User user;

  @override
  List<Object> get props => [user];
}

class AuthSocialSignUpRequired extends AuthState {

  const AuthSocialSignUpRequired({
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

class AuthError extends AuthState {

  const AuthError({required this.message});
  final String message;

  @override
  List<Object> get props => [message];
}

class ForgotPasswordSent extends AuthState {
  const ForgotPasswordSent({this.otp = ""});
  final String otp;
  @override
  List<Object> get props => [otp];
}

class ForgotPasswordOtpVerified extends AuthState {}

class ResetPasswordSuccess extends AuthState {}
