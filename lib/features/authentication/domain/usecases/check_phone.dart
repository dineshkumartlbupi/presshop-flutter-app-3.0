import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class CheckPhone implements UseCase<bool, String> {
  CheckPhone(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, bool>> call(String phone) async {
    return await repository.checkPhone(phone);
  }
}
