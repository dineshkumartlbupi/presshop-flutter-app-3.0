import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class VerifyOtp implements UseCase<bool, VerifyOtpParams> {
  final AuthRepository repository;

  VerifyOtp(this.repository);

  @override
  Future<Either<Failure, bool>> call(VerifyOtpParams params) async {
    return await repository.verifyOtp(params.toMap());
  }
}

class VerifyOtpParams extends Equatable {
  final String phone;
  final String email;
  final String otp;

  const VerifyOtpParams({
    required this.phone,
    required this.email,
    required this.otp,
  });

  Map<String, dynamic> toMap() {
    return {
      "phone": phone,
      "email": email,
      "phone_otp": otp,
    };
  }

  @override
  List<Object> get props => [phone, email, otp];
}
