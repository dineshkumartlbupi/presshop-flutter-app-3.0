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

  const SignUpSuccess({required this.user});
  final User user;

  @override
  List<Object> get props => [user];
}

class SignUpOtpSent extends SignUpState {
  const SignUpOtpSent({required this.data});
  final Map<String, dynamic> data;
  @override
  List<Object> get props => [data];
}

class SignUpError extends SignUpState {

  const SignUpError({required this.message});
  final String message;

  @override
  List<Object> get props => [message];
}

class UserNameCheckResult extends SignUpState {
  UserNameCheckResult(this.isAvailable, {this.errorMessage = ""})
      : timestamp = DateTime.now();
  final bool isAvailable;
  final String errorMessage;
  final DateTime timestamp;

  @override
  List<Object> get props => [isAvailable, errorMessage, timestamp];
}

class EmailCheckResult extends SignUpState {
  EmailCheckResult(this.isAvailable) : timestamp = DateTime.now();
  final bool isAvailable;
  final DateTime timestamp;

  @override
  List<Object> get props => [isAvailable, timestamp];
}

class PhoneCheckResult extends SignUpState {
  PhoneCheckResult(this.isAvailable, {this.errorMessage = ""})
      : timestamp = DateTime.now();
  final bool isAvailable;
  final String errorMessage;
  final DateTime timestamp;

  @override
  List<Object> get props => [isAvailable, errorMessage, timestamp];
}

class AvatarsLoaded extends SignUpState {

  const AvatarsLoaded(this.avatars);
  final List<Avatar> avatars;

  @override
  List<Object> get props => [avatars];
}

class ReferralCodeVerified extends SignUpState {
  ReferralCodeVerified(this.data) : timestamp = DateTime.now();
  final Map<String, dynamic> data;
  final DateTime timestamp;

  @override
  List<Object> get props => [data, timestamp];
}

class ReferralCodeVerificationFailed extends SignUpState {
  ReferralCodeVerificationFailed(this.message) : timestamp = DateTime.now();
  final String message;
  final DateTime timestamp;

  @override
  List<Object> get props => [message, timestamp];
}

class SocialExistsChecked extends SignUpState {

  const SocialExistsChecked(this.exists);
  final bool exists;

  @override
  List<Object> get props => [exists];
}
