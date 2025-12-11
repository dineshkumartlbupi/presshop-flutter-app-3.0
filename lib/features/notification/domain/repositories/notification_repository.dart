import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Either<Failure, NotificationsResult>> getNotifications(int limit, int offset);
  Future<Either<Failure, void>> markNotificationsAsRead();
  Future<Either<Failure, void>> clearAllNotifications();
  Future<Either<Failure, StudentBeansInfo>> checkStudentBeans();
  Future<Either<Failure, String>> activateStudentBeans();
}
