import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:presshop/core/api/api_constant.dart';

class GlobalSocketClient {
  IO.Socket? _socket;
  final String _socketUrl = ApiConstantsNew.config.socketUrl2;

  IO.Socket get socket {
    if (_socket == null) {
      throw StateError('GlobalSocketClient: socket used before initialization');
    }
    return _socket!;
  }

  bool get isInitialized => _socket != null;
  bool get isConnected => _socket?.connected ?? false;

  void initSocket({required String userId, required String userType}) {
    if (_socket != null) {
      debugPrint(":::: Global Socket already initialized :::::");
      if (!_socket!.connected) {
        debugPrint(":::: Global Socket not connected, connecting... :::::");
        _socket!.connect();
      }
      return;
    }

    debugPrint(":::: Initializing Global Socket :::::");
    debugPrint("socketUrl:::::$_socketUrl");

    _socket = IO.io(
      _socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({
            'userId': userId,
            'userType': userType,
          })
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(3000)
          .setReconnectionAttempts(5)
          .build(),
    );

    debugPrint("Socket Disconnect : ${socket.disconnected}");

    socket.connect();

    socket.onConnect((_) {
      debugPrint('Connected to Global socket: ${socket.id}');
      print("::: Global Socket Connection SUCCESS ::: ID: ${socket.id}");

      if (userType == "website") socket.emit("joinWebsite");
      if (userType == "admin") socket.emit("joinAdmin", userId);
      if (userType == "hopper") socket.emit("joinHopper", userId);
      if (userType == "user") socket.emit("joinUser", userId);
    });

    socket.onDisconnect((_) {
      debugPrint('Disconnected from Global socket');
      print("::: Global Socket Connection DISCONNECTED :::");
    });

    socket.onError((data) {
      debugPrint("Error Global Socket ::: $data");
      print("::: Global Socket Connection FAILURE ::: Error: $data");
    });
    
    socket.on('reconnect_attempt', (data) {
      debugPrint("Global Socket Reconnect Attempt: $data");
    });

    socket.on('connect_error', (data) {
      debugPrint("Global Socket Connect Error: $data");
    });
  }

  void on(String event, dynamic Function(dynamic) callback) {
    if (isInitialized) {
      socket.on(event, callback);
    } else {
      debugPrint("GlobalSocketClient: Cannot listen to $event, socket not initialized");
    }
  }

  void off(String event) {
    if (isInitialized) {
      socket.off(event);
    }
  }

  void emit(String event, [dynamic data]) {
    if (!isInitialized) {
      debugPrint("GlobalSocketClient: Cannot emit $event, socket not initialized");
      return;
    }
    socket.emit(event, data);
  }

  void dispose() {
    if (_socket != null) {
      _socket!.dispose();
      _socket = null;
    }
  }
}
