import '../../domain/entities/task_all.dart';

class AllTaskModel extends TaskAll {
  const AllTaskModel({
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
    super.isNeedPhoto = false,
    super.isNeedVideo = false,
    super.isNeedInterview = false,
    super.photoPrice = "0",
    super.videoPrice = "0",
    super.interviewPrice = "0",
    super.currency = "",
    super.currencySymbol = "",
    super.isAvailableForAccept = false,
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
      isAvailableForAccept: json['is_available_for_accept'] ?? false,
      mediaHouseDetails: (json['mediahouse_id'] is Map<String, dynamic>)
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
      isNeedPhoto: (json['need_photos'] ?? false) is bool
          ? (json['need_photos'] ?? false)
          : (json['need_photos'] == "true" || json['need_photos'] == "1"),
      isNeedVideo: (json['need_videos'] ?? false) is bool
          ? (json['need_videos'] ?? false)
          : (json['need_videos'] == "true" || json['need_videos'] == "1"),
      isNeedInterview: (json['need_interview'] ?? false) is bool
          ? (json['need_interview'] ?? false)
          : (json['need_interview'] == "true" || json['need_interview'] == "1"),
      photoPrice:
          (json['hopper_photo_price'] ?? json['photo_price'] ?? "0").toString(),
      videoPrice: (json['hopper_videos_price'] ??
              json['hopper_video_price'] ??
              json['videos_price'] ??
              "0")
          .toString(),
      interviewPrice:
          (json['hopper_interview_price'] ?? json['interview_price'] ?? "0")
              .toString(),
      currency: (json['currency'] ?? "").toString(),
      currencySymbol:
          (json['currency_symbol'] ?? json['currencySymbol'] ?? "").toString(),
    );
  }
}

class UploadContents extends UploadContentsEntity {
  const UploadContents({
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
  const AcceptedTask({
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
  const MediaHouseDetails({
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
