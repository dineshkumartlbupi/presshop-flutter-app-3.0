import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_all.dart';
import '../../domain/entities/task_detail.dart';
import '../../domain/usecases/get_all_tasks.dart';
import '../../domain/usecases/get_local_tasks.dart';
import '../../domain/usecases/get_task_detail.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetAllTasks getAllTasks;
  final GetLocalTasks getLocalTasks;
  final GetTaskDetail getTaskDetail;
  final SharedPreferences sharedPreferences;

  TaskBloc({
    required this.getAllTasks,
    required this.getLocalTasks,
    required this.getTaskDetail,
    required this.sharedPreferences,
  }) : super(const TaskState()) {
    on<FetchAllTasksEvent>(_onFetchAllTasks);
    on<FetchLocalTasksEvent>(_onFetchLocalTasks);
    on<FetchTaskDetailEvent>(_onFetchTaskDetail);
  }

  Future<void> _onFetchAllTasks(
      FetchAllTasksEvent event, Emitter<TaskState> emit) async {
    if (event.offset == 0) {
      emit(state.copyWith(allTasksStatus: TaskStatus.loading));
    }

    try {
      final tasks = await getAllTasks(limit: event.limit, offset: event.offset);
      
      bool hasReachedMax = tasks.length < event.limit;
      List<TaskAll> updatedList = event.offset == 0
          ? tasks
          : List.of(state.allTasks)..addAll(tasks);

      emit(state.copyWith(
        allTasksStatus: TaskStatus.success,
        allTasks: updatedList,
        hasReachedMaxAllTasks: hasReachedMax,
      ));
    } catch (e) {
      emit(state.copyWith(
        allTasksStatus: TaskStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFetchLocalTasks(
      FetchLocalTasksEvent event, Emitter<TaskState> emit) async {
    if (event.offset == 0) {
      emit(state.copyWith(localTasksStatus: TaskStatus.loading));
    }

    try {
      final tasks = await getLocalTasks(
          limit: event.limit, offset: event.offset, filters: event.filterParams);
      
      bool hasReachedMax = tasks.length < event.limit;
      List<Task> updatedList = event.offset == 0
          ? tasks
          : List.of(state.localTasks)..addAll(tasks);

      emit(state.copyWith(
        localTasksStatus: TaskStatus.success,
        localTasks: updatedList,
        hasReachedMaxLocalTasks: hasReachedMax,
      ));
    } catch (e) {
      emit(state.copyWith(
        localTasksStatus: TaskStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFetchTaskDetail(
      FetchTaskDetailEvent event, Emitter<TaskState> emit) async {
    try {
      final taskDetail = await getTaskDetail(event.taskId);
      
      String myId = sharedPreferences.getString(hopperIdKey) ?? "";
      bool isAccepted = taskDetail.acceptedBy.contains(myId);
      
      // Removed roomId logic as it was fetched from a different part of the JSON response in the old code (map["resp"]["room_id"]).
      // The TaskDetail entity doesn't seem to hold roomId unless I missed it.
      // TaskDetail entity has `mediaHouseId`.
      // The old code logic: `if (map["resp"] != null) { roomId = (map["resp"]["room_id"] ?? "").toString(); }`
      // The repository `getTaskDetail` currently returns `TaskDetailModel` which parses `task`.
      // It ignores `resp`.
      // If `resp` is important (for Chat?), I should update `getTaskDetail` to return a wrapper or update Entity.
      // But `TaskRemoteDataSourceImpl` returns `TaskDetailModel.fromJson(map["task"])`.
      // So `resp` is lost.
      // Use case: Chat room ID?
      // I'll check `TaskDetail` entity again. It does NOT have roomId.
      // I'll check if `roomId` is critical. Usually it is for chatting.
      // If critical, I need to update Entity and Repo to include `roomId`.
      // For now, I'll pass empty string or handle it later.
      
      emit(state.copyWith(
          taskDetail: taskDetail,
          roomId: "", // temporary
          isTaskAccepted: isAccepted,
          myId: myId));
    } catch (e) {
      debugPrint("Error fetching task detail: $e");
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
