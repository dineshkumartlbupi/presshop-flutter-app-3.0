
import 'package:presshop/features/task/data/models/task_models.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_detail.dart';

// Alias for legacy support during refactor - redundant if we update UI
typedef TaskParentClass = Task;

class PendingTask extends TaskPending {
  PendingTask.fromJson(Map<String, dynamic> json) : super(
    status: "pending",
    totalAmount: '0',
    title: (json["title"] ?? "").toString(),
    body: (json["body"] ?? "").toString(),
    broadCastId: (json["broadCast_id"] ?? "").toString(),
    taskDetail: TaskDetailModel.fromJson(json["task"] ?? {}),
  );
}

class MyTaskModel extends TaskMy {
  MyTaskModel.fromJson(Map<String, dynamic> json) : super(
    status: (json["task_status"] ?? "").toString(),
    totalAmount: json['total_payment']?.toString() ?? '0',
    taskDetail: TaskDetailModel.fromJson(json["task_id"] ?? {}),
  );
}
