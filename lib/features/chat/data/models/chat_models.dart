import '../../domain/entities/chat_entities.dart';

class ChatMessageModel extends ChatMessageEntity {
  final Map<String, dynamic> _uiState = {};

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

  factory ChatMessageModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    final senderDetails = json['sender_details'] ?? {};
    final senderName = senderDetails['name'] ?? 
                      "${senderDetails['first_name'] ?? ''} ${senderDetails['last_name'] ?? ''}".trim();
    final senderId = (json['sender_id'] ?? '').toString();

    // Handle media list (fallback to 'content' if 'media' is missing)
    List<String> mediaList = [];
    if (json['media'] != null && json['media'] is List) {
      mediaList = List<String>.from(json['media']);
    } else if (json['content'] != null) {
      if (json['content'] is List) {
        mediaList = List<String>.from(json['content']);
      } else if (json['content'] is String && json['content'].toString().isNotEmpty) {
        mediaList = [json['content'].toString()];
      }
    }

    String mType = (json['message_type'] ?? 'text').toString();
    
    // Automatically map generic 'media' type to 'image' or 'video' for UI compatibility
    if (mType == 'media' && mediaList.isNotEmpty) {
      final firstMedia = mediaList.first.toLowerCase();
      if (firstMedia.endsWith('.mp4') || 
          firstMedia.endsWith('.mov') || 
          firstMedia.endsWith('.m4v') ||
          firstMedia.endsWith('.avi')) {
        mType = 'video';
      } else {
        mType = 'image';
      }
    }

    return ChatMessageModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      roomId: (json['room_id'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      messageType: mType,
      senderId: senderId,
      senderType: (json['sender_type'] ?? '').toString(),
      senderName: senderName.isNotEmpty ? senderName : "Unknown",
      senderImage: (senderDetails['profile_image'] ?? '').toString(),
      createdAt: (json['createdAt'] ?? '').toString(),
      readStatus: (json['read_status'] ?? json['readStatus'] ?? 'unread').toString(),
      media: mediaList,
      isSender: senderId == currentUserId,
    );
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
  ChatRoomModel({
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

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    final receiver = json['receiver_details'] ?? json['user_details'] ?? {};
    final receiverName = receiver['name'] ?? 
                        "${receiver['first_name'] ?? ''} ${receiver['last_name'] ?? ''}".trim();

    return ChatRoomModel(
      roomId: (json['room_id'] ?? '').toString(),
      receiverId: (receiver['_id'] ?? '').toString(),
      receiverName: receiverName.isNotEmpty ? receiverName : "Unknown",
      receiverImage: (receiver['profile_image'] ?? '').toString(),
      lastMessage: (json['last_message'] ?? '').toString(),
      lastMessageType: (json['last_message_type'] ?? 'text').toString(),
      lastMessageTime: (json['updatedAt'] ?? json['createdAt'] ?? '').toString(),
      unreadCount: int.tryParse(json['unread_count']?.toString() ?? '0') ?? 0,
      isOnline: json['is_online'] == true,
    );
  }
}
