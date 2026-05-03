import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class VerifyOtp implements UseCase<bool, VerifyOtpParams> {

  VerifyOtp(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, bool>> call(VerifyOtpParams params) async {
    return await repository.verifyOtp(params.toMap());
  }
}

class VerifyOtpParams extends Equatable {

  const VerifyOtpParams({
    required this.phone,
    required this.email,
    required this.otp,
  });
  final String phone;
  final String email;
  final String otp;

  Map<String, dynamic> toMap() {
    return {
      "phone": phone,
      "email": email,
      "otp": otp,
    };
  }

  @override
  List<Object> get props => [phone, email, otp];
}
