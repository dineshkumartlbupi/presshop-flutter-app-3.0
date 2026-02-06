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
  }) : super(TaskState.initial()) {
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
    on<FetchTaskDetailEvent>(_onFetchTaskDetail);
  }
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

  Future<void> _onGetTaskDetail(
      GetTaskDetailEvent event, Emitter<TaskState> emit) async {
    if (event.showLoader) {
      emit(state.copyWith(
          taskDetailStatus: TaskStatus.loading, clearErrorMessage: true));
    }
    final result = await getTaskDetail(GetTaskDetailParams(
        taskId: event.taskId, showLoader: event.showLoader));
    result.fold(
      (failure) => emit(state.copyWith(
          taskDetailStatus: TaskStatus.failure, errorMessage: failure.message)),
      (taskAssignedEntity) => emit(state.copyWith(
          taskDetailStatus: TaskStatus.success,
          taskDetail: taskAssignedEntity)),
    );
  }

  Future<void> _onAcceptRejectTask(
      AcceptRejectTaskEvent event, Emitter<TaskState> emit) async {
    emit(state.copyWith(
        actionStatus: TaskStatus.loading,
        clearErrorMessage: true,
        clearSuccessMessage: true));
    final result = await acceptRejectTask(AcceptRejectParams(
      taskId: event.taskId,
      mediaHouseId: event.mediaHouseId,
      status: event.status,
    ));
    result.fold(
      (failure) {
        AppLogger.error("Failed to ${event.status} task: ${failure.message}",
            trackAnalytics: true);
        emit(state.copyWith(
            actionStatus: TaskStatus.failure, errorMessage: failure.message));
      },
      (_) {
        final eventName = event.status == 'accepted'
            ? EventNames.taskAccepted
            : EventNames.taskRejected;
        AppLogger.trackEvent(eventName, parameters: {
          'task_id': event.taskId,
          'media_house_id': event.mediaHouseId,
        });
        emit(state.copyWith(
            actionStatus: TaskStatus.success,
            successMessage: "Task ${event.status} successfully"));
      },
    );
  }

  Future<void> _onGetTaskChat(
      GetTaskChatEvent event, Emitter<TaskState> emit) async {
    if (event.showLoader) {
      emit(state.copyWith(
          actionStatus: TaskStatus.loading, clearErrorMessage: true));
    }
    final result = await getTaskChat(GetTaskChatParams(
        roomId: event.roomId,
        type: event.type,
        contentId: event.contentId,
        showLoader: event.showLoader));
    result.fold(
      (failure) => emit(state.copyWith(
          actionStatus: TaskStatus.failure, errorMessage: failure.message)),
      (chatList) => emit(
          state.copyWith(actionStatus: TaskStatus.success, chatList: chatList)),
    );
  }

  Future<void> _onUploadTaskMedia(
      UploadTaskMediaEvent event, Emitter<TaskState> emit) async {
    if (event.showLoader) {
      emit(state.copyWith(
          actionStatus: TaskStatus.loading, clearErrorMessage: true));
    }
    final result = await uploadTaskMedia(
        UploadTaskMediaParams(data: event.data, showLoader: event.showLoader));
    result.fold(
      (failure) {
        AppLogger.error("Task media upload failed: ${failure.message}",
            trackAnalytics: true);
        emit(state.copyWith(
            actionStatus: TaskStatus.failure, errorMessage: failure.message));
      },
      (response) {
        final taskId = event.data.fields
            .firstWhere((f) => f.key == 'task_id',
                orElse: () => const MapEntry('', 'unknown'))
            .value;
        AppLogger.trackEvent(EventNames.taskSubmitted, parameters: {
          'task_id': taskId,
        });
        emit(state.copyWith(
            actionStatus: TaskStatus.success, uploadResponse: response));
      },
    );
  }

  Future<void> _onGetRoomId(
      GetRoomIdEvent event, Emitter<TaskState> emit) async {
    final result = await getRoomId(GetRoomIdParams(
      receiverId: event.receiverId,
      taskId: event.taskId,
      roomType: event.roomType,
      type: event.type,
    ));

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (roomId) => emit(state.copyWith(roomId: roomId)),
    );
  }

  Future<void> _onGetHopperAcceptedCount(
      GetHopperAcceptedCountEvent event, Emitter<TaskState> emit) async {
    debugPrint(
        "🚀 TaskBloc: Getting Hopper Accepted Count for taskId: '${event.taskId}'");
    final result = await getHopperAcceptedCount(event.taskId);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (count) => emit(state.copyWith(hopperAcceptedCount: count)),
    );
  }

  Future<void> _onGetTaskTransactionDetails(
      GetTaskTransactionDetailsEvent event, Emitter<TaskState> emit) async {
    final result = await getTaskTransactionDetails(event.transactionId);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (transactions) => emit(state.copyWith(transactions: transactions)),
    );
  }

  Future<void> _onGetContentTransactionDetails(
      GetContentTransactionDetailsEvent event, Emitter<TaskState> emit) async {
    final result = await getContentTransactionDetails(ContentTransactionParams(
      roomId: event.roomId,
      mediaHouseId: event.mediaHouseId,
    ));
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (transactions) => emit(state.copyWith(transactions: transactions)),
    );
  }

  Future<void> _onFetchAllTasks(
      FetchAllTasksEvent event, Emitter<TaskState> emit) async {
    emit(state.copyWith(
        allTasksStatus: TaskStatus.loading, clearErrorMessage: true));

    final result = await getAllTasks(GetAllTasksParams(
      limit: 10,
      offset: event.offset,
      filterParams: event.filterParams ?? {},
      showLoader: event.showLoader,
    ));

    result.fold(
        (failure) => emit(state.copyWith(
            allTasksStatus: TaskStatus.failure,
            errorMessage: failure.message)), (tasks) {
      final updatedTasks =
          event.offset == 0 ? tasks : [...state.allTasks, ...tasks];
      emit(state.copyWith(
          allTasksStatus: TaskStatus.success, allTasks: updatedTasks));
    });
  }

  Future<void> _onFetchLocalTasks(
      FetchLocalTasksEvent event, Emitter<TaskState> emit) async {
    emit(state.copyWith(
        localTasksStatus: TaskStatus.loading, clearErrorMessage: true));

    final result = await getLocalTasks(GetLocalTasksParams(
        filterParams: event.filterParams ?? {}, showLoader: event.showLoader));

    result.fold(
      (failure) => emit(state.copyWith(
          localTasksStatus: TaskStatus.failure, errorMessage: failure.message)),
      (tasks) => emit(state.copyWith(
          localTasksStatus: TaskStatus.success, localTasks: tasks)),
    );
  }

  Future<void> _onFetchTaskDetail(
      FetchTaskDetailEvent event, Emitter<TaskState> emit) async {
    if (event.showLoader) {
      emit(state.copyWith(
          taskDetailStatus: TaskStatus.loading, clearErrorMessage: true));
    }
    final result = await getTaskDetail(GetTaskDetailParams(
        taskId: event.taskId, showLoader: event.showLoader));
    result.fold(
      (failure) => emit(state.copyWith(
          taskDetailStatus: TaskStatus.failure, errorMessage: failure.message)),
      (taskAssignedEntity) => emit(state.copyWith(
          taskDetailStatus: TaskStatus.success,
          taskDetail: taskAssignedEntity)),
    );
  }

  @override
  void onTransition(Transition<TaskEvent, TaskState> transition) {
    super.onTransition(transition);
    // debugPrint("🚀 TaskBloc Transition: ${transition.event} -> ${transition.nextState}");
  }
}
