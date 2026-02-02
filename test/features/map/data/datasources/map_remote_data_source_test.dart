import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:location/location.dart' as loc;
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/services/location_service.dart';
import 'package:presshop/features/map/data/datasources/map_remote_data_source.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockLocationService extends Mock implements LocationService {}

class MockLocationData extends Mock implements loc.LocationData {}

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MapRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;
  late MockLocationService mockLocationService;

  setUpAll(() {
    registerFallbackValue(MockBuildContext());
  });

  setUp(() {
    mockApiClient = MockApiClient();
    mockLocationService = MockLocationService();
    dataSource = MapRemoteDataSourceImpl(
      apiClient: mockApiClient,
      googleApiKey: 'test_key',
      locationService: mockLocationService,
    );
  });

  group('getIncidents', () {
    final tIncidentJson = {
      '_id': '1',
      'markerType': 'icon',
      'lat': 51.5,
      'lng': -0.12,
    };

    test('should perform a GET request and return List<Incident> on success',
        () async {
      // arrange
      final response = Response(
        requestOptions: RequestOptions(path: ''),
        data: [tIncidentJson],
        statusCode: 200,
      );
      when(() => mockApiClient.get(any())).thenAnswer((_) async => response);
      // act
      final result = await dataSource.getIncidents();
      // assert
      expect(result.length, 1);
      expect(result[0].id, '1');
      verify(() => mockApiClient.get(any()));
    });
  });

  group('getCurrentLocation', () {
    test('should throw Failure when context is not available', () async {
      // act & assert
      // It throws ServerFailure because navigatorKey.currentContext is null
      // and ApiErrorHandler wraps the resulting error.
      expect(() => dataSource.getCurrentLocation(), throwsA(isA<Failure>()));
    });
  });
}
