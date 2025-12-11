import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class VerifyForgotPasswordOtp implements UseCase<bool, VerifyForgotPasswordOtpParams> {
  final AuthRepository repository;

  VerifyForgotPasswordOtp(this.repository);

  @override
  Future<Either<Failure, bool>> call(VerifyForgotPasswordOtpParams params) async {
    return await repository.verifyForgotPasswordOtp(params.email, params.otp);
  }
}

class VerifyForgotPasswordOtpParams extends Equatable {
  final String email;
  final String otp;

  const VerifyForgotPasswordOtpParams({required this.email, required this.otp});

  @override
  List<Object> get props => [email, otp];
}
