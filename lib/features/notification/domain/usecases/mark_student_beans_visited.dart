import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/notification_repository.dart';

class MarkStudentBeansVisited {
  final NotificationRepository repository;

  MarkStudentBeansVisited(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.markStudentBeansVisited();
  }
}
