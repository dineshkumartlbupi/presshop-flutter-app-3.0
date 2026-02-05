import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import '../repositories/dashboard_repository.dart';

class AddDevice implements UseCase<void, AddDeviceParams> {

  AddDevice(this.repository);
  final DashboardRepository repository;

  @override
  Future<Either<Failure, void>> call(AddDeviceParams params) async {
    return await repository.addDevice(params.data);
  }
}

class AddDeviceParams extends Equatable {

  const AddDeviceParams(this.data);
  final Map<String, dynamic> data;

  @override
  List<Object> get props => [data];
}
