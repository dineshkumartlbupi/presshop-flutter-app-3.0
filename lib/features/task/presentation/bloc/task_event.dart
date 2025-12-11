part of 'task_bloc.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class FetchAllTasksEvent extends TaskEvent {
  final int limit;
  final int offset;

  const FetchAllTasksEvent({this.limit = 10, this.offset = 0});

  @override
  List<Object> get props => [limit, offset];
}

class FetchLocalTasksEvent extends TaskEvent {
  final int limit;
  final int offset;
  final Map<String, String> filterParams;

  const FetchLocalTasksEvent({this.limit = 10, this.offset = 0, this.filterParams = const {}});

  @override
  List<Object> get props => [limit, offset, filterParams];
}

class FetchTaskDetailEvent extends TaskEvent {
  final String taskId;

  const FetchTaskDetailEvent(this.taskId);

  @override
  List<Object> get props => [taskId];
}
