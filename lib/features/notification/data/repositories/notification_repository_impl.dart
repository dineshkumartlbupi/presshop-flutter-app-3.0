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
      } else if (nestedData is List) {
        notifications = nestedData
            .whereType<Map<String, dynamic>>()
            .map((e) => NotificationModel.fromJson(e))
            .toList();
      }

      // Robust extraction of counts from either root or nested level
      unreadCount = int.tryParse(
              (remoteData['unreadCount'] ??
               remoteData['unread_count'] ??
               (nestedData is Map ? nestedData['unreadCount'] : null) ??
               (nestedData is Map ? nestedData['unread_count'] : null) ??
               '0').toString()) ?? 0;

      alertCount = int.tryParse(
              (remoteData['hopperAlertCount'] ??
               remoteData['alert_count'] ??
               remoteData['hopper_alert_count'] ??
               (nestedData is Map ? nestedData['hopperAlertCount'] : null) ??
               (nestedData is Map ? nestedData['alert_count'] : null) ??
               (nestedData is Map ? nestedData['hopper_alert_count'] : null) ??
               '0').toString()) ?? 0;

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
