import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/features/chatbot/data/models/chat_model.dart';

part 'chatbot_event.dart';
part 'chatbot_state.dart';

class ChatbotBloc extends Bloc<ChatbotEvent, ChatbotState> {
  final ApiClient apiClient;
  late DialogFlowtter dialogFlowtter;
  int failCount = 0;
  List<ChatModel> chatList = [];

  ChatbotBloc({required this.apiClient}) : super(ChatbotInitial()) {
    on<InitChatbotEvent>(_onInitChatbot);
    on<FetchMessagesEvent>(_onFetchMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<AddLocalMessageEvent>(_onAddLocalMessage);
    on<RequestHumanAssistanceEvent>(_onRequestHumanAssistance);
    on<MessagesReceivedEvent>(_onMessagesReceived);
    on<ChatbotErrorEvent>(_onChatbotError);
  }

  Future<void> _onInitChatbot(
      InitChatbotEvent event, Emitter<ChatbotState> emit) async {
    try {
      dialogFlowtter =
          await DialogFlowtter(jsonPath: "assets/dialog_flow_auth.json");
      add(FetchMessagesEvent());
    } catch (e) {
      emit(ChatbotError("Failed to initialize chatbot: $e"));
    }
  }

  Future<void> _onFetchMessages(
      FetchMessagesEvent event, Emitter<ChatbotState> emit) async {
    emit(ChatbotLoading());
    try {
      final response = await apiClient.get(getMessageApiUrl);

      if (response.statusCode == 200) {
        var data = response.data;
        List<ChatModel> fetchedList = [];
        if (data is List) {
          fetchedList = data.map((e) => ChatModel.fromJson(e)).toList();
        } else if (data is Map && data.containsKey('data')) {
          fetchedList =
              (data['data'] as List).map((e) => ChatModel.fromJson(e)).toList();
        }

        if (fetchedList.isEmpty) {
          fetchedList.add(ChatModel(
              message:
                  "Hi, I’m Emily, your digital assistant at PressHop. How can I help? ",
              isUser: false,
              isNavigate: false,
              time: DateTime.now().toString()));
        }
        add(MessagesReceivedEvent(fetchedList));
      } else {
        emit(ChatbotError("Failed to fetch messages: ${response.statusCode}"));
      }
    } catch (e) {
      emit(ChatbotError(e.toString()));
    }
  }

  Future<void> _onMessagesReceived(
      MessagesReceivedEvent event, Emitter<ChatbotState> emit) async {
    chatList = event.chatList;
    emit(ChatbotLoaded(chatList: List.from(chatList)));
  }

  Future<void> _onSendMessage(
      SendMessageEvent event, Emitter<ChatbotState> emit) async {
    chatList.add(ChatModel(
        message: event.message,
        isUser: true,
        isNavigate: false,
        time: DateTime.now().toString()));

    emit(ChatbotLoaded(chatList: List.from(chatList), isTyping: true));

    callAddMessageApi(event.message, event.time, "true");

    try {
      // DialogFlow response
      DetectIntentResponse response = await dialogFlowtter.detectIntent(
        queryInput: QueryInput(
            text: TextInput(
          text: event.message,
          languageCode: "en",
        )),
      );

      if (response.message != null) {
        if (response.queryResult!.action == "input.unknown") {
          String msg = failCount < 1
              ? "I’m sorry, I didn’t quite get that! Can you repeat or rephrase your question? I’m eager to help."
              : "Hmm... I’m not quite sure about that one! Shall I grab a human from the PressHop team to assist you?";

          chatList.add(
            ChatModel(
                message: msg,
                isUser: false,
                isNavigate: false,
                time: DateTime.now().toString(),
                hasShownFirstFailMsg: failCount > 0),
          );

          if (failCount < 1) {
            callAddMessageApi(msg, DateTime.now().toString(), "false");
          }
          failCount++;
        } else {
          failCount = 0;
          chatList.add(ChatModel(
              message: response.message!.text!.text![0],
              isUser: false,
              isNavigate: false,
              time: DateTime.now().toString()));
          callAddMessageApi(response.message!.text!.text![0],
              DateTime.now().toString(), "false");
        }
      }
    } catch (e) {
      debugPrint("DialogFlow Error: $e");
      chatList.add(ChatModel(
          message:
              "I'm having trouble connecting right now. Please try again later.",
          isUser: false,
          isNavigate: false,
          time: DateTime.now().toString()));
    }

    emit(ChatbotLoaded(chatList: List.from(chatList), isTyping: false));
  }

  Future<void> _onAddLocalMessage(
      AddLocalMessageEvent event, Emitter<ChatbotState> emit) async {
    chatList.add(ChatModel(
        message: event.message,
        isUser: false,
        isNavigate: event.isHumanAssistanceRequested,
        time: DateTime.now().toString()));
    emit(ChatbotLoaded(chatList: List.from(chatList)));
  }

  Future<void> _onRequestHumanAssistance(
      RequestHumanAssistanceEvent event, Emitter<ChatbotState> emit) async {
    failCount = 0;
    if (event.request) {
      add(AddLocalMessageEvent(
          message:
              "Loved our chat! Now handing you over to a real person for extra support.",
          isHumanAssistanceRequested: true));
      callAddMessageApi(
          "Loved our chat! Now handing you over to a real person for extra support.",
          DateTime.now().toString(),
          "false");
      chatList.removeAt(event.index);
    } else {
      chatList.removeAt(event.index);
      chatList.add(ChatModel(
          message:
              "Hi, I’m Emily, your digital assistant at PressHop. How can I help? ",
          isUser: false,
          isNavigate: false,
          time: DateTime.now().toString()));
      emit(ChatbotLoaded(chatList: List.from(chatList)));
    }
  }

  Future<void> _onChatbotError(
      ChatbotErrorEvent event, Emitter<ChatbotState> emit) async {
    debugPrint("Chatbot Error: ${event.error}");

    if (chatList.isEmpty) {
      chatList.add(ChatModel(
          message:
              "Hi, I’m Emily, your digital assistant at PressHop. How can I help? ",
          isUser: false,
          isNavigate: false,
          time: DateTime.now().toString()));
      emit(ChatbotLoaded(chatList: List.from(chatList)));
    } else {
      emit(ChatbotLoaded(chatList: List.from(chatList)));
    }
  }

  Future<void> callAddMessageApi(
      String message, String time, String isUser) async {
    try {
      Map<String, String> map = {
        "message": message,
        "time": time,
        "is_user": isUser,
      };

      final response = await apiClient.post(addMessageApiUrl, data: map);

      if (response.statusCode == 200) {
        var data = response.data;
        if (data != null && data is Map<String, dynamic>) {
          if (chatList.isNotEmpty) {
            for (int i = chatList.length - 1; i >= 0; i--) {
              if (chatList[i].isUser) {
                chatList[i].time =
                    data['createdAt'] ?? data['time'] ?? chatList[i].time;
                add(MessagesReceivedEvent(List.from(chatList)));
                break;
              }
            }
          }
        }
      }
    } catch (exception) {
      debugPrint(exception.toString());
    }
  }
}
