import 'package:dartz/dartz.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presshop/core/error/exceptions.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/map/data/datasources/map_remote_data_source.dart';
import 'package:presshop/features/map/domain/entities/route_info.dart';
import 'package:presshop/features/map/data/models/marker_model.dart';
import 'package:presshop/features/map/domain/repositories/map_repository.dart';

class MapRepositoryImpl implements MapRepository {
  MapRepositoryImpl({required this.remoteDataSource});
  final MapRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, RouteInfo>> getRoute(LatLng start, LatLng end) async {
    try {
      final result = await remoteDataSource.getRoute(start, end);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getPlaceSuggestions(
      String input) async {
    try {
      final result = await remoteDataSource.getPlaceSuggestions(input);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LatLng>> getPlaceDetails(String placeId) async {
    try {
      final result = await remoteDataSource.getPlaceDetails(placeId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, LatLng>> getCurrentLocation() async {
    try {
      final result = await remoteDataSource.getCurrentLocation();
      return Right(result);
    } on LocationException catch (e) {
      return Left(LocationFailure(message: e.message));
    } catch (e) {
      return Left(LocationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Incident>>> getIncidents({
    double? lat,
    double? lng,
    double? km,
    String? category,
  }) async {
    try {
      final result = await remoteDataSource.getIncidents(
        lat: lat,
        lng: lng,
        km: km,
        category: category,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> reportIncident(
      Map<String, dynamic> data) async {
    try {
      await remoteDataSource.reportIncident(data);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getAddressFromCoordinates(
      LatLng position) async {
    try {
      final result = await remoteDataSource.getAddressFromCoordinates(position);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
