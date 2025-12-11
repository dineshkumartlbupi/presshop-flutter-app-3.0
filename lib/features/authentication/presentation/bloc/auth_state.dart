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
  final User user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthSocialSignUpRequired extends AuthState {
  final String socialType;
  final String socialId;
  final String email;
  final String name;
  final String photoUrl;

  const AuthSocialSignUpRequired({
    required this.socialType,
    required this.socialId,
    required this.email,
    required this.name,
    required this.photoUrl,
  });
   @override
  List<Object> get props => [socialType, socialId, email, name, photoUrl];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

class ForgotPasswordSent extends AuthState {}
class ForgotPasswordOtpVerified extends AuthState {}
class ResetPasswordSuccess extends AuthState {}

