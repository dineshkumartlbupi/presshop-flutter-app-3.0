import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class CheckOnboardingStatus implements UseCase<bool, NoParams> {
  final AuthRepository repository;

  CheckOnboardingStatus(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.checkOnboardingStatus();
  }
}
