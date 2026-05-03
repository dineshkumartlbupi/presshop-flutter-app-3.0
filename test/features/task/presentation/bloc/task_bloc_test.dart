import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart' hide Task;
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/analytics/analytics_constants.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/task/domain/entities/task.dart';
import 'package:presshop/features/task/domain/entities/task_all.dart';
import 'package:presshop/features/task/domain/entities/task_assigned_entity.dart';
import 'package:presshop/features/task/domain/usecases/accept_reject_task.dart';
import 'package:presshop/features/task/domain/usecases/get_all_tasks.dart';
import 'package:presshop/features/task/domain/usecases/get_content_transaction_details.dart';
import 'package:presshop/features/task/domain/usecases/get_hopper_accepted_count.dart';
import 'package:presshop/features/task/domain/usecases/get_local_tasks.dart';
import 'package:presshop/features/task/domain/usecases/get_room_id.dart';
import 'package:presshop/features/task/domain/usecases/get_task_chat.dart';
import 'package:presshop/features/task/domain/usecases/get_task_detail.dart';
import 'package:presshop/features/task/domain/usecases/get_task_transaction_details.dart';
import 'package:presshop/features/task/domain/usecases/upload_task_media.dart';
import 'package:presshop/features/task/presentation/bloc/task_bloc.dart';
import 'package:presshop/features/task/presentation/bloc/task_event.dart';
import 'package:presshop/features/task/presentation/bloc/task_state.dart';
import 'package:presshop/features/task/data/models/all_task_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

class MockGetTaskDetail extends Mock implements GetTaskDetail {}

class MockAcceptRejectTask extends Mock implements AcceptRejectTask {}

class MockGetTaskChat extends Mock implements GetTaskChat {}

class MockUploadTaskMedia extends Mock implements UploadTaskMedia {}

class MockGetRoomId extends Mock implements GetRoomId {}

class MockGetHopperAcceptedCount extends Mock
    implements GetHopperAcceptedCount {}

class MockGetTaskTransactionDetails extends Mock
    implements GetTaskTransactionDetails {}

class MockGetContentTransactionDetails extends Mock
    implements GetContentTransactionDetails {}

class MockGetAllTasks extends Mock implements GetAllTasks {}

class MockGetLocalTasks extends Mock implements GetLocalTasks {}

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

class MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {}

class MockFormData extends Mock implements FormData {}

// Fakes
class FakeAcceptRejectParams extends Fake implements AcceptRejectParams {}

class FakeGetTaskChatParams extends Fake implements GetTaskChatParams {}

class FakeGetRoomIdParams extends Fake implements GetRoomIdParams {}

class FakeGetAllTasksParams extends Fake implements GetAllTasksParams {}

class FakeContentTransactionParams extends Fake
    implements ContentTransactionParams {}

class FakeGetLocalTasksParams extends Fake implements GetLocalTasksParams {}

class FakeGetTaskDetailParams extends Fake implements GetTaskDetailParams {}

