import 'package:presshop/core/core_export.dart';
import '../../domain/entities/task_assigned_entity.dart';

class TaskAssignedResponseModel extends TaskAssignedEntity {
  TaskAssignedResponseModel({
    required this.success,
    required this.message,
    required this.data,
  }) : super(code: data.code, task: data.task, resp: data.resp);

  factory TaskAssignedResponseModel.fromJson(Map<String, dynamic> json) {
    return TaskAssignedResponseModel(
      success: json['success'],
      message: json['message'],
      data: TaskAssignedDataModel.fromJson(json['data']),
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
    return TaskAssignedDataModel(
      code: json['code'],
      task: TaskAssignedItemModel.fromJson(json['task']),
      resp: ChatRoomDataModel.fromJson(json['resp']),
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
    super.isNeedPhoto = false,
    super.isNeedVideo = false,
    super.isNeedInterview = false,
    super.photoPrice = "0",
    super.videoPrice = "0",
    super.interviewPrice = "0",
    super.currency = "",
    super.currencySymbol = "",
  });

  factory TaskAssignedItemModel.fromJson(Map<String, dynamic> json) {
    return TaskAssignedItemModel(
      id: json['_id'],
      mediaHouse: MediaHouseDataModel.fromJson(json['mediahouse_id']),
      deadlineDate: DateTime.parse(json['deadline_date']),
      heading: json['heading'],
      description: json['description'],
      location: json['location'],
      addressLocation:
          AddressLocationDataModel.fromJson(json['address_location']),
      status: json['status'],
      isDraft: json['is_draft'],
      paidStatus: json['paid_status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      content: (json['content'] as List)
          .map((e) => TaskContentDataModel.fromJson(e))
          .toList(),
      isNeedPhoto:
          (json["need_photos"] ?? "").toString().toLowerCase() == "true" ||
              (json["hopper_photo_price"] != null &&
                  json["hopper_photo_price"].toString() != "0"),
      isNeedVideo:
          (json["need_videos"] ?? "").toString().toLowerCase() == "true" ||
              (json["hopper_videos_price"] != null &&
                  json["hopper_videos_price"].toString() != "0"),
      isNeedInterview:
          (json["need_interview"] ?? "").toString().toLowerCase() == "true" ||
              (json["hopper_interview_price"] != null &&
                  json["hopper_interview_price"].toString() != "0"),
      photoPrice:
          (json["hopper_photo_price"] ?? json["photo_price"] ?? "0").toString(),
      videoPrice: (json["hopper_videos_price"] ?? json["videos_price"] ?? "0")
          .toString(),
      interviewPrice:
          (json["hopper_interview_price"] ?? json["interview_price"] ?? "0")
              .toString(),
      currency: (json['currency'] ?? '').toString(),
      currencySymbol: (json['currency_symbol'] != null &&
              json['currency_symbol'].toString().isNotEmpty)
          ? json['currency_symbol'].toString()
          : getCurrencySymbol(json['currency']?.toString()),
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
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      profileImage: json['profile_image'],
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
      type: json['type'],
      coordinates:
          List<double>.from(json['coordinates'].map((x) => x.toDouble())),
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
    return TaskContentDataModel(
      media: json['media'],
      mediaType: json['media_type'],
      watermark: json['watermark'],
      hopperId: json['hopper_id'],
      imageId: json['image_id'],
      timeStamp: DateTime.parse(json['time_stamp']),
    );
  }
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
      id: json['_id'],
      participants: List<String>.from(json['participants']),
      type: json['type'],
      roomId: json['room_id'],
      senderId: json['sender_id'],
      taskId: json['task_id'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
