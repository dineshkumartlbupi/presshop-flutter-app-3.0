import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/error/api_error_handler.dart';
import 'package:presshop/features/chat/data/models/chat_models.dart';
import 'package:presshop/main.dart';

class ChatRemoteDataSource {

  ChatRemoteDataSource(this.apiClient);
  final ApiClient apiClient;

  /// Helper to robustly extract data from various response structures
  dynamic _extractData(dynamic rawData) {
    if (rawData == null) return null;

    // Common keys used in the backend for the main payload
    final keys = [
      'response',
      'data',
      'resposne',
      'details',
      'resp',
      'messages'
    ];

    if (rawData is Map) {
      for (final key in keys) {
        if (rawData.containsKey(key) && rawData[key] != null) {
          return rawData[key];
        }
      }
    }

    // If no common key found, return the raw data itself (it might be the list)
    return rawData;
  }

  /// Fetches the list of chat rooms
  Future<List<ChatRoomModel>> getChatList(
      {int offset = 0, int limit = 50}) async {
    try {
      final response = await apiClient.post(
        ApiConstantsNew.chat.chatList,
        data: {'offset': offset, 'limit': limit},
      );

      final extracted = _extractData(response.data);
      if (extracted is List) {
        return extracted
            .map((json) =>
                ChatRoomModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("ChatRemoteDataSource: getChatList Error: $e");
      throw ApiErrorHandler.handle(e);
    }
  }

  /// Fetches message history for a specific room
  Future<List<ChatMessageModel>> getRoomHistory({
    required String roomId,
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstantsNew.chat.roomHistory,
        data: {
          'room_id': roomId,
          'offset': offset,
          'limit': limit,
        },
      );

      final hopperId =
          sharedPreferences!.getString(SharedPreferencesKeys.hopperIdKey) ?? "";
      final extracted = _extractData(response.data);
      if (extracted is List) {
        return extracted
            .map((json) => ChatMessageModel.fromJson(
                Map<String, dynamic>.from(json), hopperId))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("ChatRemoteDataSource: getRoomHistory Error: $e");
      throw ApiErrorHandler.handle(e);
    }
  }

  /// Uploads media and returns the remote URL(s)
  Future<List<String>> uploadChatMedia(String filePath) async {
    try {
      FormData formData = FormData();
      formData.files.add(MapEntry(
        "media[0]",
        await MultipartFile.fromFile(filePath),
      ));

      final response = await apiClient.multipartPost(
        ApiConstantsNew.content.uploadChatAttachment,
        formData: formData,
      );

      final data = response.data;
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle different key naming for URLs
        final urls = data['urls'] ?? data['media_urls'] ?? data['data'] ?? [];
        if (urls is List) {
          return List<String>.from(urls);
        }
      }
      return [];
    } catch (e) {
      debugPrint("ChatRemoteDataSource: uploadChatMedia Error: $e");
      throw ApiErrorHandler.handle(e);
    }
  }

  /// Creates a chat room (or gets existing)
  Future<String> createRoom({
    required String receiverId,
    required String roomType,
    String taskId = "",
    String type = "external_task",
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstantsNew.chat.createRoom,
        data: {
          "receiver_id": receiverId,
          "room_type": roomType,
          "type": type,
          "task_id": taskId,
        },
      );

      final data = _extractData(response.data);
      if (data is Map && data.containsKey('room_id')) {
        return data['room_id'].toString();
      }
      return "";
    } catch (e) {
      debugPrint("ChatRemoteDataSource: createRoom Error: $e");
      throw ApiErrorHandler.handle(e);
    }
  }
}
