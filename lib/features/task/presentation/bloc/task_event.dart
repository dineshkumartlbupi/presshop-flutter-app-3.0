import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class GetTaskDetailEvent extends TaskEvent {
  const GetTaskDetailEvent(this.taskId,
      {this.latitude, this.longitude, this.showLoader = true});

  final String taskId;
  final double? latitude;
  final double? longitude;
  final bool showLoader;

  @override
  List<Object?> get props => [taskId, latitude, longitude, showLoader];
}

class AcceptRejectTaskEvent extends TaskEvent {
  const AcceptRejectTaskEvent({
    required this.taskId,
    required this.mediaHouseId,
    required this.status,
  });

  final String taskId;
  final String mediaHouseId;
  final String status;

  @override
  List<Object> get props => [taskId, mediaHouseId, status];
}

class GetTaskChatEvent extends TaskEvent {
  final String roomId;
  final String type;
  final String contentId;
  final bool showLoader;
  const GetTaskChatEvent({
    required this.roomId,
    required this.type,
    required this.contentId,
    this.showLoader = true,
  });
  @override
  List<Object> get props => [roomId, type, contentId, showLoader];
}

class UploadTaskMediaEvent extends TaskEvent {
  final FormData data;
  final bool showLoader;
  const UploadTaskMediaEvent(this.data, {this.showLoader = true});
}

class GetRoomIdEvent extends TaskEvent {
  const GetRoomIdEvent({
    required this.receiverId,
    required this.taskId,
    required this.roomType,
    required this.type,
  });
  final String receiverId;
  final String taskId;
  final String roomType;
  final String type;
  @override
  List<Object> get props => [receiverId, taskId, roomType, type];
}

class GetHopperAcceptedCountEvent extends TaskEvent {
  const GetHopperAcceptedCountEvent(this.taskId);

  final String taskId;

  @override
  List<Object> get props => [taskId];
}

class GetTaskTransactionDetailsEvent extends TaskEvent {
  const GetTaskTransactionDetailsEvent(this.transactionId);

  final String transactionId;

  @override
  List<Object> get props => [transactionId];
}

class GetContentTransactionDetailsEvent extends TaskEvent {
  const GetContentTransactionDetailsEvent({
    required this.roomId,
    required this.mediaHouseId,
  });
  final String roomId;
  final String mediaHouseId;
  @override
  List<Object> get props => [roomId, mediaHouseId];
}

class FetchAllTasksEvent extends TaskEvent {
  const FetchAllTasksEvent(
      {required this.offset, this.filterParams, this.showLoader = true});

  final int offset;
  final Map<String, dynamic>? filterParams;
  final bool showLoader;

  @override
  List<Object> get props => [offset, filterParams ?? {}, showLoader];
}

class FetchLocalTasksEvent extends TaskEvent {
  const FetchLocalTasksEvent({this.filterParams, this.showLoader = true});

  final Map<String, dynamic>? filterParams;
  final bool showLoader;

  @override
  List<Object> get props => [filterParams ?? {}, showLoader];
}

class FetchTaskDetailEvent extends TaskEvent {
  const FetchTaskDetailEvent(this.taskId,
      {this.latitude, this.longitude, this.showLoader = true});

  final String taskId;
  final double? latitude;
  final double? longitude;
  final bool showLoader;

  @override
  List<Object?> get props => [taskId, latitude, longitude, showLoader];
}

// Local task management events
class AddLocalTaskEvent extends TaskEvent {
  const AddLocalTaskEvent(this.localTask);

  final dynamic localTask; // ManageTaskChatModel

  @override
  List<Object> get props => [localTask];
}

class UpdateLocalTaskProgressEvent extends TaskEvent {
  final String taskId;
  final int progress;
  final String status;
  const UpdateLocalTaskProgressEvent({
    required this.taskId,
    required this.progress,
    required this.status,
  });
  @override
  List<Object> get props => [taskId, progress, status];
}

class RemoveLocalTaskEvent extends TaskEvent {
  const RemoveLocalTaskEvent(this.taskId);

  final String taskId;

  @override
  List<Object> get props => [taskId];
}
