import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';
import '../entities/user.dart';

class GetProfile implements UseCase<User, NoParams> {
  final AuthRepository repository;

  GetProfile(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.getProfile();
  }
}
