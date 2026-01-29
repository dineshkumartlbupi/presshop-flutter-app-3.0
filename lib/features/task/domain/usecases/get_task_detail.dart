import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/task/domain/entities/task_assigned_entity.dart';
import 'package:presshop/features/task/domain/repositories/task_repository.dart';

class GetTaskDetail implements UseCase<TaskAssignedEntity, String> {
  final TaskRepository repository;

  GetTaskDetail(this.repository);

  @override
  Future<Either<Failure, TaskAssignedEntity>> call(String taskId) async {
    return await repository.getTaskDetail(taskId);
  }
}
