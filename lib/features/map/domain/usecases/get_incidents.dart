import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/map/domain/entities/incident_entity.dart';
import 'package:presshop/features/map/domain/repositories/map_repository.dart';

class GetIncidents implements UseCase<List<IncidentEntity>, NoParams> {
  final MapRepository repository;

  GetIncidents(this.repository);

  @override
  Future<Either<Failure, List<IncidentEntity>>> call(NoParams params) async {
    return await repository.getIncidents();
  }
}
