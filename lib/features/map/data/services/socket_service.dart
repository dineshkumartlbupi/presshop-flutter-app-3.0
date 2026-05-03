// import 'package:flutter/foundation.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:presshop/core/api/api_constant.dart';
// import 'package:presshop/core/api/socket_constants.dart';

// import 'package:socket_io_client/socket_io_client.dart' as IO;

// class SocketService {
//   IO.Socket? _socket;
//   final String _socketUrl = ApiConstantsNew.config.socketUrl2;

//   IO.Socket get socket => _socket!;

//   bool get isInitialized => _socket != null;

//   Function(dynamic)? onIncidentNew;
//   Function(dynamic)? onIncidentUpdated;
//   Function(dynamic)? onIncidentCreated;
//   Function(dynamic)? onCommentNew;
//   Function(dynamic)? onCommentLike;
//   Function(dynamic)? onNewsShare;
//   Function(dynamic)? onNewsLike;
//   void initSocket({required String userId, required String joinAs}) {
//     if (_socket != null) {
//       debugPrint(":::: Socket already initialized :::::");
//       if (!_socket!.connected) {
//         debugPrint(":::: Socket not connected, connecting... :::::");
//         _socket!.connect();
//       }
//       return;
//     }

//     debugPrint(":::: Inside Socket Func :::::");
//     debugPrint("socketUrl:::::$_socketUrl");

//     _socket = IO.io(
//       _socketUrl,
//       IO.OptionBuilder()
//           .setTransports(['websocket', 'polling'])
//           .setQuery({
//             'userId': userId,
//             'userType': joinAs,
//           })
//           .disableAutoConnect()
//           .build(),
//     );

//     debugPrint("Socket Disconnect : ${socket.disconnected}");

//     socket.connect();

//     socket.onConnect((_) {
//       debugPrint('Connected to socket: ${socket.id}');
//       print("::: Socket Connection SUCCESS ::: ID: ${socket.id}");

//       if (joinAs == "website") socket.emit(SocketEvents.joinWebsite);
//       if (joinAs == "admin") socket.emit(SocketEvents.joinAdmin, userId);
//       if (joinAs == "hopper") socket.emit(SocketEvents.joinHopper, userId);
//       if (joinAs == "user") socket.emit(SocketEvents.joinUser, userId);

//       // Important: Rejoin news channel on every fresh connection
//       joinNewsAll();
//     });

//     socket.onDisconnect((_) {
//       debugPrint('Disconnected from socket');
//       print("::: Socket Connection DISCONNECTED :::");
//     });

//     socket.onError((data) {
//       debugPrint("Error Socket ::: $data");
//       print("::: Socket Connection FAILURE ::: Error: $data");
//     });

//     // Listen for incident events
//     socket.on(SocketEvents.incidentNew, (data) {
//       debugPrint(
//           "Socket: incident:new received (data length: ${data?.toString().length})");
//       onIncidentNew?.call(data);
//     });

//     socket.on(SocketEvents.incidentUpdated, (data) {
//       debugPrint(
//           "Socket: incident:updated received (data length: ${data?.toString().length})");
//       onIncidentUpdated?.call(data);
//     });

//     socket.on(SocketEvents.incidentCreated, (data) {
//       debugPrint(
//           "Socket: incident:created received (data length: ${data?.toString().length})");

//       onIncidentCreated?.call(data);
//     });

//     ///// Comments and Interaction Events
//     socket.on(SocketEvents.aggregatedCommentLike, (like) {
//       debugPrint("Socket: aggregated:comment:like received: $like");
//       onCommentLike?.call(like);
//     });

//     socket.on(SocketEvents.aggregatedNewsLike, (like) {
//       debugPrint("Socket: aggregated:news:like received: $like");
//       onNewsLike?.call(like);
//     });

//     socket.on(SocketEvents.aggregatedCommentNew, (comment) {
//       debugPrint("Socket: aggregated:comment:new received: $comment");
//       onCommentNew?.call(comment);
//     });

