import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetNotifications {
  GetNotifications(this.repository);
  final NotificationRepository repository;

  Future<Either<Failure, NotificationsResult>> call(
      {int limit = 10, int offset = 0}) async {
    return await repository.getNotifications(limit, offset);
  }
}
