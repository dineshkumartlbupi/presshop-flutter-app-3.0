import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../entities/chat_entities.dart';
import '../repositories/chat_repository.dart';

class GetChatListUseCase implements UseCase<List<ChatRoomEntity>, NoParams> {
  final ChatRepository repository;

  GetChatListUseCase(this.repository);

  @override
  Future<Either<Failure, List<ChatRoomEntity>>> call(NoParams params) async {
    return await repository.getChatList();
  }
}
