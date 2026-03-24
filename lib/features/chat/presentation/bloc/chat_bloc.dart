import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../../domain/usecases/get_chat_list.dart';
import '../../domain/usecases/get_room_chat.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/upload_media.dart';
import '../../domain/usecases/update_typing_status.dart';
import 'package:presshop/features/chat/presentation/bloc/chat_event.dart';
import 'package:presshop/features/chat/presentation/bloc/chat_state.dart';
import 'package:presshop/features/chat/data/datasources/chat_socket_datasource.dart';
import 'package:presshop/features/chat/data/models/chat_models.dart';
import 'package:presshop/main.dart';
import 'package:record/record.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatListUseCase _getChatListUseCase;
  final GetRoomChatUseCase _getRoomChatUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final UploadMediaUseCase _uploadMediaUseCase;
  final UpdateTypingStatusUseCase _updateTypingStatusUseCase;
  final ChatSocketDataSource _chatSocketDataSource;
  final AudioRecorder _audioRecorder;
  final ScrollController scrollController = ScrollController();

  ChatBloc({
    required GetChatListUseCase getChatListUseCase,
    required GetRoomChatUseCase getRoomChatUseCase,
    required SendMessageUseCase sendMessageUseCase,
    required UploadMediaUseCase uploadMediaUseCase,
    required UpdateTypingStatusUseCase updateTypingStatusUseCase,
    required ChatSocketDataSource chatSocketDataSource,
    AudioRecorder? audioRecorder,
  })  : _getChatListUseCase = getChatListUseCase,
        _getRoomChatUseCase = getRoomChatUseCase,
        _sendMessageUseCase = sendMessageUseCase,
        _uploadMediaUseCase = uploadMediaUseCase,
        _updateTypingStatusUseCase = updateTypingStatusUseCase,
        _chatSocketDataSource = chatSocketDataSource,
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
    return super.close();
  }

  Future<void> _onLoadChatList(
    LoadChatListEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state.status != ChatStatus.loaded) {
      emit(state.copyWith(status: ChatStatus.loading));
    }

    try {
      if (Hive.isBoxOpen('sync_cache')) {
        final cacheBox = Hive.box('sync_cache');
        const String cacheKey = 'chat_list_v3';

        debugPrint("ChatBloc: Loading chat list starting...");

        // 1. Silent Load from Cache
        final cachedData = cacheBox.get(cacheKey);
        if (cachedData != null && cachedData is List) {
          try {
            final chatList = cachedData
                .map((e) =>
                    ChatRoomModel.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList();
            if (chatList.isNotEmpty) {
              emit(state.copyWith(
                  status: ChatStatus.loaded, chatList: chatList));
            }
          } catch (e) {
            debugPrint("ChatBloc: Error loading chat list from cache: $e");
          }
        }
      }
    } catch (e) {
      debugPrint("ChatBloc: Hive check failed: $e");
    }

    // 2. Refresh from UseCase
    final result = await _getChatListUseCase(NoParams());

    result.fold(
      (failure) {
        if (state.chatList.isEmpty) {
          emit(state.copyWith(
              status: ChatStatus.failure, errorMessage: failure.message));
        }
      },
      (chatList) {
        emit(state.copyWith(
          status: ChatStatus.loaded,
          chatList: chatList.cast<ChatRoomModel>(),
        ));
      },
    );
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

    // Socket message handler
    void _handleIncomingMessage(dynamic data) async {
      if (data is! Map) return;
      final Map<String, dynamic> mappedData = Map<String, dynamic>.from(data);
      final incomingMessage = ChatMessageModel.fromJson(mappedData, hopperId);

      bool isRelevant = false;
      if (incomingMessage.roomId == state.currentRoomId) {
        isRelevant = true;
      } else if ((incomingMessage.senderId == state.receiverId &&
              mappedData['receiver_id'] == hopperId) ||
          (incomingMessage.senderId == hopperId &&
              mappedData['receiver_id'] == state.receiverId)) {
        isRelevant = true;
      }

      if (isRelevant) {
        final currentMessages = List<ChatMessageModel>.from(state.messages);

        int existingIndex = -1;
        for (int i = 0; i < currentMessages.length; i++) {
          final m = currentMessages[i];
          if (incomingMessage.id.isNotEmpty && incomingMessage.id == m.id) {
            existingIndex = i;
            break;
          }
          if (m.senderId == incomingMessage.senderId &&
              m.message == incomingMessage.message) {
            existingIndex = i;
            break;
          }
        }

        if (existingIndex != -1) {
          currentMessages[existingIndex] = incomingMessage;
          add(ReceiveMessageEvent(currentMessages));
          return;
        }

        currentMessages.insert(0, incomingMessage);
        add(ReceiveMessageEvent(currentMessages));

        if (!incomingMessage.isSender && incomingMessage.readStatus != 'read') {
          _chatSocketDataSource.markAsRead(
            incomingMessage.roomId,
            hopperId,
            receiverId: incomingMessage.senderId,
          );
        }
      }
    }

    _chatSocketDataSource.onChatMessage = _handleIncomingMessage;
    _chatSocketDataSource.onMediaMessage = _handleIncomingMessage;
    _chatSocketDataSource.onVoiceMessage = _handleIncomingMessage;

    _chatSocketDataSource.onTyping = (data) {
      if (data is Map) {
        final userId = data['user_id']?.toString() ?? '';
        final typingStatus = data['is_typing'] == true;
        if (userId.isNotEmpty && userId != hopperId) {
          add(OtherUserTypingUpdatedEvent(typingStatus));
        }
      }
    };

    _chatSocketDataSource.onAdminStatus = (data) {
      if (data is Map) {
        final bool isOnline = data['is_online'] == true ||
            data['status'] == 'online' ||
            data['online'] == true;
        add(OtherUserOnlineStatusUpdatedEvent(isOnline));
      }
    };

    _chatSocketDataSource.onReadMessage = (data) async {
      if (data['room_id'] == state.currentRoomId) {
        final updatedMessages = state.messages.map((m) {
          return ChatMessageModel(
            id: m.id,
            roomId: m.roomId,
            message: m.message,
            messageType: m.messageType,
            senderId: m.senderId,
            senderType: m.senderType,
            senderName: m.senderName,
            senderImage: m.senderImage,
            createdAt: m.createdAt,
            readStatus: 'read',
            media: m.media,
            isSender: m.isSender,
          );
        }).toList();
        add(ReceiveMessageEvent(updatedMessages));
      }
    };

    _chatSocketDataSource.joinRoom(event.roomId);

    // API load via UseCase
    final result = await _getRoomChatUseCase(event.roomId);

    result.fold(
      (failure) {
        emit(state.copyWith(status: ChatStatus.loaded));
      },
      (messages) {
        final bool hasMore = messages.length >= 20;
        emit(state.copyWith(
          status: ChatStatus.loaded,
          messages: messages as List<ChatMessageModel>,
          offset: messages.length,
          hasMore: hasMore,
          isFetchingMore: false,
        ));

        _chatSocketDataSource.markAsRead(
          event.roomId,
          hopperId,
          receiverId: state.receiverId,
        );
      },
    );
  }

  void _onReceiveMessage(ReceiveMessageEvent event, Emitter<ChatState> emit) {
    final List<ChatMessageModel> incoming = event.messages;
    final List<ChatMessageModel> cleanMessages = [];
    final Set<String> seenIds = {};
    final Set<String> seenContent = {};

    for (var m in incoming) {
      if (m.id.isNotEmpty) {
        if (!seenIds.contains(m.id)) {
          seenIds.add(m.id);
          cleanMessages.add(m);
        }
      } else if (m.message.isNotEmpty) {
        final String contentKey = "${m.senderId}|${m.message}";
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
    // Note: The UseCase call doesn't currently support offset/limit in the call signature,
    // so we might need to adjust the interface or keep it simple for now.
    // For now, let's keep the existing logic but recognize it needs clean-up.
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
    final userId =
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

    if (roomId.isEmpty) return;

    String content = event.message;
    List<String> mediaUrls = [];

    // 1. Handle Upload via UseCase
    if (event.messageType != "text" && event.filePath != null) {
      emit(state.copyWith(status: ChatStatus.sending));
      final uploadResult = await _uploadMediaUseCase(File(event.filePath!));

      bool uploadSuccess = false;
      uploadResult.fold(
        (failure) {
          emit(state.copyWith(
              status: ChatStatus.failure, errorMessage: failure.message));
        },
        (url) {
          content = url;
          mediaUrls = [url];
          uploadSuccess = true;
        },
      );

      if (!uploadSuccess) return;
    }

    // 2. Send via UseCase (which coordinates socket)
    final sendResult = await _sendMessageUseCase(SendMessageParams(
      roomId: roomId,
      message: content,
      receiverId: state.receiverId,
      messageType: event.messageType,
      userId: userId,
      media: mediaUrls,
    ));

    sendResult.fold(
      (failure) {
        emit(state.copyWith(
            status: ChatStatus.failure, errorMessage: failure.message));
      },
      (tempMessage) {
        final currentMessages = List<ChatMessageModel>.from(state.messages);

        // Populate sender info for the temporary UI message
        final uiMessage = ChatMessageModel(
          id: tempMessage.id,
          roomId: tempMessage.roomId,
          message: tempMessage.message,
          messageType: tempMessage.messageType,
          senderId: userId,
          senderType: 'hopper',
          senderName: senderName,
          senderImage: senderImage,
          createdAt: tempMessage.createdAt,
          readStatus: tempMessage.readStatus,
          media: tempMessage.media,
          isSender: true,
        );

        currentMessages.insert(0, uiMessage);
        emit(state.copyWith(
          status: ChatStatus.loaded,
          messages: currentMessages,
        ));
      },
    );
  }

  Future<void> _onUpdateTypingStatus(
    UpdateTypingStatusEvent event,
    Emitter<ChatState> emit,
  ) async {
    final userId =
        sharedPreferences!.getString(SharedPreferencesKeys.hopperIdKey) ?? "";
    await _updateTypingStatusUseCase(TypingStatusParams(
      roomId: event.roomId,
      isTyping: event.isTyping,
      receiverId: state.receiverId,
      userId: userId,
    ));
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
