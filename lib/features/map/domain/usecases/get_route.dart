import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/map/domain/entities/geo_point.dart';
import 'package:presshop/features/map/domain/entities/route_info_entity.dart';
import 'package:presshop/features/map/domain/repositories/map_repository.dart';

class GetRouteParams extends Equatable {
  final GeoPoint start;
  final GeoPoint end;

  const GetRouteParams({
    required this.start,
    required this.end,
  });

  @override
  List<Object> get props => [start, end];
}

class GetRoute implements UseCase<RouteInfoEntity, GetRouteParams> {
  final MapRepository repository;

  GetRoute(this.repository);

  @override
  Future<Either<Failure, RouteInfoEntity>> call(GetRouteParams params) async {
    return await repository.getRoute(params.start, params.end);
  }
}
