import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/dashboard_repository.dart';

class GetRoomId implements UseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final DashboardRepository repository;

  GetRoomId(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      Map<String, dynamic> params) async {
    return await repository.getRoomId(params);
  }
}
