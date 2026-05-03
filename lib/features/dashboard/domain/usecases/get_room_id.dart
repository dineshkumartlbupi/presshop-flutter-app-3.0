import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/dashboard_repository.dart';

class GetRoomId implements UseCase<Map<String, dynamic>, Map<String, dynamic>> {
  GetRoomId(this.repository);
  final DashboardRepository repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      Map<String, dynamic> params) async {
    return await repository.getRoomId(params);
  }
}
