import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../entities/student_beans_info.dart';
import '../repositories/dashboard_repository.dart';

class CheckStudentBeans implements UseCase<StudentBeansInfo, NoParams> {

  CheckStudentBeans(this.repository);
  final DashboardRepository repository;

  @override
  Future<Either<Failure, StudentBeansInfo>> call(NoParams params) async {
    return await repository.checkStudentBeans();
  }
}
