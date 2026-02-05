import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/map/data/models/marker_model.dart';
import 'package:presshop/features/map/domain/repositories/map_repository.dart';

class GetIncidents implements UseCase<List<Incident>, NoParams> {

  GetIncidents(this.repository);
  final MapRepository repository;

  @override
  Future<Either<Failure, List<Incident>>> call(NoParams params) async {
    return await repository.getIncidents();
  }
}
