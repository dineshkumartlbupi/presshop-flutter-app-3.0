part of 'chatbot_bloc.dart';

abstract class ChatbotState extends Equatable {
  const ChatbotState();
  
  @override
  List<Object> get props => [];
}

class ChatbotInitial extends ChatbotState {}

class ChatbotLoading extends ChatbotState {}

class ChatbotLoaded extends ChatbotState {
  final List<ChatModel> chatList;
  final bool isTyping;

  const ChatbotLoaded({this.chatList = const [], this.isTyping = false});

  @override
  List<Object> get props => [chatList, isTyping];
  
  ChatbotLoaded copyWith({List<ChatModel>? chatList, bool? isTyping}) {
      return ChatbotLoaded(
          chatList: chatList ?? this.chatList,
          isTyping: isTyping ?? this.isTyping
      );
  }
}

class ChatbotError extends ChatbotState {
  final String message;
  
  const ChatbotError(this.message);

  @override
  List<Object> get props => [message];
}