void main() {
  late TaskBloc bloc;
  late MockGetTaskDetail mockGetTaskDetail;
  late MockAcceptRejectTask mockAcceptRejectTask;
  late MockGetTaskChat mockGetTaskChat;
  late MockUploadTaskMedia mockUploadTaskMedia;
  late MockGetRoomId mockGetRoomId;
  late MockGetHopperAcceptedCount mockGetHopperAcceptedCount;
  late MockGetTaskTransactionDetails mockGetTaskTransactionDetails;
  late MockGetContentTransactionDetails mockGetContentTransactionDetails;
  late MockGetAllTasks mockGetAllTasks;
  late MockGetLocalTasks mockGetLocalTasks;
  late MockFirebaseAnalytics mockAnalytics;
  late MockFirebaseCrashlytics mockCrashlytics;

  setUpAll(() {
    registerFallbackValue(FakeAcceptRejectParams());
    registerFallbackValue(FakeGetTaskChatParams());
    registerFallbackValue(FakeGetRoomIdParams());
    registerFallbackValue(FakeGetAllTasksParams());
    registerFallbackValue(FakeContentTransactionParams());
    registerFallbackValue(FakeGetLocalTasksParams());
    registerFallbackValue(FakeGetTaskDetailParams());
    registerFallbackValue(MockFormData());
  });

  setUp(() async {
    mockGetTaskDetail = MockGetTaskDetail();
    mockAcceptRejectTask = MockAcceptRejectTask();
    mockGetTaskChat = MockGetTaskChat();
    mockUploadTaskMedia = MockUploadTaskMedia();
    mockGetRoomId = MockGetRoomId();
    mockGetHopperAcceptedCount = MockGetHopperAcceptedCount();
    mockGetTaskTransactionDetails = MockGetTaskTransactionDetails();
    mockGetContentTransactionDetails = MockGetContentTransactionDetails();
    mockGetAllTasks = MockGetAllTasks();
    mockGetLocalTasks = MockGetLocalTasks();
    mockAnalytics = MockFirebaseAnalytics();
    mockCrashlytics = MockFirebaseCrashlytics();

    await sl.reset();
    sl.registerLazySingleton<FirebaseAnalytics>(() => mockAnalytics);
    sl.registerLazySingleton<FirebaseCrashlytics>(() => mockCrashlytics);

    // Initialize Hive for tests
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
    await Hive.openBox('sync_cache');

    // Default mocks for Firebase
    when(() => mockAnalytics.logEvent(
        name: any(named: 'name'),
        parameters: any(named: 'parameters'))).thenAnswer((_) async {});
    when(() => mockCrashlytics.recordError(any(), any(),
        reason: any(named: 'reason'))).thenAnswer((_) async {});
    when(() => mockCrashlytics.log(any())).thenAnswer((_) async {});

    bloc = TaskBloc(
      getTaskDetail: mockGetTaskDetail,
      acceptRejectTask: mockAcceptRejectTask,
      getTaskChat: mockGetTaskChat,
      uploadTaskMedia: mockUploadTaskMedia,
      getRoomId: mockGetRoomId,
      getHopperAcceptedCount: mockGetHopperAcceptedCount,
      getTaskTransactionDetails: mockGetTaskTransactionDetails,
      getContentTransactionDetails: mockGetContentTransactionDetails,
      getAllTasks: mockGetAllTasks,
      getLocalTasks: mockGetLocalTasks,
    );
  });

  tearDown(() {
    bloc.close();
  });

  const tTaskId = 'task1';
  final tTaskAssignedEntity = TaskAssignedEntity(
      code: 200,
      task: TaskAssignedDetailEntity(
          id: 'task1',
          mediaHouse: const MediaHouseEntity(
              id: 'mh1',
              firstName: 'MH',
              lastName: 'L',
              email: 'e',
              phone: 'p',
              role: 'r',
              profileImage: 'img'),
          deadlineDate: DateTime(2023),
          heading: 'Task Heading',
          description: 'Desc',
          location: 'Loc',
          addressLocation:
              const AddressLocationEntity(type: 'Point', coordinates: [0, 0]),
          status: 'open',
          isDraft: false,
          paidStatus: 'unpaid',
          createdAt: DateTime(2023),
          updatedAt: DateTime(2023),
          content: const []),
      resp: ChatRoomEntity(
          id: 'cr1',
          participants: const [],
          type: 't',
          roomId: 'r1',
          senderId: 's1',
          taskId: 't1',
          createdAt: DateTime(2023)));

  group('GetTaskDetailEvent', () {
    blocTest<TaskBloc, TaskState>(
      'emits [loading, success] when successful',
      build: () {
        when(() => mockGetTaskDetail(any()))
            .thenAnswer((_) async => Right(tTaskAssignedEntity));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetTaskDetailEvent(tTaskId)),
      expect: () => [
        const TaskState().copyWith(
            taskDetailStatus: TaskStatus.loading,
            clearTaskDetail: true,
            clearErrorMessage: true),
        const TaskState().copyWith(
          taskDetail: tTaskAssignedEntity,
          taskDetailStatus: TaskStatus.success,
        ),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'emits [loading, failure] when failed',
      build: () {
        when(() => mockGetTaskDetail(any())).thenAnswer(
            (_) async => const Left(ServerFailure(message: 'Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetTaskDetailEvent(tTaskId)),
      expect: () => [
        const TaskState().copyWith(
            taskDetailStatus: TaskStatus.loading,
            clearTaskDetail: true,
            clearErrorMessage: true),
        const TaskState().copyWith(
            taskDetailStatus: TaskStatus.failure, errorMessage: 'Error'),
      ],
    );
  });

  group('AcceptRejectTaskEvent', () {
    blocTest<TaskBloc, TaskState>(
        'emits [loading, success] and tracks acceptance',
        build: () {
          when(() => mockAcceptRejectTask(any()))
              .thenAnswer((_) async => const Right(null));
          return bloc;
        },
        act: (bloc) => bloc.add(const AcceptRejectTaskEvent(
            taskId: '1', mediaHouseId: 'MH1', status: 'accepted')),
        expect: () => [
              const TaskState().copyWith(actionStatus: TaskStatus.loading),
              const TaskState().copyWith(
                  actionStatus: TaskStatus.success,
                  successMessage: "Task accepted successfully"),
            ],
        verify: (_) {
          verify(() => mockAnalytics.logEvent(
              name: EventNames.taskAccepted,
              parameters: any(named: 'parameters'))).called(1);
        });
  });

  group('FetchAllTasksEvent', () {
    final tTaskAll = AllTaskModel(
        id: '1',
        userId: 'u1',
        heading: 'Task 1',
        createdAt: 'date',
        description: 'desc',
        location: 'loc',
        status: 'pending');
    final tTasks = <AllTaskModel>[tTaskAll];

    blocTest<TaskBloc, TaskState>(
      'emits [loading, success] on first load',
      build: () {
        when(() => mockGetAllTasks(any()))
            .thenAnswer((_) async => Right(tTasks));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchAllTasksEvent(offset: 0)),
      expect: () => [
        const TaskState().copyWith(
            allTasksStatus: TaskStatus.loading, clearErrorMessage: true),
        const TaskState().copyWith(
            allTasks: tTasks, allTasksStatus: TaskStatus.success),
      ],
    );
  });

  group('FetchLocalTasksEvent', () {
    final tTask = TaskPending(
        status: 'pending',
        totalAmount: '100',
        title: 'Start Task',
        body: 'body',
        broadCastId: 'bid');
    final tTasks = <Task>[tTask];

    blocTest<TaskBloc, TaskState>(
      'emits [loading, success]',
      build: () {
        when(() => mockGetLocalTasks(any()))
            .thenAnswer((_) async => Right(tTasks));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchLocalTasksEvent()),
      expect: () => [
        const TaskState().copyWith(
            localTasksStatus: TaskStatus.loading, clearErrorMessage: true),
        const TaskState().copyWith(
            localTasks: tTasks, localTasksStatus: TaskStatus.success),
      ],
    );
  });

  group('GetRoomIdEvent', () {
    const tRoomId = 'room123';
    blocTest<TaskBloc, TaskState>('emits [RoomIdLoaded] when successful',
        build: () {
          when(() => mockGetRoomId(any()))
              .thenAnswer((_) async => const Right(tRoomId));
          return bloc;
        },
        act: (bloc) => bloc.add(const GetRoomIdEvent(
            receiverId: 'r1', taskId: 't1', roomType: 'rt', type: 't')),
        expect: () => [
          const TaskState(actionStatus: TaskStatus.loading),
          const TaskState(roomId: tRoomId, actionStatus: TaskStatus.initial),
        ],
      );
  });

  group('GetHopperAcceptedCountEvent', () {
    const tCount = '5';
    blocTest<TaskBloc, TaskState>(
        'emits [HopperAcceptedCountLoaded] when successful',
        build: () {
          when(() => mockGetHopperAcceptedCount(any()))
              .thenAnswer((_) async => const Right(tCount));
          return bloc;
        },
        act: (bloc) => bloc.add(const GetHopperAcceptedCountEvent('t1')),
        expect: () => [const TaskState(hopperAcceptedCount: tCount)]);
  });
}
