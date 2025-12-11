import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/core/constants/string_constants.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/task.dart';
import '../models/all_task_model.dart';
import '../models/my_task_model.dart';
import '../models/task_models.dart';

abstract class TaskRemoteDataSource {
  Future<List<AllTaskModel>> getAllTasks(int limit, int offset);
  Future<List<Task>> getLocalTasks(int limit, int offset, Map<String, dynamic> filters);
  Future<TaskDetailModel> getTaskDetail(String taskId);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio dio;
  final SharedPreferences sharedPreferences;

  TaskRemoteDataSourceImpl({required this.dio, required this.sharedPreferences});

  @override
  Future<List<AllTaskModel>> getAllTasks(int limit, int offset) async {
    String token = sharedPreferences.getString(tokenKey) ?? "";
    dio.options.headers["Authorization"] = "Bearer $token";
    dio.options.headers["Content-Type"] = "application/json";

    // Note: Bloc had logic to handle 'offset == 0' loading state, etc. DataSource just fetches.
    // Bloc called POST? Yes, TaskBloc line 41: dio.post.
    var response = await dio.post(
      baseUrl + getAllTaskUrl,
      data: {"limit": limit, "offset": offset},
    );

    if (response.statusCode == 200) {
      var data = response.data;
      if (data['data'] != null) {
        return (data['data'] as List)
            .map((e) => AllTaskModel.fromJson(e))
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception("Failed to fetch all tasks: ${response.statusCode}");
    }
  }

  @override
  Future<List<Task>> getLocalTasks(int limit, int offset, Map<String, dynamic> filters) async {
    String token = sharedPreferences.getString(tokenKey) ?? "";
    dio.options.headers["Authorization"] = "Bearer $token";
    dio.options.headers["Content-Type"] = "application/json";

    Map<String, dynamic> params = Map.from(filters);
    params["limit"] = limit.toString();
    params["offset"] = offset.toString();

    // Bloc used GET.
    var response = await dio.get(
      baseUrl + getAllMyTaskUrl,
      queryParameters: params,
    );

    if (response.statusCode == 200) {
      var data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      List<Task> combinedList = [];

      if (data['data'] != null) {
        var dataModel = data["data"] as List;
        var list = dataModel.map((e) => MyTaskModel.fromJson(e)).toList();
        combinedList.addAll(list);
      }

      // Pending tasks only on first page (offset 0)? Bloc checked 'event.offset == 0'.
      // DataSource shouldn't care about business logic like "only on first page" unless passed as param?
      // Since 'offset' is passed, we can check it.
      if (offset == 0 && data['pending_unaccepted'] != null) {
        var pendingTaskList = data["pending_unaccepted"] as List;
        if (pendingTaskList.isNotEmpty) {
          var pendingList = pendingTaskList.map((e) => PendingTask.fromJson(e)).toList();
          combinedList.addAll(pendingList);
        }
      }

      return combinedList;
    } else {
      throw Exception("Failed to fetch local tasks: ${response.statusCode}");
    }
  }

  @override
  Future<TaskDetailModel> getTaskDetail(String taskId) async {
    String token = sharedPreferences.getString(tokenKey) ?? "";
    dio.options.headers["Authorization"] = "Bearer $token";

    var response = await dio.get(baseUrl + taskDetailUrl + taskId);

    if (response.statusCode == 200) {
      var map = response.data;
      if (map is String) map = jsonDecode(map);

      if (map["code"] == 200 && map["task"] != null) {
        return TaskDetailModel.fromJson(map["task"]);
      } else {
        throw Exception("Task detail not found or error in response");
      }
    } else {
      throw Exception("Failed to fetch task detail: ${response.statusCode}");
    }
  }
}
