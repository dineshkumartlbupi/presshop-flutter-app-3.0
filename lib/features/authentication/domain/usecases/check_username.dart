import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class CheckUserName implements UseCase<bool, String> {
  final AuthRepository repository;

  CheckUserName(this.repository);

  @override
  Future<Either<Failure, bool>> call(String userName) async {
    return await repository.checkUserName(userName);
  }
}
