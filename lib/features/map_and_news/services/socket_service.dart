import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presshop/utils/Common.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;
  final String _socketUrl = socketUrl;
  Function(dynamic)? onIncidentNew;
  Function(dynamic)? onIncidentUpdated;
  Function(dynamic)? onIncidentCreated;
  Function(dynamic)? onCommentNew;
  Function(dynamic)? onCommentLike;
  Function(dynamic)? onNewsShare;
  Function(dynamic)? onNewsLike;
  void initSocket({
    required String userId,
    required String joinAs, // "website" | "admin" | "hopper" | "user"
  }) {
    debugPrint(":::: Inside Socket Func :::::");
    debugPrint("socketUrl:::::$_socketUrl");

    socket = IO.io(
      _socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    debugPrint("Socket Disconnect : ${socket.disconnected}");

    socket.connect();

    socket.onConnect((_) {
      debugPrint('Connected to socket: ${socket.id}');
      print("::: Socket Connection SUCCESS ::: ID: ${socket.id}");

      if (joinAs == "website") socket.emit("joinWebsite");
      if (joinAs == "admin") socket.emit("joinAdmin", userId);
      if (joinAs == "hopper") socket.emit("joinHopper", userId);
      if (joinAs == "user") socket.emit("joinUser", userId);

      // socket.emit('add_hopper_comment', {
      //   'id': "385855634",
      //   'text': "text",
      //   'parent_id': null,
      //   'user_id': userId,
      // });
    });

    socket.onDisconnect((_) {
      debugPrint('Disconnected from socket');
      print("::: Socket Connection DISCONNECTED :::");
    });

    socket.onError((data) {
      debugPrint("Error Socket ::: $data");
      print("::: Socket Connection FAILURE ::: Error: $data");
    });

    // Listen for incident events
    socket.on("incident:new", (data) {
      debugPrint("Socket: incident:new received");
      onIncidentNew?.call(data);
    });

    socket.on("incident:updated", (data) {
      debugPrint("Socket: incident:updated received");
      onIncidentUpdated?.call(data);
    });

    socket.on("incident:created", (data) {
      debugPrint("Socket: incident:created receisdfdsved");
      debugPrint("incident:created: $data");

      onIncidentCreated?.call(data);
    });

    ///// Comments and Interaction Events
    socket.on("aggregated:comment:like", (like) {
      debugPrint("Socket: aggregated:comment:like received: $like");
      onCommentLike?.call(like);
    });

    socket.on("aggregated:news:like", (like) {
      debugPrint("Socket: aggregated:news:like received: $like");
      onNewsLike?.call(like);
    });

    socket.on("aggregated:comment:new", (comment) {
      debugPrint("Socket: aggregated:comment:new received: $comment");
      onCommentNew?.call(comment);
    });

    socket.on("aggregated:news:share", (share) {
      debugPrint("Socket: aggregated:news:share received: $share");
      onNewsShare?.call(share);
    });
  }

  void emitAlert({
    required String alertType,
    required LatLng position,
    String message = "",
    required String userId,
  }) {
    debugPrint(":::: Inside Socket Emit Alert :::::");
    print(":::: Inside Socket Emit Alert :::::");
    final Map<String, dynamic> data = {
      "userId": userId,
      "message": message,
      "type": alertType,
      "lat": position.latitude,
      "lng": position.longitude,
      "severity": "low",
    };

    debugPrint("Emit Socket Alert : $data");
    print("Emit Socket Alert : $data");

    socket.emit("incident:create", data);
  }

  void joinContent(String contentId) {
    debugPrint("Socket: Joining content room: $contentId");
    socket.emit("join:content", contentId);
  }

  void addComment({
    required String contentId,
    required String text,
    required String userId,
    String? parentId,
  }) {
    final data = {
      'id': contentId,
      'text': text,
      'parent_id': parentId,
      'user_id': userId,
    };
    debugPrint("Socket: Emitting add:aggregated:comment: $data");
    socket.emit('add:aggregated:comment', data);
  }

  void likeComment({
    required String contentId,
    required String commentId,
    required String userId,
  }) {
    final data = {
      "contentId": contentId,
      "commentId": commentId,
      "userId": userId,
    };
    debugPrint("Socket: Emitting add:aggregated:comment:like: $data");
    socket.emit("add:aggregated:comment:like", data);
  }

  void likeNews({
    required String userId,
    required String contentId,
  }) {
    final data = {
      "user_id": userId,
      "contentId": contentId,
    };
    debugPrint("Socket: Emitting add:aggregated:news:like: $data");
    socket.emit("add:aggregated:news:like", data);
  }

  void viewNews({
    required String contentId,
  }) {
    final data = {
      "contentId": contentId,
    };
    debugPrint("Socket: Emitting add:aggregated:news:view: $data");
    socket.emit("add:aggregated:news:view", data);
  }

  void shareNews({
    required String contentId,
  }) {
    final data = {
      "contentId": contentId,
    };
    debugPrint("Socket: Emitting add:aggregated:news:share: $data");
    socket.emit("add:aggregated:news:share", data);
  }

  void dispose() {
    socket.dispose();
  }
}
