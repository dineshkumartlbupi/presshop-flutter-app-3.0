import 'dart:convert';
import 'package:presshop/core/utils/safe_parser.dart';
import '../../domain/entities/task_assigned_entity.dart';

class TaskAssignedResponseModel extends TaskAssignedEntity {
  TaskAssignedResponseModel({
    required this.success,
    required this.message,
    required this.data,
  }) : super(code: data.code, task: data.task, resp: data.resp);

  factory TaskAssignedResponseModel.fromJson(Map<String, dynamic> json) {
    return TaskAssignedResponseModel(
      success: SafeParser.parseBool(json['success']),
      message: SafeParser.parseString(json['message']),
      data: TaskAssignedDataModel.fromJson(json['data'] ?? json),
    );
  }
  final bool success;
  final String message;
  final TaskAssignedDataModel data;
}

class TaskAssignedDataModel {
  TaskAssignedDataModel({
    required this.code,
    required this.task,
    required this.resp,
  });

  factory TaskAssignedDataModel.fromJson(Map<String, dynamic> json) {
    bool isFlattened = json.containsKey('_id') && !json.containsKey('task');
    List<HopperLocationModel> activeHoppersLocations = [];
    if (isFlattened) {
      final String effectiveRoomId =
          SafeParser.parseString(json['room_id'] ?? json['resp']?['room_id']);

      return TaskAssignedDataModel(
        code: 200,
        task: TaskAssignedItemModel.fromJson(json),
        resp: ChatRoomDataModel(
            id: effectiveRoomId.isNotEmpty ? effectiveRoomId : "dummy",
            participants: const [],
            type: "",
            roomId: effectiveRoomId,
            senderId: "",
            taskId: SafeParser.parseString(json['_id']),
            createdAt: DateTime.now()),
      );
    }

    return TaskAssignedDataModel(
      code: SafeParser.parseInt(json['code']),
      task: TaskAssignedItemModel.fromJson(json['task'] ?? {}),
      resp: (json['resp'] != null && json['resp'] is Map)
          ? ChatRoomDataModel.fromJson(json['resp'])
          : ChatRoomDataModel(
              id: "dummy",
              participants: [],
              type: "",
              roomId: "",
              senderId: "",
              taskId: "",
              createdAt: DateTime.now()),
    );
  }
  final int code;
  final TaskAssignedItemModel task;
  final ChatRoomDataModel resp;
}

class TaskAssignedItemModel extends TaskAssignedDetailEntity {
  const TaskAssignedItemModel({
    required super.id,
    required MediaHouseDataModel super.mediaHouse,
    required super.deadlineDate,
    required super.heading,
    required super.description,
    required super.location,
    required AddressLocationDataModel super.addressLocation,
    required super.status,
    required super.isDraft,
    required super.paidStatus,
    required super.createdAt,
    required super.updatedAt,
    required List<TaskContentDataModel> super.content,
    super.isNeedPhoto,
    super.isNeedVideo,
    super.isNeedInterview,
    super.photoPrice,
    super.videoPrice,
    super.interviewPrice,
    super.currency,
    super.currencySymbol,
    List<HopperInfoDataModel> super.hopperInfo = const [],
    super.hopperTaskAmount,
    super.hopperLocation,
    super.activeHoppersCount,
    super.activeHoppersLocations,
    super.acceptedHoppers,
    super.distance,
    super.walkTime,
    super.driveTime,
    super.specialRequirements,
    super.preferences,
  });

