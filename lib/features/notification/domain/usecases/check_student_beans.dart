import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class CheckStudentBeans {
  final NotificationRepository repository;

  CheckStudentBeans(this.repository);

  Future<Either<Failure, StudentBeansInfo>> call() async {
    return await repository.checkStudentBeans();
  }
}
