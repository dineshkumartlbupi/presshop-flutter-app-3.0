import '../../domain/entities/admin_detail.dart';

class AdminDetailModel extends AdminDetail {
  const AdminDetailModel({
    required super.id,
    required super.name,
    required super.profilePic,
    required super.lastMessageTime,
    required super.lastMessage,
    required super.roomId,
    required super.senderId,
    required super.receiverId,
    required super.roomType,
  });

  factory AdminDetailModel.fromJson(Map<String, dynamic> json) {
    var roomDetails = json["room_details"];
    bool hasRoomDetails = roomDetails != null && roomDetails is Map;

    return AdminDetailModel(
      id: (json["_id"] ?? "").toString(),
      name: (json["name"] ?? "").toString(),
      profilePic: (json["profile_image"] ?? "").toString(),
      lastMessageTime: '', // Logic from CommonModel
      lastMessage: '', // Logic from CommonModel
      roomId: hasRoomDetails ? (roomDetails['room_id'] ?? '').toString() : '',
      senderId:
          hasRoomDetails ? (roomDetails['sender_id'] ?? '').toString() : '',
      receiverId:
          hasRoomDetails ? (roomDetails['receiver_id'] ?? '').toString() : '',
      roomType:
          hasRoomDetails ? (roomDetails['room_type'] ?? '').toString() : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "profile_image": profilePic,
      "room_details": {
        "room_id": roomId,
        "sender_id": senderId,
        "receiver_id": receiverId,
        "room_type": roomType,
      }
    };
  }
}
