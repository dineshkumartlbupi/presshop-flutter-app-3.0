import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../entities/chat_entities.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase implements UseCase<ChatMessageEntity, SendMessageParams> {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  @override
  Future<Either<Failure, ChatMessageEntity>> call(SendMessageParams params) async {
    return await repository.sendMessage(
      roomId: params.roomId,
      message: params.message,
      receiverId: params.receiverId,
      messageType: params.messageType,
      userId: params.userId,
      media: params.media,
    );
  }
}

class SendMessageParams extends Equatable {
  final String roomId;
  final String message;
  final String receiverId;
  final String messageType;
  final String userId;
  final List<String>? media;

  const SendMessageParams({
    required this.roomId,
    required this.message,
    required this.receiverId,
    required this.messageType,
    required this.userId,
    this.media,
  });

  @override
  List<Object?> get props => [roomId, message, receiverId, messageType, userId, media];
}
