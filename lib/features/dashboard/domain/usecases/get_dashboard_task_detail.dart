import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/task/domain/entities/task_assigned_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardTaskDetail implements UseCase<TaskAssignedEntity, String> {

  GetDashboardTaskDetail(this.repository);
  final DashboardRepository repository;

  @override
  Future<Either<Failure, TaskAssignedEntity>> call(String params) async {
    return await repository.getTaskDetail(params);
  }
}
