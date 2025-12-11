import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

/// Events for Chat Listing
class LoadChatListEvent extends ChatEvent {}

class SearchUserEvent extends ChatEvent {
  final String query;
  const SearchUserEvent(this.query);

  @override
  List<Object> get props => [query];
}

class CheckOnlineStatusEvent extends ChatEvent {
   final String userId;
   const CheckOnlineStatusEvent(this.userId);
   
   @override
   List<Object> get props => [userId];
}

/// Events for Conversation
class EnterChatRoomEvent extends ChatEvent {
  final String roomId;
  final String receiverId;
  final String receiverName;
  final String receiverImage;
  const EnterChatRoomEvent({
    required this.roomId, 
    required this.receiverId,
    required this.receiverName,
    required this.receiverImage,
  });

  @override
  List<Object> get props => [roomId, receiverId, receiverName, receiverImage];
}

class LeaveChatRoomEvent extends ChatEvent {}

class SendMessageEvent extends ChatEvent {
  final String message;
  final String messageType; // text, image, video, audio
  final String? filePath; // For media
  final String? thumbnailPath; // For video
  final String? audioDuration;
  final String? replyToMessageId; // For reply
  final String? replyMessageContent;

  const SendMessageEvent({
    required this.message,
    required this.messageType,
    this.filePath,
    this.thumbnailPath,
    this.audioDuration,
    this.replyToMessageId,
    this.replyMessageContent
  });

  @override
  List<Object> get props => [message, messageType, filePath ?? '', thumbnailPath ?? '', audioDuration ?? '', replyToMessageId ?? ''];
}

class UpdateTypingStatusEvent extends ChatEvent {
  final bool isTyping;
  final String roomId;
  const UpdateTypingStatusEvent({required this.isTyping, required this.roomId});

  @override
  List<Object> get props => [isTyping, roomId];
}

class ReceiveMessageEvent extends ChatEvent {
  final List<DocumentSnapshot> messages;
  const ReceiveMessageEvent(this.messages);
  
  @override
  List<Object> get props => [messages];
}

/// Media Picking
class PickChatAttachmentEvent extends ChatEvent {
  final String type; // 'camera', 'gallery', 'video'
  const PickChatAttachmentEvent(this.type);
  
  @override
  List<Object> get props => [type];
}

/// Audio Recording
class StartAudioRecordingEvent extends ChatEvent {}
class StopAudioRecordingEvent extends ChatEvent {}

/// App Lifecycle for Online Status
class UpdateAppLifecycleEvent extends ChatEvent {
    final bool isOnline;
    final String roomId;
    const UpdateAppLifecycleEvent({required this.isOnline, required this.roomId});
    @override
    List<Object> get props => [isOnline, roomId];
}
