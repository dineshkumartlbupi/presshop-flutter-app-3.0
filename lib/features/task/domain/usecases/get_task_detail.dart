import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/task/domain/entities/task_detail.dart';
import 'package:presshop/features/task/domain/repositories/task_repository.dart';

class GetTaskDetail implements UseCase<TaskDetail, String> {
  final TaskRepository repository;

  GetTaskDetail(this.repository);

  @override
  Future<Either<Failure, TaskDetail>> call(String taskId) async {
    return await repository.getTaskDetail(taskId);
  }
}
