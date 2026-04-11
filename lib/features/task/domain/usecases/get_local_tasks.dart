import 'package:dartz/dartz.dart' hide Task;
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

import 'package:equatable/equatable.dart';

class GetLocalTasks implements UseCase<List<Task>, GetLocalTasksParams> {
  GetLocalTasks(this.repository);
  final TaskRepository repository;

  @override
  Future<Either<Failure, List<Task>>> call(GetLocalTasksParams params) async {
    return await repository.getLocalTasks(params.filterParams,
        showLoader: params.showLoader);
  }
}

class GetLocalTasksParams extends Equatable {

  const GetLocalTasksParams(
      {required this.filterParams, this.showLoader = true});
  final Map<String, dynamic> filterParams;
  final bool showLoader;

  @override
  List<Object?> get props => [filterParams, showLoader];
}
