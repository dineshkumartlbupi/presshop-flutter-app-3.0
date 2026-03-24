import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

class UpdateTypingStatusUseCase implements UseCase<void, TypingStatusParams> {
  final ChatRepository repository;

  UpdateTypingStatusUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(TypingStatusParams params) async {
    return await repository.updateTypingStatus(
      roomId: params.roomId,
      isTyping: params.isTyping,
      receiverId: params.receiverId,
      userId: params.userId,
    );
  }
}

class TypingStatusParams extends Equatable {
  final String roomId;
  final bool isTyping;
  final String receiverId;
  final String userId;

  const TypingStatusParams({
    required this.roomId,
    required this.isTyping,
    required this.receiverId,
    required this.userId,
  });

  @override
  List<Object?> get props => [roomId, isTyping, receiverId, userId];
}
