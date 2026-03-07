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
import 'package:hive/hive.dart';
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
    final cacheBox = Hive.box('sync_cache');
    const String cacheKey = 'chat_list_v2';

    debugPrint("ChatBloc: Loading chat list starting...");

    // 1. Silent Load from Cache
    final cachedData = cacheBox.get(cacheKey);
    if (cachedData != null && cachedData is List) {
      try {
        debugPrint(
            "ChatBloc: Found cached chat list: ${cachedData.length} rooms");
        final chatList =
            cachedData.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        if (chatList.isNotEmpty) {
          emit(state.copyWith(status: ChatStatus.loaded, chatList: chatList));
        }
      } catch (e) {
        debugPrint("ChatBloc: Error loading chat list from cache: $e");
      }
    }

    if (state.status != ChatStatus.loaded) {
      emit(state.copyWith(status: ChatStatus.loading));
    }

    // 2. Refresh from API
    try {
      final response = await _apiClient.post(
        ApiConstantsNew.chat.chatList,
        data: {'offset': 0, 'limit': 50},
      );

      if (response.statusCode == 200) {
        final List<dynamic> rooms = response.data['response'] ?? [];
        final chatList = rooms.cast<Map<String, dynamic>>().toList();

        debugPrint("ChatBloc: API Success: ${chatList.length} rooms");

        // Update Cache
        try {
          await cacheBox.put(cacheKey, chatList);
          debugPrint("ChatBloc: Chat list cache updated");
        } catch (e) {
          debugPrint("ChatBloc: Error updating chat list cache: $e");
        }

        emit(state.copyWith(status: ChatStatus.loaded, chatList: chatList));
      } else {
        if (state.chatList.isEmpty) {
          emit(
            state.copyWith(
              status: ChatStatus.failure,
              errorMessage: "Failed to load chat list",
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("ChatBloc: API Error: $e");
      if (state.chatList.isEmpty) {
        emit(
          state.copyWith(
              status: ChatStatus.failure, errorMessage: e.toString()),
        );
      }
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
      debugPrint(
          "ChatBloc: Loading local messages for room: ${event.roomId}...");
      final localMessages = await _chatLocalDataSource.getMessages(
        event.roomId,
      );
      if (localMessages.isNotEmpty) {
        debugPrint("ChatBloc: Found ${localMessages.length} local messages");
        emit(
          state.copyWith(status: ChatStatus.loaded, messages: localMessages),
        );
      } else {
        debugPrint("ChatBloc: No local messages found");
      }
    } catch (e) {
      debugPrint("ChatBloc: Error loading local messages: $e");
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

        // Deduplication: skip if this is an echo of our optimistically added message
        final String incomingSenderId =
            (data['sender_id'] ?? '').toString().trim();
        final String incomingMessage =
            (data['message'] ?? '').toString().trim();
        final bool isDuplicate = currentMessages.any((m) {
          final String existingSenderId =
              (m['sender_id'] ?? '').toString().trim();
          final String existingMessage = (m['message'] ?? '').toString().trim();
          return existingSenderId == incomingSenderId &&
              existingMessage == incomingMessage &&
              existingSenderId == hopperId;
        });

        if (isDuplicate) {
          debugPrint(":::: Skipping duplicate message (optimistic echo) :::::");
          return;
        }

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
      debugPrint("ChatBloc: Fetching room history from API...");
      final response = await _apiClient.post(
        ApiConstantsNew.chat.roomHistory,
        data: {'room_id': event.roomId},
      );

      debugPrint("ChatBloc: Room history raw response: ${response.data}");

      if (response.statusCode == 200) {
        List<dynamic> history = [];

        // Handle multiple API response formats
        if (response.data is Map) {
          final responseData = response.data as Map<String, dynamic>;
          if (responseData['response'] is List) {
            history = responseData['response'];
          } else if (responseData['data'] is List) {
            history = responseData['data'];
          } else if (responseData['messages'] is List) {
            history = responseData['messages'];
          }
        } else if (response.data is List) {
          history = response.data;
        }

        final messages = history.cast<Map<String, dynamic>>().toList();
        debugPrint(
            "ChatBloc: API History Success: ${messages.length} messages");
        await _chatLocalDataSource.saveMessages(messages);

        emit(state.copyWith(status: ChatStatus.loaded, messages: messages));
        _chatSocketService.markAsRead(
          event.roomId,
          hopperId,
          receiverId: state.receiverId,
        );
      } else {
        debugPrint(
            "ChatBloc: API History Error: Status ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("ChatBloc: Error fetching chat history: $e");
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

    // Optimistic update: add message to UI immediately
    final currentMessages = List<Map<String, dynamic>>.from(state.messages);
    currentMessages.insert(0, messageData);
    emit(state.copyWith(
      status: event.messageType != "text" && event.filePath != null
          ? ChatStatus.sending
          : ChatStatus.loaded,
      messages: currentMessages,
    ));

    await _chatLocalDataSource.saveMessage(messageData);

    debugPrint(":::: ChatBloc _onSendMessage :::::");
    debugPrint("messageType: ${event.messageType}");
    debugPrint("  : $roomId");

    // Ensure socket is initialized
    _chatSocketService.initSocket(userId: senderId, userType: "hopper");

    if (event.messageType == 'audio') {
      _chatSocketService.sendVoiceMessage(messageData);
    } else if (event.messageType == 'text') {
      _chatSocketService.sendMessage(messageData);
    } else {
      _chatSocketService.sendMediaMessage(messageData);
    }

    // Also send via HTTP API as fallback for reliability
    try {
      await _apiClient.post(
        ApiConstantsNew.chat.sendChatMessage,
        data: messageData,
        showLoader: false,
      );
      debugPrint(":::: Message also sent via HTTP API :::::");
    } catch (e) {
      debugPrint(":::: HTTP API send fallback error (non-critical): $e :::::");
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
