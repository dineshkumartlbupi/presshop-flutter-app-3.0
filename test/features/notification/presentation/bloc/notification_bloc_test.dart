import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/dashboard/domain/usecases/activate_student_beans.dart';
import 'package:presshop/features/dashboard/domain/usecases/check_student_beans.dart';
import 'package:presshop/features/dashboard/domain/usecases/mark_student_beans_visited.dart';
import 'package:presshop/features/notification/domain/entities/notification_entity.dart';
import 'package:presshop/features/notification/domain/usecases/clear_all_notifications.dart';
import 'package:presshop/features/notification/domain/usecases/get_notifications.dart';
import 'package:presshop/features/notification/domain/usecases/mark_notifications_read.dart';
import 'package:presshop/features/notification/presentation/bloc/notification_bloc.dart';

class MockGetNotifications extends Mock implements GetNotifications {}

class MockMarkNotificationsAsRead extends Mock
    implements MarkNotificationsAsRead {}

class MockClearAllNotifications extends Mock implements ClearAllNotifications {}

class MockCheckStudentBeans extends Mock implements CheckStudentBeans {}

class MockActivateStudentBeans extends Mock implements ActivateStudentBeans {}

class MockMarkStudentBeansVisited extends Mock
    implements MarkStudentBeansVisited {}

void main() {
  late NotificationBloc bloc;
  late MockGetNotifications mockGetNotifications;
  late MockMarkNotificationsAsRead mockMarkNotificationsAsRead;
  late MockClearAllNotifications mockClearAllNotifications;
  late MockCheckStudentBeans mockCheckStudentBeans;
  late MockActivateStudentBeans mockActivateStudentBeans;
  late MockMarkStudentBeansVisited mockMarkStudentBeansVisited;

  setUp(() {
    mockGetNotifications = MockGetNotifications();
    mockMarkNotificationsAsRead = MockMarkNotificationsAsRead();
    mockClearAllNotifications = MockClearAllNotifications();
    mockCheckStudentBeans = MockCheckStudentBeans();
    mockActivateStudentBeans = MockActivateStudentBeans();
    mockMarkStudentBeansVisited = MockMarkStudentBeansVisited();

    bloc = NotificationBloc(
      getNotifications: mockGetNotifications,
      markNotificationsAsRead: mockMarkNotificationsAsRead,
      clearAllNotifications: mockClearAllNotifications,
      checkStudentBeans: mockCheckStudentBeans,
      activateStudentBeans: mockActivateStudentBeans,
      markStudentBeansVisited: mockMarkStudentBeansVisited,
    );

    registerFallbackValue(NoParams());
  });

  const tNotification = NotificationEntity(
    id: '1',
    title: 'Test',
    description: 'Desc',
    time: 'now',
    senderImage: '',
    messageType: 'type',
    senderId: 's1',
    paymentStatus: 'pending',
    contentId: 'c1',
    broadcastId: 'b1',
    imageUrl: '',
    videoUrl: '',
    exclusive: false,
    unread: true,
  );

  const tNotificationsResult = NotificationsResult(
    notifications: [tNotification],
    unreadCount: 1,
  );

  group('FetchNotificationsEvent', () {
    blocTest<NotificationBloc, NotificationState>(
      'emits [loading, success] when fetching notifications passes',
      build: () {
        when(() => mockGetNotifications(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            )).thenAnswer((_) async => const Right(tNotificationsResult));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchNotificationsEvent(offset: 0)),
      expect: () => [
        const NotificationState(
            status: NotificationStatus.loading, notifications: []),
        const NotificationState(
          status: NotificationStatus.success,
          notifications: [tNotification],
          unreadCount: 1,
        ),
      ],
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [failure] when fetching notifications fails',
      build: () {
        when(() => mockGetNotifications(
                  limit: any(named: 'limit'),
                  offset: any(named: 'offset'),
                ))
            .thenAnswer(
                (_) async => const Left(ServerFailure(message: 'Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchNotificationsEvent(offset: 0)),
      expect: () => [
        const NotificationState(
            status: NotificationStatus.loading, notifications: []),
        const NotificationState(
          status: NotificationStatus.failure,
          errorMessage: 'Error',
        ),
      ],
    );
  });

  group('ClearAllNotificationsEvent', () {
    blocTest<NotificationBloc, NotificationState>(
      'emits [empty] and sets notifications to [] when cleared successfully',
      build: () {
        when(() => mockClearAllNotifications())
            .thenAnswer((_) async => const Right(true));
        return bloc;
      },
      act: (bloc) => bloc.add(const ClearAllNotificationsEvent()),
      expect: () => [
        const NotificationState(
            notifications: [], status: NotificationStatus.empty),
      ],
    );
  });
}
