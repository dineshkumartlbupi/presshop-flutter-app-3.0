part of 'chatbot_bloc.dart';

abstract class ChatbotEvent extends Equatable {
  const ChatbotEvent();

  @override
  List<Object> get props => [];
}

class InitChatbotEvent extends ChatbotEvent {}

class FetchMessagesEvent extends ChatbotEvent {}

class SendMessageEvent extends ChatbotEvent {
  final String message;
  final String time;

  const SendMessageEvent({required this.message, required this.time});

  @override
  List<Object> get props => [message, time];
}

class AddLocalMessageEvent extends ChatbotEvent {
  final String message;
  final bool isHumanAssistanceRequested;

  const AddLocalMessageEvent({required this.message, required this.isHumanAssistanceRequested});

  @override
  List<Object> get props => [message, isHumanAssistanceRequested];
}

class RequestHumanAssistanceEvent extends ChatbotEvent {
    final bool request;
    final int index;

    const RequestHumanAssistanceEvent({required this.request, required this.index});
}

class MessagesReceivedEvent extends ChatbotEvent {
  final List<ChatModel> chatList;
  const MessagesReceivedEvent(this.chatList);
}

