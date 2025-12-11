part of 'task_bloc.dart';

enum TaskStatus { initial, loading, success, failure }

class TaskState extends Equatable {
  final TaskStatus allTasksStatus;
  final TaskStatus localTasksStatus;
  final List<TaskAll> allTasks;
  final List<Task> localTasks;
  final bool hasReachedMaxAllTasks;
  final bool hasReachedMaxLocalTasks;
  final String? errorMessage;
  final TaskDetail? taskDetail; // For broadcast dialog
  final String roomId;
  final bool isTaskAccepted;
  final String myId;

  const TaskState({
    this.allTasksStatus = TaskStatus.initial,
    this.allTasks = const [],
    this.hasReachedMaxAllTasks = false,
    this.localTasksStatus = TaskStatus.initial,
    this.localTasks = const [],
    this.hasReachedMaxLocalTasks = false,
    this.errorMessage = '',
    this.taskDetail,
    this.roomId = "",
    this.isTaskAccepted = false,
    this.myId = "",
  });

  TaskState copyWith({
    TaskStatus? allTasksStatus,
    List<TaskAll>? allTasks,
    bool? hasReachedMaxAllTasks,
    TaskStatus? localTasksStatus,
    List<Task>? localTasks,
    bool? hasReachedMaxLocalTasks,
    String? errorMessage,
    TaskDetail? taskDetail,
    String? roomId,
    bool? isTaskAccepted,
    String? myId,
  }) {
    return TaskState(
      allTasksStatus: allTasksStatus ?? this.allTasksStatus,
      allTasks: allTasks ?? this.allTasks,
      hasReachedMaxAllTasks: hasReachedMaxAllTasks ?? this.hasReachedMaxAllTasks,
      localTasksStatus: localTasksStatus ?? this.localTasksStatus,
      localTasks: localTasks ?? this.localTasks,
      hasReachedMaxLocalTasks: hasReachedMaxLocalTasks ?? this.hasReachedMaxLocalTasks,
      errorMessage: errorMessage ?? this.errorMessage,
      taskDetail: taskDetail ?? this.taskDetail,
      roomId: roomId ?? this.roomId,
      isTaskAccepted: isTaskAccepted ?? this.isTaskAccepted,
      myId: myId ?? this.myId,
    );
  }

  @override
  List<Object?> get props => [
        allTasksStatus,
        allTasks,
        hasReachedMaxAllTasks,
        localTasksStatus,
        localTasks,
        hasReachedMaxLocalTasks,
        errorMessage,
        taskDetail,
        roomId,
        isTaskAccepted,
        myId,
      ];
}
