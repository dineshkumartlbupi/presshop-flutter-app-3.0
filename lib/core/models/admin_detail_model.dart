
class AdminDetailModel {
  String id = "";
  String name = "";
  String profilePic = "";
  String lastMessageTime = "";
  String lastMessage = "";
  String roomId = "";
  String senderId = "";
  String receiverId = "";
  String roomType = "";

  AdminDetailModel({
    required this.id,
    required this.name,
    required this.profilePic,
    required this.lastMessageTime,
    required this.lastMessage,
    required this.roomId,
    required this.senderId,
    required this.receiverId,
    required this.roomType,
  });

  AdminDetailModel.fromJson(Map<String, dynamic> json) {
    id = (json["_id"] ?? "").toString();
    name = (json["name"] ?? "").toString();
    profilePic = (json["profile_image"] ?? "").toString();
    lastMessageTime = '';
    lastMessage = '';
    roomId =
        json["room_details"] != null ? json["room_details"]['room_id'] : '';
    senderId =
        json["room_details"] != null ? json["room_details"]['sender_id'] : '';
    receiverId =
        json["room_details"] != null ? json["room_details"]['receiver_id'] : '';
    roomType =
        json["room_details"] != null ? json["room_details"]['room_type'] : '';
  }
}
