import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ChatStatus { initial, loading, loaded, failure, sending, recording }

class ChatState extends Equatable {
  final ChatStatus status;
  final List<DocumentSnapshot> chatList;
  final List<DocumentSnapshot> searchResult;
  final List<DocumentSnapshot> messages;
  final bool isTyping; // Received typing status from other user
  final bool isSelfTyping;
  final bool isRecording;
  final bool isOnline; // Other user status
  final String errorMessage;
  final String currentRoomId;
  final String receiverId;
  final String receiverName;
  final String receiverImage;
  final String uploadProgress;

  const ChatState({
    this.status = ChatStatus.initial,
    this.chatList = const [],
    this.searchResult = const [],
    this.messages = const [],
    this.isTyping = false,
    this.isSelfTyping = false,
    this.isRecording = false,
    this.isOnline = false,
    this.errorMessage = '',
    this.currentRoomId = '',
    this.receiverId = '',
    this.receiverName = '',
    this.receiverImage = '',
    this.uploadProgress = '0.0',
  });

  ChatState copyWith({
    ChatStatus? status,
    List<DocumentSnapshot>? chatList,
    List<DocumentSnapshot>? searchResult,
    List<DocumentSnapshot>? messages,
    bool? isTyping,
    bool? isSelfTyping,
    bool? isRecording,
    bool? isOnline,
    String? errorMessage,
    String? currentRoomId,
    String? receiverId,
    String? receiverName,
    String? receiverImage,
    String? uploadProgress,
  }) {
    return ChatState(
      status: status ?? this.status,
      chatList: chatList ?? this.chatList,
      searchResult: searchResult ?? this.searchResult,
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      isSelfTyping: isSelfTyping ?? this.isSelfTyping,
      isRecording: isRecording ?? this.isRecording,
      isOnline: isOnline ?? this.isOnline,
      errorMessage: errorMessage ?? this.errorMessage,
      currentRoomId: currentRoomId ?? this.currentRoomId,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      receiverImage: receiverImage ?? this.receiverImage,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  @override
  List<Object> get props => [
        status,
        chatList,
        searchResult,
        messages,
        isTyping,
        isSelfTyping,
        isRecording,
        isOnline,
        errorMessage,
        currentRoomId,
        receiverId,
        receiverName,
        receiverImage,
        uploadProgress,
      ];
}
