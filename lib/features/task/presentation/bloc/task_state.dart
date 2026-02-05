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
  const TaskDetailLoaded(this.taskDetail);
  @override
  final TaskAssignedEntity taskDetail;
  @override
  List<Object> get props => [taskDetail];
}

class TaskChatLoaded extends TaskState {
  const TaskChatLoaded(this.chatList);
  final List<ManageTaskChatModel> chatList;
  @override
  List<Object> get props => [chatList];
}

class TaskMediaUploaded extends TaskState {
  const TaskMediaUploaded(this.response);
  final Map<String, dynamic> response;
  @override
  List<Object> get props => [response];
}

class RoomIdLoaded extends TaskState {
  const RoomIdLoaded(this.roomId);
  final String roomId;
  @override
  List<Object> get props => [roomId];
}

class HopperAcceptedCountLoaded extends TaskState {
  const HopperAcceptedCountLoaded(this.count);
  final String count;
  @override
  List<Object> get props => [count];
}

class TaskError extends TaskState {
  const TaskError(this.message);
  final String message;
  @override
  List<Object> get props => [message];
}

class TaskActionSuccess extends TaskState {
  const TaskActionSuccess(this.message);
  final String message;
  @override
  List<Object> get props => [message];
}

class TransactionDetailsLoaded extends TaskState {
  const TransactionDetailsLoaded(this.transactions);
  final List<EarningTransactionDetail> transactions;
  @override
  List<Object> get props => [transactions];
}

class TasksLoaded extends TaskState {

  const TasksLoaded({
    this.allTasks = const [],
    this.localTasks = const [],
    this.allTasksStatus = TaskStatus.initial,
    this.localTasksStatus = TaskStatus.initial,
  });
  @override
  final List<TaskAll> allTasks;
  @override
  final List<Task> localTasks;
  @override
  final TaskStatus allTasksStatus;
  @override
  final TaskStatus localTasksStatus;

  @override
  List<Object> get props =>
      [allTasks, localTasks, allTasksStatus, localTasksStatus];
}
