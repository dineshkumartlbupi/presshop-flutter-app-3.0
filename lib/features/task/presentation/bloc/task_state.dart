import 'package:equatable/equatable.dart';
import 'package:presshop/features/task/data/models/manage_task_chat_model.dart';
import 'package:presshop/features/earning/data/models/earning_model.dart';
import 'package:presshop/features/task/domain/entities/task.dart';
import 'package:presshop/features/task/domain/entities/task_all.dart';
import 'package:presshop/features/task/domain/entities/task_assigned_entity.dart';

enum TaskStatus { initial, loading, success, failure }

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];

  TaskAssignedEntity? get taskDetail => null;
  List<TaskAll> get allTasks => [];
  List<Task> get localTasks => [];
  TaskStatus get allTasksStatus => TaskStatus.initial;
  TaskStatus get localTasksStatus => TaskStatus.initial;
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskDetailLoaded extends TaskState {
  final TaskAssignedEntity taskDetail;
  const TaskDetailLoaded(this.taskDetail);
  @override
  List<Object> get props => [taskDetail];
}

class TaskChatLoaded extends TaskState {
  final List<ManageTaskChatModel> chatList;
  const TaskChatLoaded(this.chatList);
  @override
  List<Object> get props => [chatList];
}

class TaskMediaUploaded extends TaskState {
  final Map<String, dynamic> response;
  const TaskMediaUploaded(this.response);
  @override
  List<Object> get props => [response];
}

class RoomIdLoaded extends TaskState {
  final String roomId;
  const RoomIdLoaded(this.roomId);
  @override
  List<Object> get props => [roomId];
}

class HopperAcceptedCountLoaded extends TaskState {
  final String count;
  const HopperAcceptedCountLoaded(this.count);
  @override
  List<Object> get props => [count];
}

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);
  @override
  List<Object> get props => [message];
}

class TaskActionSuccess extends TaskState {
  final String message;
  const TaskActionSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class TransactionDetailsLoaded extends TaskState {
  final List<EarningTransactionDetail> transactions;
  const TransactionDetailsLoaded(this.transactions);
  @override
  List<Object> get props => [transactions];
}

class TasksLoaded extends TaskState {
  final List<TaskAll> allTasks;
  final List<Task> localTasks;
  final TaskStatus allTasksStatus;
  final TaskStatus localTasksStatus;

  const TasksLoaded({
    this.allTasks = const [],
    this.localTasks = const [],
    this.allTasksStatus = TaskStatus.initial,
    this.localTasksStatus = TaskStatus.initial,
  });

  @override
  List<Object> get props =>
      [allTasks, localTasks, allTasksStatus, localTasksStatus];
}
