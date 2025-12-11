import 'package:equatable/equatable.dart';

class MediaHouseDetailsEntity extends Equatable {
  final String id;
  final String fullName;
  final String profileImage;

  const MediaHouseDetailsEntity({
    required this.id,
    required this.fullName,
    required this.profileImage,
  });

  @override
  List<Object?> get props => [id, fullName, profileImage];
}

class UploadContentsEntity extends Equatable {
  final String id;
  final String videothubnail;
  final String type;
  final String imageAndVideo;

  const UploadContentsEntity({
    required this.id,
    required this.videothubnail,
    required this.type,
    required this.imageAndVideo,
  });

  @override
  List<Object?> get props => [id, videothubnail, type, imageAndVideo];
}

class AcceptedTaskEntity extends Equatable {
  final String id;
  final String taskId;
  final String taskStatus;
  final String hopperId;
  final String createdAt;
  final String updatedAt;

  const AcceptedTaskEntity({
    required this.id,
    required this.taskId,
    required this.taskStatus,
    required this.hopperId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, taskId, taskStatus, hopperId, createdAt, updatedAt];
}

class TaskAll extends Equatable {
  final String id;
  final String userId;
  final DateTime? deadlineDate;
  final String heading;
  final String createdAt;
  final String description;
  final String location;
  final String status;
  final List<AcceptedTaskEntity> acceptedTasks;
  final MediaHouseDetailsEntity? mediaHouseDetails;
  final UploadContentsEntity? uploadContents;

  const TaskAll({
    required this.id,
    required this.userId,
    this.deadlineDate,
    required this.heading,
    required this.createdAt,
    required this.description,
    required this.location,
    required this.status,
    this.acceptedTasks = const [],
    this.mediaHouseDetails,
    this.uploadContents,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        deadlineDate,
        heading,
        createdAt,
        description,
        location,
        status,
        acceptedTasks,
        mediaHouseDetails,
        uploadContents,
      ];
}