  factory TaskAssignedItemModel.fromJson(Map<String, dynamic> json) {
    return TaskAssignedItemModel(
      id: SafeParser.parseString(json['_id']),
      mediaHouse: (json['mediahouse_id'] != null &&
              (json['mediahouse_id'] is Map || json['mediahouse_id'] is String))
          ? (json['mediahouse_id'] is String)
              ? MediaHouseDataModel(
                  id: SafeParser.parseString(json['mediahouse_id']),
                  firstName: "",
                  lastName: "",
                  email: "",
                  phone: "",
                  role: "",
                  profileImage: "")
              : MediaHouseDataModel.fromJson(json['mediahouse_id'])
          : MediaHouseDataModel(
              id: "",
              firstName: "",
              lastName: "",
              email: "",
              phone: "",
              role: "",
              profileImage: ""),
      deadlineDate: SafeParser.parseDateTime(json['deadline_date']),
      heading: SafeParser.parseString(json['heading']),
      description: SafeParser.parseString(json['description']),
      location: SafeParser.parseString(json['location']),
      addressLocation: (json['address_location'] is String)
          ? AddressLocationDataModel.fromJson(
              jsonDecode(json['address_location']))
          : AddressLocationDataModel.fromJson(json['address_location'] ?? {}),
      status: SafeParser.parseString(json['status']),
      isDraft: SafeParser.parseBool(json['is_draft']),
      paidStatus: SafeParser.parseString(json['paid_status']),
      createdAt: SafeParser.parseDateTime(json['createdAt']),
      updatedAt: SafeParser.parseDateTime(json['updatedAt']),
      content: SafeParser.parseList<TaskContentDataModel>(
          json['content'], (e) => TaskContentDataModel.fromJson(e ?? {})),
      isNeedPhoto: SafeParser.parseBool(json['need_photos']),
      isNeedVideo: SafeParser.parseBool(json['need_videos']),
      isNeedInterview: SafeParser.parseBool(json['need_interview']),
      photoPrice: SafeParser.parseString(
          json['hopper_photo_price'] ?? json['photo_price'],
          defaultValue: "0"),
      videoPrice: SafeParser.parseString(
          json['hopper_videos_price'] ?? json['hopper_video_price'],
          defaultValue: "0"),
      interviewPrice: SafeParser.parseString(
          json['hopper_interview_price'] ?? json['interview_price'],
          defaultValue: "0"),
      currency: SafeParser.parseString(json['currency']),
      currencySymbol: SafeParser.parseString(
          json['currency_symbol'] ?? json['currencySymbol']),
      hopperInfo: SafeParser.parseList<HopperInfoDataModel>(
          json['hopperInfo'], (e) => HopperInfoDataModel.fromJson(e ?? {})),
      hopperTaskAmount: SafeParser.parseString(json['hopperTaskAmount']),
      // hopperLocation: SafeParser.parseList<HopperLocationModel>(
      //   json['hopperLocation'],
      //   (e) => HopperLocationModel.fromJson(e ?? {}),
      // ),
      acceptedHoppers: SafeParser.parseList<String>(
          json['accepted_hoppers'], (e) => SafeParser.parseString(e)),
      distance: SafeParser.parseString(json['distance'] ?? json['miles'] ?? ""),
      walkTime: SafeParser.parseString(
          json['timeByWalking'] ?? json['by_feet'] ?? json['walk_time'] ?? ""),
      driveTime: SafeParser.parseString(
          json['timeByDriving'] ?? json['by_car'] ?? json['drive_time'] ?? ""),
      hopperLocation: (json['hopperLocation'] is String)
          ? HopperLocationModel.fromJson(jsonDecode(json['hopperLocation']))
          : (json['hopperLocation'] != null
              ? HopperLocationModel.fromJson(json['hopperLocation'])
              : null),
      activeHoppersLocations: SafeParser.parseList<HopperLocationModel>(
          json['active_hopper_locations'] ??
              json['active_hoppers_location'] ??
              json['active_hoppers_locations'],
          (e) => HopperLocationModel.fromJson(e ?? {})),
      activeHoppersCount: SafeParser.parseInt(json['active_hoppers'] ??
          json['hopperCount'] ??
          json['assignedHoppers'] ??
          SafeParser.parseList<HopperLocationModel>(
              json['active_hopper_locations'] ??
                  json['active_hoppers_location'] ??
                  json['active_hoppers_locations'],
              (e) => HopperLocationModel.fromJson(e ?? {})).length),
      specialRequirements: SafeParser.parseString(
          json['special_requirements'] ?? json['specialRequirements']),
      preferences: (json['preferences'] is Map<String, dynamic>)
          ? json['preferences']
          : null,
    );
  }
}

class HopperInfoDataModel extends HopperInfoEntity {
  const HopperInfoDataModel({
    required super.id,
    required super.type,
    required super.count,
    required super.hours,
  });

