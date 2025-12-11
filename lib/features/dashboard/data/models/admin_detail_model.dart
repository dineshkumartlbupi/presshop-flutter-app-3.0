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
    return AdminDetailModel(
      id: (json["_id"] ?? "").toString(),
      name: (json["name"] ?? "").toString(),
      profilePic: (json["profile_image"] ?? "").toString(),
      lastMessageTime: '', // Logic from CommonModel
      lastMessage: '', // Logic from CommonModel
      roomId: json["room_details"] != null ? json["room_details"]['room_id'] ?? '' : '',
      senderId: json["room_details"] != null ? json["room_details"]['sender_id'] ?? '' : '',
      receiverId: json["room_details"] != null ? json["room_details"]['receiver_id'] ?? '' : '',
      roomType: json["room_details"] != null ? json["room_details"]['room_type'] ?? '' : '',
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
