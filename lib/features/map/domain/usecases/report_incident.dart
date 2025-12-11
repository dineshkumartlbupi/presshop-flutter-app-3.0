import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/map/domain/entities/geo_point.dart';
import 'package:presshop/features/map/domain/entities/incident_entity.dart';
import 'package:presshop/features/map/domain/repositories/map_repository.dart';

class ReportIncidentParams extends Equatable {
  final String alertType;
  final GeoPoint position;

  const ReportIncidentParams({
    required this.alertType,
    required this.position,
  });

  @override
  List<Object> get props => [alertType, position];
}

class ReportIncident implements UseCase<IncidentEntity, ReportIncidentParams> {
  final MapRepository repository;

  ReportIncident(this.repository);

  @override
  Future<Either<Failure, IncidentEntity>> call(ReportIncidentParams params) async {
    return await repository.reportIncident(params.alertType, params.position);
  }
}
