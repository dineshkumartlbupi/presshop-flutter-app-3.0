import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../entities/task_all.dart';
import '../repositories/task_repository.dart';

class GetAllTasks implements UseCase<List<TaskAll>, GetAllTasksParams> {
  final TaskRepository repository;

  GetAllTasks(this.repository);

  @override
  Future<Either<Failure, List<TaskAll>>> call(GetAllTasksParams params) async {
    return await repository.getAllTasks(
        limit: params.limit,
        offset: params.offset,
        filterParams: params.filterParams);
  }
}

class GetAllTasksParams extends Equatable {
  final int limit;
  final int offset;
  final Map<String, dynamic>? filterParams;

  const GetAllTasksParams(
      {required this.limit, required this.offset, this.filterParams});

  @override
  List<Object?> get props => [limit, offset, filterParams];
}
