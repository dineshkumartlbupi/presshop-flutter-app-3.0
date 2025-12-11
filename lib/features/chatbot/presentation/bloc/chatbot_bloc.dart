import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:presshop/core/api/network_class.dart';
import 'package:presshop/core/api/network_response.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/features/chatbot/data/models/chat_model.dart';

part 'chatbot_event.dart';
part 'chatbot_state.dart';

class ChatbotBloc extends Bloc<ChatbotEvent, ChatbotState> implements NetworkResponse {
  late DialogFlowtter dialogFlowtter;
  int failCount = 0;
  List<ChatModel> chatList = [];

  ChatbotBloc() : super(ChatbotInitial()) {
    on<InitChatbotEvent>(_onInitChatbot);
    on<FetchMessagesEvent>(_onFetchMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<AddLocalMessageEvent>(_onAddLocalMessage);
    on<RequestHumanAssistanceEvent>(_onRequestHumanAssistance);
    on<MessagesReceivedEvent>(_onMessagesReceived);
  }

  Future<void> _onInitChatbot(InitChatbotEvent event, Emitter<ChatbotState> emit) async {
    try {
      dialogFlowtter = DialogFlowtter();
      add(FetchMessagesEvent());
    } catch (e) {
      emit(ChatbotError("Failed to initialize chatbot: $e"));
    }
  }

  Future<void> _onFetchMessages(FetchMessagesEvent event, Emitter<ChatbotState> emit) async {
    emit(ChatbotLoading());
    try {
         NetworkClass(getMessageApiUrl, this, getMessageApiReq)
          .callRequestServiceHeader(false, "get", null);
          // Note: Response handled in onResponse
    } catch (e) {
      emit(ChatbotError(e.toString()));
    }
  }

  Future<void> _onMessagesReceived(MessagesReceivedEvent event, Emitter<ChatbotState> emit) async {
      chatList = event.chatList;
      emit(ChatbotLoaded(chatList: List.from(chatList)));
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatbotState> emit) async {
     chatList.add(ChatModel(
        message: event.message,
        isUser: true,
        isNavigate: false,
        time: DateTime.now().toString()));
    
    emit(ChatbotLoaded(chatList: List.from(chatList), isTyping: true));

    callAddMessageApi(event.message, event.time, "true");
    
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
    
    emit(ChatbotLoaded(chatList: List.from(chatList), isTyping: false));
  }

  Future<void> _onAddLocalMessage(AddLocalMessageEvent event, Emitter<ChatbotState> emit) async {
      chatList.add(ChatModel(
        message: event.message,
        isUser: false,
        isNavigate: event.isHumanAssistanceRequested,
        time: DateTime.now().toString()));
      emit(ChatbotLoaded(chatList: List.from(chatList)));
  }

  Future<void> _onRequestHumanAssistance(RequestHumanAssistanceEvent event, Emitter<ChatbotState> emit) async {
      failCount = 0;
      if (event.request) {
          add(AddLocalMessageEvent(message: "Loved our chat! Now handing you over to a real person for extra support.", isHumanAssistanceRequested: true));
          chatList.removeAt(event.index);
           // emit(ChatbotLoaded(chatList: List.from(chatList))); // handled by AddLocalMessageEvent
      } else {
          chatList.removeAt(event.index);
          chatList.add(ChatModel(
                message: "Hi, I’m Emily, your digital assistant at PressHop. How can I help? ",
                isUser: false,
                isNavigate: false,
                time: DateTime.now().toString()));
           emit(ChatbotLoaded(chatList: List.from(chatList)));
      }
  }

  callAddMessageApi(String message, String time, String isUser) {
    try {
      Map<String, String> map = {
        "message": message,
        "time": time,
        "is_user": isUser,
      };
      NetworkClass.fromNetworkClass(
              addMessageApiUrl, this, addMessageApiReq, map)
          .callRequestServiceHeader(false, "post", null);
    } on Exception catch (exception) {
      debugPrint(exception.toString());
    }
  }

  @override
  void onError({Key? key, required int requestCode, required String response}) {
     // Handle internal error if needed, but usually we emit states
     debugPrint("Error: $requestCode $response");
  }

  @override
  void onResponse({Key? key, required int requestCode, required String response}) {
    if (requestCode == getMessageApiReq) {
       try {
          var data = jsonDecode(response);
          List<ChatModel> fetchedList = list.map((e) => ChatModel.fromJson(e)).toList();
          if (fetchedList.isEmpty) {
            fetchedList.add(ChatModel(
                message:
                    "Hi, I’m Emily, your digital assistant at PressHop. How can I help? ",
                isUser: false,
                isNavigate: false,
                time: DateTime.now().toString()));
          }
           
           add(MessagesReceivedEvent(fetchedList));

       } catch (e) {
          // emit(ChatbotError("Failed to parse messages")); // Cannot emit here safely without wrapping
          debugPrint("Failed to parse messages: $e");
       }
    }
  }
}

