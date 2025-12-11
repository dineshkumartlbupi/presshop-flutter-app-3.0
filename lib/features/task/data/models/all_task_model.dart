import '../../domain/entities/task_all.dart';

class AllTaskModel extends TaskAll {
  AllTaskModel({
    super.id = "",
    super.userId = "",
    super.deadlineDate,
    super.heading = "",
    super.createdAt = "",
    super.description = "",
    super.location = "",
    super.status = "",
    super.mediaHouseDetails,
    super.acceptedTasks = const [],
    super.uploadContents,
  });

  factory AllTaskModel.fromJson(Map<String, dynamic> json) {
    return AllTaskModel(
      id: (json['_id'] ?? "").toString(),
      userId: (json['hopper_id'] ?? "").toString(),
      deadlineDate: json['deadline_date'] != null
          ? DateTime.parse(json['deadline_date'])
          : null,
      heading: (json['heading'] ?? "").toString(),
      createdAt: (json['createdAt'] ?? "").toString(),
      description: (json['task_description'] ?? "").toString(),
      location: (json['location'] ?? "").toString(),
      status: (json['status'] ?? "").toString(),
      mediaHouseDetails: json['mediahouse_id'] != null
          ? MediaHouseDetails.fromJson(json['mediahouse_id'])
          : null,
      acceptedTasks: json['acceptedTasks'] != null
          ? (json['acceptedTasks'] as List)
              .map((v) => AcceptedTask.fromJson(v))
              .toList()
          : [],
      uploadContents: json['uploadContents'] != null
          ? UploadContents.fromJson(json['uploadContents'])
          : null,
    );
  }
}

class UploadContents extends UploadContentsEntity {
  UploadContents({
    super.id = "",
    super.videothubnail = "",
    super.type = "",
    super.imageAndVideo = "",
  });

  factory UploadContents.fromJson(Map<String, dynamic> json) {
    return UploadContents(
      id: (json['_id'] ?? "").toString(),
      videothubnail: (json['videothubnail'] ?? "").toString(),
      type: (json['type'] ?? "").toString(),
      imageAndVideo: (json['imageAndVideo'] ?? "").toString(),
    );
  }
}

class AcceptedTask extends AcceptedTaskEntity {
  AcceptedTask({
    super.id = "",
    super.taskId = "",
    super.taskStatus = "",
    super.hopperId = "",
    super.createdAt = "",
    super.updatedAt = "",
  });

  factory AcceptedTask.fromJson(Map<String, dynamic> json) {
    return AcceptedTask(
      id: (json['_id'] ?? "").toString(),
      taskId: (json['task_id'] ?? "").toString(),
      taskStatus: (json['task_status'] ?? "").toString(),
      hopperId: (json['hopper_id'] ?? "").toString(),
      createdAt: (json['createdAt'] ?? "").toString(),
      updatedAt: (json['updatedAt'] ?? "").toString(),
    );
  }
}

class MediaHouseDetails extends MediaHouseDetailsEntity {
  MediaHouseDetails({
    super.id = "",
    super.fullName = "",
    super.profileImage = "",
  });

  factory MediaHouseDetails.fromJson(Map<String, dynamic> json) {
    return MediaHouseDetails(
      id: (json['_id'] ?? "").toString(),
      fullName: (json['full_name'] ?? "").toString(),
      profileImage: (json['profile_image'] ?? "").toString(),
    );
  }
}
