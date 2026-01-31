import 'package:equatable/equatable.dart';

class TaskAssignedEntity extends Equatable {
  final int code;
  final TaskAssignedDetailEntity task;
  final ChatRoomEntity resp;

  const TaskAssignedEntity({
    required this.code,
    required this.task,
    required this.resp,
  });

  @override
  List<Object?> get props => [code, task, resp];
}

class TaskAssignedDetailEntity extends Equatable {
  final String id;
  final MediaHouseEntity mediaHouse;
  final DateTime deadlineDate;
  final String heading;
  final String description;
  final String location;
  final AddressLocationEntity addressLocation;
  final String status;
  final bool isDraft;
  final String paidStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TaskContentEntity> content;

  const TaskAssignedDetailEntity({
    required this.id,
    required this.mediaHouse,
    required this.deadlineDate,
    required this.heading,
    required this.description,
    required this.location,
    required this.addressLocation,
    required this.status,
    required this.isDraft,
    required this.paidStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.content,
  });

  @override
  List<Object?> get props => [
        id,
        mediaHouse,
        deadlineDate,
        heading,
        description,
        location,
        addressLocation,
        status,
        isDraft,
        paidStatus,
        createdAt,
        updatedAt,
        content,
      ];
}

class MediaHouseEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String role;
  final String profileImage;

  const MediaHouseEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    required this.profileImage,
  });

  @override
  List<Object?> get props =>
      [id, firstName, lastName, email, phone, role, profileImage];
}

class AddressLocationEntity extends Equatable {
  final String type;
  final List<double> coordinates;

  const AddressLocationEntity({
    required this.type,
    required this.coordinates,
  });

  @override
  List<Object?> get props => [type, coordinates];
}

class TaskContentEntity extends Equatable {
  final String media;
  final String mediaType;
  final String watermark;
  final String hopperId;
  final String imageId;
  final DateTime timeStamp;

  const TaskContentEntity({
    required this.media,
    required this.mediaType,
    required this.watermark,
    required this.hopperId,
    required this.imageId,
    required this.timeStamp,
  });

  @override
  List<Object?> get props =>
      [media, mediaType, watermark, hopperId, imageId, timeStamp];
}

class ChatRoomEntity extends Equatable {
  final String id;
  final List<String> participants;
  final String type;
  final String roomId;
  final String senderId;
  final String taskId;
  final DateTime createdAt;

  const ChatRoomEntity({
    required this.id,
    required this.participants,
    required this.type,
    required this.roomId,
    required this.senderId,
    required this.taskId,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, participants, type, roomId, senderId, taskId, createdAt];
}
