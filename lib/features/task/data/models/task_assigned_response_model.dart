import 'dart:convert';
import 'package:presshop/core/utils/safe_parser.dart';
import '../../domain/entities/task_assigned_entity.dart';

class TaskAssignedResponseModel extends TaskAssignedEntity {
  final bool success;
  final String message;
  final TaskAssignedDataModel data;

  TaskAssignedResponseModel({
    required this.success,
    required this.message,
    required this.data,
  }) : super(code: data.code, task: data.task, resp: data.resp);

  factory TaskAssignedResponseModel.fromJson(Map<String, dynamic> json) {
    return TaskAssignedResponseModel(
      success: SafeParser.parseBool(json['success']),
      message: SafeParser.parseString(json['message']),
      data: TaskAssignedDataModel.fromJson(json['data']),
    );
  }
}

class TaskAssignedDataModel {
  final int code;
  final TaskAssignedItemModel task;
  final ChatRoomDataModel resp;

  TaskAssignedDataModel({
    required this.code,
    required this.task,
    required this.resp,
  });

  factory TaskAssignedDataModel.fromJson(Map<String, dynamic> json) {
    return TaskAssignedDataModel(
      code: SafeParser.parseInt(json['code']),
      task: TaskAssignedItemModel.fromJson(json['task']),
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
}

class TaskAssignedItemModel extends TaskAssignedDetailEntity {
  TaskAssignedItemModel({
    required String id,
    required MediaHouseDataModel mediaHouse,
    required DateTime deadlineDate,
    required String heading,
    required String description,
    required String location,
    required AddressLocationDataModel addressLocation,
    required String status,
    required bool isDraft,
    required String paidStatus,
    required DateTime createdAt,
    required DateTime updatedAt,
    required List<TaskContentDataModel> content,
  }) : super(
          id: id,
          mediaHouse: mediaHouse,
          deadlineDate: deadlineDate,
          heading: heading,
          description: description,
          location: location,
          addressLocation: addressLocation,
          status: status,
          isDraft: isDraft,
          paidStatus: paidStatus,
          createdAt: createdAt,
          updatedAt: updatedAt,
          content: content,
        );

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
          : AddressLocationDataModel.fromJson(json['address_location']),
      status: SafeParser.parseString(json['status']),
      isDraft: SafeParser.parseBool(json['is_draft']),
      paidStatus: SafeParser.parseString(json['paid_status']),
      createdAt: SafeParser.parseDateTime(json['createdAt']),
      updatedAt: SafeParser.parseDateTime(json['updatedAt']),
      content: SafeParser.parseList<TaskContentDataModel>(
          json['content'], (e) => TaskContentDataModel.fromJson(e)),
    );
  }
}

class MediaHouseDataModel extends MediaHouseEntity {
  MediaHouseDataModel({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String role,
    required String profileImage,
  }) : super(
          id: id,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          role: role,
          profileImage: profileImage,
        );

  factory MediaHouseDataModel.fromJson(Map<String, dynamic> json) {
    return MediaHouseDataModel(
      id: SafeParser.parseString(json['_id']),
      firstName: SafeParser.parseString(json['firstName']),
      lastName: SafeParser.parseString(json['lastName']),
      email: SafeParser.parseString(json['email']),
      phone: SafeParser.parseString(json['phone']),
      role: SafeParser.parseString(json['role']),
      profileImage: SafeParser.parseString(json['profile_image']),
    );
  }
}

class AddressLocationDataModel extends AddressLocationEntity {
  AddressLocationDataModel({
    required String type,
    required List<double> coordinates,
  }) : super(type: type, coordinates: coordinates);

  factory AddressLocationDataModel.fromJson(Map<String, dynamic> json) {
    return AddressLocationDataModel(
      type: SafeParser.parseString(json['type']),
      coordinates: SafeParser.parseList<double>(
          json['coordinates'], (x) => SafeParser.parseDouble(x)),
    );
  }
}

class TaskContentDataModel extends TaskContentEntity {
  TaskContentDataModel({
    required String media,
    required String mediaType,
    required String watermark,
    required String hopperId,
    required String imageId,
    required DateTime timeStamp,
  }) : super(
          media: media,
          mediaType: mediaType,
          watermark: watermark,
          hopperId: hopperId,
          imageId: imageId,
          timeStamp: timeStamp,
        );

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

class ChatRoomDataModel extends ChatRoomEntity {
  ChatRoomDataModel({
    required String id,
    required List<String> participants,
    required String type,
    required String roomId,
    required String senderId,
    required String taskId,
    required DateTime createdAt,
  }) : super(
          id: id,
          participants: participants,
          type: type,
          roomId: roomId,
          senderId: senderId,
          taskId: taskId,
          createdAt: createdAt,
        );

  factory ChatRoomDataModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomDataModel(
      id: SafeParser.parseString(json['_id']),
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
