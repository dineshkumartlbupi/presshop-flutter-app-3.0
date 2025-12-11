import '../entities/task_all.dart';
import '../repositories/task_repository.dart';

class GetAllTasks {
  final TaskRepository repository;

  GetAllTasks(this.repository);

  Future<List<TaskAll>> call({required int limit, required int offset}) async {
    return await repository.getAllTasks(limit: limit, offset: offset);
  }
}
