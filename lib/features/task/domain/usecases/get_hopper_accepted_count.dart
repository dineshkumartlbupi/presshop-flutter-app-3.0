import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/task/domain/repositories/task_repository.dart';

class GetHopperAcceptedCount implements UseCase<String, String> {
  GetHopperAcceptedCount(this.repository);
  final TaskRepository repository;

  @override
  Future<Either<Failure, String>> call(String taskId) async {
    return await repository.getHopperAcceptedCount(taskId);
  }
}
