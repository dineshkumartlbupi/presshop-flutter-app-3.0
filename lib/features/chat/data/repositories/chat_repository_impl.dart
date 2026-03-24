import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:presshop/core/api/network_info.dart';
import 'package:presshop/core/error/failures.dart';
import '../../domain/entities/chat_entities.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../datasources/chat_socket_datasource.dart';
import '../models/chat_models.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatSocketDataSource socketDataSource;
  final NetworkInfo networkInfo;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.socketDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<ChatRoomEntity>>> getChatList() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteChatList = await remoteDataSource.getChatList();
        return Right(remoteChatList);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<ChatMessageEntity>>> getRoomChat(String roomId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteRoomChat = await remoteDataSource.getRoomHistory(roomId: roomId);
        return Right(remoteRoomChat);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, ChatMessageEntity>> sendMessage({
    required String roomId,
    required String message,
    required String receiverId,
    required String messageType,
    required String userId,
    List<String>? media,
  }) async {
    // Send via socket is an emission, usually we return a local message model immediately
    // or wait for socket ack. For this architecture, we emit and return a placeholder/success.
    try {
      final data = {
        'room_id': roomId,
        'message': message,
        'receiver_id': receiverId,
        'message_type': messageType,
        if (media != null) 'media': media,
      };

      if (messageType == 'text') {
        socketDataSource.sendMessage(data);
      } else if (messageType == 'media' || messageType == 'image' || messageType == 'video') {
        socketDataSource.sendMediaMessage(data);
      } else if (messageType == 'recording') {
        socketDataSource.sendVoiceMessage(data);
      }

      // Return a temporary model until the server confirms via socket listener
      return Right(ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        roomId: roomId,
        message: message,
        messageType: messageType,
        senderId: "", // Will be filled by Bloc/UI or confirmed by server
        senderType: "",
        senderName: "",
        senderImage: "",
        createdAt: DateTime.now().toIso8601String(),
        readStatus: "unread",
        media: media ?? [],
        isSender: true,
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadMedia(File file) async {
    if (await networkInfo.isConnected) {
      try {
        final urls = await remoteDataSource.uploadChatMedia(file.path);
        if (urls.isNotEmpty) {
          return Right(urls.first);
        } else {
          return const Left(ServerFailure(message: "Upload failed: No URL returned"));
        }
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateTypingStatus({
    required String roomId,
    required bool isTyping,
    required String receiverId,
    required String userId,
  }) async {
    try {
      socketDataSource.sendTypingStatus(roomId, userId, isTyping, receiverId: receiverId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
