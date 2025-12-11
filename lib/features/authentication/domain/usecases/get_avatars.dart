import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';
import '../entities/avatar.dart';

class GetAvatars implements UseCase<List<Avatar>, NoParams> {
  final AuthRepository repository;

  GetAvatars(this.repository);

  @override
  Future<Either<Failure, List<Avatar>>> call(NoParams params) async {
    return await repository.getAvatars();
  }
}
