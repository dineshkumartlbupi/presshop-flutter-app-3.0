import 'dart:ui';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:presshop/core/error/failures.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/map/data/services/marker_service.dart';
import 'package:presshop/features/map/data/services/socket_service.dart';
import 'package:presshop/features/map/domain/repositories/map_repository.dart';
import 'package:presshop/features/map/domain/usecases/get_current_location.dart';
import 'package:presshop/features/map/domain/usecases/get_route.dart';
import 'package:presshop/features/map/presentation/bloc/map_bloc.dart';
import 'package:presshop/features/map/presentation/bloc/map_event.dart';
import 'package:presshop/features/map/presentation/bloc/map_state.dart';
import 'package:presshop/features/map/domain/entities/route_info.dart';
import 'package:presshop/features/news/domain/repositories/news_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockGetCurrentLocation extends Mock implements GetCurrentLocation {}

class MockGetRoute extends Mock implements GetRoute {}

class MockMapRepository extends Mock implements MapRepository {}

class MockSocketService extends Mock implements SocketService {}

class MockNewsRepository extends Mock implements NewsRepository {}

class MockMarkerService extends Mock implements MarkerService {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MapBloc bloc;
  late MockGetCurrentLocation mockGetCurrentLocation;
  late MockGetRoute mockGetRoute;
  late MockMapRepository mockMapRepository;
  late MockSocketService mockSocketService;
  late MockNewsRepository mockNewsRepository;
  late MockMarkerService mockMarkerService;
  late MockSharedPreferences mockSharedPreferences;

  setUpAll(() {
    registerFallbackValue(const Size(0, 0));
    registerFallbackValue(NoParams());
    registerFallbackValue(const LatLng(0, 0));
    registerFallbackValue(
        GetRouteParams(start: const LatLng(0, 0), end: const LatLng(0, 0)));
  });

  setUp(() {
    mockGetCurrentLocation = MockGetCurrentLocation();
    mockGetRoute = MockGetRoute();
    mockMapRepository = MockMapRepository();
    mockSocketService = MockSocketService();
    mockNewsRepository = MockNewsRepository();
    mockMarkerService = MockMarkerService();
    mockSharedPreferences = MockSharedPreferences();

    // Default shared preferences mock
    when(() => mockSharedPreferences.getString(any())).thenReturn(null);
    when(() => mockSharedPreferences.setBool(any(), any()))
        .thenAnswer((_) async => true);

    bloc = MapBloc(
      getCurrentLocation: mockGetCurrentLocation,
      getRoute: mockGetRoute,
      repository: mockMapRepository,
      socketService: mockSocketService,
      newsRepository: mockNewsRepository,
      markerService: mockMarkerService,
      sharedPreferences: mockSharedPreferences,
    );
  });

  test('initial state is MapState()', () {
    expect(bloc.state, const MapState());
  });

  group('GetCurrentLocationEvent', () {
    const tLocation = LatLng(51.5, -0.12);

    blocTest<MapBloc, MapState>(
      'emits correct states when successful',
      build: () {
        when(() => mockGetCurrentLocation(any()))
            .thenAnswer((_) async => const Right(tLocation));
        when(() => mockMarkerService.createCircularAssetMarker(any(),
                size: any(named: 'size')))
            .thenAnswer((_) async => BitmapDescriptor.defaultMarker);
        when(() => mockMapRepository.getAddressFromCoordinates(any()))
            .thenAnswer((_) async => const Right('Test Address'));
        when(() => mockNewsRepository.getAggregatedNews(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            km: any(named: 'km'))).thenAnswer((_) async => const Right([]));
        when(() => mockMapRepository.getIncidents())
            .thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetCurrentLocationEvent()),
      expect: () => [
        isA<MapState>().having((s) => s.myLocation, 'myLocation', tLocation),
        isA<MapState>().having((s) => s.isLoadingNews, 'isLoadingNews', true),
        isA<MapState>().having((s) => s.isLoadingNews, 'isLoadingNews', false),
      ],
    );

    blocTest<MapBloc, MapState>(
      'emits default location when fetch fails',
      build: () {
        when(() => mockGetCurrentLocation(any())).thenAnswer(
            (_) async => const Left(ServerFailure(message: 'Error')));
        when(() => mockNewsRepository.getAggregatedNews(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            km: any(named: 'km'))).thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(const GetCurrentLocationEvent()),
      expect: () => [
        isA<MapState>().having(
            (s) => s.myLocation, 'myLocation', const LatLng(51.5074, -0.1278)),
        isA<MapState>().having((s) => s.isLoadingNews, 'isLoadingNews', true),
        isA<MapState>().having((s) => s.isLoadingNews, 'isLoadingNews', false),
      ],
    );
  });

  group('FetchNewsEvent', () {
    blocTest<MapBloc, MapState>(
      'emits [isLoadingNews: true, isLoadingNews: false] when successful',
      build: () {
        when(() => mockNewsRepository.getAggregatedNews(
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
            km: any(named: 'km'))).thenAnswer((_) async => const Right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchNewsEvent(lat: 0, lng: 0, km: 10)),
      expect: () => [
        const MapState(isLoadingNews: true),
        const MapState(isLoadingNews: false),
      ],
    );
  });

  group('GetRouteEvent', () {
    final tRouteInfo = RouteInfo(
      points: [const LatLng(0, 0), const LatLng(1, 1)],
      distanceKm: 1.5,
      durationMinutes: 10,
    );
    blocTest<MapBloc, MapState>(
      'emits state with routeInfo when successful',
      build: () {
        when(() => mockGetRoute(any()))
            .thenAnswer((_) async => Right(tRouteInfo));
        when(() => mockMarkerService.bitmapFromIncidentAsset(any(), any()))
            .thenAnswer((_) async => BitmapDescriptor.defaultMarker);
        return bloc;
      },
      act: (bloc) =>
          bloc.add(const GetRouteEvent(start: LatLng(0, 0), end: LatLng(1, 1))),
      expect: () => [
        isA<MapState>().having((s) => s.routeInfo, 'routeInfo', tRouteInfo),
      ],
    );
    group('SearchPlacesEvent', () {
      blocTest<MapBloc, MapState>(
        'emits state with placeSuggestions when successful',
        build: () {
          when(() => mockMapRepository.getPlaceSuggestions(any()))
              .thenAnswer((_) async => const Right([]));
          return bloc;
        },
        act: (bloc) => bloc.add(const SearchPlacesEvent(query: 'test')),
        expect: () => [
          const MapState(placeSuggestions: []),
        ],
      );
    });
  });

  group('ToggleGetDirectionCardEvent', () {
    blocTest<MapBloc, MapState>(
      'toggles showGetDirectionCard',
      build: () => bloc,
      act: (bloc) => bloc.add(const ToggleGetDirectionCardEvent()),
      expect: () => [
        const MapState(showGetDirectionCard: true),
      ],
    );
  });
}
