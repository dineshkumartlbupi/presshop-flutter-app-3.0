import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/map/domain/entities/geo_point.dart';
import 'package:presshop/features/map/domain/repositories/map_repository.dart';

class GetCurrentLocation implements UseCase<GeoPoint, NoParams> {
  final MapRepository repository;

  GetCurrentLocation(this.repository);

  @override
  Future<Either<Failure, GeoPoint>> call(NoParams params) async {
    return await repository.getCurrentLocation();
  }
}
