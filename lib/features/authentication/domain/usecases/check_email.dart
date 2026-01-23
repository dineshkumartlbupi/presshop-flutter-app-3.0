import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class CheckEmail implements UseCase<bool, String> {
  CheckEmail(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, bool>> call(String email) async {
    return await repository.checkEmail(email);
  }
}
