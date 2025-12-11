import 'package:equatable/equatable.dart';
import 'task_media.dart';

class TaskDetail extends Equatable {
  final String id;
  final bool isNeedPhoto;
  final bool isNeedVideo;
  final bool isNeedInterview;
  final String mode;
  final String type;
  final String status;
  final String paidStatus;
  final DateTime deadLine;
  final String mediaHouseId;
  final String mediaHouseImage;
  final String mediaHouseName;
  final String companyName;
  final String title;
  final String description;
  final List<String> acceptedBy;
  final String specialReq;
  final String location;
  final String photoPrice;
  final String videoPrice;
  final String interviewPrice;
  final String receivedAmount;
  final double latitude;
  final double longitude;
  final String role;
  final String categoryId;
  final String userId;
  final String createdAt;
  final String discountPercent;
  final String miles;
  final String byFeet;
  final String byCar;
  final List<TaskMedia> mediaList;
  final String broadcastLocation;

  const TaskDetail({
    required this.id,
    this.isNeedPhoto = false,
    this.isNeedVideo = false,
    this.isNeedInterview = false,
    this.mode = "",
    this.type = "",
    this.status = "",
    this.paidStatus = "",
    required this.deadLine,
    this.mediaHouseId = "",
    this.mediaHouseImage = "",
    this.mediaHouseName = "",
    this.companyName = "",
    this.title = "",
    this.description = "",
    this.acceptedBy = const [],
    this.specialReq = "",
    this.location = "",
    this.photoPrice = "",
    this.videoPrice = "",
    this.interviewPrice = "",
    this.receivedAmount = "",
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.role = "",
    this.categoryId = "",
    this.userId = "",
    this.createdAt = "",
    this.discountPercent = "",
    this.miles = "",
    this.byFeet = "",
    this.byCar = "",
    this.mediaList = const [],
    this.broadcastLocation = "",
  });

  @override
  List<Object?> get props => [
        id,
        isNeedPhoto,
        isNeedVideo,
        isNeedInterview,
        mode,
        type,
        status,
        paidStatus,
        deadLine,
        mediaHouseId,
        mediaHouseName,
        title,
        description,
        location,
        createdAt,
        mediaList,
      ];
}
