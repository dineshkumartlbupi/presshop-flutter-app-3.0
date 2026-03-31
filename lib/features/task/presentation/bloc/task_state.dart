import 'package:equatable/equatable.dart';
import 'package:presshop/features/task/data/models/manage_task_chat_model.dart';
import 'package:presshop/features/earning/data/models/earning_model.dart';
import 'package:presshop/features/task/domain/entities/task.dart';
import 'package:presshop/features/task/domain/entities/task_all.dart';
import 'package:presshop/features/task/domain/entities/task_assigned_entity.dart';

enum TaskStatus { initial, loading, success, failure }

class TaskState extends Equatable {
  final TaskAssignedEntity? taskDetail;
  final List<TaskAll> allTasks;
  final List<Task> localTasks;
  final List<ManageTaskChatModel> chatList;
  final List<EarningTransactionDetail> transactions;
  final Map<String, dynamic>? uploadResponse;
  final String? roomId;
  final String? hopperAcceptedCount;
  final TaskStatus allTasksStatus;
  final TaskStatus localTasksStatus;
  final TaskStatus taskDetailStatus;
  final TaskStatus actionStatus;
  final String? errorMessage;
  final String? successMessage;

  const TaskState({
    this.taskDetail,
    this.allTasks = const [],
    this.localTasks = const [],
    this.chatList = const [],
    this.transactions = const [],
    this.uploadResponse,
    this.roomId,
    this.hopperAcceptedCount,
    this.allTasksStatus = TaskStatus.initial,
    this.localTasksStatus = TaskStatus.initial,
    this.taskDetailStatus = TaskStatus.initial,
    this.actionStatus = TaskStatus.initial,
    this.errorMessage,
    this.successMessage,
  });

  factory TaskState.initial() => const TaskState();

  TaskState copyWith({
    TaskAssignedEntity? taskDetail,
    List<TaskAll>? allTasks,
    List<Task>? localTasks,
    List<ManageTaskChatModel>? chatList,
    List<EarningTransactionDetail>? transactions,
    Map<String, dynamic>? uploadResponse,
    String? roomId,
    String? hopperAcceptedCount,
    TaskStatus? allTasksStatus,
    TaskStatus? localTasksStatus,
    TaskStatus? taskDetailStatus,
    TaskStatus? actionStatus,
    String? errorMessage,
    String? successMessage,
    bool clearTaskDetail = false,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
    bool clearRoomId = false,
  }) {
    return TaskState(
      taskDetail: clearTaskDetail ? null : (taskDetail ?? this.taskDetail),
      allTasks: allTasks ?? this.allTasks,
      localTasks: localTasks ?? this.localTasks,
      chatList: chatList ?? this.chatList,
      transactions: transactions ?? this.transactions,
      uploadResponse: uploadResponse ?? this.uploadResponse,
      roomId: clearRoomId ? null : (roomId ?? this.roomId),
      hopperAcceptedCount: hopperAcceptedCount ?? this.hopperAcceptedCount,
      allTasksStatus: allTasksStatus ?? this.allTasksStatus,
      localTasksStatus: localTasksStatus ?? this.localTasksStatus,
      taskDetailStatus: taskDetailStatus ?? this.taskDetailStatus,
      actionStatus: actionStatus ?? this.actionStatus,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        taskDetail,
        allTasks,
        localTasks,
        chatList,
        transactions,
        uploadResponse,
        roomId,
        hopperAcceptedCount,
        allTasksStatus,
        localTasksStatus,
        taskDetailStatus,
        actionStatus,
        errorMessage,
        successMessage,
      ];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskError extends TaskState {
  const TaskError(String message)
      : super(errorMessage: message, actionStatus: TaskStatus.failure);
}
