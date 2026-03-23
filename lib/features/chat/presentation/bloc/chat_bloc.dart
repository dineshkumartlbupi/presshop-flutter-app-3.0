import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:presshop/core/core_export.dart'; // Constants

import 'package:presshop/features/chat/presentation/bloc/chat_event.dart';
import 'package:presshop/features/chat/presentation/bloc/chat_state.dart';

import 'package:presshop/features/chat/data/datasources/chat_socket_datasource.dart';
import 'package:presshop/main.dart'; // Globals
import 'package:record/record.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart'; // For ScrollController

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatSocketDataSource _chatSocketDataSource;
  final ApiClient _apiClient = GetIt.I<ApiClient>();
  final AudioRecorder _audioRecorder;
  final ScrollController scrollController = ScrollController();

  ChatBloc({
    required ChatSocketDataSource chatSocketDataSource,
    AudioRecorder? audioRecorder,
  })  : _chatSocketDataSource = chatSocketDataSource,
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
    on<FetchMoreMessagesEvent>(_onFetchMoreMessages);
  }

  @override
  Future<void> close() {
    _chatSocketDataSource.dispose();
    _audioRecorder.dispose();
    scrollController.dispose();
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
    _chatSocketDataSource.initSocket(userId: hopperId, userType: "hopper");
    _chatSocketDataSource.initializeListeners();

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

    // Skip Local Data Loading - As requested

    // 3. Setup Listeners
    // Unified message handler
    _handleIncomingMessage(dynamic data) async {
      debugPrint(":::: ChatBloc _handleIncomingMessage :::::");
      debugPrint("data: $data");

      if (data is! Map) return;

      final Map<String, dynamic> mappedData = Map<String, dynamic>.from(data);

      // Handle structural differences from different senders (Admin vs Hopper)
      if (mappedData['message_type'] == 'chat') {
        mappedData['message_type'] = 'text';
      }

      // Normalize sender details if missing but sender_data is present
      if (mappedData['sender_details'] == null &&
          mappedData['sender_data'] != null) {
        mappedData['sender_details'] = mappedData['sender_data'];
      }

      // Ensure readStatus key is consistent (read_status vs readStatus)
      if (mappedData['readStatus'] == null &&
          mappedData['read_status'] != null) {
        mappedData['readStatus'] = mappedData['read_status'];
      }

      debugPrint("currentRoomId: ${state.currentRoomId}");
      debugPrint("receiverId: ${state.receiverId}, hopperId: $hopperId");

      // Save to local storage
      // Skip Local Saving

      bool isRelevant = false;

      // 1. Direct Room Match
      if (mappedData['room_id'] == state.currentRoomId) {
        isRelevant = true;
      }
      // 2. Sender/Receiver Match (for mismatched room IDs)
      else if ((mappedData['sender_id'] == state.receiverId &&
              mappedData['receiver_id'] == hopperId) ||
          (mappedData['sender_id'] == hopperId &&
              mappedData['receiver_id'] == state.receiverId)) {
        isRelevant = true;
        debugPrint(
            ":::: Message accepted via sender/receiver match despite room mismatch :::::");
      }

      if (isRelevant) {
        final currentMessages = List<Map<String, dynamic>>.from(state.messages);

        final String incomingMsgId = (mappedData['_id'] ??
                mappedData['messageId'] ??
                mappedData['id'] ??
                '')
            .toString();
        final String incomingSenderId =
            (mappedData['sender_id'] ?? '').toString().trim();
        final String incomingMessage =
            (mappedData['message'] ?? '').toString().trim();

        debugPrint(
            ":::: Deduplicating: ID=$incomingMsgId, Sender=$incomingSenderId, Msg=$incomingMessage");

        int existingIndex = -1;
        for (int i = 0; i < currentMessages.length; i++) {
          final m = currentMessages[i];
          final String existingMsgId =
              (m['_id'] ?? m['messageId'] ?? m['id'] ?? '').toString();
          final String existingSenderId =
              (m['sender_id'] ?? m['senderId'] ?? '').toString().trim();
          final String existingMessage = (m['message'] ?? '').toString().trim();

          debugPrint(
              ":::: Comparing with Index $i: ID=$existingMsgId, Sender=$existingSenderId, Msg=$existingMessage");

          // 1. Precise Match by ID
          if (incomingMsgId.isNotEmpty && incomingMsgId == existingMsgId) {
            existingIndex = i;
            debugPrint(":::: Match found by ID at index $i");
            break;
          }

          // 2. Heuristic Match by Content + Sender (for optimistic echos or ID-less messages)
          if (existingSenderId == incomingSenderId &&
              existingMessage == incomingMessage) {
            existingIndex = i;
            debugPrint(":::: Match found by Content at index $i");
            break;
          }
        }

        if (existingIndex != -1) {
          debugPrint(":::: Updating existing message at index $existingIndex");
          currentMessages[existingIndex] = mappedData;
          add(ReceiveMessageEvent(currentMessages));
          return;
        }

        debugPrint(":::: Adding new message to list");
        currentMessages.insert(0, mappedData);
        add(ReceiveMessageEvent(currentMessages));

        // Mark as read immediately if it's from the other user
        final String incomingSenderIdActual =
            mappedData['sender_id']?.toString() ?? '';
        final bool isSender = incomingSenderIdActual == hopperId;
        final String status = mappedData['status']?.toString() ??
            mappedData['read_status']?.toString() ??
            '';
        if (!isSender && status != 'read') {
          _chatSocketDataSource.markAsRead(
            mappedData['room_id']?.toString() ?? state.currentRoomId,
            hopperId,
            receiverId: incomingSenderIdActual,
          );
        }
      } else {
        debugPrint(":::: Message ignored - not for this room/context :::::");
      }
    }

    // 3. Setup Listeners
    _chatSocketDataSource.onChatMessage = _handleIncomingMessage;
    _chatSocketDataSource.onMediaMessage = _handleIncomingMessage;
    _chatSocketDataSource.onVoiceMessage = _handleIncomingMessage;

    _chatSocketDataSource.onTyping = (data) {
      debugPrint(":::: ChatBloc onTyping received :::: Data: $data");
      if (data is Map) {
        final userId = data['user_id']?.toString() ?? '';
        final typingStatus = data['is_typing'] == true;
        debugPrint(
            ":::: ChatBloc Typing Logic :::: userId: $userId, hopperId: $hopperId, isTyping: $typingStatus");
        if (userId.isNotEmpty && userId != hopperId) {
          debugPrint(
              ":::: ChatBloc: Updating Other User Typing: $typingStatus");
          add(OtherUserTypingUpdatedEvent(typingStatus));
        } else if (userId == hopperId) {
          debugPrint(":::: ChatBloc: Ignored self typing echo ::::");
        }
      }
    };

    _chatSocketDataSource.onAdminStatus = (data) {
      debugPrint(":::: ChatBloc onAdminStatus ::::: Data: $data");
      if (data is Map) {
        final bool isOnline = data['is_online'] == true ||
            data['status'] == 'online' ||
            data['online'] == true;
        add(OtherUserOnlineStatusUpdatedEvent(isOnline));
      }
    };

    _chatSocketDataSource.onReadMessage = (data) async {
      debugPrint(":::: ChatBloc onReadMessage :::: Data: $data");
      if (data['room_id'] == state.currentRoomId) {
        final updatedMessages = state.messages.map((m) {
          final newMsg = Map<String, dynamic>.from(m);
          newMsg['read_status'] = 'read';
          newMsg['readStatus'] = 'read';
          return newMsg;
        }).toList();

        add(ReceiveMessageEvent(updatedMessages));
        // Skip Local Saving
      }
    };

    _chatSocketDataSource.joinRoom(event.roomId);
    try {
      debugPrint("ChatBloc: Fetching room history from API...");
      final response = await _apiClient.post(
        ApiConstantsNew.chat.roomHistory,
        data: {
          'room_id': event.roomId,
          'offset': 0,
          'limit': 20,
        },
      );

      debugPrint(
          ":::: DEBUG: StatusCode=${response.statusCode}, Type=${response.statusCode.runtimeType} :::: ");

      if (response.statusCode.toString() == "200" ||
          response.statusCode.toString() == "201") {
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
        // Skip Local Saving

        final bool hasMore = messages.length >= 20;

        emit(state.copyWith(
          status: ChatStatus.loaded,
          messages: messages,
          offset: messages.length,
          hasMore: hasMore,
          isFetchingMore: false,
        ));
        _chatSocketDataSource.markAsRead(
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
    // Aggressive deduplication of the incoming message list to ensure state is always clean
    final List<Map<String, dynamic>> cleanMessages = [];
    final Set<String> seenIds = {};
    final Set<String> seenContent = {};

    for (var m in event.messages) {
      final String msgId =
          (m['_id'] ?? m['messageId'] ?? m['id'] ?? '').toString();
      final String content = (m['message'] ?? '').toString().trim();
      final String sender = (m['sender_id'] ?? '').toString().trim();

      if (msgId.isNotEmpty) {
        if (!seenIds.contains(msgId)) {
          seenIds.add(msgId);
          cleanMessages.add(m);
        }
      } else if (content.isNotEmpty) {
        final String contentKey = "$sender|$content";
        if (!seenContent.contains(contentKey)) {
          seenContent.add(contentKey);
          cleanMessages.add(m);
        }
      } else {
        cleanMessages.add(m);
      }
    }

    emit(state.copyWith(messages: cleanMessages));
  }

  Future<void> _onFetchMoreMessages(
    FetchMoreMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state.isFetchingMore || !state.hasMore) return;

    emit(state.copyWith(isFetchingMore: true));

    try {
      debugPrint(
          "ChatBloc: Fetching more messages for room: ${state.currentRoomId}, offset: ${state.offset}");
      final response = await _apiClient.post(
        ApiConstantsNew.chat.roomHistory,
        data: {
          'room_id': state.currentRoomId,
          'offset': state.offset,
          'limit': 20,
        },
      );

      if (response.statusCode.toString() == "200" ||
          response.statusCode.toString() == "201") {
        List<dynamic> history = [];
        if (response.data is Map) {
          final responseData = response.data as Map<String, dynamic>;
          history = responseData['response'] ??
              responseData['data'] ??
              responseData['messages'] ??
              [];
        } else if (response.data is List) {
          history = response.data;
        }

        final newMessages = history.cast<Map<String, dynamic>>().toList();
        debugPrint(
            "ChatBloc: Fetch More Success: ${newMessages.length} new messages");

        if (newMessages.isEmpty) {
          emit(state.copyWith(isFetchingMore: false, hasMore: false));
          return;
        }

        // Skip Local Saving

        // Append to the bottom (since messages are ordered DESC by date)
        final List<Map<String, dynamic>> updatedMessages =
            List.from(state.messages)..addAll(newMessages);

        emit(state.copyWith(
          isFetchingMore: false,
          messages: updatedMessages,
          offset: state.offset + newMessages.length,
          hasMore: newMessages.length >= 20,
        ));
      } else {
        emit(state.copyWith(isFetchingMore: false));
      }
    } catch (e) {
      debugPrint("ChatBloc: Error fetching more messages: $e");
      emit(state.copyWith(isFetchingMore: false));
    }
  }

  Future<void> _onLeaveChatRoom(
    LeaveChatRoomEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state.currentRoomId.isNotEmpty) {
      _chatSocketDataSource.leaveRoom(state.currentRoomId);
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
      'message': event.messageType == "text" ? event.message : event.filePath,
      'message_type': event.messageType,
      'sender_name': senderName,
      'sender_image': senderImage,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'uploadPercent': 100.0,
      'isAudioSelected': false,
      'messageId': 'temp_${DateTime.now().millisecondsSinceEpoch}',
      'readStatus': 'unread',
      'read_status': 'unread',
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

    // Skip Local Saving

    debugPrint(":::: ChatBloc _onSendMessage :::::");
    debugPrint("messageType: ${event.messageType}");
    debugPrint("  : $roomId");

    // Ensure socket is initialized
    _chatSocketDataSource.initSocket(userId: senderId, userType: "hopper");

    if (event.messageType == 'audio' || event.messageType == 'recording') {
      _chatSocketDataSource.sendVoiceMessage(messageData);
    } else if (event.messageType == 'text') {
      _chatSocketDataSource.sendMessage(messageData);
    } else {
      _chatSocketDataSource.sendMediaMessage(messageData);
    }

    // Also send via HTTP API as fallback for reliability
    try {
      // await _apiClient.post(
      //   ApiConstantsNew.chat.sendChatMessage,
      //   data: messageData,
      //   showLoader: false,
      // );
      // debugPrint(":::: Message also sent via HTTP API :::::");
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
    debugPrint(
        "ChatBloc: Sending typing status: ${event.isTyping} for room ${event.roomId} to receiver ${state.receiverId} with value: ${event.typedValue}");
    _chatSocketDataSource.sendTypingStatus(
        event.roomId, senderId, event.isTyping,
        receiverId: state.receiverId, typedValue: event.typedValue);
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
