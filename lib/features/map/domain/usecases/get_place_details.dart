import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/map/domain/entities/geo_point.dart';
import 'package:presshop/features/map/domain/repositories/map_repository.dart';

class GetPlaceDetails implements UseCase<GeoPoint, String> {
  final MapRepository repository;

  GetPlaceDetails(this.repository);

  @override
  Future<Either<Failure, GeoPoint>> call(String placeId) async {
    return await repository.getPlaceDetails(placeId);
  }
}
