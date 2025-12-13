import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import '../entities/admin_detail.dart';
import 'package:presshop/features/task/domain/entities/task_detail.dart';

abstract class DashboardRepository {
  Future<Either<Failure, List<AdminDetail>>> getActiveAdmins();
  Future<Either<Failure, void>> updateLocation(Map<String, dynamic> params);
  Future<Either<Failure, void>> addDevice(Map<String, dynamic> params);
  Future<Either<Failure, TaskDetail>> getTaskDetail(String id);
  Future<Either<Failure, Map<String, dynamic>>> getRoomId();
  Future<Either<Failure, Map<String, dynamic>>> checkAppVersion();
  Future<Either<Failure, Map<String, dynamic>>> activateStudentBeans();
  Future<Either<Failure, void>> removeDevice(Map<String, dynamic> params);
}