  factory HopperInfoDataModel.fromJson(Map<String, dynamic> json) {
    return HopperInfoDataModel(
      id: SafeParser.parseString(json['id']),
      type: SafeParser.parseString(json['type']),
      count: SafeParser.parseString(json['count']),
      hours: SafeParser.parseString(json['hours']),
    );
  }
}

class MediaHouseDataModel extends MediaHouseEntity {
  const MediaHouseDataModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    required super.role,
    required super.profileImage,
  });

  factory MediaHouseDataModel.fromJson(Map<String, dynamic> json) {
    return MediaHouseDataModel(
      id: SafeParser.parseString(json['_id'] ?? json['id']),
      firstName:
          SafeParser.parseString(json['firstName'] ?? json['first_name']),
      lastName: SafeParser.parseString(json['lastName'] ?? json['last_name']),
      email: SafeParser.parseString(json['email']),
      phone: SafeParser.parseString(json['phone']),
      role: SafeParser.parseString(json['role']),
      profileImage:
          SafeParser.parseString(json['profile_image'] ?? json['profileImage']),
    );
  }
}

class AddressLocationDataModel extends AddressLocationEntity {
  const AddressLocationDataModel({
    required super.type,
    required super.coordinates,
  });

  factory AddressLocationDataModel.fromJson(Map<String, dynamic> json) {
    return AddressLocationDataModel(
      type: SafeParser.parseString(json['type']),
      coordinates: SafeParser.parseList<double>(
          json['coordinates'], (x) => SafeParser.parseDouble(x)),
    );
  }
}

class TaskContentDataModel extends TaskContentEntity {
  const TaskContentDataModel({
    required super.media,
    required super.mediaType,
    required super.watermark,
    required super.hopperId,
    required super.imageId,
    required super.timeStamp,
  });

  factory TaskContentDataModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> contentMap =
        (json['content'] != null && json['content'] is Map)
            ? json['content']
            : json;

    String mType =
        SafeParser.parseString(contentMap['media_type'] ?? json['media_type'])
            .toLowerCase();

    return TaskContentDataModel(
      media: SafeParser.parseString(contentMap['media'] ?? json['media']),
      mediaType: mType.contains("video")
          ? "video"
          : mType.contains("audio")
              ? "audio"
              : "image",
      watermark: SafeParser.parseString(contentMap['watermark'] ??
          contentMap['thumbnail'] ??
          json['watermark']),
      hopperId: SafeParser.parseString(json['hopper_id']),
      imageId: SafeParser.parseString(
          json['imageId'] ?? json['image_id'] ?? json['_id']),
      timeStamp:
          SafeParser.parseDateTime(json['time_stamp'] ?? json['createdAt']),
    );
  }
}

class HopperLocationModel {
  HopperLocationModel({
    this.id = "",
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.avatar = "",
  });

  HopperLocationModel.fromJson(Map<String, dynamic> json) {
    id = (json["id"] ?? "").toString();
    latitude = double.tryParse((json["latitude"] ?? "0.0").toString()) ?? 0.0;
    longitude = double.tryParse((json["longitude"] ?? "0.0").toString()) ?? 0.0;
    avatar = (json["avatarImage"] ?? json["avatar"] ?? "").toString();

    // Auto-fix for swapped coordinates (Latitude cannot exceed 90 degrees)
    if (latitude.abs() > 90 && longitude.abs() <= 90) {
      double temp = latitude;
      latitude = longitude;
      longitude = temp;
    }
  }
  String id = "";
  double latitude = 0.0;
  double longitude = 0.0;
  String avatar = "";
}

class ChatRoomDataModel extends ChatRoomEntity {
  const ChatRoomDataModel({
    required super.id,
    required super.participants,
    required super.type,
    required super.roomId,
    required super.senderId,
    required super.taskId,
    required super.createdAt,
  });

  factory ChatRoomDataModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomDataModel(
      id: SafeParser.parseString(json['_id'] ?? json['room_id']),
      participants: SafeParser.parseList<String>(
          json['participants'], (e) => SafeParser.parseString(e)),
      type: SafeParser.parseString(json['type']),
      roomId: SafeParser.parseString(json['room_id']),
      senderId: SafeParser.parseString(json['sender_id']),
      taskId: SafeParser.parseString(json['task_id']),
      createdAt: SafeParser.parseDateTime(json['createdAt']),
    );
  }
}
