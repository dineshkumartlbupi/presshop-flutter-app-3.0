import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({required this.remoteDataSource});
  final NotificationRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, NotificationsResult>> getNotifications(
      int limit, int offset) async {
    try {
      final remoteData = await remoteDataSource.getNotifications(limit, offset);

      List<NotificationModel> notifications = [];
      int unreadCount = 0;
      int alertCount = 0;

      // Handle cases where response might be wrapped in 'data' or not
      final dynamic nestedData = remoteData['data'] ?? remoteData;

      if (nestedData is Map<String, dynamic>) {
        final dynamic listData = nestedData['data'];
        if (listData is List) {
          notifications = listData
              .whereType<Map<String, dynamic>>()
              .map((e) => NotificationModel.fromJson(e))
              .toList();
        }
        unreadCount = nestedData['unreadCount'] ?? 0;
        alertCount = nestedData['hopperAlertCount'] ?? 0;
      } else if (nestedData is List) {
        notifications = nestedData
            .whereType<Map<String, dynamic>>()
            .map((e) => NotificationModel.fromJson(e))
            .toList();
      }

      return Right(NotificationsResult(
        notifications: notifications,
        unreadCount: unreadCount,
        alertCount: alertCount,
      ));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markNotificationsAsRead() async {
    try {
      await remoteDataSource.markNotificationsAsRead();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllNotifications() async {
    try {
      await remoteDataSource.clearAllNotifications();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
