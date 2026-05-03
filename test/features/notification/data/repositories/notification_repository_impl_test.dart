import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:presshop/features/notification/data/datasources/notification_remote_datasource.dart';

class MockNotificationRemoteDataSource extends Mock
    implements NotificationRemoteDataSource {}

void main() {
  late NotificationRepositoryImpl repository;
  late MockNotificationRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockNotificationRemoteDataSource();
    repository =
        NotificationRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('getNotifications', () {
    final tNotificationsResponse = {
      'data': {
        'data': [
          {
            '_id': '1',
            'title': 'Test Title',
            'body': 'Test Body',
            'createdAt': '2023-01-01',
            'is_read': true,
            'message_type': 'info',
            'sender_id': 'sender1',
          }
        ],
        'unreadCount': 5,
        'hopperAlertCount': 2,
      }
    };

    test(
        'should return NotificationsResult when the call to remote data source is successful',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getNotifications(any(), any()))
          .thenAnswer((_) async => tNotificationsResponse);

      // act
      final result = await repository.getNotifications(10, 0);

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (data) {
          expect(data.notifications.length, 1);
          expect(data.notifications[0].id, '1');
          expect(data.unreadCount, 5);
          expect(data.alertCount, 2);
        },
      );
    });

    test(
        'should return ServerFailure when the call to remote data source fails',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getNotifications(any(), any()))
          .thenThrow(Exception('Server Error'));

      // act
      final result = await repository.getNotifications(10, 0);

      // assert
      expect(result.isLeft(), true);
    });
  });

  group('markNotificationsAsRead', () {
    test('should return Right(null) when call is successful', () async {
      // arrange
      when(() => mockRemoteDataSource.markNotificationsAsRead())
          .thenAnswer((_) async {});

      // act
      final result = await repository.markNotificationsAsRead();

      // assert
      expect(result, const Right(null));
    });

    test('should return ServerFailure when call fails', () async {
      // arrange
      when(() => mockRemoteDataSource.markNotificationsAsRead())
          .thenThrow(Exception('Error'));

      // act
      final result = await repository.markNotificationsAsRead();

      // assert
      expect(result.isLeft(), true);
    });
  });
}
