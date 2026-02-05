import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/dashboard_repository.dart';

class UpdateLocation implements UseCase<void, UpdateLocationParams> {

  UpdateLocation(this.repository);
  final DashboardRepository repository;

  @override
  Future<Either<Failure, void>> call(UpdateLocationParams params) async {
    return await repository.updateLocation(params.data);
  }
}

class UpdateLocationParams extends Equatable {

  const UpdateLocationParams(this.data);
  final Map<String, dynamic> data;

  @override
  List<Object> get props => [data];
}
