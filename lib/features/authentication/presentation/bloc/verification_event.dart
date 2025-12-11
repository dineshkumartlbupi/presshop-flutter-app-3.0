import 'package:equatable/equatable.dart';

abstract class VerificationEvent extends Equatable {
  const VerificationEvent();

  @override
  List<Object> get props => [];
}

class VerifyOtpSubmitted extends VerificationEvent {
  final String phone;
  final String email;
  final String otp;

  const VerifyOtpSubmitted({
    required this.phone,
    required this.email,
    required this.otp,
  });

  @override
  List<Object> get props => [phone, email, otp];
}

class ResendOtpRequested extends VerificationEvent {
  final Map<String, dynamic> params;

  const ResendOtpRequested(this.params);

  @override
  List<Object> get props => [params];
}

class RegistrationRequested extends VerificationEvent {
  final Map<String, dynamic> params;
  final bool isSocial;
  final String? imagePath;

  const RegistrationRequested({
    required this.params,
    this.isSocial = false,
    this.imagePath,
  });

  @override
  List<Object> get props => [params, isSocial, imagePath ?? ''];
}
