import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/error/exceptions.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/features/map/data/datasources/map_remote_data_source.dart';
import 'package:presshop/features/map/data/models/marker_model.dart';
import 'package:presshop/features/map/data/repositories/map_repository_impl.dart';
import 'package:presshop/features/map/domain/entities/route_info.dart';

class MockMapRemoteDataSource extends Mock implements MapRemoteDataSource {}

void main() {
  late MapRepositoryImpl repository;
  late MockMapRemoteDataSource mockRemoteDataSource;

  setUpAll(() {
    registerFallbackValue(const LatLng(0, 0));
  });

  setUp(() {
    mockRemoteDataSource = MockMapRemoteDataSource();
    repository = MapRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('getRoute', () {
    const tStart = LatLng(0, 0);
    const tEnd = LatLng(1, 1);
    final tRouteInfo =
        RouteInfo(points: [tStart, tEnd], distanceKm: 5.0, durationMinutes: 15);

    test(
        'should return RouteInfo when call to remote data source is successful',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getRoute(any(), any()))
          .thenAnswer((_) async => tRouteInfo);
      // act
      final result = await repository.getRoute(tStart, tEnd);
      // assert
      expect(result, Right(tRouteInfo));
      verify(() => mockRemoteDataSource.getRoute(tStart, tEnd));
    });

    test(
        'should return ServerFailure when call to remote data source is unsuccessful',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getRoute(any(), any()))
          .thenThrow(ServerException('Error'));
      // act
      final result = await repository.getRoute(tStart, tEnd);
      // assert
      expect(result, const Left(ServerFailure(message: 'Error')));
    });
  });

  group('getCurrentLocation', () {
    const tLatLng = LatLng(51.5074, -0.1278);

    test('should return LatLng when call to remote data source is successful',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getCurrentLocation())
          .thenAnswer((_) async => tLatLng);
      // act
      final result = await repository.getCurrentLocation();
      // assert
      expect(result, const Right(tLatLng));
    });

    test(
        'should return LocationFailure when call to remote data source throws LocationException',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getCurrentLocation())
          .thenThrow(LocationException('Location Error'));
      // act
      final result = await repository.getCurrentLocation();
      // assert
      expect(result, const Left(LocationFailure(message: 'Location Error')));
    });
  });

  group('getIncidents', () {
    final tIncident = Incident(
      id: '1',
      markerType: 'icon',
      position: const LatLng(0, 0),
    );
    final tIncidents = [tIncident];

    test(
        'should return List<Incident> when call to remote data source is successful',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getIncidents())
          .thenAnswer((_) async => tIncidents);
      // act
      final result = await repository.getIncidents();
      // assert
      expect(result, Right(tIncidents));
    });
  });

  group('getAddressFromCoordinates', () {
    const tLatLng = LatLng(0, 0);
    const tAddress = 'Test Address';

    test('should return address string when call is successful', () async {
      // arrange
      when(() => mockRemoteDataSource.getAddressFromCoordinates(any()))
          .thenAnswer((_) async => tAddress);
      // act
      final result = await repository.getAddressFromCoordinates(tLatLng);
      // assert
      expect(result, const Right(tAddress));
    });
  });
}
