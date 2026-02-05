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
      'emits [TaskLoading, TaskDetailLoaded] when successful',
      build: () {
        when(() => mockGetTaskDetail(any()))
            .thenAnswer((_) async => Right(tTaskAssignedEntity));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetTaskDetailEvent(tTaskId)),
      expect: () => [
        TaskLoading(),
        TaskDetailLoaded(tTaskAssignedEntity),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TaskError] when failed',
      build: () {
        when(() => mockGetTaskDetail(any())).thenAnswer(
            (_) async => const Left(ServerFailure(message: 'Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetTaskDetailEvent(tTaskId)),
      expect: () => [
        TaskLoading(),
        const TaskError('Error'),
      ],
    );
  });

  group('AcceptRejectTaskEvent', () {
    blocTest<TaskBloc, TaskState>(
        'emits [TaskLoading, TaskActionSuccess] and tracks acceptance',
        build: () {
          when(() => mockAcceptRejectTask(any()))
              .thenAnswer((_) async => const Right(null));
          return bloc;
        },
        act: (bloc) => bloc.add(const AcceptRejectTaskEvent(
            taskId: '1', mediaHouseId: 'MH1', status: 'accepted')),
        expect: () => [
              TaskLoading(),
              const TaskActionSuccess('Task accepted successfully'),
            ],
        verify: (_) {
          verify(() => mockAnalytics.logEvent(
              name: EventNames.taskAccepted,
              parameters: any(named: 'parameters'))).called(1);
        });
  });

  group('FetchAllTasksEvent', () {
    final tTaskAll = TaskAll(
        id: '1',
        userId: 'u1',
        heading: 'Task 1', // Corrected parameter
        createdAt: 'date',
        description: 'desc',
        location: 'loc',
        status: 'pending');
    final tTasks = <TaskAll>[tTaskAll];

    blocTest<TaskBloc, TaskState>(
      'emits [TasksLoaded(loading), TasksLoaded(success)] on first load',
      build: () {
        when(() => mockGetAllTasks(any()))
            .thenAnswer((_) async => Right(tTasks));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchAllTasksEvent(offset: 0)),
      expect: () => [
        const TasksLoaded(allTasksStatus: TaskStatus.loading),
        TasksLoaded(allTasks: tTasks, allTasksStatus: TaskStatus.success),
      ],
    );
  });

  group('FetchLocalTasksEvent', () {
    final tTask = TaskPending(
        status: 'pending',
        totalAmount: '100', // Task abstract param
        title: 'Start Task', // TaskPending specific param
        body: 'body',
        broadCastId: 'bid');
    final tTasks = <Task>[tTask];

    blocTest<TaskBloc, TaskState>(
      'emits [TasksLoaded(loading), TasksLoaded(success)]',
      build: () {
        when(() => mockGetLocalTasks(any()))
            .thenAnswer((_) async => Right(tTasks));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchLocalTasksEvent()),
      expect: () => [
        const TasksLoaded(localTasksStatus: TaskStatus.loading),
        TasksLoaded(localTasks: tTasks, localTasksStatus: TaskStatus.success),
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
        expect: () => [const RoomIdLoaded(tRoomId)]);
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
        expect: () => [const HopperAcceptedCountLoaded(tCount)]);
  });
}
