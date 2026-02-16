import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:presshop/core/api/api_constant.dart';

class ChatSocketService {
  IO.Socket? _socket;
  final String _socketUrl = ApiConstantsNew.config.socketUrl2;

  IO.Socket get socket {
    if (_socket == null) {
      throw StateError('ChatSocketService: socket used before initSocket()');
    }
    return _socket!;
  }

  bool get _isSocketInitialized => _socket != null;

  Function(dynamic)? onChatMessage;
  Function(dynamic)? onMediaMessage;
  Function(dynamic)? onVoiceMessage;
  Function(dynamic)? onTyping;
  Function(dynamic)? onRoomJoin;
  Function(dynamic)? onConnect;
  Function(dynamic)? onDisconnect;
  Function(dynamic)? onAdminStatus;
  Function(dynamic)? onReadMessage;

  void initSocket({required String userId, required String userType}) {
    if (_socket != null && _socket!.connected) {
      debugPrint(":::: Chat Socket already initialized and connected :::::");
      return;
    }

    debugPrint(":::: Initializing Chat Socket :::::");
    debugPrint("socketUrl: $_socketUrl");
    debugPrint("userId: $userId, userType: $userType");

    _socket = IO.io(
      _socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'userId': userId, 'userType': userType})
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      debugPrint('Chat Socket Connected: ${socket.id}');
      if (userType == "hopper") {
        socket.emit("joinHopper", userId);
      } else if (userType == "admin") {
        socket.emit("joinAdmin", userId);
      }
      onConnect?.call(_);
    });

    socket.onDisconnect((_) {
      debugPrint('Chat Socket Disconnected');
      onDisconnect?.call(_);
    });

    socket.onError((data) {
      debugPrint("Chat Socket Error: $data");
    });

    // Listeners
    socket.on('chat message', (data) {
      debugPrint("Socket received chat message: $data");
      onChatMessage?.call(data);
    });

    socket.on('media message', (data) {
      debugPrint("Socket received media message: $data");
      onMediaMessage?.call(data);
    });

    socket.on('voice message', (data) {
      debugPrint("Socket received voice message: $data");
      onVoiceMessage?.call(data);
    });

    socket.on('typing', (data) {
      debugPrint("Socket received typing: $data");
      onTyping?.call(data);
    });

    socket.on('room join', (data) {
      debugPrint("Socket received room join: $data");
      onRoomJoin?.call(data);
    });

    socket.on('adminStatus', (data) {
      debugPrint("Socket received adminStatus: $data");
      onAdminStatus?.call(data);
    });

    socket.on('read message', (data) {
      debugPrint("Socket received read message: $data");
      onReadMessage?.call(data);
    });
  }

  void joinRoom(String roomId) {
    if (!_isSocketInitialized) return;
    debugPrint("Socket emitting room join for: $roomId");
    socket.emit('room join', {'room_id': roomId});
  }

  void leaveRoom(String roomId) {
    if (!_isSocketInitialized) return;
    debugPrint("Socket emitting leave room for: $roomId");
    socket.emit('leave room', {'room_id': roomId});
  }

  void sendMessage(Map<String, dynamic> data) {
    if (!_isSocketInitialized) {
      debugPrint("Socket NOT initialized, cannot send message. Data: $data");
      return;
    }
    debugPrint("Socket emitting chat message: $data");
    socket.emit('chat message', data);
  }

  void sendMediaMessage(Map<String, dynamic> data) {
    if (!_isSocketInitialized) return;
    debugPrint("Socket emitting media message: $data");
    socket.emit('media message', data);
  }

  void sendVoiceMessage(Map<String, dynamic> data) {
    if (!_isSocketInitialized) return;
    debugPrint("Socket emitting voice message: $data");
    socket.emit('voice message', data);
  }

  void sendTypingStatus(String roomId, String userId, bool isTyping,
      {String? receiverId}) {
    if (!_isSocketInitialized) return;
    final data = {
      'room_id': roomId,
      'user_id': userId,
      if (receiverId != null) 'receiver_id': receiverId,
    };
    if (isTyping) {
      socket.emit('typing', data);
    } else {
      socket.emit('stop typing', data);
    }
  }

  void markAsRead(String roomId, String userId, {String? receiverId}) {
    if (!_isSocketInitialized) return;
    debugPrint("Socket emitting read message for: $roomId");
    socket.emit('read message', {
      'room_id': roomId,
      'user_id': userId,
      if (receiverId != null) 'receiver_id': receiverId,
    });
  }

  void dispose() {
    if (_isSocketInitialized) {
      socket.dispose();
    }
  }
}
