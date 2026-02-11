import 'dart:math' as math;
import 'package:flutter/material.dart';
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

import 'package:shared_preferences/shared_preferences.dart';
import 'package:presshop/core/utils/shared_preferences.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc({
    required this.getCurrentLocation,
    required this.getRoute,
    required this.repository,
    required this.socketService,
    required this.newsRepository,
    required this.markerService,
    required this.sharedPreferences,
  }) : super(MapState(
          // Set default initial camera position to prevent null crashes
          initialCamera: const CameraPosition(
            target: LatLng(51.5074, -0.1278), // London as default
            zoom: 14,
          ),
        )) {
    on<GetCurrentLocationEvent>(_onGetCurrentLocation);
    on<GetRouteEvent>(_onGetRoute);
    on<SearchPlacesEvent>(_onSearchPlaces);
    on<OnIncidentNewEvent>(_onIncidentNew);
    on<OnIncidentUpdatedEvent>(_onIncidentUpdated);
    on<FetchNewsEvent>(_onFetchNews);
    on<SetSearchedLocationEvent>(_onSetSearchedLocation);
    on<SetSelectedPositionEvent>(_onSetSelectedPosition);
    on<ToggleAlertPanelEvent>(_onToggleAlertPanel);
    on<ClearSelectedMarkerEvent>(_onClearSelectedMarker);
    on<ClearSelectedPolygonEvent>(_onClearSelectedPolygon);
    on<UpdateFiltersEvent>(_onUpdateFilters);
    on<AddAlertMarkerEvent>(_onAddAlertMarker);
    on<SetPreviewAlertMarkerEvent>(_onSetPreviewAlertMarker);
    on<SetSelectedIncidentEvent>(_onSetSelectedIncident);
    on<SetMapSelectedLocationEvent>(_onSetMapSelectedLocation);
    on<ClearMapSelectedLocationEvent>(_onClearMapSelectedLocation);
    on<StartNavigationEvent>(_onStartNavigation);
    on<StopNavigationEvent>(_onStopNavigation);
    on<ToggleGetDirectionCardEvent>(_onToggleGetDirectionCard);
    on<UpdatePulseCircleEvent>(_onUpdatePulseCircle);
    on<SetDestinationSelectionModeEvent>(_onSetDestinationSelectionMode);
    on<ClearRouteEvent>(_onClearRoute);

    _initSocket();
  }
  final GetCurrentLocation getCurrentLocation;
  final GetRoute getRoute;
  final MapRepository repository;
  final SocketService socketService;
  final NewsRepository newsRepository;
  final MarkerService markerService;
  final SharedPreferences sharedPreferences;

  void _onToggleGetDirectionCard(
    ToggleGetDirectionCardEvent event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(showGetDirectionCard: !state.showGetDirectionCard));
  }

  void _initSocket() {
    final userId =
        sharedPreferences.getString(SharedPreferencesKeys.hopperIdKey) ?? '';
    if (userId.isNotEmpty) {
      socketService.initSocket(userId: userId, joinAs: "hopper");
    }

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

      BitmapDescriptor icon;
      if (incident.markerType == 'content') {
        icon = await markerService.createContentMarker(
          incident.image ?? '',
          size: 60, // Reduced from 90 for better appearance
        );
      } else {
        String assetPath = markerService.markerIcons[incident.type] ??
            markerService.markerIcons['accident']!;
        icon = await markerService.bitmapResize(assetPath, width: 50);
      }

      final marker = Marker(
        markerId: MarkerId(incident.id),
        position: incident.position,
        icon: icon,
        onTap: () {
          add(SetSelectedIncidentEvent(incident));
        },
      );

      emit(state.copyWith(
        markers: {...state.markers, marker},
      ));
    } catch (e) {
      debugPrint("Error handling new incident: $e");
    }
  }

  Future<void> _onIncidentUpdated(
    OnIncidentUpdatedEvent event,
    Emitter<MapState> emit,
  ) async {
    try {
      final incident = Incident.fromJson(event.data);

      BitmapDescriptor icon;
      if (incident.markerType == 'content') {
        icon = await markerService.createContentMarker(
          incident.image ?? '',
          size: 60, // Reduced from 90 for better appearance
        );
      } else {
        String assetPath = markerService.markerIcons[incident.type] ??
            markerService.markerIcons['accident']!;
        icon = await markerService.bitmapResize(assetPath, width: 50);
      }

      final marker = Marker(
        markerId: MarkerId(incident.id),
        position: incident.position,
        icon: icon,
        onTap: () {
          add(SetSelectedIncidentEvent(incident));
        },
      );

      final updatedMarkers =
          state.markers.where((m) => m.markerId.value != incident.id).toSet();
      updatedMarkers.add(marker);

      emit(state.copyWith(
        markers: updatedMarkers,
      ));
    } catch (e) {
      debugPrint("Error handling updated incident: $e");
    }
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocationEvent event,
    Emitter<MapState> emit,
  ) async {
    final result = await getCurrentLocation(NoParams());
    await result.fold(
      (failure) async {
        final defaultLocation = const LatLng(51.5074, -0.1278); // London
        debugPrint("Using default location due to error: ${failure.message}");

        emit(state.copyWith(
          errorMessage: failure.message,
          myLocation: defaultLocation,
          initialCamera: CameraPosition(target: defaultLocation, zoom: 14),
        ));
        add(FetchNewsEvent(
            lat: defaultLocation.latitude,
            lng: defaultLocation.longitude,
            km: 10));
      },
      (location) async {
        // Emit location IMMEDIATELY for instant camera positioning
        emit(state.copyWith(
          myLocation: location,
          initialCamera: CameraPosition(target: location, zoom: 14),
        ));

        // Small delay to let map platform channel initialize
        await Future.delayed(const Duration(milliseconds: 100));

        // Fetch news immediately (non-blocking)
        add(FetchNewsEvent(
            lat: location.latitude, lng: location.longitude, km: 10));

        // Create avatar marker in background (non-blocking for camera)
        final profileImage = sharedPreferences
                .getString(SharedPreferencesKeys.profileImageKey) ??
            '';
        BitmapDescriptor icon = BitmapDescriptor.defaultMarker;

        // Reduce avatar size for better performance (100x100 instead of 150x150)
        if (profileImage.isNotEmpty) {
          icon = await markerService.createAvatarMarker(profileImage,
              size: const Size(100, 100));
        } else {
          icon = await markerService.createCircularAssetMarker(
              "assets/markers/avatar.png",
              size: const Size(100, 100));
        }

        final meMarker = Marker(
          markerId: const MarkerId('my_custom_location'),
          position: location,
          icon: icon,
          anchor: const Offset(0.5, 0.5),
        );

        // Fetch address in background (non-blocking for camera)
        String? address;
        final addressResult =
            await repository.getAddressFromCoordinates(location);
        addressResult.fold(
          (failure) => debugPrint("Failed to get address: ${failure.message}"),
          (addr) => address = addr,
        );

        // Update with avatar marker and address after they're ready
        emit(state.copyWith(
          myLocationAddress: address,
          markers: {...state.markers, meMarker},
        ));

        await _fetchInitialIncidents(emit);
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

    await result.fold(
      (failure) async =>
          emit(state.copyWith(errorMessage: "Failed to get route")),
      (routeInfo) async {
        // Create polyline
        final polyline = Polyline(
          polylineId: const PolylineId('route'),
          points: routeInfo.points,
          color: Colors.blue,
          width: 5,
          geodesic: true,
        );

        LatLng? midpoint;
        if (routeInfo.points.isNotEmpty) {
          final midIndex = routeInfo.points.length ~/ 2;
          midpoint = routeInfo.points[midIndex];
        }

        BitmapDescriptor startIcon = BitmapDescriptor.defaultMarker;
        BitmapDescriptor endIcon =
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);

        try {
          startIcon = await markerService.bitmapFromIncidentAsset(
            "assets/markers/starting_markers.png",
            60,
          );
          endIcon = await markerService.bitmapFromIncidentAsset(
            "assets/markers/destination-marker.png",
            60,
          );
        } catch (e) {
          debugPrint("Error loading route markers: $e");
        }

        final startMarker = Marker(
          markerId: const MarkerId('start'),
          position: event.start,
          icon: startIcon,
        );

        final destinationMarker = Marker(
          markerId: const MarkerId('destination'),
          position: event.end,
          icon: endIcon,
        );

        final updatedMarkers = Set<Marker>.from(state.markers);
        updatedMarkers.removeWhere((m) =>
            m.markerId.value == 'destination' || m.markerId.value == 'start');
        updatedMarkers.add(startMarker);
        updatedMarkers.add(destinationMarker);

        emit(state.copyWith(
          routeInfo: routeInfo,
          polylines: {polyline},
          destination: event.end,
          routeMidpoint: midpoint,
          markers: updatedMarkers,
        ));
      },
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
    debugPrint(
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
        debugPrint("DEBUG: FetchNews Failed: ${failure.message}");
        emit(state.copyWith(
            isLoadingNews: false, errorMessage: failure.message));
      },
      (newsList) async {
        debugPrint("DEBUG: FetchNews Success. Items found: ${newsList.length}");
        try {
          final List<Incident> incidents = newsList.map((news) {
            double lat = news.latitude ?? 0.0;
            double lng = news.longitude ?? 0.0;

            if (lat == 0.0 && lng == 0.0) {
              lat = double.tryParse(news.location?.split(',')[0] ?? '0') ?? 0.0;
              lng = double.tryParse(news.location?.split(',')[1] ?? '0') ?? 0.0;
            }

            // Removed noisy per-item print

            return Incident(
                id: news.id,
                markerType: news.markerType ?? 'news',
                type: news.type ?? 'news',
                position: LatLng(lat, lng),
                address: news.location,
                time: news.createdAt,
                category: 'News',
                alertType: 'News',
                image: news.mediaUrl,
                description: news.description,
                title: news.title,
                mediaType: news.mediaType);
          }).toList();

          // Load markers progressively in batches for better performance
          final Set<Marker> newMarkers = {};
          const int batchSize = 5; // Process 5 markers at a time

          for (int i = 0; i < incidents.length; i += batchSize) {
            final end = (i + batchSize < incidents.length)
                ? i + batchSize
                : incidents.length;
            final batch = incidents.sublist(i, end);

            final List<Future<Marker>> batchFutures =
                batch.map((incident) async {
              BitmapDescriptor icon = BitmapDescriptor.defaultMarker;

              if (incident.markerType == 'icon') {
                String assetPath = markerService.markerIcons[incident.type] ??
                    markerService.markerIcons['accident']!;
                icon = await markerService.bitmapResize(assetPath, width: 50);
              } else if (incident.markerType == 'news' ||
                  incident.markerType == 'content') {
                try {
                  String overlayIcon = incident.mediaType == 'video'
                      ? 'assets/markers/video-icon.png'
                      : 'assets/markers/image-icon.png';
                  icon = await markerService.createContentMarker(
                    incident.image ?? '',
                    size: 60, // Reduced from 90 for better appearance
                    overlayIcon: overlayIcon,
                  );
                } catch (e) {
                  debugPrint(
                      "DEBUG: Failed to load image for marker ${incident.id}, using default. Error: $e");
                  icon = BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueViolet);
                }
              }

              return Marker(
                markerId: MarkerId(incident.id),
                position: incident.position,
                icon: icon,
                onTap: () {
                  add(SetSelectedIncidentEvent(incident));
                },
              );
            }).toList();

            // Wait for this batch to complete
            final batchMarkers = await Future.wait(batchFutures);
            newMarkers.addAll(batchMarkers);

            // Update UI progressively after each batch
            emit(state.copyWith(
              isLoadingNews: i + batchSize >= incidents.length ? false : true,
              newsList: incidents,
              markers: {...state.markers, ...newMarkers},
            ));

            // Removed noisy batch print
          }

          debugPrint("DEBUG: Created ${newMarkers.length} markers for news.");
          emit(state.copyWith(
            isLoadingNews: false,
            newsList: incidents,
            markers: {...state.markers, ...newMarkers},
          ));
        } catch (e, stack) {
          debugPrint("Error parsing news for map: $e");
          debugPrint(stack.toString());
          emit(state.copyWith(
              isLoadingNews: false, errorMessage: "Error displaying news"));
        }
      },
    );
  }

  void _onSetSearchedLocation(
    SetSearchedLocationEvent event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(searchedLocation: event.location));
    add(FetchNewsEvent(
      lat: event.location.latitude,
      lng: event.location.longitude,
      km: 10, // Default or from state
      category: state.selectedCategory ?? 'all',
    ));
  }

  void _onSetSelectedPosition(
    SetSelectedPositionEvent event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(selectedPosition: event.position));
  }

  void _onToggleAlertPanel(
    ToggleAlertPanelEvent event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(showAlertPanel: !state.showAlertPanel));
  }

  void _onClearSelectedMarker(
    ClearSelectedMarkerEvent event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(
        clearSelectedPosition: true, clearSelectedIncident: true));
  }

  void _onClearSelectedPolygon(
    ClearSelectedPolygonEvent event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(
        clearSelectedPolygonId: true, clearSelectedPolygonPosition: true));
  }

  void _onUpdateFilters(
    UpdateFiltersEvent event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(
      selectedAlertType: event.alertType,
      selectedDistance: event.distance,
      selectedCategory: event.category,
    ));
    // Re-fetch news if filters change
    if (state.myLocation != null) {
      add(FetchNewsEvent(
        lat: state.searchedLocation?.latitude ?? state.myLocation!.latitude,
        lng: state.searchedLocation?.longitude ?? state.myLocation!.longitude,
        km: double.tryParse(event.distance?.split(' ')[0] ?? '10') ?? 10,
        category: event.category ?? 'all',
      ));
    }
  }

  Future<void> _onAddAlertMarker(
    AddAlertMarkerEvent event,
    Emitter<MapState> emit,
  ) async {
    final userId =
        sharedPreferences.getString(SharedPreferencesKeys.hopperIdKey) ?? '';
    if (userId.isEmpty) {
      debugPrint("Cannot emit alert: userId is empty");
      return;
    }

    try {
      socketService.emitAlert(
        alertType: event.type,
        position: event.position,
        address: state.myLocationAddress ?? "",
        userId: userId,
      );
      // We rely on the socket 'incident:created'/'incident:new' event to add the marker back to the map.
      // This ensures we have the correct server-generated ID and data.
    } catch (e) {
      debugPrint("Error emitting alert: $e");
    }
  }

  void _onSetPreviewAlertMarker(
    SetPreviewAlertMarkerEvent event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(
      previewAlertType: event.type,
      previewAlertPosition: event.position,
    ));
  }

  void _onSetSelectedIncident(
    SetSelectedIncidentEvent event,
    Emitter<MapState> emit,
  ) {
    // If in destination selection mode, use this incident's location
    if (state.isDestinationSelectionMode) {
      add(SetMapSelectedLocationEvent(
        position: event.incident.position,
        address: event.incident.address ??
            "${event.incident.position.latitude}, ${event.incident.position.longitude}",
        isOrigin: state.isSelectingOrigin,
      ));
      add(SetDestinationSelectionModeEvent(isSelectionMode: false));
      // Don't select incident detail
      return;
    }

    emit(state.copyWith(
      selectedIncident: event.incident,
      selectedPosition: event.incident.position,
      clearSelectedPolygonId: true,
      clearSelectedPolygonPosition: true,
    ));
  }

  Future<void> _onSetMapSelectedLocation(
    SetMapSelectedLocationEvent event,
    Emitter<MapState> emit,
  ) async {
    final markerId =
        event.isOrigin ? 'start_selection' : 'destination_selection';
    final marker = Marker(
      markerId: MarkerId(markerId),
      position: event.position,
      icon: BitmapDescriptor.defaultMarkerWithHue(
          event.isOrigin ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed),
    );

    emit(state.copyWith(
      mapSelectedLocation: event.position,
      mapSelectedAddress: event.address,
      mapSelectedIsOrigin: event.isOrigin,
      clearMapSelectedLocation: false,
      markers: {...state.markers, marker},
    ));
  }

  void _onClearMapSelectedLocation(
    ClearMapSelectedLocationEvent event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(
      clearMapSelectedLocation: true,
      clearMapSelectedAddress: true,
      clearMapSelectedIsOrigin: true,
    ));
  }

  void _onStartNavigation(
    StartNavigationEvent event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(
      isNavigating: true,
      showGetDirectionCard: false,
    ));
  }

  void _onStopNavigation(
    StopNavigationEvent event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(
      isNavigating: false,
      clearCurrentNavigationPosition: true,
    ));
  }

  void _onUpdatePulseCircle(
    UpdatePulseCircleEvent event,
    Emitter<MapState> emit,
  ) {
    if (state.myLocation == null) return;

    final double baseRadiusAtZoom14 = 400.0;
    final double safeZoom = event.zoomLevel.roundToDouble();
    final double scaleFactor = math.pow(2, 14 - safeZoom).toDouble();
    final double dynamicRadius = baseRadiusAtZoom14 * scaleFactor;
    final double radius = dynamicRadius * event.radiusMultiplier;

    final pulseCircle = Circle(
      circleId: const CircleId('my_location_pulse'),
      center: state.myLocation!,
      radius: radius,
      fillColor: const Color.fromARGB(255, 247, 70, 70)
          .withValues(alpha: event.opacity * 0.5),
      strokeColor: const Color.fromARGB(255, 255, 84, 84)
          .withValues(alpha: event.opacity),
      strokeWidth: 1,
    );

    emit(state.copyWith(
      circles: {
        ...state.circles.where((c) => c.circleId.value != 'my_location_pulse'),
        pulseCircle,
      },
    ));
  }

  void _onSetDestinationSelectionMode(
    SetDestinationSelectionModeEvent event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(
      isDestinationSelectionMode: event.isSelectionMode,
      isSelectingOrigin: event.isOrigin,
    ));
  }

  void _onClearRoute(
    ClearRouteEvent event,
    Emitter<MapState> emit,
  ) {
    final updatedMarkers = state.markers
        .where((m) =>
            m.markerId.value != 'destination' && m.markerId.value != 'start')
        .toSet();

    emit(state.copyWith(
      polylines: {},
      clearDestination: true,
      clearRouteInfo: true,
      isNavigating: false,
      showGetDirectionCard: false,
      isDestinationSelectionMode: false,
      clearMapSelectedLocation: true,
      clearMapSelectedAddress: true,
      clearMapSelectedIsOrigin: true,
      markers: updatedMarkers,
    ));
  }

  Future<void> _fetchInitialIncidents(Emitter<MapState> emit) async {
    final result = await repository.getIncidents();
    await result.fold(
      (failure) async {
        debugPrint("Failed to fetch initial incidents: ${failure.message}");
      },
      (incidents) async {
        debugPrint("Fetched ${incidents.length} initial incidents");

        final List<Future<Marker>> markerFutures =
            incidents.map((incident) async {
          BitmapDescriptor icon;
          if (incident.markerType == 'content') {
            icon =
                await markerService.createContentMarker(incident.image ?? '');
          } else {
            String assetPath = markerService.markerIcons[incident.type] ??
                markerService.markerIcons['accident']!;
            // Using generic resize for now, respecting the new 50px size
            icon = await markerService.bitmapResize(assetPath, width: 50);
          }

          return Marker(
            markerId: MarkerId(incident.id),
            position: incident.position,
            icon: icon,
            onTap: () {
              add(SetSelectedIncidentEvent(incident));
            },
          );
        }).toList();

        final List<Marker> newMarkersList = await Future.wait(markerFutures);
        final Set<Marker> newMarkers = newMarkersList.toSet();

        // We use state.markers to keep existing markers (like myLocation)
        emit(state.copyWith(
          markers: {...state.markers, ...newMarkers},
        ));
      },
    );
  }
}
