import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/task/domain/repositories/task_repository.dart';
import 'package:equatable/equatable.dart';

class AcceptRejectTask implements UseCase<void, AcceptRejectParams> {

  AcceptRejectTask(this.repository);
  final TaskRepository repository;

  @override
  Future<Either<Failure, void>> call(AcceptRejectParams params) async {
    return await repository.acceptRejectTask(
        taskId: params.taskId,
        mediaHouseId: params.mediaHouseId,
        status: params.status);
  }
}

class AcceptRejectParams extends Equatable {

  const AcceptRejectParams(
      {required this.taskId, required this.mediaHouseId, required this.status});
  final String taskId;
  final String mediaHouseId;
  final String status;

  @override
  List<Object> get props => [taskId, mediaHouseId, status];
}
