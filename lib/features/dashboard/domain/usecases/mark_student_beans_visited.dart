import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/dashboard_repository.dart';

class MarkStudentBeansVisited implements UseCase<void, NoParams> {
  MarkStudentBeansVisited(this.repository);
  final DashboardRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.markStudentBeansVisited();
  }
}
