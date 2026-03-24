import 'package:equatable/equatable.dart';

class ChatMessageEntity extends Equatable {
  final String id;
  final String roomId;
  final String message;
  final String messageType;
  final String senderId;
  final String senderType;
  final String senderName;
  final String senderImage;
  final String createdAt;
  final String readStatus;
  final List<String> media;
  final bool isSender;

  const ChatMessageEntity({
    required this.id,
    required this.roomId,
    required this.message,
    required this.messageType,
    required this.senderId,
    required this.senderType,
    required this.senderName,
    required this.senderImage,
    required this.createdAt,
    required this.readStatus,
    required this.media,
    required this.isSender,
  });

  @override
  List<Object?> get props => [
        id,
        roomId,
        message,
        messageType,
        senderId,
        senderType,
        senderName,
        senderImage,
        createdAt,
        readStatus,
        media,
        isSender,
      ];
}

class ChatRoomEntity extends Equatable {
  final String roomId;
  final String receiverId;
  final String receiverName;
  final String receiverImage;
  final String lastMessage;
  final String lastMessageType;
  final String lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  const ChatRoomEntity({
    required this.roomId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImage,
    required this.lastMessage,
    required this.lastMessageType,
    required this.lastMessageTime,
    required this.unreadCount,
    this.isOnline = false,
  });

  @override
  List<Object?> get props => [
        roomId,
        receiverId,
        receiverName,
        receiverImage,
        lastMessage,
        lastMessageType,
        lastMessageTime,
        unreadCount,
        isOnline,
      ];
}
