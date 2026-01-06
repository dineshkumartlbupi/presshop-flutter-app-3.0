import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/map/domain/repositories/map_repository.dart';

class ReportIncident implements UseCase<void, ReportIncidentParams> {
  final MapRepository repository;

  ReportIncident(this.repository);

  @override
  Future<Either<Failure, void>> call(ReportIncidentParams params) async {
    return await repository.reportIncident(params.data);
  }
}

class ReportIncidentParams {
  final Map<String, dynamic> data;

  ReportIncidentParams(this.data);
}
