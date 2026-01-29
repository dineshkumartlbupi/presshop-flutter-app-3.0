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
      success: json['success'],
      message: json['message'],
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
      code: json['code'],
      task: TaskAssignedItemModel.fromJson(json['task']),
      resp: ChatRoomDataModel.fromJson(json['resp']),
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
  AddressLocationDataModel({
    required String type,
    required List<double> coordinates,
  }) : super(type: type, coordinates: coordinates);

  factory AddressLocationDataModel.fromJson(Map<String, dynamic> json) {
    return AddressLocationDataModel(
      type: json['type'],
      coordinates:
          List<double>.from(json['coordinates'].map((x) => x.toDouble())),
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
