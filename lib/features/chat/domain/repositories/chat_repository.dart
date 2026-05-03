import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import '../entities/chat_entities.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ChatRoomEntity>>> getChatList();
  
  Future<Either<Failure, List<ChatMessageEntity>>> getRoomChat(String roomId);
  
  Future<Either<Failure, ChatMessageEntity>> sendMessage({
    required String roomId,
    required String message,
    required String receiverId,
    required String messageType,
    required String userId,
    List<String>? media,
  });

  Future<Either<Failure, String>> uploadMedia(File file);

  Future<Either<Failure, void>> updateTypingStatus({
    required String roomId,
    required bool isTyping,
    required String receiverId,
    required String userId,
  });
}
