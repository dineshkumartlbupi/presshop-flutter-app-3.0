import 'package:equatable/equatable.dart';

class AdminDetail extends Equatable {
  final String id;
  final String name;
  final String profilePic;
  final String lastMessageTime;
  final String lastMessage;
  final String roomId;
  final String senderId;
  final String receiverId;
  final String roomType;

  const AdminDetail({
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

  @override
  List<Object?> get props => [id, name, profilePic, roomId, senderId, receiverId];
}
