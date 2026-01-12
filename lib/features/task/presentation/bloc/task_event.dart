import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class GetTaskDetailEvent extends TaskEvent {
  final String taskId;
  const GetTaskDetailEvent(this.taskId);
  @override
  List<Object> get props => [taskId];
}

class AcceptRejectTaskEvent extends TaskEvent {
  final String taskId;
  final String mediaHouseId;
  final String status;
  const AcceptRejectTaskEvent({
    required this.taskId,
    required this.mediaHouseId,
    required this.status,
  });
  @override
  List<Object> get props => [taskId, mediaHouseId, status];
}

class GetTaskChatEvent extends TaskEvent {
  final String roomId;
  final String type;
  final String contentId;
  const GetTaskChatEvent({
    required this.roomId,
    required this.type,
    required this.contentId,
  });
  @override
  List<Object> get props => [roomId, type, contentId];
}

class UploadTaskMediaEvent extends TaskEvent {
  final FormData data;
  const UploadTaskMediaEvent(this.data);
}

class GetRoomIdEvent extends TaskEvent {
  final String receiverId;
  final String taskId;
  final String roomType;
  final String type;
  const GetRoomIdEvent({
    required this.receiverId,
    required this.taskId,
    required this.roomType,
    required this.type,
  });
  @override
  List<Object> get props => [receiverId, taskId, roomType, type];
}

class GetHopperAcceptedCountEvent extends TaskEvent {
  final String taskId;
  const GetHopperAcceptedCountEvent(this.taskId);
  @override
  List<Object> get props => [taskId];
}

class GetTaskTransactionDetailsEvent extends TaskEvent {
  final String transactionId;
  const GetTaskTransactionDetailsEvent(this.transactionId);
  @override
  List<Object> get props => [transactionId];
}

class GetContentTransactionDetailsEvent extends TaskEvent {
  final String roomId;
  final String mediaHouseId;
  const GetContentTransactionDetailsEvent({
    required this.roomId,
    required this.mediaHouseId,
  });
  @override
  List<Object> get props => [roomId, mediaHouseId];
}

class FetchAllTasksEvent extends TaskEvent {
  final int offset;
  final Map<String, dynamic>? filterParams;
  const FetchAllTasksEvent({required this.offset, this.filterParams});
  @override
  List<Object> get props => [offset, filterParams ?? {}];
}

class FetchLocalTasksEvent extends TaskEvent {
  final Map<String, dynamic>? filterParams;
  const FetchLocalTasksEvent({this.filterParams});
  @override
  List<Object> get props => [filterParams ?? {}];
}

class FetchTaskDetailEvent extends TaskEvent {
  final String taskId;
  const FetchTaskDetailEvent(this.taskId);
  @override
  List<Object> get props => [taskId];
}
