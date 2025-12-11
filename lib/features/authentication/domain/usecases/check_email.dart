import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class CheckEmail implements UseCase<bool, String> {
  final AuthRepository repository;

  CheckEmail(this.repository);

  @override
  Future<Either<Failure, bool>> call(String email) async {
    return await repository.checkEmail(email);
  }
}
