import 'package:equatable/equatable.dart';
// import 'package:image_picker/image_picker.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

/// Events for Chat Listing
class LoadChatListEvent extends ChatEvent {}

class SearchUserEvent extends ChatEvent {
  const SearchUserEvent(this.query);
  final String query;

  @override
  List<Object> get props => [query];
}

class CheckOnlineStatusEvent extends ChatEvent {
  const CheckOnlineStatusEvent(this.userId);
  final String userId;

  @override
  List<Object> get props => [userId];
}

/// Events for Conversation
class EnterChatRoomEvent extends ChatEvent {
  const EnterChatRoomEvent({
    required this.roomId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImage,
  });
  final String roomId;
  final String receiverId;
  final String receiverName;
  final String receiverImage;

  @override
  List<Object> get props => [roomId, receiverId, receiverName, receiverImage];
}

class LeaveChatRoomEvent extends ChatEvent {}

class SendMessageEvent extends ChatEvent {
  const SendMessageEvent(
      {required this.message,
      required this.messageType,
      this.filePath,
      this.thumbnailPath,
      this.audioDuration,
      this.replyToMessageId,
      this.replyMessageContent});
  final String message;
  final String messageType; // text, image, video, audio
  final String? filePath; // For media
  final String? thumbnailPath; // For video
  final String? audioDuration;
  final String? replyToMessageId; // For reply
  final String? replyMessageContent;

  @override
  List<Object> get props => [
        message,
        messageType,
        filePath ?? '',
        thumbnailPath ?? '',
        audioDuration ?? '',
        replyToMessageId ?? ''
      ];
}

class UpdateTypingStatusEvent extends ChatEvent {
  const UpdateTypingStatusEvent(
      {required this.isTyping, required this.roomId, this.typedValue});
  final bool isTyping;
  final String roomId;
  final String? typedValue;

  @override
  List<Object> get props => [isTyping, roomId, typedValue ?? ''];
}

class ReceiveMessageEvent extends ChatEvent {
  const ReceiveMessageEvent(this.messages);
  final List<Map<String, dynamic>> messages;

  @override
  List<Object> get props => [messages];
}

/// Media Picking
class PickChatAttachmentEvent extends ChatEvent {
  // 'camera', 'gallery', 'video'
  const PickChatAttachmentEvent(this.type);
  final String type;

  @override
  List<Object> get props => [type];
}

/// Audio Recording
class StartAudioRecordingEvent extends ChatEvent {}

class StopAudioRecordingEvent extends ChatEvent {}

/// App Lifecycle for Online Status
class UpdateAppLifecycleEvent extends ChatEvent {
  const UpdateAppLifecycleEvent({required this.isOnline, required this.roomId});
  final bool isOnline;
  final String roomId;
  @override
  List<Object> get props => [isOnline, roomId];
}

class OtherUserTypingUpdatedEvent extends ChatEvent {
  const OtherUserTypingUpdatedEvent(this.isTyping);
  final bool isTyping;

  @override
  List<Object> get props => [isTyping];
}

class ChatListUpdatedEvent extends ChatEvent {
  const ChatListUpdatedEvent(this.chatList);
  final List<Map<String, dynamic>> chatList;

  @override
  List<Object> get props => [chatList];
}

class OtherUserOnlineStatusUpdatedEvent extends ChatEvent {
  const OtherUserOnlineStatusUpdatedEvent(this.isOnline);
  final bool isOnline;

  @override
  List<Object> get props => [isOnline];
}

class FetchMoreMessagesEvent extends ChatEvent {
  const FetchMoreMessagesEvent();
}
