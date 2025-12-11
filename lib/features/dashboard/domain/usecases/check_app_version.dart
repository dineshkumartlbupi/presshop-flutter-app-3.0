import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/dashboard_repository.dart';

class CheckAppVersion implements UseCase<Map<String, dynamic>, NoParams> {
  final DashboardRepository repository;

  CheckAppVersion(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(NoParams params) async {
    return await repository.checkAppVersion();
  }
}
