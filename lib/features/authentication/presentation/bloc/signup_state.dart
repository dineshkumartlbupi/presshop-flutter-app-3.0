import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/avatar.dart';

abstract class SignUpState extends Equatable {
  const SignUpState();
  
  @override
  List<Object> get props => [];
}

class SignUpInitial extends SignUpState {}

class SignUpLoading extends SignUpState {}

class SignUpSuccess extends SignUpState {
  final User user;

  const SignUpSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class SignUpOtpSent extends SignUpState {
  final Map<String, dynamic> data;
  const SignUpOtpSent({required this.data});
  @override
  List<Object> get props => [data];
}

class SignUpError extends SignUpState {
  final String message;

  const SignUpError({required this.message});

  @override
  List<Object> get props => [message];
}

class UserNameCheckResult extends SignUpState {
  final bool isAvailable;

  const UserNameCheckResult(this.isAvailable);

  @override
  List<Object> get props => [isAvailable];
}

class EmailCheckResult extends SignUpState {
  final bool isAvailable;

  const EmailCheckResult(this.isAvailable);

  @override
  List<Object> get props => [isAvailable];
}

class PhoneCheckResult extends SignUpState {
  final bool isAvailable;

  const PhoneCheckResult(this.isAvailable);

  @override
  List<Object> get props => [isAvailable];
}

class AvatarsLoaded extends SignUpState {
  final List<Avatar> avatars;

  const AvatarsLoaded(this.avatars);

  @override
  List<Object> get props => [avatars];
}

class ReferralCodeVerified extends SignUpState {
  final Map<String, dynamic> data;

  const ReferralCodeVerified(this.data);

  @override
  List<Object> get props => [data];
}

class SocialExistsChecked extends SignUpState {
  final bool exists;

  const SocialExistsChecked(this.exists);

  @override
  List<Object> get props => [exists];
}
