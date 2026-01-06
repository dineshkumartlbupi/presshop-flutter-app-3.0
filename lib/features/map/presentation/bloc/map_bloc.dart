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

class MapBloc extends Bloc<MapEvent, MapState> {
  final GetCurrentLocation getCurrentLocation;
  final GetRoute getRoute;
  final MapRepository repository;
  final SocketService socketService;

  MapBloc({
    required this.getCurrentLocation,
    required this.getRoute,
    required this.repository,
    required this.socketService,
  }) : super(const MapState()) {
    on<GetCurrentLocationEvent>(_onGetCurrentLocation);
    on<GetRouteEvent>(_onGetRoute);
    on<SearchPlacesEvent>(_onSearchPlaces);
    on<OnIncidentNewEvent>(_onIncidentNew);
    on<OnIncidentUpdatedEvent>(_onIncidentUpdated);

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
      (location) => emit(state.copyWith(
        myLocation: location,
        initialCamera: CameraPosition(target: location, zoom: 14),
      )),
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
}
