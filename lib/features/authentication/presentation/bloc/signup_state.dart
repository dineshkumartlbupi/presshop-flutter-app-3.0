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

  const UserNameCheckResult(this.isAvailable, {this.errorMessage = ""});
  final bool isAvailable;
  final String errorMessage;

  @override
  List<Object> get props => [isAvailable, errorMessage];
}

class EmailCheckResult extends SignUpState {

  const EmailCheckResult(this.isAvailable);
  final bool isAvailable;

  @override
  List<Object> get props => [isAvailable];
}

class PhoneCheckResult extends SignUpState {

  const PhoneCheckResult(this.isAvailable, {this.errorMessage = ""});
  final bool isAvailable;
  final String errorMessage;

  @override
  List<Object> get props => [isAvailable, errorMessage];
}

class AvatarsLoaded extends SignUpState {

  const AvatarsLoaded(this.avatars);
  final List<Avatar> avatars;

  @override
  List<Object> get props => [avatars];
}

class ReferralCodeVerified extends SignUpState {

  const ReferralCodeVerified(this.data);
  final Map<String, dynamic> data;

  @override
  List<Object> get props => [data];
}

class SocialExistsChecked extends SignUpState {

  const SocialExistsChecked(this.exists);
  final bool exists;

  @override
  List<Object> get props => [exists];
}
