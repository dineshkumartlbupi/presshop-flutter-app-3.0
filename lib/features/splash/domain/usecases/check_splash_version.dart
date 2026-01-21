import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/splash_repository.dart';
import 'package:presshop/features/splash/domain/entities/version.dart';

class CheckSplashVersion implements UseCase<Version, NoParams> {
  final SplashRepository repository;

  CheckSplashVersion(this.repository);

  @override
  Future<Either<Failure, Version>> call(NoParams params) async {
    return await repository.checkAppVersion();
  }
}
