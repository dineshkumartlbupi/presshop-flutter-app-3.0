import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/task/domain/entities/task_assigned_entity.dart';
import 'package:presshop/features/task/domain/repositories/task_repository.dart';

class GetTaskDetail
    implements UseCase<TaskAssignedEntity, GetTaskDetailParams> {
  final TaskRepository repository;

  GetTaskDetail(this.repository);

  @override
  Future<Either<Failure, TaskAssignedEntity>> call(
      GetTaskDetailParams params) async {
    return await repository.getTaskDetail(params.taskId,
        showLoader: params.showLoader);
  }
}

class GetTaskDetailParams {
  final String taskId;
  final bool showLoader;

  GetTaskDetailParams({required this.taskId, this.showLoader = true});
}
