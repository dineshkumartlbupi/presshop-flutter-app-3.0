import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presshop/features/map/domain/repositories/map_repository.dart';
import 'package:presshop/features/map/domain/usecases/get_current_location.dart';
import 'package:presshop/features/map/domain/usecases/get_route.dart';
import 'package:presshop/features/map/presentation/bloc/map_event.dart';
import 'package:presshop/features/map/presentation/bloc/map_state.dart';
import 'package:presshop/features/map/data/services/socket_service.dart';
import 'package:presshop/features/map/data/models/marker_model.dart';
import 'package:presshop/features/news/domain/repositories/news_repository.dart';
import 'package:presshop/features/map/data/services/marker_service.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final GetCurrentLocation getCurrentLocation;
  final GetRoute getRoute;
  final MapRepository repository;
  final SocketService socketService;
  final NewsRepository newsRepository;
  final MarkerService markerService;

  MapBloc({
    required this.getCurrentLocation,
    required this.getRoute,
    required this.repository,
    required this.socketService,
    required this.newsRepository,
    required this.markerService,
  }) : super(const MapState()) {
    on<GetCurrentLocationEvent>(_onGetCurrentLocation);
    on<GetRouteEvent>(_onGetRoute);
    on<SearchPlacesEvent>(_onSearchPlaces);
    on<OnIncidentNewEvent>(_onIncidentNew);
    on<OnIncidentUpdatedEvent>(_onIncidentUpdated);
    on<FetchNewsEvent>(_onFetchNews);

    _initSocket();
  }

  void _initSocket() {
    // Assuming userId is available or passed. For now using a placeholder or fetching from prefs if possible in data layer
    // Ideally, userId should be passed to Bloc or retrieved from a User repository
    // socketService.initSocket(userId: "USER_ID", joinAs: "hopper");

    socketService.onIncidentNew = (data) {
      add(OnIncidentNewEvent(data));
    };
    socketService.onIncidentUpdated = (data) {
      add(OnIncidentUpdatedEvent(data));
    };
    socketService.onIncidentCreated = (data) {
      add(OnIncidentNewEvent(data));
    };
  }

  Future<void> _onIncidentNew(
    OnIncidentNewEvent event,
    Emitter<MapState> emit,
  ) async {
    try {
      final incident = Incident.fromJson(event.data);
      if (state.markers.any((m) => m.markerId.value == incident.id)) {
        return;
      }
      // Logic to add marker... needs to be implemented or moved to a helper
      // For now, just adding to state if possible, but marker creation requires async bitmap generation
      // This might need to be done in the event handler
    } catch (e) {
      print("Error handling new incident: $e");
    }
  }

  Future<void> _onIncidentUpdated(
    OnIncidentUpdatedEvent event,
    Emitter<MapState> emit,
  ) async {
    try {
      final incident = Incident.fromJson(event.data);
      // Update logic
    } catch (e) {
      print("Error handling updated incident: $e");
    }
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocationEvent event,
    Emitter<MapState> emit,
  ) async {
    // emit(state.copyWith(isLoadingNews: true)); // Example loading state
    final result = await getCurrentLocation(NoParams());
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: "Failed to get location")),
      (location) {
        emit(state.copyWith(
          myLocation: location,
          initialCamera: CameraPosition(target: location, zoom: 14),
        ));
        add(FetchNewsEvent(
            lat: location.latitude, lng: location.longitude, km: 10));
      },
    );
  }

  Future<void> _onGetRoute(
    GetRouteEvent event,
    Emitter<MapState> emit,
  ) async {
    // emit(state.copyWith(isLoading: true));
    final result =
        await getRoute(GetRouteParams(start: event.start, end: event.end));
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: "Failed to get route")),
      (routeInfo) => emit(state.copyWith(routeInfo: routeInfo)),
    );
  }

  Future<void> _onSearchPlaces(
    SearchPlacesEvent event,
    Emitter<MapState> emit,
  ) async {
    final result = await repository.getPlaceSuggestions(event.query);
    result.fold(
      (failure) =>
          emit(state.copyWith(errorMessage: "Failed to search places")),
      (places) => emit(state.copyWith(placeSuggestions: places)),
    );
  }

  Future<void> _onFetchNews(
    FetchNewsEvent event,
    Emitter<MapState> emit,
  ) async {
    print(
        "DEBUG: _onFetchNews triggered. Lat: ${event.lat}, Lng: ${event.lng}");
    emit(state.copyWith(isLoadingNews: true));
    final result = await newsRepository.getAggregatedNews(
      lat: event.lat,
      lng: event.lng,
      km: event.km,
      category: event.category,
    );

    await result.fold(
      (failure) async {
        print("DEBUG: FetchNews Failed: ${failure.message}");
        emit(state.copyWith(
            isLoadingNews: false,
            errorMessage: failure.message ?? "Failed to fetch news"));
      },
      (newsList) async {
        print("DEBUG: FetchNews Success. Items found: ${newsList.length}");
        try {
          final List<Incident> incidents = newsList.map((news) {
            final lat =
                double.tryParse(news.location?.split(',')[0] ?? '0') ?? 0.0;
            final lng =
                double.tryParse(news.location?.split(',')[1] ?? '0') ?? 0.0;

            print(
                "DEBUG: News ID: ${news.id}, Location: ${news.location}, Parsed: $lat, $lng");

            return Incident(
                id: news.id,
                markerType: 'news', // or appropriate type
                type: 'news',
                position: LatLng(lat, lng),
                address: news.location,
                time: news.createdAt,
                category: 'News',
                alertType: 'News',
                image: news.mediaUrl,
                description: news.description,
                title: news.title);
          }).toList();

          final Set<Marker> newMarkers = {};
          for (final incident in incidents) {
            // Basic marker creation logic - can be enhanced with custom icons
            final marker = Marker(
              markerId: MarkerId(incident.id),
              position: incident.position,
              infoWindow: InfoWindow(title: incident.title ?? 'News'),
            );
            newMarkers.add(marker);
          }
          emit(state.copyWith(
            isLoadingNews: false,
            newsList: incidents,
            markers: {...state.markers, ...newMarkers},
          ));
        } catch (e, stack) {
          print("Error parsing news for map: $e");
          print(stack);
          emit(state.copyWith(
              isLoadingNews: false, errorMessage: "Error displaying news"));
        }
      },
    );
  }
}
