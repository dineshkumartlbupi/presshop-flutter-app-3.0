import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class ChangePassword implements UseCase<void, ChangePasswordParams> {

  ChangePassword(this.repository);
  final ProfileRepository repository;

  @override
  Future<Either<Failure, void>> call(ChangePasswordParams params) async {
    return await repository.changePassword(
        params.oldPassword, params.newPassword);
  }
}

class ChangePasswordParams {

  const ChangePasswordParams({
    required this.oldPassword,
    required this.newPassword,
  });
  final String oldPassword;
  final String newPassword;
}
