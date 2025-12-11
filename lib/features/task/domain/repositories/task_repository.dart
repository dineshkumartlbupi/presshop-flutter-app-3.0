import '../entities/task.dart';
import '../entities/task_all.dart';
import '../entities/task_detail.dart';

abstract class TaskRepository {
  Future<List<TaskAll>> getAllTasks({required int limit, required int offset});
  Future<List<Task>> getLocalTasks({required int limit, required int offset, required Map<String, dynamic> filters});
  Future<TaskDetail> getTaskDetail(String taskId);
}
