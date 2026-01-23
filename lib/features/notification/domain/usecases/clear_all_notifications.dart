import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/notification_repository.dart';

class ClearAllNotifications {
  ClearAllNotifications(this.repository);
  final NotificationRepository repository;

  Future<Either<Failure, void>> call() async {
    return await repository.clearAllNotifications();
  }
}
