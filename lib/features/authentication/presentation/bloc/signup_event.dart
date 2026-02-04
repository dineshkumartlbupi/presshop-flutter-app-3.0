import 'package:equatable/equatable.dart';

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object> get props => [];
}

class SignUpSubmitted extends SignUpEvent {

  const SignUpSubmitted({required this.data});
  final Map<String, dynamic> data;

  @override
  List<Object> get props => [data];
}

class SocialSignUpSubmitted extends SignUpEvent {

  const SocialSignUpSubmitted({required this.data});
  final Map<String, dynamic> data;

  @override
  List<Object> get props => [data];
}

class CheckUserNameEvent extends SignUpEvent {

  const CheckUserNameEvent(this.userName);
  final String userName;

  @override
  List<Object> get props => [userName];
}

class CheckEmailEvent extends SignUpEvent {

  const CheckEmailEvent(this.email);
  final String email;

  @override
  List<Object> get props => [email];
}

class CheckPhoneEvent extends SignUpEvent {

  const CheckPhoneEvent(this.phone);
  final String phone;

  @override
  List<Object> get props => [phone];
}

class FetchAvatarsEvent extends SignUpEvent {}

class VerifyReferralCodeEvent extends SignUpEvent {

  const VerifyReferralCodeEvent(this.code);
  final String code;

  @override
  List<Object> get props => [code];
}

class CheckSocialExistsEvent extends SignUpEvent {

  const CheckSocialExistsEvent(this.params);
  final Map<String, dynamic> params;

  @override
  List<Object> get props => [params];
}
