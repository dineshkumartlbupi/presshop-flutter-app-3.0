import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/utils/common_utils.dart';
import '../../domain/entities/chat_entities.dart';

class ChatMessageModel extends ChatMessageEntity {

  ChatMessageModel({
    required super.id,
    required super.roomId,
    required super.message,
    required super.messageType,
    required super.senderId,
    required super.senderType,
    required super.senderName,
    required super.senderImage,
    required super.createdAt,
    required super.readStatus,
    required super.media,
    required super.isSender,
  });

  factory ChatMessageModel.fromJson(
      Map<String, dynamic> json, String currentUserId) {
    final senderDetails = json['sender_details'] ?? json['sender_data'] ?? {};
    final senderName = (senderDetails['name'] ??
            senderDetails['full_name'] ??
            "${senderDetails['first_name'] ?? ''} ${senderDetails['last_name'] ?? ''}")
        .toString()
        .trim();
    String senderId = (json['sender_id'] ?? json['user_id'] ?? '').toString();
    if (senderId.isEmpty && json['status'] == 'send') {
      senderId = currentUserId;
    }

    // Handle media list (fallback to 'content' if 'media' is missing)
    List<String> mediaList = [];
    final rawMedia = json['media'] ?? json['content'];

    if (rawMedia != null) {
      if (rawMedia is List) {
        mediaList = rawMedia
            .map((item) {
              if (item is Map) {
                return (item['media'] ?? item['url'] ?? item['content'] ?? '')
                    .toString();
              }
              return item.toString();
            })
            .where((s) => s.isNotEmpty)
            .toList();
      } else if (rawMedia is String && rawMedia.isNotEmpty) {
        mediaList = [rawMedia];
      }
    }

    String mType = (json['message_type'] ?? 'text').toString();
    if (mType == 'chat') {
      mType = 'text'; // Map API 'chat' type to UI 'text' type
    }

    // Automatically map generic 'media' type to 'image' or 'video' for UI compatibility
    if (mType == 'media' && mediaList.isNotEmpty) {
      final firstMedia = mediaList.first.toLowerCase();
      if (firstMedia.contains('.mp4') ||
          firstMedia.contains('.mov') ||
          firstMedia.contains('.m4v') ||
          firstMedia.contains('.avi')) {
        mType = 'video';
      } else {
        mType = 'image';
      }
    }

    return ChatMessageModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      roomId: (json['room_id'] ?? '').toString(),
      message: (json['message'] ?? '').toString().isNotEmpty
          ? (json['message'] ?? '').toString()
          : (mType == 'image' || mType == 'video' || mType == 'media') &&
                  mediaList.isNotEmpty
              ? mediaList.first
              : (json['message'] ?? '').toString(),
      messageType: mType,
      senderId: senderId,
      senderType: (json['sender_type'] ?? '').toString(),
      senderName: senderName.isNotEmpty ? senderName : "Unknown",
      senderImage:
          getMediaImageUrl((senderDetails['profile_image'] ?? '').toString()),
      createdAt: (json['createdAt'] ?? '').toString(),
      readStatus:
          (json['read_status'] ?? json['readStatus'] ?? 'unread').toString(),
      media: mediaList.map((e) => getMediaImageUrl(e)).toList(),
      isSender: senderId == currentUserId,
    );
  }
  final Map<String, dynamic> _uiState = {};

  /// Temporary compatibility for UI that still uses map-like access
  dynamic operator [](String key) {
    if (_uiState.containsKey(key)) return _uiState[key];
    switch (key) {
      case 'id':
      case '_id':
      case 'messageId':
        return id;
      case 'room_id':
      case 'roomId':
        return roomId;
      case 'message':
        return message;
      case 'message_type':
        return messageType;
      case 'sender_id':
        return senderId;
      case 'sender_type':
        return senderType;
      case 'sender_name':
        return senderName;
      case 'sender_image':
        return senderImage;
      case 'createdAt':
      case 'date':
        return createdAt;
      case 'read_status':
      case 'readStatus':
        return readStatus;
      case 'media':
        return media;
      case 'isSender':
        return isSender;
      case 'uploadPercent':
        return 100;
      case 'videoThumbnail':
        return (media.isNotEmpty && messageType == 'video') ? media.first : "";
      default:
        return null;
    }
  }

  void operator []=(String key, dynamic value) {
    _uiState[key] = value;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'room_id': roomId,
      'message': message,
      'message_type': messageType,
      'sender_id': senderId,
      'sender_type': senderType,
      'createdAt': createdAt,
      'read_status': readStatus,
      'media': media,
    };
  }
}

class ChatRoomModel extends ChatRoomEntity {
  const ChatRoomModel({
    required super.roomId,
    required super.receiverId,
    required super.receiverName,
    required super.receiverImage,
    required super.lastMessage,
    required super.lastMessageType,
    required super.lastMessageTime,
    required super.unreadCount,
    super.isOnline = false,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    final receiver = json['receiver_details'] ?? json['user_details'] ?? {};
    final receiverName = (receiver['name'] ??
            receiver['full_name'] ??
            "${receiver['first_name'] ?? ''} ${receiver['last_name'] ?? ''}")
        .toString()
        .trim();

    return ChatRoomModel(
      roomId: (json['room_id'] ?? '').toString(),
      receiverId: (receiver['_id'] ?? '').toString(),
      receiverName: receiverName.isNotEmpty ? receiverName : "Unknown",
      receiverImage:
          getMediaImageUrl((receiver['profile_image'] ?? '').toString()),
      lastMessage: (json['last_message'] ?? '').toString(),
      lastMessageType: (json['last_message_type'] ?? 'text').toString(),
      lastMessageTime:
          (json['updatedAt'] ?? json['createdAt'] ?? '').toString(),
      unreadCount: int.tryParse(json['unread_count']?.toString() ?? '0') ?? 0,
      isOnline: json['is_online'] == true,
    );
  }

  /// Temporary compatibility for UI that still uses map-like access
  dynamic operator [](String key) {
    switch (key) {
      case 'room_id':
      case 'roomId':
        return roomId;
      case 'receiver_id':
      case 'receiverId':
        return receiverId;
      case 'receiver_name':
      case 'receiverName':
        return receiverName;
      case 'receiver_image':
      case 'receiverImage':
        return receiverImage;
      case 'last_message':
        return lastMessage;
      case 'last_message_type':
        return lastMessageType;
      case 'last_message_time':
        return lastMessageTime;
      case 'unread_count':
        return unreadCount;
      case 'is_online':
        return isOnline;
      default:
        return null;
    }
  }
}
