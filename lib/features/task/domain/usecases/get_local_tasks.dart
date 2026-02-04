import 'package:dartz/dartz.dart' hide Task;
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetLocalTasks implements UseCase<List<Task>, Map<String, dynamic>> {

  GetLocalTasks(this.repository);
  final TaskRepository repository;

  @override
  Future<Either<Failure, List<Task>>> call(Map<String, dynamic> params) async {
    return await repository.getLocalTasks(params);
  }
}
