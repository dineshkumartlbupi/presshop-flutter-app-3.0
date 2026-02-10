import 'package:equatable/equatable.dart';
import 'task_detail.dart';

abstract class Task extends Equatable {
  const Task({required this.status, required this.totalAmount});
  final String status;
  final String totalAmount;

  @override
  List<Object?> get props => [status, totalAmount];
}

class TaskPending extends Task {
  const TaskPending({
    required super.status,
    required super.totalAmount,
    this.taskDetail,
    required this.title,
    required this.body,
    required this.broadCastId,
    this.isAvailableForAccept = false,
  });
  final TaskDetail? taskDetail;
  final String title;
  final String body;
  final String broadCastId;
  final bool isAvailableForAccept;

  @override
  List<Object?> get props => [
        ...super.props,
        taskDetail,
        title,
        body,
        broadCastId,
        isAvailableForAccept
      ];
}

class TaskMy extends Task {
  const TaskMy({
    required super.status,
    required super.totalAmount,
    this.taskDetail,
  });
  final TaskDetail? taskDetail;

  @override
  List<Object?> get props => [...super.props, taskDetail];
}
