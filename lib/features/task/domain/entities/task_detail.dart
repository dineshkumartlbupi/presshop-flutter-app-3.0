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

  TaskDetail copyWith({
    String? id,
    bool? isNeedPhoto,
    bool? isNeedVideo,
    bool? isNeedInterview,
    String? mode,
    String? type,
    String? status,
    String? paidStatus,
    DateTime? deadLine,
    String? mediaHouseId,
    String? mediaHouseImage,
    String? mediaHouseName,
    String? companyName,
    String? title,
    String? description,
    List<String>? acceptedBy,
    String? specialReq,
    String? location,
    String? photoPrice,
    String? videoPrice,
    String? interviewPrice,
    String? receivedAmount,
    double? latitude,
    double? longitude,
    String? role,
    String? categoryId,
    String? userId,
    String? createdAt,
    String? discountPercent,
    String? miles,
    String? byFeet,
    String? byCar,
    List<TaskMedia>? mediaList,
    String? broadcastLocation,
  }) {
    return TaskDetail(
      id: id ?? this.id,
      isNeedPhoto: isNeedPhoto ?? this.isNeedPhoto,
      isNeedVideo: isNeedVideo ?? this.isNeedVideo,
      isNeedInterview: isNeedInterview ?? this.isNeedInterview,
      mode: mode ?? this.mode,
      type: type ?? this.type,
      status: status ?? this.status,
      paidStatus: paidStatus ?? this.paidStatus,
      deadLine: deadLine ?? this.deadLine,
      mediaHouseId: mediaHouseId ?? this.mediaHouseId,
      mediaHouseImage: mediaHouseImage ?? this.mediaHouseImage,
      mediaHouseName: mediaHouseName ?? this.mediaHouseName,
      companyName: companyName ?? this.companyName,
      title: title ?? this.title,
      description: description ?? this.description,
      acceptedBy: acceptedBy ?? this.acceptedBy,
      specialReq: specialReq ?? this.specialReq,
      location: location ?? this.location,
      photoPrice: photoPrice ?? this.photoPrice,
      videoPrice: videoPrice ?? this.videoPrice,
      interviewPrice: interviewPrice ?? this.interviewPrice,
      receivedAmount: receivedAmount ?? this.receivedAmount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      role: role ?? this.role,
      categoryId: categoryId ?? this.categoryId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      discountPercent: discountPercent ?? this.discountPercent,
      miles: miles ?? this.miles,
      byFeet: byFeet ?? this.byFeet,
      byCar: byCar ?? this.byCar,
      mediaList: mediaList ?? this.mediaList,
      broadcastLocation: broadcastLocation ?? this.broadcastLocation,
    );
  }

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
