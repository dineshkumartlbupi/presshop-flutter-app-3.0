import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:presshop/features/task/domain/usecases/accept_reject_task.dart';
import 'package:presshop/features/task/domain/usecases/get_hopper_accepted_count.dart';
import 'package:presshop/features/task/domain/usecases/get_room_id.dart';
import 'package:presshop/features/task/domain/usecases/get_task_chat.dart';
import 'package:presshop/features/task/domain/usecases/get_task_detail.dart';
import 'package:presshop/features/task/domain/usecases/upload_task_media.dart';
import 'package:presshop/features/task/domain/usecases/get_task_transaction_details.dart';
import 'package:presshop/features/task/domain/usecases/get_content_transaction_details.dart';
import 'package:presshop/features/task/presentation/bloc/task_event.dart';
import 'package:presshop/features/task/domain/usecases/get_all_tasks.dart';
import 'package:presshop/features/task/domain/usecases/get_local_tasks.dart';
import 'package:presshop/core/utils/app_logger.dart';
import 'package:presshop/core/analytics/analytics_constants.dart';
import 'package:presshop/features/task/presentation/bloc/task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTaskDetail getTaskDetail;
  final AcceptRejectTask acceptRejectTask;
  final GetTaskChat getTaskChat;
  final UploadTaskMedia uploadTaskMedia;
  final GetRoomId getRoomId;
  final GetHopperAcceptedCount getHopperAcceptedCount;
  final GetTaskTransactionDetails getTaskTransactionDetails;
  final GetContentTransactionDetails getContentTransactionDetails;
  final GetAllTasks getAllTasks;
  final GetLocalTasks getLocalTasks;

  TaskBloc({
    required this.getTaskDetail,
    required this.acceptRejectTask,
    required this.getTaskChat,
    required this.uploadTaskMedia,
    required this.getRoomId,
    required this.getHopperAcceptedCount,
    required this.getTaskTransactionDetails,
    required this.getContentTransactionDetails,
    required this.getAllTasks,
    required this.getLocalTasks,
  }) : super(TaskInitial()) {
    on<GetTaskDetailEvent>(_onGetTaskDetail);
    on<AcceptRejectTaskEvent>(_onAcceptRejectTask);
    on<GetTaskChatEvent>(_onGetTaskChat);
    on<UploadTaskMediaEvent>(_onUploadTaskMedia);
    on<GetRoomIdEvent>(_onGetRoomId);
    on<GetHopperAcceptedCountEvent>(_onGetHopperAcceptedCount);
    on<GetTaskTransactionDetailsEvent>(_onGetTaskTransactionDetails);
    on<GetContentTransactionDetailsEvent>(_onGetContentTransactionDetails);
    on<FetchAllTasksEvent>(_onFetchAllTasks);
    on<FetchLocalTasksEvent>(_onFetchLocalTasks);
    on<FetchTaskDetailEvent>(
        _onFetchTaskDetail); // Alias for GetTaskDetailEvent if needed or separate
  }

  Future<void> _onGetTaskDetail(
      GetTaskDetailEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final result = await getTaskDetail(event.taskId);
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (taskAssignedEntity) => emit(TaskDetailLoaded(taskAssignedEntity)),
    );
  }

  Future<void> _onAcceptRejectTask(
      AcceptRejectTaskEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final result = await acceptRejectTask(AcceptRejectParams(
      taskId: event.taskId,
      mediaHouseId: event.mediaHouseId,
      status: event.status,
    ));
    result.fold(
      (failure) {
        AppLogger.error("Failed to ${event.status} task: ${failure.message}",
            trackAnalytics: true);
        emit(TaskError(failure.message));
      },
      (_) {
        final eventName = event.status == 'accepted'
            ? EventNames.taskAccepted
            : EventNames.taskRejected;
        AppLogger.trackEvent(eventName, parameters: {
          'task_id': event.taskId,
          'media_house_id': event.mediaHouseId,
        });
        emit(TaskActionSuccess("Task ${event.status} successfully"));
      },
    );
  }

  Future<void> _onGetTaskChat(
      GetTaskChatEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final result = await getTaskChat(GetTaskChatParams(
      roomId: event.roomId,
      type: event.type,
      contentId: event.contentId,
    ));
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (chatList) => emit(TaskChatLoaded(chatList)),
    );
  }

  Future<void> _onUploadTaskMedia(
      UploadTaskMediaEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final result = await uploadTaskMedia(event.data);
    result.fold(
      (failure) {
        AppLogger.error("Task media upload failed: ${failure.message}",
            trackAnalytics: true);
        emit(TaskError(failure.message));
      },
      (response) {
        final taskId = event.data.fields
            .firstWhere((f) => f.key == 'task_id',
                orElse: () => const MapEntry('', 'unknown'))
            .value;
        AppLogger.trackEvent(EventNames.taskSubmitted, parameters: {
          'task_id': taskId,
        });
        emit(TaskMediaUploaded(response));
      },
    );
  }

  Future<void> _onGetRoomId(
      GetRoomIdEvent event, Emitter<TaskState> emit) async {
    // Only emit loading for room ID if it's a blocking operation?
    // Usually Room ID fetch is background or quick. Let's keep it safe.
    // emit(TaskLoading());
    // Maybe don't emit loading for minor fetches to avoid full screen loaders jumping?
    // But for consistency let's emit loading or handle in UI.

    final result = await getRoomId(GetRoomIdParams(
      receiverId: event.receiverId,
      taskId: event.taskId,
      roomType: event.roomType,
      type: event.type,
    ));

    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (roomId) => emit(RoomIdLoaded(roomId)),
    );
  }

  Future<void> _onGetHopperAcceptedCount(
      GetHopperAcceptedCountEvent event, Emitter<TaskState> emit) async {
    debugPrint(
        "🚀 TaskBloc: Getting Hopper Accepted Count for taskId: '${event.taskId}'");
    final result = await getHopperAcceptedCount(event.taskId);
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (count) => emit(HopperAcceptedCountLoaded(count)),
    );
  }

  Future<void> _onGetTaskTransactionDetails(
      GetTaskTransactionDetailsEvent event, Emitter<TaskState> emit) async {
    final result = await getTaskTransactionDetails(event.transactionId);
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (transactions) => emit(TransactionDetailsLoaded(transactions)),
    );
  }

  Future<void> _onGetContentTransactionDetails(
      GetContentTransactionDetailsEvent event, Emitter<TaskState> emit) async {
    final result = await getContentTransactionDetails(ContentTransactionParams(
      roomId: event.roomId,
      mediaHouseId: event.mediaHouseId,
    ));
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (transactions) => emit(TransactionDetailsLoaded(transactions)),
    );
  }

  Future<void> _onFetchAllTasks(
      FetchAllTasksEvent event, Emitter<TaskState> emit) async {
    TasksLoaded currentState;
    if (state is TasksLoaded) {
      currentState = state as TasksLoaded;
      emit(TasksLoaded(
        allTasks: currentState.allTasks,
        localTasks: currentState.localTasks,
        allTasksStatus: TaskStatus.loading,
        localTasksStatus: currentState.localTasksStatus,
      ));
    } else {
      currentState = const TasksLoaded(allTasksStatus: TaskStatus.loading);
      emit(currentState);
    }

    final result = await getAllTasks(GetAllTasksParams(
      limit: 10,
      offset: event.offset,
      filterParams: event.filterParams ?? {},
    ));

    result.fold(
      (failure) => emit(TasksLoaded(
        allTasks: currentState.allTasks,
        localTasks: currentState.localTasks,
        allTasksStatus: TaskStatus.failure,
        localTasksStatus: currentState.localTasksStatus,
      )),
      (tasks) => emit(TasksLoaded(
        allTasks: tasks,
        localTasks: currentState.localTasks,
        allTasksStatus: TaskStatus.success,
        localTasksStatus: currentState.localTasksStatus,
      )),
    );
  }

  Future<void> _onFetchLocalTasks(
      FetchLocalTasksEvent event, Emitter<TaskState> emit) async {
    TasksLoaded currentState;
    if (state is TasksLoaded) {
      currentState = state as TasksLoaded;
      emit(TasksLoaded(
        allTasks: currentState.allTasks,
        localTasks: currentState.localTasks,
        allTasksStatus: currentState.allTasksStatus,
        localTasksStatus: TaskStatus.loading,
      ));
    } else {
      currentState = const TasksLoaded(localTasksStatus: TaskStatus.loading);
      emit(currentState);
    }

    final result = await getLocalTasks(event.filterParams ?? {});

    result.fold(
      (failure) => emit(TasksLoaded(
        allTasks: currentState.allTasks,
        localTasks: currentState.localTasks,
        allTasksStatus: currentState.allTasksStatus,
        localTasksStatus: TaskStatus.failure,
      )),
      (tasks) => emit(TasksLoaded(
        allTasks: currentState.allTasks,
        localTasks: tasks,
        allTasksStatus: currentState.allTasksStatus,
        localTasksStatus: TaskStatus.success,
      )),
    );
  }

  Future<void> _onFetchTaskDetail(
      FetchTaskDetailEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final result = await getTaskDetail(event.taskId);
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (taskAssignedEntity) => emit(TaskDetailLoaded(taskAssignedEntity)),
    );
  }
}
