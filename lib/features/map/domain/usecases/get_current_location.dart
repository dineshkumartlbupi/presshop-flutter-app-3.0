import 'package:dartz/dartz.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/map/domain/repositories/map_repository.dart';

class GetCurrentLocation implements UseCase<LatLng, NoParams> {

  GetCurrentLocation(this.repository);
  final MapRepository repository;

  @override
  Future<Either<Failure, LatLng>> call(NoParams params) async {
    return await repository.getCurrentLocation();
  }
}
