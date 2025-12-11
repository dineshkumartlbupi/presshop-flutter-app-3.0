import '../entities/task_detail.dart';
import '../repositories/task_repository.dart';

class GetTaskDetail {
  final TaskRepository repository;

  GetTaskDetail(this.repository);

  Future<TaskDetail> call(String taskId) async {
    return await repository.getTaskDetail(taskId);
  }
}
