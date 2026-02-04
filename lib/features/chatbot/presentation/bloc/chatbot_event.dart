part of 'chatbot_bloc.dart';

abstract class ChatbotEvent extends Equatable {
  const ChatbotEvent();

  @override
  List<Object> get props => [];
}

class InitChatbotEvent extends ChatbotEvent {}

class FetchMessagesEvent extends ChatbotEvent {}

class SendMessageEvent extends ChatbotEvent {

  const SendMessageEvent({required this.message, required this.time});
  final String message;
  final String time;

  @override
  List<Object> get props => [message, time];
}

class AddLocalMessageEvent extends ChatbotEvent {

  const AddLocalMessageEvent(
      {required this.message, required this.isHumanAssistanceRequested});
  final String message;
  final bool isHumanAssistanceRequested;

  @override
  List<Object> get props => [message, isHumanAssistanceRequested];
}

class RequestHumanAssistanceEvent extends ChatbotEvent {

  const RequestHumanAssistanceEvent(
      {required this.request, required this.index});
  final bool request;
  final int index;
}

class MessagesReceivedEvent extends ChatbotEvent {
  const MessagesReceivedEvent(this.chatList);
  final List<ChatModel> chatList;
}

class ChatbotErrorEvent extends ChatbotEvent {
  const ChatbotErrorEvent(this.error);
  final String error;

  @override
  List<Object> get props => [error];
}
