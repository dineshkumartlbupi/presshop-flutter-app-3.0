import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class ResetPassword implements UseCase<bool, ResetPasswordParams> {

  ResetPassword(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, bool>> call(ResetPasswordParams params) async {
    return await repository.resetPassword(params.email, params.password);
  }
}

class ResetPasswordParams extends Equatable {

  const ResetPasswordParams({required this.email, required this.password});
  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}
