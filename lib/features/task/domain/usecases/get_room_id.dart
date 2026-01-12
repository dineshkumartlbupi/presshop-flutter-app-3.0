import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/task/domain/repositories/task_repository.dart';
import 'package:equatable/equatable.dart';

class GetRoomId implements UseCase<String, GetRoomIdParams> {
  final TaskRepository repository;

  GetRoomId(this.repository);

  @override
  Future<Either<Failure, String>> call(GetRoomIdParams params) async {
    return await repository.getRoomId(
        params.receiverId, params.taskId, params.roomType, params.type);
  }
}

class GetRoomIdParams extends Equatable {
  final String receiverId;
  final String taskId;
  final String roomType;
  final String type;

  const GetRoomIdParams({
    required this.receiverId,
    required this.taskId,
    required this.roomType,
    required this.type,
  });

  @override
  List<Object> get props => [receiverId, taskId, roomType, type];
}
