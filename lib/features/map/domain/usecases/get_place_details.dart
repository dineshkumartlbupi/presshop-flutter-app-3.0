import 'package:dartz/dartz.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/map/domain/repositories/map_repository.dart';

class GetPlaceDetails implements UseCase<LatLng, String> {
  final MapRepository repository;

  GetPlaceDetails(this.repository);

  @override
  Future<Either<Failure, LatLng>> call(String placeId) async {
    return await repository.getPlaceDetails(placeId);
  }
}
