import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/notification_repository.dart';

class ActivateStudentBeans {
  final NotificationRepository repository;

  ActivateStudentBeans(this.repository);

  Future<Either<Failure, String>> call() async {
    return await repository.activateStudentBeans();
  }
}
