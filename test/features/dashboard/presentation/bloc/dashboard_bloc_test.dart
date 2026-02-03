import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:presshop/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:presshop/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:presshop/features/dashboard/domain/usecases/add_device.dart';
import 'package:presshop/features/dashboard/domain/usecases/get_active_admins.dart';
import 'package:presshop/features/dashboard/domain/usecases/get_dashboard_task_detail.dart';
import 'package:presshop/features/dashboard/domain/usecases/get_room_id.dart';
import 'package:presshop/features/dashboard/domain/usecases/update_location.dart';
import 'package:presshop/features/dashboard/domain/usecases/check_app_version.dart';
import 'package:presshop/features/dashboard/domain/usecases/activate_student_beans.dart';
import 'package:presshop/features/dashboard/domain/usecases/check_student_beans.dart';
import 'package:presshop/features/dashboard/domain/usecases/mark_student_beans_visited.dart';
import 'package:presshop/features/authentication/domain/usecases/get_profile.dart';
import 'package:presshop/features/authentication/domain/entities/user.dart';
import 'package:presshop/features/dashboard/domain/entities/student_beans_info.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/task/domain/entities/task_assigned_entity.dart';

class MockGetActiveAdmins extends Mock implements GetActiveAdmins {}

class MockUpdateLocation extends Mock implements UpdateLocation {}

class MockAddDevice extends Mock implements AddDevice {}

class MockGetDashboardTaskDetail extends Mock
    implements GetDashboardTaskDetail {}

class MockGetRoomId extends Mock implements GetRoomId {}

class MockCheckAppVersion extends Mock implements CheckAppVersion {}

class MockActivateStudentBeans extends Mock implements ActivateStudentBeans {}

class MockCheckStudentBeans extends Mock implements CheckStudentBeans {}

class MockMarkStudentBeansVisited extends Mock
    implements MarkStudentBeansVisited {}

class MockGetProfile extends Mock implements GetProfile {}

