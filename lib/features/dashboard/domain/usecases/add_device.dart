import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/dashboard_repository.dart';

class AddDevice implements UseCase<void, AddDeviceParams> {
  final DashboardRepository repository;

  AddDevice(this.repository);

  @override
  Future<Either<Failure, void>> call(AddDeviceParams params) async {
    return await repository.addDevice(params.data);
  }
}

class AddDeviceParams extends Equatable {
  final Map<String, dynamic> data;

  const AddDeviceParams(this.data);

  @override
  List<Object> get props => [data];
}
