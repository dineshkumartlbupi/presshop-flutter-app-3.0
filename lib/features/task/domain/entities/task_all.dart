import 'package:equatable/equatable.dart';

class MediaHouseDetailsEntity extends Equatable {
  const MediaHouseDetailsEntity({
    required this.id,
    required this.fullName,
    required this.profileImage,
  });
  final String id;
  final String fullName;
  final String profileImage;

  @override
  List<Object?> get props => [id, fullName, profileImage];
}

class UploadContentsEntity extends Equatable {
  const UploadContentsEntity({
    required this.id,
    required this.videothubnail,
    required this.type,
    required this.imageAndVideo,
  });
  final String id;
  final String videothubnail;
  final String type;
  final String imageAndVideo;

  @override
  List<Object?> get props => [id, videothubnail, type, imageAndVideo];
}

class AcceptedTaskEntity extends Equatable {
  const AcceptedTaskEntity({
    required this.id,
    required this.taskId,
    required this.taskStatus,
    required this.hopperId,
    required this.createdAt,
    required this.updatedAt,
  });
  final String id;
  final String taskId;
  final String taskStatus;
  final String hopperId;
  final String createdAt;
  final String updatedAt;

  @override
  List<Object?> get props =>
      [id, taskId, taskStatus, hopperId, createdAt, updatedAt];
}

class TaskAll extends Equatable {
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
    this.isNeedPhoto = false,
    this.isNeedVideo = false,
    this.isNeedInterview = false,
    this.photoPrice = "0",
    this.videoPrice = "0",
    this.interviewPrice = "0",
    this.currency = "",
    this.currencySymbol = "",
  });
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
  final bool isNeedPhoto;
  final bool isNeedVideo;
  final bool isNeedInterview;
  final String photoPrice;
  final String videoPrice;
  final String interviewPrice;
  final String currency;
  final String currencySymbol;

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
        isNeedPhoto,
        isNeedVideo,
        isNeedInterview,
        photoPrice,
        videoPrice,
        interviewPrice,
        currency,
        currencySymbol,
      ];
}
