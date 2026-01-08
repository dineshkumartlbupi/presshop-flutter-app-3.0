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
      List<TaskAll> updatedList;
      if (event.offset == 0) {
        updatedList = List.from(tasks);
      } else {
        updatedList = List.from(state.allTasks)..addAll(tasks);
      }

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
          limit: event.limit,
          offset: event.offset,
          filters: event.filterParams);

      bool hasReachedMax = tasks.length < event.limit;

      List<Task> updatedList;
      if (event.offset == 0) {
        updatedList = List<Task>.from(tasks);
      } else {
        updatedList = List<Task>.from(state.localTasks)..addAll(tasks);
      }

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
    debugPrint(
        "🚀 TaskBloc: FetchTaskDetailEvent Triggered. TaskId: ${event.taskId}");
    try {
      final taskDetail = await getTaskDetail(event.taskId);
      debugPrint(
          "🚀 TaskBloc: Task Detail Fetched Successfully: ${taskDetail.title}");

      String myId = sharedPreferences.getString(hopperIdKey) ?? "";
      bool isAccepted = taskDetail.acceptedBy.contains(myId);

      emit(state.copyWith(
          taskDetail: taskDetail,
          roomId: "", // temporary
          isTaskAccepted: isAccepted,
          myId: myId));
    } catch (e) {
      debugPrint("🚀 TaskBloc Error fetching task detail: $e");
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
