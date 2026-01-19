import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/splash_repository.dart';

class CheckSplashVersion implements UseCase<Map<String, dynamic>, NoParams> {
  final SplashRepository repository;

  CheckSplashVersion(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(NoParams params) async {
    return await repository.checkAppVersion();
  }
}
