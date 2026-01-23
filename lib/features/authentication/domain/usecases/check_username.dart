import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class CheckUserName implements UseCase<bool, String> {
  CheckUserName(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, bool>> call(String userName) async {
    return await repository.checkUserName(userName);
  }
}
