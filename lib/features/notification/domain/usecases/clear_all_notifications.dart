import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/notification_repository.dart';

class ClearAllNotifications {
  final NotificationRepository repository;

  ClearAllNotifications(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.clearAllNotifications();
  }
}