void main() {
  late DashboardBloc bloc;
  late MockGetActiveAdmins mockGetActiveAdmins;
  late MockUpdateLocation mockUpdateLocation;
  late MockAddDevice mockAddDevice;
  late MockGetDashboardTaskDetail mockGetDashboardTaskDetail;
  late MockGetRoomId mockGetRoomId;
  late MockCheckAppVersion mockCheckAppVersion;
  late MockActivateStudentBeans mockActivateStudentBeans;
  late MockCheckStudentBeans mockCheckStudentBeans;
  late MockMarkStudentBeansVisited mockMarkStudentBeansVisited;
  late MockGetProfile mockGetProfile;

  setUp(() {
    mockGetActiveAdmins = MockGetActiveAdmins();
    mockUpdateLocation = MockUpdateLocation();
    mockAddDevice = MockAddDevice();
    mockGetDashboardTaskDetail = MockGetDashboardTaskDetail();
    mockGetRoomId = MockGetRoomId();
    mockCheckAppVersion = MockCheckAppVersion();
    mockActivateStudentBeans = MockActivateStudentBeans();
    mockCheckStudentBeans = MockCheckStudentBeans();
    mockMarkStudentBeansVisited = MockMarkStudentBeansVisited();
    mockGetProfile = MockGetProfile();

    bloc = DashboardBloc(
      getActiveAdmins: mockGetActiveAdmins,
      updateLocation: mockUpdateLocation,
      addDevice: mockAddDevice,
      getDashboardTaskDetail: mockGetDashboardTaskDetail,
      getRoomId: mockGetRoomId,
      checkAppVersion: mockCheckAppVersion,
      activateStudentBeans: mockActivateStudentBeans,
      checkStudentBeans: mockCheckStudentBeans,
      markStudentBeansVisited: mockMarkStudentBeansVisited,
      getProfile: mockGetProfile,
    );
  });

  setUpAll(() {
    registerFallbackValue(NoParams());
    registerFallbackValue(const UpdateLocationParams({}));
    registerFallbackValue(const AddDeviceParams({}));
  });

  const tTaskId = 'task123';
  const tUser = User(id: '1', firstName: 'F', lastName: 'L', email: 'e');
  const tStudentBeansInfo = StudentBeansInfo(shouldShow: true);

  group('DashboardBloc', () {
    test('initial state should be DashboardInitial', () {
      expect(bloc.state, equals(DashboardInitial()));
    });

    blocTest<DashboardBloc, DashboardState>(
      'emits [DashboardActiveAdminsLoaded] when FetchActiveAdmins succeeds',
      build: () {
        when(() => mockGetActiveAdmins(any()))
            .thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchActiveAdmins()),
      expect: () => [
        const DashboardActiveAdminsLoaded([]),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits [DashboardLocationUpdated] when UpdateLocationEvent succeeds',
      build: () {
        when(() => mockUpdateLocation(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateLocationEvent({})),
      expect: () => [
        DashboardLocationUpdated(),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits [DashboardDeviceAdded] when AddDeviceEvent succeeds',
      build: () {
        when(() => mockAddDevice(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const AddDeviceEvent({})),
      expect: () => [
        DashboardDeviceAdded(),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits [DashboardMyProfileLoaded] when FetchMyProfileEvent succeeds',
      build: () {
        when(() => mockGetProfile(any()))
            .thenAnswer((_) async => const Right(tUser));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchMyProfileEvent()),
      expect: () => [
        const DashboardMyProfileLoaded(tUser),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits [DashboardAppVersionChecked] when CheckAppVersionEvent succeeds',
      build: () {
        when(() => mockCheckAppVersion(any()))
            .thenAnswer((_) async => const Right({}));
        return bloc;
      },
      act: (bloc) => bloc.add(const CheckAppVersionEvent()),
      expect: () => [
        const DashboardAppVersionChecked({}),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits [DashboardStudentBeansInfoLoaded] when DashboardCheckStudentBeansEvent succeeds',
      build: () {
        when(() => mockCheckStudentBeans(any()))
            .thenAnswer((_) async => const Right(tStudentBeansInfo));
        return bloc;
      },
      act: (bloc) => bloc.add(const DashboardCheckStudentBeansEvent()),
      expect: () => [
        const DashboardStudentBeansInfoLoaded(tStudentBeansInfo),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits [DashboardLoading, DashboardTaskDetailLoaded] when FetchTaskDetailEvent succeeds',
      build: () {
        // Create a minimal mock ChatRoomEntity and TaskAssignedDetailEntity
        final tChatRoom = ChatRoomEntity(
          id: '1',
          participants: const [],
          type: 'task',
          roomId: 'r1',
          senderId: 's1',
          taskId: tTaskId,
          createdAt: tUserCreatedAt,
        );
        final tTaskAssignedEntity = TaskAssignedEntity(
          code: 200,
          task: TaskAssignedDetailEntity(
            id: tTaskId,
            mediaHouse: const MediaHouseEntity(
              id: 'm1',
              firstName: 'M',
              lastName: 'H',
              email: 'm@h.com',
              phone: '1',
              role: 'media',
              profileImage: '',
            ),
            deadlineDate: tUserCreatedAt,
            heading: 'H',
            description: 'D',
            location: 'L',
            addressLocation:
                const AddressLocationEntity(type: 'Point', coordinates: [0, 0]),
            status: 'active',
            isDraft: false,
            paidStatus: 'unpaid',
            createdAt: tUserCreatedAt,
            updatedAt: tUserCreatedAt,
            content: const [],
          ),
          resp: tChatRoom,
        );
        when(() => mockGetDashboardTaskDetail(any()))
            .thenAnswer((_) async => Right(tTaskAssignedEntity));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchTaskDetailEvent(tTaskId)),
      expect: () => [
        DashboardLoading(),
        anyOf(isA<DashboardTaskDetailLoaded>()),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits [DashboardRoomIdLoaded] when FetchRoomIdEvent succeeds',
      build: () {
        const tRoomData = {'roomId': '123'};
        when(() => mockGetRoomId(any()))
            .thenAnswer((_) async => const Right(tRoomData));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchRoomIdEvent({})),
      expect: () => [
        const DashboardRoomIdLoaded({'roomId': '123'}),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits [StudentBeansActivated] when ActivateStudentBeansEvent succeeds',
      build: () {
        when(() => mockActivateStudentBeans(any()))
            .thenAnswer((_) async => const Right({}));
        return bloc;
      },
      act: (bloc) => bloc.add(const ActivateStudentBeansEvent()),
      expect: () => [
        const StudentBeansActivated({}),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits [DashboardMarkStudentBeansVisitedLoaded] when DashboardMarkStudentBeansVisitedEvent succeeds',
      build: () {
        when(() => mockMarkStudentBeansVisited(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const DashboardMarkStudentBeansVisitedEvent()),
      expect: () => [
        DashboardMarkStudentBeansVisitedLoaded(),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits [DashboardTabChanged] when ChangeDashboardTabEvent is added',
      build: () => bloc,
      act: (bloc) => bloc.add(const ChangeDashboardTabEvent(1)),
      expect: () => [
        const DashboardTabChanged(1),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits [DashboardError] when FetchActiveAdmins fails',
      build: () {
        when(() => mockGetActiveAdmins(any())).thenAnswer(
            (_) async => const Left(ServerFailure(message: 'Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchActiveAdmins()),
      expect: () => [
        const DashboardError("Failed to fetch active admins"),
      ],
    );
  });
}

final tUserCreatedAt = DateTime(2023);
