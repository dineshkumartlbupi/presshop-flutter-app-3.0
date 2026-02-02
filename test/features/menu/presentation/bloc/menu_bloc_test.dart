import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:presshop/features/authentication/domain/usecases/logout_user.dart';
import 'package:presshop/features/dashboard/domain/usecases/remove_device.dart';
import 'package:presshop/features/menu/domain/services/menu_service.dart';
import 'package:presshop/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:presshop/features/notification/domain/entities/notification_entity.dart';
import 'package:presshop/features/notification/domain/usecases/get_notifications.dart';

class MockGetNotifications extends Mock implements GetNotifications {}

class MockRemoveDevice extends Mock implements RemoveDevice {}

class MockLogoutUser extends Mock implements LogoutUser {}

class MockMenuService extends Mock implements MenuService {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late MenuBloc bloc;
  late MockGetNotifications mockGetNotifications;
  late MockRemoveDevice mockRemoveDevice;
  late MockLogoutUser mockLogoutUser;
  late MockMenuService mockMenuService;
  late MockAuthLocalDataSource mockAuthLocalDataSource;

  setUp(() {
    mockGetNotifications = MockGetNotifications();
    mockRemoveDevice = MockRemoveDevice();
    mockLogoutUser = MockLogoutUser();
    mockMenuService = MockMenuService();
    mockAuthLocalDataSource = MockAuthLocalDataSource();

    bloc = MenuBloc(
      getNotifications: mockGetNotifications,
      removeDevice: mockRemoveDevice,
      logoutUser: mockLogoutUser,
      menuService: mockMenuService,
      authLocalDataSource: mockAuthLocalDataSource,
    );

    registerFallbackValue(NoParams());
    registerFallbackValue(const RemoveDeviceParams(deviceId: 'test_id'));
  });

  tearDown(() {
    bloc.close();
  });

  group('MenuBloc', () {
    test('initial state is MenuState()', () {
      expect(bloc.state, const MenuState());
    });

    group('MenuLoadCounts', () {
      const tNotificationData =
          NotificationsResult(unreadCount: 5, alertCount: 2, notifications: []);

      blocTest<MenuBloc, MenuState>(
        'emits [success] with counts when GetNotifications succeeds',
        build: () {
          when(() => mockGetNotifications())
              .thenAnswer((_) async => const Right(tNotificationData));
          return bloc;
        },
        act: (bloc) => bloc.add(MenuLoadCounts()),
        expect: () => [
          const MenuState(
            status: MenuStatus.success,
            notificationCount: 5,
            alertCount: 2,
          ),
        ],
      );

      blocTest<MenuBloc, MenuState>(
        'emits [failure] when GetNotifications fails',
        build: () {
          when(() => mockGetNotifications()).thenAnswer(
              (_) async => const Left(ServerFailure(message: 'Server Error')));
          return bloc;
        },
        act: (bloc) => bloc.add(MenuLoadCounts()),
        expect: () => [
          const MenuState(status: MenuStatus.failure),
        ],
      );
    });

    group('MenuLogoutRequested', () {
      const tDeviceId = 'test_device_id';

      blocTest<MenuBloc, MenuState>(
          'emits [loading, success] when logout succeeds',
          build: () {
            when(() => mockMenuService.getDeviceId())
                .thenAnswer((_) async => tDeviceId);
            when(() => mockRemoveDevice(any()))
                .thenAnswer((_) async => const Right(null));
            when(() => mockMenuService.clearSession()).thenAnswer((_) async {});
            when(() => mockAuthLocalDataSource.clearCache())
                .thenAnswer((_) async {});
            when(() => mockMenuService.googleSignOut())
                .thenAnswer((_) async {});
            when(() => mockLogoutUser(any()))
                .thenAnswer((_) async => const Right(null));
            return bloc;
          },
          act: (bloc) => bloc.add(MenuLogoutRequested()),
          expect: () => [
                const MenuState(logoutStatus: MenuLogoutStatus.loading),
                const MenuState(logoutStatus: MenuLogoutStatus.success),
              ],
          verify: (_) {
            verify(() => mockMenuService.getDeviceId()).called(1);
            verify(() => mockRemoveDevice(any())).called(1);
            verify(() => mockMenuService.clearSession()).called(1);
            verify(() => mockAuthLocalDataSource.clearCache()).called(1);
            verify(() => mockLogoutUser(any())).called(1);
          });

      blocTest<MenuBloc, MenuState>(
        'emits [loading, failure] when logout fails',
        build: () {
          when(() => mockMenuService.getDeviceId())
              .thenAnswer((_) async => tDeviceId);
          when(() => mockRemoveDevice(any()))
              .thenAnswer((_) async => const Right(null));
          when(() => mockMenuService.clearSession()).thenAnswer((_) async {});
          when(() => mockAuthLocalDataSource.clearCache())
              .thenAnswer((_) async {});
          when(() => mockMenuService.googleSignOut()).thenAnswer((_) async {});
          when(() => mockLogoutUser(any())).thenAnswer(
              (_) async => const Left(ServerFailure(message: 'Logout Error')));
          return bloc;
        },
        act: (bloc) => bloc.add(MenuLogoutRequested()),
        expect: () => [
          const MenuState(logoutStatus: MenuLogoutStatus.loading),
          const MenuState(
              logoutStatus: MenuLogoutStatus.failure,
              errorMessage: 'Logout failed'),
        ],
      );
    });
  });
}
