import '../../domain/repositories/task_repository.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_all.dart';
import '../../domain/entities/task_detail.dart';
import '../datasources/task_remote_data_source.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<TaskAll>> getAllTasks({required int limit, required int offset}) async {
    final models = await remoteDataSource.getAllTasks(limit, offset);
    return models; 
  }

  @override
  Future<List<Task>> getLocalTasks({required int limit, required int offset, required Map<String, dynamic> filters}) async {
    final models = await remoteDataSource.getLocalTasks(limit, offset, filters);
    return models;
  }

  @override
  Future<TaskDetail> getTaskDetail(String taskId) async {
    return await remoteDataSource.getTaskDetail(taskId);
  }
}
