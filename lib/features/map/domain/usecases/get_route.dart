import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/map/domain/entities/route_info.dart';
import 'package:presshop/features/map/domain/repositories/map_repository.dart';

class GetRoute implements UseCase<RouteInfo, GetRouteParams> {
  final MapRepository repository;

  GetRoute(this.repository);

  @override
  Future<Either<Failure, RouteInfo>> call(GetRouteParams params) async {
    return await repository.getRoute(params.start, params.end);
  }
}

class GetRouteParams extends Equatable {
  final LatLng start;
  final LatLng end;

  const GetRouteParams({required this.start, required this.end});

  @override
  List<Object?> get props => [start, end];
}
