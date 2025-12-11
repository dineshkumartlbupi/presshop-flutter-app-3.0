import 'package:equatable/equatable.dart';
import 'task_detail.dart';

abstract class Task extends Equatable {
  final String status;
  final String totalAmount;

  const Task({required this.status, required this.totalAmount});

  @override
  List<Object?> get props => [status, totalAmount];
}

class TaskPending extends Task {
  final TaskDetail? taskDetail;
  final String title;
  final String body;
  final String broadCastId;

  const TaskPending({
    required super.status,
    required super.totalAmount,
    this.taskDetail,
    required this.title,
    required this.body,
    required this.broadCastId,
  });

  @override
  List<Object?> get props => [...super.props, taskDetail, title, body, broadCastId];
}

class TaskMy extends Task {
  final TaskDetail? taskDetail;

  const TaskMy({
    required super.status,
    required super.totalAmount,
    this.taskDetail,
  });

  @override
  List<Object?> get props => [...super.props, taskDetail];
}
