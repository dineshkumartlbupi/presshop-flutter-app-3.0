import 'package:equatable/equatable.dart';

abstract class VerificationEvent extends Equatable {
  const VerificationEvent();

  @override
  List<Object> get props => [];
}

class VerifyOtpSubmitted extends VerificationEvent {

  const VerifyOtpSubmitted({
    required this.phone,
    required this.email,
    required this.otp,
  });
  final String phone;
  final String email;
  final String otp;

  @override
  List<Object> get props => [phone, email, otp];
}

class ResendOtpRequested extends VerificationEvent {

  const ResendOtpRequested(this.params);
  final Map<String, dynamic> params;

  @override
  List<Object> get props => [params];
}

class RegistrationRequested extends VerificationEvent {

  const RegistrationRequested({
    required this.params,
    this.isSocial = false,
    this.imagePath,
  });
  final Map<String, dynamic> params;
  final bool isSocial;
  final String? imagePath;

  @override
  List<Object> get props => [params, isSocial, imagePath ?? ''];
}
