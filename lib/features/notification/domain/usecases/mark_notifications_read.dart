import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/notification_repository.dart';

class MarkNotificationsAsRead {
  final NotificationRepository repository;

  MarkNotificationsAsRead(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.markNotificationsAsRead();
  }
}
