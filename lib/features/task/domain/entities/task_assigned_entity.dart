import 'package:equatable/equatable.dart';

class TaskAssignedEntity extends Equatable {
  const TaskAssignedEntity({
    required this.code,
    required this.task,
    required this.resp,
  });
  final int code;
  final TaskAssignedDetailEntity task;
  final ChatRoomEntity resp;

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
  final bool isNeedPhoto;
  final bool isNeedVideo;
  final bool isNeedInterview;
  final String photoPrice;
  final String videoPrice;
  final String interviewPrice;
  final String currency;
  final String currencySymbol;
  final List<HopperInfoEntity> hopperInfo;
  final String hopperTaskAmount;
  final List<String> acceptedHoppers;
  final String distance;
  final String walkTime;
  final String driveTime;

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
    this.isNeedPhoto = false,
    this.isNeedVideo = false,
    this.isNeedInterview = false,
    this.photoPrice = "0",
    this.videoPrice = "0",
    this.interviewPrice = "0",
    this.currency = "",
    this.currencySymbol = "",
    this.hopperInfo = const [],
    this.hopperTaskAmount = "0",
    this.acceptedHoppers = const [],
    this.distance = "",
    this.walkTime = "",
    this.driveTime = "",
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
        isNeedPhoto,
        isNeedVideo,
        isNeedInterview,
        photoPrice,
        videoPrice,
        interviewPrice,
        currency,
        currencySymbol,
        hopperInfo,
        hopperTaskAmount,
        acceptedHoppers,
        distance,
        walkTime,
        driveTime,
      ];
}

class HopperInfoEntity extends Equatable {
  const HopperInfoEntity({
    required this.id,
    required this.type,
    required this.count,
    required this.hours,
  });
  final String id;
  final String type;
  final String count;
  final String hours;

  @override
  List<Object?> get props => [id, type, count, hours];
}

class MediaHouseEntity extends Equatable {
  const MediaHouseEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    required this.profileImage,
  });
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String role;
  final String profileImage;

  @override
  List<Object?> get props =>
      [id, firstName, lastName, email, phone, role, profileImage];
}

class AddressLocationEntity extends Equatable {
  const AddressLocationEntity({
    required this.type,
    required this.coordinates,
  });
  final String type;
  final List<double> coordinates;

  @override
  List<Object?> get props => [type, coordinates];
}

class TaskContentEntity extends Equatable {
  const TaskContentEntity({
    required this.media,
    required this.mediaType,
    required this.watermark,
    required this.hopperId,
    required this.imageId,
    required this.timeStamp,
  });
  final String media;
  final String mediaType;
  final String watermark;
  final String hopperId;
  final String imageId;
  final DateTime timeStamp;

  @override
  List<Object?> get props =>
      [media, mediaType, watermark, hopperId, imageId, timeStamp];
}

class ChatRoomEntity extends Equatable {
  const ChatRoomEntity({
    required this.id,
    required this.participants,
    required this.type,
    required this.roomId,
    required this.senderId,
    required this.taskId,
    required this.createdAt,
  });
  final String id;
  final List<String> participants;
  final String type;
  final String roomId;
  final String senderId;
  final String taskId;
  final DateTime createdAt;

  @override
  List<Object?> get props =>
      [id, participants, type, roomId, senderId, taskId, createdAt];
}
