class AllTaskModel {
  String id = "";
  String userId = "";
  DateTime? deadlineDate;
  String heading = "";
  String createdAt = "";
  String description = "";
  String location = "";
  List<AcceptedTask> acceptedTasks = [];
  MediaHouseDetails? mediaHouseDetails;
  UploadContents? uploadContents;

  AllTaskModel({
    this.id = "",
    this.deadlineDate,
    this.heading = "",
    this.createdAt = "",
    this.description = "",
    this.location = "",
    this.mediaHouseDetails,
    this.acceptedTasks = const [],
    this.uploadContents,
  });

  AllTaskModel.fromJson(Map<String, dynamic> json) {
    id = (json['_id'] ?? "").toString();
    userId = (json['hopper_id'] ?? "").toString();
    deadlineDate = json['deadline_date'] != null
        ? DateTime.parse(json['deadline_date'])
        : null;
    heading = (json['heading'] ?? "").toString();
    createdAt = (json['createdAt'] ?? "").toString();
    description = (json['task_description'] ?? "").toString();
    location = (json['location'] ?? "").toString();
    mediaHouseDetails = json['mediahouse_id'] != null
        ? MediaHouseDetails.fromJson(json['mediahouse_id'])
        : null;
    if (json['acceptedTasks'] != null) {
      acceptedTasks = <AcceptedTask>[];
      json['acceptedTasks'].forEach((v) {
        acceptedTasks.add(AcceptedTask.fromJson(v));
      });
    }
    uploadContents = json['uploadContents'] != null
        ? UploadContents.fromJson(json['uploadContents'])
        : null;
  }
}

class UploadContents {
  String id = "";
  String videothubnail = "";
  String type = "";
  String imageAndVideo = "";

  UploadContents(
      {this.id = "",
      this.videothubnail = "",
      this.type = "",
      this.imageAndVideo = ""});

  UploadContents.fromJson(Map<String, dynamic> json) {
    id = (json['_id'] ?? "").toString();
    videothubnail = (json['videothubnail'] ?? "").toString();
    type = (json['type'] ?? "").toString();
    imageAndVideo = (json['imageAndVideo'] ?? "").toString();
  }
}

class AcceptedTask {
  String id = "";
  String taskId = "";
  String taskStatus = "";
  String hopperId = "";
  String createdAt = "";
  String updatedAt = "";

  AcceptedTask(
      {this.id = "",
      this.taskId = "",
      this.taskStatus = "",
      this.hopperId = "",
      this.createdAt = "",
      this.updatedAt = ""});

  AcceptedTask.fromJson(Map<String, dynamic> json) {
    id = (json['_id'] ?? "").toString();
    taskId = (json['task_id'] ?? "").toString();
    taskStatus = (json['task_status'] ?? "").toString();
    hopperId = (json['hopper_id'] ?? "").toString();
    createdAt = (json['createdAt'] ?? "").toString();
    updatedAt = (json['updatedAt'] ?? "").toString();
  }
}

class MediaHouseDetails {
  String id = "";
  String fullName = "";
  String profileImage = "";

  MediaHouseDetails({
    this.id = "",
    this.fullName = "",
    this.profileImage = "",
  });

  MediaHouseDetails.fromJson(Map<String, dynamic> json) {
    id = (json['_id'] ?? "").toString();
    fullName = (json['full_name'] ?? "").toString();
    profileImage = (json['profile_image'] ?? "").toString();
  }
}
