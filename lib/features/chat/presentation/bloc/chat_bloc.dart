import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:presshop/core/core_export.dart'; // Constants

import 'package:presshop/features/chat/presentation/bloc/chat_event.dart';
import 'package:presshop/features/chat/presentation/bloc/chat_state.dart';
import 'package:presshop/main.dart'; // Globals
import 'package:record/record.dart';
import 'package:presshop/features/chat/data/services/chat_socket_service.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';
import 'package:presshop/features/chat/data/datasources/chat_local_data_source.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatSocketService _chatSocketService;
  final ChatLocalDataSource _chatLocalDataSource;
  final ApiClient _apiClient = GetIt.I<ApiClient>();
  final AudioRecorder _audioRecorder;

  ChatBloc({
    required ChatSocketService chatSocketService,
    required ChatLocalDataSource localDataSource,
    AudioRecorder? audioRecorder,
  })  : _chatSocketService = chatSocketService,
        _chatLocalDataSource = localDataSource,
        _audioRecorder = audioRecorder ?? AudioRecorder(),
        super(const ChatState()) {
    on<LoadChatListEvent>(_onLoadChatList);
    on<EnterChatRoomEvent>(_onEnterChatRoom);
    on<LeaveChatRoomEvent>(_onLeaveChatRoom);
    on<SendMessageEvent>(_onSendMessage);
    on<UpdateTypingStatusEvent>(_onUpdateTypingStatus);
    on<StartAudioRecordingEvent>(_onStartAudioRecording);
    on<StopAudioRecordingEvent>(_onStopAudioRecording);
    on<UpdateAppLifecycleEvent>(_onUpdateAppLifecycle);
    on<OtherUserTypingUpdatedEvent>(_onOtherUserTypingUpdated);
    on<OtherUserOnlineStatusUpdatedEvent>(_onOtherUserOnlineStatusUpdated);
    on<ChatListUpdatedEvent>(_onChatListUpdated);
    on<ReceiveMessageEvent>(_onReceiveMessage);
  }

  @override
  Future<void> close() {
    _chatSocketService.dispose();
    _audioRecorder.dispose();
    return super.close();
  }

  Future<void> _onLoadChatList(
    LoadChatListEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      final response = await _apiClient.post(
        ApiConstantsNew.chat.chatList,
        data: {'offset': 0, 'limit': 50},
      );

      if (response.statusCode == 200) {
        final List<dynamic> rooms = response.data['response'] ?? [];
        final chatList = rooms.cast<Map<String, dynamic>>();
        emit(state.copyWith(status: ChatStatus.loaded, chatList: chatList));
      } else {
        emit(
          state.copyWith(
            status: ChatStatus.failure,
            errorMessage: "Failed to load chat list",
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: ChatStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  void _onChatListUpdated(ChatListUpdatedEvent event, Emitter<ChatState> emit) {
    emit(state.copyWith(status: ChatStatus.loaded, chatList: event.chatList));
  }

  Future<void> _onEnterChatRoom(
    EnterChatRoomEvent event,
    Emitter<ChatState> emit,
  ) async {
    final hopperId =
        sharedPreferences!.getString(SharedPreferencesKeys.hopperIdKey) ?? "";

    // 1. Initialize Socket immediately to prevent race conditions
    debugPrint(":::: ChatBloc _onEnterChatRoom :::::");
    debugPrint("hopperId: $hopperId, roomId: ${event.roomId}");
    _chatSocketService.initSocket(userId: hopperId, userType: "hopper");

    emit(
      state.copyWith(
        status: ChatStatus.loading,
        currentRoomId: event.roomId,
        receiverId: event.receiverId,
        receiverName: event.receiverName,
        receiverImage: event.receiverImage,
        messages: [],
      ),
    );

    // 2. Load Local Data
    try {
      final localMessages = await _chatLocalDataSource.getMessages(
        event.roomId,
      );
      if (localMessages.isNotEmpty) {
        emit(
          state.copyWith(status: ChatStatus.loaded, messages: localMessages),
        );
      }
    } catch (e) {
      debugPrint("Error loading local messages: $e");
    }

    // 3. Setup Listeners
    // Unified message handler
    _handleIncomingMessage(dynamic data) async {
      debugPrint(":::: ChatBloc _handleIncomingMessage :::::");
      debugPrint("data: $data");
      debugPrint("currentRoomId: ${state.currentRoomId}");
      debugPrint("receiverId: ${state.receiverId}, hopperId: $hopperId");

      // Save to local storage
      await _chatLocalDataSource.saveMessage(data);

      bool isRelevant = false;

      // 1. Direct Room Match
      if (data['room_id'] == state.currentRoomId) {
        isRelevant = true;
      }
      // 2. Sender/Receiver Match (for mismatched room IDs)
      else if ((data['sender_id'] == state.receiverId &&
              data['receiver_id'] == hopperId) ||
          (data['sender_id'] == hopperId &&
              data['receiver_id'] == state.receiverId)) {
        isRelevant = true;
        debugPrint(
            ":::: Message accepted via sender/receiver match despite room mismatch :::::");
      }

      if (isRelevant) {
        final currentMessages = List<Map<String, dynamic>>.from(state.messages);
        currentMessages.insert(0, data);
        add(ReceiveMessageEvent(currentMessages));

        // Mark as read immediately if it's from the other user
        if (data['sender_id'] != hopperId) {
          _chatSocketService.markAsRead(
            state.currentRoomId,
            hopperId,
            receiverId: state.receiverId,
          );
        }
      } else {
        debugPrint(":::: Message ignored - not for this room/context :::::");
      }
    }

    // 3. Setup Listeners
    _chatSocketService.onChatMessage = _handleIncomingMessage;
    _chatSocketService.onMediaMessage = _handleIncomingMessage;
    _chatSocketService.onVoiceMessage = _handleIncomingMessage;

    _chatSocketService.onTyping = (data) {
      debugPrint(":::: ChatBloc onTyping :::::");
      debugPrint("data: $data");
      debugPrint("currentRoomId: ${state.currentRoomId}");
      debugPrint("hopperId: $hopperId, data['user_id']: ${data['user_id']}");

      if (data['room_id'] == state.currentRoomId &&
          data['user_id'] != hopperId) {
        debugPrint(":::: Adding OtherUserTypingUpdatedEvent :::::");
        add(OtherUserTypingUpdatedEvent(data['is_typing'] ?? false));
      } else {
        debugPrint(":::: Type event ignored :::::");
      }
    };

    _chatSocketService.onAdminStatus = (data) {
      final status = data['status'] == 'online';
      add(OtherUserOnlineStatusUpdatedEvent(status));
    };

    _chatSocketService.onReadMessage = (data) async {
      debugPrint(":::: ChatBloc onReadMessage :::::");
      if (data['room_id'] == state.currentRoomId) {
        final updatedMessages = state.messages.map((m) {
          final newMsg = Map<String, dynamic>.from(m);
          newMsg['read_status'] = 'read';
          return newMsg;
        }).toList();

        add(ReceiveMessageEvent(updatedMessages));
        await _chatLocalDataSource.saveMessages(updatedMessages);
      }
    };
    _chatSocketService.joinRoom(event.roomId);
    try {
      final response = await _apiClient.post(
        ApiConstantsNew.chat.roomHistory,
        data: {'room_id': event.roomId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> history = response.data['response'] ?? [];
        final messages = history.cast<Map<String, dynamic>>().toList();
        await _chatLocalDataSource.saveMessages(messages);

        emit(state.copyWith(status: ChatStatus.loaded, messages: messages));
        _chatSocketService.markAsRead(
          event.roomId,
          hopperId,
          receiverId: state.receiverId,
        );
      }
    } catch (e) {
      debugPrint("Error fetching chat history: $e");
    }

    emit(state.copyWith(status: ChatStatus.loaded));
  }

  void _onReceiveMessage(ReceiveMessageEvent event, Emitter<ChatState> emit) {
    emit(state.copyWith(messages: event.messages));
  }

  Future<void> _onLeaveChatRoom(
    LeaveChatRoomEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state.currentRoomId.isNotEmpty) {
      _chatSocketService.leaveRoom(state.currentRoomId);
    }
    emit(state.copyWith(messages: [], currentRoomId: ''));
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final senderId =
        sharedPreferences!.getString(SharedPreferencesKeys.hopperIdKey) ?? "";
    final senderName =
        "${sharedPreferences!.getString(SharedPreferencesKeys.firstNameKey) ?? ""} ${sharedPreferences!.getString(SharedPreferencesKeys.lastNameKey) ?? ""}"
            .trim();
    final senderImage =
        sharedPreferences!.getString(SharedPreferencesKeys.avatarKey) ?? "";

    String roomId = state.currentRoomId;
    if (roomId.isEmpty) {
      roomId =
          sharedPreferences!.getString(SharedPreferencesKeys.adminRoomIdKey) ??
              "";
    }

    if (roomId.isEmpty) {
      debugPrint(
          ":::: ERROR: Cannot send message, roomId is empty in state and storage :::::");
      return;
    }

    Map<String, dynamic> messageData = {
      'room_id': roomId,
      'sender_id': senderId,
      'receiver_id': state.receiverId,
      'message': event.message,
      'message_type': event.messageType,
      'sender_name': senderName,
      'sender_image': senderImage,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };

    if (event.messageType != "text" && event.filePath != null) {
      emit(state.copyWith(status: ChatStatus.sending));
    }

    await _chatLocalDataSource.saveMessage(messageData);

    debugPrint(":::: ChatBloc _onSendMessage :::::");
    debugPrint("messageType: ${event.messageType}");
    debugPrint("roomId: $roomId");

    // Ensure socket is initialized
    _chatSocketService.initSocket(userId: senderId, userType: "hopper");

    if (event.messageType == 'audio') {
      _chatSocketService.sendVoiceMessage(messageData);
    } else if (event.messageType == 'text') {
      _chatSocketService.sendMessage(messageData);
    } else {
      _chatSocketService.sendMediaMessage(messageData);
    }
  }

  Future<void> _onUpdateTypingStatus(
    UpdateTypingStatusEvent event,
    Emitter<ChatState> emit,
  ) async {
    final senderId =
        sharedPreferences!.getString(SharedPreferencesKeys.hopperIdKey) ?? "";
    _chatSocketService.sendTypingStatus(event.roomId, senderId, event.isTyping);
  }

  Future<void> _onStartAudioRecording(
    StartAudioRecordingEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (await _audioRecorder.hasPermission()) {
      final directory = await getApplicationDocumentsDirectory();
      String path =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(const RecordConfig(), path: path);
      emit(state.copyWith(isRecording: true));
    }
  }

  Future<void> _onStopAudioRecording(
    StopAudioRecordingEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (!state.isRecording) return;
    final path = await _audioRecorder.stop();
    emit(state.copyWith(isRecording: false));
    if (path != null) {
      add(SendMessageEvent(message: "", messageType: "audio", filePath: path));
    }
  }

  Future<void> _onUpdateAppLifecycle(
    UpdateAppLifecycleEvent event,
    Emitter<ChatState> emit,
  ) async {}

  void _onOtherUserTypingUpdated(
    OtherUserTypingUpdatedEvent event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(isTyping: event.isTyping));
  }

  void _onOtherUserOnlineStatusUpdated(
    OtherUserOnlineStatusUpdatedEvent event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(isOnline: event.isOnline));
  }
}
