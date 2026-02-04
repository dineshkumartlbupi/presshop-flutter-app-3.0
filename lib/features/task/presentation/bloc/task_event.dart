import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class GetTaskDetailEvent extends TaskEvent {
  const GetTaskDetailEvent(this.taskId);
  final String taskId;
  @override
  List<Object> get props => [taskId];
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
  const GetTaskChatEvent({
    required this.roomId,
    required this.type,
    required this.contentId,
  });
  final String roomId;
  final String type;
  final String contentId;
  @override
  List<Object> get props => [roomId, type, contentId];
}

class UploadTaskMediaEvent extends TaskEvent {
  const UploadTaskMediaEvent(this.data);
  final FormData data;
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
  const FetchAllTasksEvent({required this.offset, this.filterParams});
  final int offset;
  final Map<String, dynamic>? filterParams;
  @override
  List<Object> get props => [offset, filterParams ?? {}];
}

class FetchLocalTasksEvent extends TaskEvent {
  const FetchLocalTasksEvent({this.filterParams});
  final Map<String, dynamic>? filterParams;
  @override
  List<Object> get props => [filterParams ?? {}];
}

class FetchTaskDetailEvent extends TaskEvent {
  const FetchTaskDetailEvent(this.taskId);
  final String taskId;
  @override
  List<Object> get props => [taskId];
}
