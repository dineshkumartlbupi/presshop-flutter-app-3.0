import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SocialExists implements UseCase<bool, Map<String, dynamic>> {
  final AuthRepository repository;

  SocialExists(this.repository);

  @override
  Future<Either<Failure, bool>> call(Map<String, dynamic> params) async {
    return await repository.socialExists(params);
  }
}
