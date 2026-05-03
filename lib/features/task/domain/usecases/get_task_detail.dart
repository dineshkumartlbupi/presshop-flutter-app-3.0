import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/task/domain/entities/task_assigned_entity.dart';
import 'package:presshop/features/task/domain/repositories/task_repository.dart';

class GetTaskDetail
    implements UseCase<TaskAssignedEntity, GetTaskDetailParams> {
  GetTaskDetail(this.repository);
  final TaskRepository repository;

  @override
  Future<Either<Failure, TaskAssignedEntity>> call(
      GetTaskDetailParams params) async {
    return await repository.getTaskDetail(params.taskId,
        latitude: params.latitude,
        longitude: params.longitude,
        showLoader: params.showLoader);
  }
}

class GetTaskDetailParams {

  GetTaskDetailParams({
    required this.taskId,
    this.latitude,
    this.longitude,
    this.showLoader = true,
  });
  final String taskId;
  final double? latitude;
  final double? longitude;
  final bool showLoader;
}
