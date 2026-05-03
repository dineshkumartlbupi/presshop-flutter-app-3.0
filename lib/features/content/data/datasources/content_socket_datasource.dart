import 'package:flutter/foundation.dart';
import 'package:presshop/core/api/global_socket_client.dart';

abstract class ContentSocketDataSource {
  void recordContentView({required String contentId, required String userId});
  void listenToViewRecorded({required Function(Map<String, dynamic>) onData});
  void stopListeningToViewRecorded();
  void initSocket({required String userId, required String userType});
}

class ContentSocketDataSourceImpl implements ContentSocketDataSource {
  final GlobalSocketClient socketClient;

  ContentSocketDataSourceImpl({required this.socketClient});

  @override
  void initSocket({required String userId, required String userType}) {
    socketClient.initSocket(userId: userId, userType: userType);
  }

  @override
  void recordContentView({required String contentId, required String userId}) {
    debugPrint(
        ":::: Emitting add:content:view:recorded for contentId: $contentId ::::");
    socketClient.emit('add:content:view:recorded', {
      'contentId': contentId,
      'user_id': userId,
    });
  }

  @override
  void listenToViewRecorded({required Function(Map<String, dynamic>) onData}) {
    debugPrint(":::: Listening to content:view:recorded ::::");
    socketClient.on('content:view:recorded', (data) {
      debugPrint(":::: Received content:view:recorded event :::: $data");
      if (data is Map<String, dynamic>) {
        onData(data);
      } else if (data is String) {
        try {} catch (e) {
          debugPrint("Error parsing socket data: $e");
        }
      }
    });
  }

  @override
  void stopListeningToViewRecorded() {
    socketClient.off('content:view:recorded');
  }
}
