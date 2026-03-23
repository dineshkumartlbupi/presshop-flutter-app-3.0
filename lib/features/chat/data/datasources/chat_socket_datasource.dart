import 'package:flutter/foundation.dart';
import 'package:presshop/core/api/socket_constants.dart';
import 'package:presshop/core/api/global_socket_client.dart';

class ChatSocketDataSource {
  final GlobalSocketClient _client;

  ChatSocketDataSource({required GlobalSocketClient client}) : _client = client;

  Function(dynamic)? onChatMessage;
  Function(dynamic)? onMediaMessage;
  Function(dynamic)? onVoiceMessage;
  Function(dynamic)? onTyping;
  Function(dynamic)? onRoomJoin;
  Function(dynamic)? onAdminStatus;
  Function(dynamic)? onReadMessage;

  bool get isInitialized => _client.isInitialized;

  void initSocket({required String userId, required String userType}) {
    _client.initSocket(userId: userId, userType: userType);
  }

  void initializeListeners() {
    _client.on(SocketEvents.chatMessage, (data) {
      debugPrint("ChatSocketDataSource received chat message: $data");
      onChatMessage?.call(data);
    });

    _client.on(SocketEvents.mediaMessage, (data) {
      debugPrint("ChatSocketDataSource received media message: $data");
      onMediaMessage?.call(data);
    });

    _client.on(SocketEvents.voiceMessage, (data) {
      debugPrint("ChatSocketDataSource received voice message: $data");
      onVoiceMessage?.call(data);
    });

    _client.on(SocketEvents.typing, (data) {
      debugPrint("ChatSocketDataSource received typing: $data");
      // Add is_typing if missing
      if (data is Map && !data.containsKey('is_typing')) {
        final Map<String, dynamic> enrichedData =
            Map<String, dynamic>.from(data);
        enrichedData['is_typing'] = true;
        onTyping?.call(enrichedData);
      } else {
        onTyping?.call(data);
      }
    });

    _client.on(SocketEvents.stopTyping, (data) {
      debugPrint("ChatSocketDataSource received stop typing: $data");
      final Map<String, dynamic> stopData =
          (data is Map) ? Map<String, dynamic>.from(data) : {};
      stopData['is_typing'] = false;
      onTyping?.call(stopData);
    });

    _client.on(SocketEvents.roomJoin, (data) {
      debugPrint("ChatSocketDataSource received room join: $data");
      onRoomJoin?.call(data);
    });

    _client.on(SocketEvents.adminStatus, (data) {
      debugPrint("ChatSocketDataSource received adminStatus: $data");
      onAdminStatus?.call(data);
    });

    _client.on(SocketEvents.readMessage, (data) {
      debugPrint("ChatSocketDataSource received read message: $data");
      onReadMessage?.call(data);
    });
  }

  void joinRoom(String roomId) {
    debugPrint("ChatSocketDataSource emitting room join for: $roomId");
    _client.emit(SocketEvents.roomJoin, {'room_id': roomId});
  }

  void leaveRoom(String roomId) {
    debugPrint("ChatSocketDataSource emitting leave room for: $roomId");
    _client.emit(SocketEvents.leaveRoom, {'room_id': roomId});
  }

  void sendMessage(Map<String, dynamic> data) {
    debugPrint("ChatSocketDataSource emitting chat message: $data");
    _client.emit(SocketEvents.chatMessage, data);
  }

  void sendMediaMessage(Map<String, dynamic> data) {
    debugPrint("ChatSocketDataSource emitting media message: $data");
    _client.emit(SocketEvents.mediaMessage, data);
  }

  void sendVoiceMessage(Map<String, dynamic> data) {
    debugPrint("ChatSocketDataSource emitting voice message: $data");
    _client.emit(SocketEvents.voiceMessage, data);
  }

  void sendTypingStatus(String roomId, String userId, bool isTyping,
      {String? receiverId, String? typedValue}) {
    final data = {
      'room_id': roomId,
      'user_id': userId,
      'is_typing': isTyping,
      if (typedValue != null) 'typed_value': typedValue,
      if (receiverId != null) 'receiver_id': receiverId,
    };
    if (isTyping) {
      _client.emit(SocketEvents.typing, data);
    } else {
      _client.emit(SocketEvents.stopTyping, data);
    }
  }

  void markAsRead(String roomId, String userId, {String? receiverId}) {
    debugPrint("ChatSocketDataSource emitting read message for: $roomId");
    final data = {
      'room_id': roomId,
      'user_id': userId,
      if (receiverId != null) 'receiver_id': receiverId,
    };
    _client.emit(SocketEvents.readMessage, data);
  }

  void dispose() {
    _client.off(SocketEvents.chatMessage);
    _client.off(SocketEvents.mediaMessage);
    _client.off(SocketEvents.voiceMessage);
    _client.off(SocketEvents.typing);
    _client.off(SocketEvents.roomJoin);
    _client.off(SocketEvents.adminStatus);
    _client.off(SocketEvents.readMessage);
  }
}
