import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/task/domain/entities/task_detail.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardTaskDetail implements UseCase<TaskDetail, String> {
  final DashboardRepository repository;

  GetDashboardTaskDetail(this.repository);

  @override
  Future<Either<Failure, TaskDetail>> call(String params) async {
    return await repository.getTaskDetail(params);
  }
}
