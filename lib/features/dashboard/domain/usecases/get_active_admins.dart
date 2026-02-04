import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../entities/admin_detail.dart';
import '../repositories/dashboard_repository.dart';

class GetActiveAdmins implements UseCase<List<AdminDetail>, NoParams> {

  GetActiveAdmins(this.repository);
  final DashboardRepository repository;

  @override
  Future<Either<Failure, List<AdminDetail>>> call(NoParams params) async {
    return await repository.getActiveAdmins();
  }
}
