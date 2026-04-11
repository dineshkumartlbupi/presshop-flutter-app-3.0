import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../entities/chat_entities.dart';
import '../repositories/chat_repository.dart';

class GetRoomChatUseCase implements UseCase<List<ChatMessageEntity>, String> {

  GetRoomChatUseCase(this.repository);
  final ChatRepository repository;

  @override
  Future<Either<Failure, List<ChatMessageEntity>>> call(String roomId) async {
    return await repository.getRoomChat(roomId);
  }
}
