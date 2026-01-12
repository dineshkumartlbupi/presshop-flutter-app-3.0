import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/task/domain/repositories/task_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/common_models_export.dart';

class GetTaskChat
    implements UseCase<List<ManageTaskChatModel>, GetTaskChatParams> {
  final TaskRepository repository;

  GetTaskChat(this.repository);

  @override
  Future<Either<Failure, List<ManageTaskChatModel>>> call(
      GetTaskChatParams params) async {
    return await repository.getTaskChat(
        params.roomId, params.type, params.contentId);
  }
}

class GetTaskChatParams extends Equatable {
  final String roomId;
  final String type;
  final String contentId;

  const GetTaskChatParams(
      {required this.roomId, required this.type, required this.contentId});

  @override
  List<Object> get props => [roomId, type, contentId];
}
