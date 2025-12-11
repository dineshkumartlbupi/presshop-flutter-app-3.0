import 'package:dartz/dartz.dart';
import 'package:presshop/core/error/exception.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/map/data/datasources/map_remote_datasource.dart';
import 'package:presshop/features/map/domain/entities/geo_point.dart';
import 'package:presshop/features/map/domain/entities/incident_entity.dart';
import 'package:presshop/features/map/domain/entities/place_suggestion_entity.dart';
import 'package:presshop/features/map/domain/entities/route_info_entity.dart';
import 'package:presshop/features/map/domain/repositories/map_repository.dart';
import 'package:geolocator/geolocator.dart';

class MapRepositoryImpl implements MapRepository {
  final MapRemoteDataSource remoteDataSource;

  MapRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, GeoPoint>> getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Left(LocationFailure("Location services are disabled."));
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Left(LocationFailure("Location permissions are denied"));
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Left(LocationFailure("Location permissions are permanently denied, we cannot request permissions."));
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return Right(GeoPoint(pos.latitude, pos.longitude));
    } catch (e) {
      return Left(LocationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<IncidentEntity>>> getIncidents() async {
    try {
      final incidents = await remoteDataSource.getIncidents();
      return Right(incidents);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, IncidentEntity>> reportIncident(String alertType, GeoPoint position) async {
    try {
      final incident = await remoteDataSource.reportIncident(alertType, position);
      return Right(incident);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, RouteInfoEntity>> getRoute(GeoPoint start, GeoPoint end) async {
    try {
      final routeInfo = await remoteDataSource.getRoute(start, end);
      return Right(routeInfo);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<PlaceSuggestionEntity>>> searchPlaces(String query) async {
    try {
      final suggestions = await remoteDataSource.searchPlaces(query);
      return Right(suggestions);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, GeoPoint>> getPlaceDetails(String placeId) async {
    try {
      final location = await remoteDataSource.getPlaceDetails(placeId);
      return Right(location);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> getAddressFromCoordinates(GeoPoint position) async {
    try {
      final address = await remoteDataSource.getAddressFromCoordinates(position);
      return Right(address);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<IncidentEntity> getIncidentStream() {
    return remoteDataSource.getIncidentStream();
  }
}

class LocationFailure extends Failure {
  final String message;
  LocationFailure(this.message);
  
  @override
  List<Object?> get props => [message];
}
