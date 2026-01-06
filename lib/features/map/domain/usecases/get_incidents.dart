import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/map/domain/entities/map_marker.dart';
import 'package:presshop/features/map/domain/repositories/map_repository.dart';

class GetIncidents implements UseCase<List<MapMarker>, NoParams> {
  final MapRepository repository;

  GetIncidents(this.repository);

  @override
  Future<Either<Failure, List<MapMarker>>> call(NoParams params) async {
    return await repository.getIncidents();
  }
}