//     socket.on(SocketEvents.aggregatedNewsShare, (share) {
//       debugPrint("Socket: aggregated:news:share received: $share");
//       onNewsShare?.call(share);
//     });
//   }

//   void emitAlert({
//     required String alertType,
//     required LatLng position,
//     String message = "",
//     String address = "",
//     required String userId,
//   }) {
//     debugPrint(":::: Inside Socket Emit Alert :::::");
//     print(":::: Inside Socket Emit Alert :::::");
//     final Map<String, dynamic> data = {
//       "userId": userId,
//       "message": message,
//       "type": alertType,
//       "lat": position.latitude,
//       "lng": position.longitude,
//       "severity": "low",
//       "address": address,
//     };

//     debugPrint("Emit Socket Alert : $data");
//     print("Emit Socket Alert : $data");

//     if (!isInitialized) {
//       debugPrint("Socket: Cannot emit alert, socket not initialized");
//       return;
//     }
//     socket.emit(SocketEvents.incidentCreate, data);
//   }

//   void joinNewsAll() {
//     if (!isInitialized) {
//       debugPrint("Socket: Cannot join news:all room, socket not initialized");
//       return;
//     }
//     debugPrint("Socket: Joining news:all room");
//     socket.emit(SocketEvents.joinNewsAll);
//   }

//   void joinContent(String contentId) {
//     if (!isInitialized) {
//       debugPrint("Socket: Cannot join content room, socket not initialized");
//       return;
//     }
//     debugPrint("Socket: Joining content room: $contentId");
//     socket.emit(SocketEvents.joinContent, contentId);
//   }

//   void addComment({
//     required String contentId,
//     required String text,
//     required String userId,
//     String? parentId,
//     String? rootParentId,
//     String? replyToName,
//   }) {
//     final data = {
//       'id': contentId,
//       'text': text,
//       'parent_id': parentId,
//       'root_parent_id': rootParentId,
//       'user_id': userId,
//       'reply_to_user_name': replyToName != null ? '@$replyToName' : null,
//     };
//     if (!isInitialized) {
//       debugPrint("Socket: Cannot add comment, socket not initialized");
//       return;
//     }
//     debugPrint("Socket: Emitting add:aggregated:comment: $data");
//     socket.emit(SocketEvents.addAggregatedComment, data);
//   }

//   void likeComment({
//     required String contentId,
//     required String commentId,
//     required String userId,
//   }) {
//     final data = {
//       "contentId": contentId,
//       "commentId": commentId,
//       "userId": userId,
//     };
//     if (!isInitialized) {
//       debugPrint("Socket: Cannot like comment, socket not initialized");
//       return;
//     }
//     debugPrint("Socket: Emitting add:aggregated:comment:like: $data");
//     socket.emit(SocketEvents.addAggregatedCommentLike, data);
//   }

//   void likeNews({required String userId, required String contentId}) {
//     if (!isInitialized) {
//       debugPrint("Socket: Cannot like news, socket not initialized");
//       return;
//     }
//     final data = {"user_id": userId, "contentId": contentId};
//     debugPrint("Socket: Emitting add:aggregated:news:like: $data");
//     socket.emit(SocketEvents.addAggregatedNewsLike, data);
//   }

//   void viewNews({required String contentId}) {
//     if (!isInitialized) {
//       debugPrint("Socket: Cannot view news, socket not initialized");
//       return;
//     }
//     final data = {"contentId": contentId};
//     debugPrint("Socket: Emitting add:aggregated:news:view: $data");
//     socket.emit(SocketEvents.addAggregatedNewsView, data);
//   }

//   void shareNews({required String contentId, String? userId}) {
//     if (!isInitialized) {
//       debugPrint("Socket: Cannot share news, socket not initialized");
//       return;
//     }
//     final data = {
//       "contentId": contentId,
//       if (userId != null) "user_id": userId,
//     };
//     debugPrint("Socket: Emitting add:aggregated:news:share: $data");
//     socket.emit(SocketEvents.addAggregatedNewsShare, data);
//   }

//   void dispose() {
//     if (_socket != null) {
//       _socket!.dispose();
//       _socket = null;
//     }
//   }
// }
