import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../repositories/dashboard_repository.dart';

class RemoveDevice implements UseCase<void, RemoveDeviceParams> {
  final DashboardRepository repository;

  RemoveDevice(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveDeviceParams params) async {
    return await repository.removeDevice(params.toMap());
  }
}

class RemoveDeviceParams extends Equatable {
  final String deviceId;

  const RemoveDeviceParams({required this.deviceId});

  Map<String, dynamic> toMap() => {
        "device_id": deviceId,
      };

  @override
  List<Object> get props => [deviceId];
}
