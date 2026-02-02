import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/features/alert/presentation/bloc/alert_bloc.dart';
import 'package:presshop/features/alert/presentation/bloc/alert_event.dart';
import 'package:presshop/features/alert/presentation/bloc/alert_state.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockLocation extends Mock implements Location {}

void main() {
  late AlertBloc bloc;
  late MockApiClient mockApiClient;
  late MockLocation mockLocation;

  setUp(() {
    mockApiClient = MockApiClient();
    mockLocation = MockLocation();
    bloc = AlertBloc(apiClient: mockApiClient, location: mockLocation);
  });

  group('FetchAlertsEvent', () {
    final tResponseData = {
      'data': [
        {
          '_id': '1',
          'title': 'Alert 1',
          'description': 'Desc 1',
          'createdAt': '2023-01-01',
        }
      ]
    };

    blocTest<AlertBloc, AlertState>(
      'emits [loading, success] when fetching alerts passes',
      build: () {
        when(() => mockApiClient.get(any(),
                queryParameters: any(named: 'queryParameters')))
            .thenAnswer((_) async => Response(
                  data: tResponseData,
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchAlertsEvent()),
      expect: () => [
        const AlertState(status: AlertStatus.loading),
        isA<AlertState>()
            .having((s) => s.status, 'status', AlertStatus.success)
            .having((s) => s.alerts.length, 'alerts length', 1),
      ],
    );

    blocTest<AlertBloc, AlertState>(
      'emits [loading, failure] when fetching alerts fails',
      build: () {
        when(() => mockApiClient.get(any(),
                queryParameters: any(named: 'queryParameters')))
            .thenThrow(DioException(requestOptions: RequestOptions(path: '')));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchAlertsEvent()),
      expect: () => [
        const AlertState(status: AlertStatus.loading),
        isA<AlertState>()
            .having((s) => s.status, 'status', AlertStatus.failure),
      ],
    );
  });

  group('GetCurrentLocationEvent', () {
    test(
        'emits state with currentLocation when permissions and service are enabled',
        () async {
      // arrange
      when(() => mockLocation.serviceEnabled()).thenAnswer((_) async => true);
      when(() => mockLocation.hasPermission())
          .thenAnswer((_) async => PermissionStatus.granted);
      when(() => mockLocation.getLocation())
          .thenAnswer((_) async => LocationData.fromMap({
                'latitude': 51.5074,
                'longitude': -0.1278,
              }));

      // act & assert later
      final expectedStates = [
        isA<AlertState>().having((s) => s.currentLocation, 'location',
            const LatLng(51.5074, -0.1278)),
      ];

      unawaited(expectLater(bloc.stream, emitsInOrder(expectedStates)));

      bloc.add(const GetCurrentLocationEvent());
    });
  });
}

// Add unawaited if not available from async
void unawaited(Future<void>? future) {}
