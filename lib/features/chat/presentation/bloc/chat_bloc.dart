import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:presshop/core/core_export.dart'; // Constants
import 'package:presshop/core/utils/shared_preferences.dart'; // Prefs
import 'package:presshop/features/chat/presentation/bloc/chat_event.dart';
import 'package:presshop/features/chat/presentation/bloc/chat_state.dart';
import 'package:presshop/main.dart'; // Globals
import 'package:record/record.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {

  ChatBloc({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    AudioRecorder? audioRecorder,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _audioRecorder = audioRecorder ?? AudioRecorder(),
        super(const ChatState()) {
    on<LoadChatListEvent>(_onLoadChatList);
    on<SearchUserEvent>(_onSearchUser);
    on<EnterChatRoomEvent>(_onEnterChatRoom);
    on<LeaveChatRoomEvent>(_onLeaveChatRoom);
    on<SendMessageEvent>(_onSendMessage);
    on<ReceiveMessageEvent>(_onReceiveMessage);
    on<UpdateTypingStatusEvent>(_onUpdateTypingStatus);
    on<StartAudioRecordingEvent>(_onStartAudioRecording);
    on<StopAudioRecordingEvent>(_onStopAudioRecording);
    on<UpdateAppLifecycleEvent>(_onUpdateAppLifecycle);
    on<OtherUserTypingUpdatedEvent>(_onOtherUserTypingUpdated);
    on<OtherUserOnlineStatusUpdatedEvent>(_onOtherUserOnlineStatusUpdated);
    on<ChatListUpdatedEvent>(_onChatListUpdated);
  }
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final AudioRecorder _audioRecorder;

  StreamSubscription? _messagesSubscription;
  StreamSubscription? _chatListSubscription;
  StreamSubscription? _typingSubscription;
  StreamSubscription? _onlineStatusSubscription;

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _chatListSubscription?.cancel();
    _typingSubscription?.cancel();
    _onlineStatusSubscription?.cancel();
    _audioRecorder.dispose();
    return super.close();
  }

  Future<void> _onLoadChatList(
      LoadChatListEvent event, Emitter<ChatState> emit) async {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      _chatListSubscription?.cancel();
      _chatListSubscription = _firestore
          .collection("Chat2")
          .orderBy('date', descending: true)
          .snapshots()
          .listen((snapshot) {
        add(ChatListUpdatedEvent(snapshot.docs));
      });
    } catch (e) {
      emit(state.copyWith(
          status: ChatStatus.failure, errorMessage: e.toString()));
    }
  }

  void _onChatListUpdated(ChatListUpdatedEvent event, Emitter<ChatState> emit) {
    emit(state.copyWith(status: ChatStatus.loaded, chatList: event.chatList));
  }

  Future<void> _onSearchUser(
      SearchUserEvent event, Emitter<ChatState> emit) async {
    // Filtering logic would go here if we had the full list in state.
  }

  Future<void> _onEnterChatRoom(
      EnterChatRoomEvent event, Emitter<ChatState> emit) async {
    emit(state.copyWith(
      status: ChatStatus.loading,
      currentRoomId: event.roomId,
      receiverId: event.receiverId,
      receiverName: event.receiverName,
      receiverImage: event.receiverImage,
    ));

    await _messagesSubscription?.cancel();
    await _typingSubscription?.cancel();
    await _onlineStatusSubscription?.cancel();

    // Subscribe to messages
    _messagesSubscription = _firestore
        .collection('Chat2')
        .doc(event.roomId)
        .collection('Messages')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      add(ReceiveMessageEvent(snapshot.docs));
    });

    // Listen to typing status of receiver
    if (event.receiverId.isNotEmpty) {
      _typingSubscription = _firestore
          .collection('Chat2')
          .doc(event.roomId)
          .collection('Typing')
          .doc(event.receiverId)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          bool isTyping = snapshot.data()?['isTyping'] ?? false;
          add(OtherUserTypingUpdatedEvent(isTyping));
        }
      });

      // Listen to online status of receiver
      _onlineStatusSubscription = _firestore
          .collection('OnlineOffline')
          .doc(event.receiverId)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          bool isOnline = snapshot.data()?['isOnline'] ?? false;
          add(OtherUserOnlineStatusUpdatedEvent(isOnline));
        }
      });
    }

    // Mark messages as read
    final unreadQuery = await _firestore
        .collection('Chat2')
        .doc(event.roomId)
        .collection('Messages')
        .where('receiverId',
            isEqualTo: sharedPreferences!.getString(hopperIdKey))
        .where('readStatus', isEqualTo: 'unread')
        .get();

    for (var doc in unreadQuery.docs) {
      doc.reference.update({'readStatus': 'read'});
    }

    emit(state.copyWith(status: ChatStatus.loaded));
  }

  void _onReceiveMessage(ReceiveMessageEvent event, Emitter<ChatState> emit) {
    emit(state.copyWith(messages: event.messages));
  }

  Future<void> _onLeaveChatRoom(
      LeaveChatRoomEvent event, Emitter<ChatState> emit) async {
    await _messagesSubscription?.cancel();
    await _typingSubscription?.cancel();
    await _onlineStatusSubscription?.cancel();
    emit(state.copyWith(messages: [], currentRoomId: ''));
  }

  Future<void> _onSendMessage(
      SendMessageEvent event, Emitter<ChatState> emit) async {
    emit(state.copyWith(status: ChatStatus.sending)); // Optional: optimistic UI

    final senderId = sharedPreferences!.getString(hopperIdKey) ?? "";
    final senderName =
        "${sharedPreferences!.getString(firstNameKey) ?? ""} ${sharedPreferences!.getString(lastNameKey) ?? ""}"
            .trim();
    final senderImage = sharedPreferences!.getString(avatarKey) ?? "";
    final senderUserName = sharedPreferences!.getString(userNameKey) ?? "";

    String messageId = DateTime.now().toUtc().millisecondsSinceEpoch.toString();
    String message = event.message;
    String thumbnail = event.thumbnailPath ?? "";
    // double uploadPercent = 0.0;

    // Upload Media if needed
    if (event.messageType != "text" &&
        event.filePath != null &&
        event.filePath!.isNotEmpty) {
      String fileName = event.messageType == 'video'
          ? '${DateTime.now().millisecondsSinceEpoch}.mp4'
          : '${DateTime.now().millisecondsSinceEpoch}.jpg'; // or png
      if (event.messageType == 'audio') {
        fileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
      }

      String path = 'Media/$fileName';
      if (event.messageType == 'video') {
        path = 'Media/$fileName'; // Matches ChatScreen logic somewhat
      }

      Reference storageRef = _storage.ref().child(path);
      UploadTask uploadTask = storageRef.putFile(File(event.filePath!));

      // We could listen to progress here and emit state, but it triggers too many rebuilds usually.
      // ChatScreen updates a field in Firestore `uploadPercent`.
      // We can do that too, OR just rely on local state.

      try {
        TaskSnapshot taskSnapshot = await uploadTask;
        message = await taskSnapshot.ref.getDownloadURL();
        // uploadPercent = 100.0;

        // Upload Thumbnail if video
        if (event.messageType == 'video' && thumbnail.isNotEmpty) {
          String thumbName =
              'thumbnail_${DateTime.now().millisecondsSinceEpoch}.png';
          Reference thumbRef = _storage.ref().child('Media/$thumbName');
          var thumbTask = thumbRef.putFile(File(thumbnail));
          await thumbTask;
          thumbnail = await thumbRef.getDownloadURL();
        }
      } catch (e) {
        emit(state.copyWith(
            status: ChatStatus.failure, errorMessage: "Upload failed: $e"));
        return;
      }
    }

    Map<String, dynamic> map = {
      'messageId': messageId,
      'senderId': senderId,
      'senderName': senderName,
      'senderImage': senderImage,
      'receiverId': state.receiverId,
      'receiverName': state.receiverName,
      'receiverImage': state.receiverImage,
      'roomId': state.currentRoomId,
      'replyMessage': event.replyMessageContent ?? "Empty Coming Soon",
      'messageType': event.messageType, // text, image, video, audio
      'message': message, // URL or Text
      'duration': event.audioDuration ?? '',
      'senderUserName': senderUserName,
      'videoThumbnail': thumbnail,
      'date': DateTime.now().toString(),
      'uploadPercent': 100.0,
      'readStatus': "unread",
      'replyType': "text", // default
      'latitude': 0.0,
      'longitude': 0.0,
      'isReply': event.replyToMessageId != null ? 1 : 0,
      'isLocal': 0,
      'isAudioSelected': event.messageType == 'audio'
    };

    try {
      DocumentReference docRef = _firestore
          .collection('Chat2')
          .doc(state.currentRoomId)
          .collection('Messages')
          .doc(); // Auto-ID or use messageId? ChatScreen uses .doc(messageId) in some places but .doc() in uploadChatNew.
      // ChatScreen: .doc() -> Autogenerated ID
      await docRef.set(map);

      // Update Room Details (Last Message) - Use merge to avoid overwriting metadata
      DocumentReference roomRef =
          _firestore.collection('Chat2').doc(state.currentRoomId);
      await roomRef.set(map, SetOptions(merge: true));

      emit(state.copyWith(status: ChatStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
          status: ChatStatus.failure, errorMessage: "Send failed: $e"));
    }
  }

  Future<void> _onUpdateTypingStatus(
      UpdateTypingStatusEvent event, Emitter<ChatState> emit) async {
    if (state.currentRoomId.isNotEmpty) {
      final senderId = sharedPreferences!.getString(hopperIdKey) ?? "";
      _firestore
          .collection('Chat2')
          .doc(state.currentRoomId)
          .collection('Typing')
          .doc(senderId)
          .set({'isTyping': event.isTyping}, SetOptions(merge: true));
    }
  }

  Future<void> _onStartAudioRecording(
      StartAudioRecordingEvent event, Emitter<ChatState> emit) async {
    if (await _audioRecorder.hasPermission()) {
      final directory = await getApplicationDocumentsDirectory();
      String path =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(const RecordConfig(), path: path);
      emit(state.copyWith(isRecording: true)); // Local state for UI updates
    }
  }

  Future<void> _onStopAudioRecording(
      StopAudioRecordingEvent event, Emitter<ChatState> emit) async {
    if (!state.isRecording) return;
    final path = await _audioRecorder.stop();
    emit(state.copyWith(isRecording: false));
    if (path != null) {
      add(SendMessageEvent(message: "", messageType: "audio", filePath: path));
    }
  }

  Future<void> _onUpdateAppLifecycle(
      UpdateAppLifecycleEvent event, Emitter<ChatState> emit) async {
    final senderId = sharedPreferences!.getString(hopperIdKey) ?? "";
    if (senderId.isNotEmpty) {
      await _firestore.collection('OnlineOffline').doc(senderId).set({
        'isOnline': event.isOnline,
        'last_seen': DateTime.now().toUtc().toLocal(),
        'roomId': event.roomId,
      }, SetOptions(merge: true));
    }
  }

  void _onOtherUserTypingUpdated(
      OtherUserTypingUpdatedEvent event, Emitter<ChatState> emit) {
    emit(state.copyWith(isTyping: event.isTyping));
  }

  void _onOtherUserOnlineStatusUpdated(
      OtherUserOnlineStatusUpdatedEvent event, Emitter<ChatState> emit) {
    emit(state.copyWith(isOnline: event.isOnline));
  }
}
