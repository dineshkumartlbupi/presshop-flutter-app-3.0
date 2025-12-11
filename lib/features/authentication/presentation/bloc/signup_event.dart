import 'package:equatable/equatable.dart';

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object> get props => [];
}

class SignUpSubmitted extends SignUpEvent {
  final Map<String, dynamic> data;

  const SignUpSubmitted({required this.data});

  @override
  List<Object> get props => [data];
}

class SocialSignUpSubmitted extends SignUpEvent {
  final Map<String, dynamic> data;

  const SocialSignUpSubmitted({required this.data});

  @override
  List<Object> get props => [data];
}

class CheckUserNameEvent extends SignUpEvent {
  final String userName;

  const CheckUserNameEvent(this.userName);

  @override
  List<Object> get props => [userName];
}

class CheckEmailEvent extends SignUpEvent {
  final String email;

  const CheckEmailEvent(this.email);

  @override
  List<Object> get props => [email];
}

class CheckPhoneEvent extends SignUpEvent {
  final String phone;

  const CheckPhoneEvent(this.phone);

  @override
  List<Object> get props => [phone];
}

class FetchAvatarsEvent extends SignUpEvent {}

class VerifyReferralCodeEvent extends SignUpEvent {
  final String code;

  const VerifyReferralCodeEvent(this.code);

  @override
  List<Object> get props => [code];
}

class CheckSocialExistsEvent extends SignUpEvent {
  final Map<String, dynamic> params;

  const CheckSocialExistsEvent(this.params);

  @override
  List<Object> get props => [params];
}
