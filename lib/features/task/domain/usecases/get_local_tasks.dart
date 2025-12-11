import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetLocalTasks {
  final TaskRepository repository;

  GetLocalTasks(this.repository);

  Future<List<Task>> call({required int limit, required int offset, required Map<String, dynamic> filters}) async {
    return await repository.getLocalTasks(limit: limit, offset: offset, filters: filters);
  }
}
