import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presshop/features/map/constants/map_news_constants.dart';
import 'package:presshop/features/map/domain/repositories/map_repository.dart';
import 'package:presshop/features/map/domain/usecases/get_current_location.dart';
import 'package:presshop/features/map/domain/usecases/get_route.dart';
import 'package:presshop/features/map/presentation/bloc/map_event.dart';
import 'package:presshop/features/map/presentation/bloc/map_state.dart';
import 'package:presshop/features/map/data/datasources/incident_socket_datasource.dart';
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
    required this.incidentSocketDataSource,
    required this.newsRepository,
    required this.markerService,
    required this.sharedPreferences,
  }) : super(MapState(
          initialCamera: const CameraPosition(
            target: LatLng(51.5074, -0.1278),
            zoom: 14,
          ),
        )) {
    on<GetCurrentLocationEvent>(_onGetCurrentLocation);
    on<GetRouteEvent>(_onGetRoute);
    on<SearchPlacesEvent>(_onSearchPlaces);
    on<OnIncidentNewEvent>(_onIncidentNew);
    on<OnIncidentUpdatedEvent>(_onIncidentUpdated);
    on<FetchNewsEvent>(_onFetchNews);
    on<FetchIncidentsEvent>(_onFetchIncidents);
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
    on<SetDraggingEvent>(_onSetDragging);
    on<ToggleAnimatedMarkersEvent>(_onToggleAnimatedMarkers);

    _initSocket();
  }
  final GetCurrentLocation getCurrentLocation;
  final GetRoute getRoute;
  final MapRepository repository;
  final IncidentSocketDataSource incidentSocketDataSource;
  final NewsRepository newsRepository;
  final MarkerService markerService;
  final SharedPreferences sharedPreferences;
  bool _isReadyForBursts = false;

  static const int kContentMarkerSize = 120;
  static const int kIncidentMarkerSize = 160; // Restored to 160px as per old code

  BitmapDescriptor? _meMarkerIcon;

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
      incidentSocketDataSource.initSocket(userId: userId, userType: "hopper");
    }

    incidentSocketDataSource.onIncidentNew = (data) {
      add(OnIncidentNewEvent(data));
    };
    incidentSocketDataSource.onIncidentUpdated = (data) {
      add(OnIncidentUpdatedEvent(data));
    };
    incidentSocketDataSource.onIncidentCreated = (data) {
      add(OnIncidentNewEvent(data));
    };

    // CRITICAL: Start the listeners on the socket client
    incidentSocketDataSource.initializeListeners();
    
    // Join the global news/incident broadcast room
    incidentSocketDataSource.joinNewsRoom();
  }

  Future<void> _onIncidentNew(
    OnIncidentNewEvent event,
    Emitter<MapState> emit,
  ) async {
    try {
      final incident = Incident.fromJson(event.data);
      final markerId = _getMarkerId(incident);
      
      if (state.markers.any((m) => m.markerId.value == markerId)) {
        return;
      }

      BitmapDescriptor icon;
      if (incident.markerType == 'content' || incident.markerType == 'news') {
        icon = await markerService.createContentMarker(
          incident.image ?? '',
          size: kContentMarkerSize,
          mediaType: incident.mediaType,
        );
      } else {
        final iconType = _resolveIconType(incident.type ?? incident.alertType);
        String assetPath = markerIcons[iconType] ?? markerIcons['accident']!;
        icon = await markerService.bitmapResize(assetPath,
            width: kIncidentMarkerSize);
      }

      final marker = Marker(
        markerId: MarkerId(markerId),
        position: incident.position,
        icon: icon,
        alpha: 0.0, // Invisible: only use animated overlay
        onTap: () {
          add(SetSelectedIncidentEvent(incident));
        },
      );

      final bool isRecent = _isIncidentRecent(incident);

      final updatedMarkers = state.markers.where((m) => m.markerId.value != markerId).toSet();
      updatedMarkers.add(marker);

      final updatedNewsList = List<Incident>.from(state.newsList);
      if (!updatedNewsList.any((i) => i.id == incident.id)) {
        updatedNewsList.add(incident);
      }

      emit(state.copyWith(
        markers: _appendMeMarker(updatedMarkers),
        newsList: updatedNewsList,
        newlyCreatedIncident: _isReadyForBursts && isRecent ? incident : null,
      ));

      if (_isReadyForBursts && isRecent) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!emit.isDone) {
          emit(state.copyWith(clearNewlyCreatedIncident: true));
        }
      }
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
      final markerId = _getMarkerId(incident);

      BitmapDescriptor icon;
      if (incident.markerType == 'content' || incident.markerType == 'news') {
        icon = await markerService.createContentMarker(
          incident.image ?? '',
          size: kContentMarkerSize, // Align with legacy size
          mediaType: incident.mediaType,
        );
      } else {
        final iconType = _resolveIconType(incident.type ?? incident.alertType);
        String assetPath = markerIcons[iconType] ?? markerIcons['accident']!;
        icon = await markerService.bitmapResize(assetPath,
            width: kIncidentMarkerSize);
      }

      final marker = Marker(
        markerId: MarkerId(markerId),
        position: incident.position,
        icon: icon,
        alpha: 0.0,
        onTap: () {
          add(SetSelectedIncidentEvent(incident));
        },
      );

      final updatedMarkers =
          state.markers.where((m) => m.markerId.value != markerId).toSet();
      updatedMarkers.add(marker);

      final updatedNewsList = List<Incident>.from(state.newsList)
          .where((i) => i.id != incident.id)
          .toList();
      updatedNewsList.add(incident);

      emit(state.copyWith(
        markers: _appendMeMarker(updatedMarkers),
        newsList: updatedNewsList,
      ));
    } catch (e) {
      debugPrint("Error handling updated incident: $e");
    }
  }

  String _getMarkerId(Incident incident) {
    return (incident.markerType == 'content' || incident.markerType == 'news')
        ? 'news_${incident.id}'
        : (incident.type?.toLowerCase().contains('weather') ?? false)
            ? 'weather_${incident.id}'
            : 'alert_${incident.id}';
  }

  String _resolveIconType(String? typeInput) {
    if (typeInput == null) return 'accident';
    final type = typeInput.toLowerCase();

    if (type.contains('accident') || type.contains('crash')) {
      return 'accident';
    } else if (type.contains('fire')) {
      return 'fire';
    } else if (type.contains('gun')) {
      return 'gun';
    } else if (type.contains('knife')) {
      return 'knife';
    } else if (type.contains('fight')) {
      return 'fight';
    } else if (type.contains('protest')) {
      return 'protest';
    } else if (type.contains('medicine') || type.contains('medical')) {
      return 'medical';
    } else if (type.contains('police')) {
      return 'police';
    } else if (type.contains('flood') || type.contains('floods')) {
      return 'floods';
    } else if (type.contains('road') || type.contains('block')) {
      return 'road-block';
    } else if (type.contains('snow')) {
      return 'snow';
    } else if (type.contains('storm')) {
      return 'storm';
    } else if (type.contains('earthquake') || type.contains('quake')) {
      return 'earthquake';
    } else if (type.contains('weather')) {
      return 'weather';
    }
    return 'nomarker';
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocationEvent event,
    Emitter<MapState> emit,
  ) async {
    final result = await getCurrentLocation(NoParams());
    await result.fold(
      (failure) async {
        debugPrint("Location error: ${failure.message}");

        emit(state.copyWith(
          errorMessage: failure.message,
          myLocation: null, // ✅ KEEP NULL
        ));
      },
      (location) async {
        emit(state.copyWith(
          myLocation: location,
          initialCamera: CameraPosition(target: location, zoom: 14),
        ));
        await Future.delayed(const Duration(milliseconds: 100));
        add(FetchNewsEvent(
            lat: location.latitude, lng: location.longitude, km: 10));
        String avatarImage =
            sharedPreferences.getString(SharedPreferencesKeys.avatarKey) ?? '';
        String profileImage = sharedPreferences
                .getString(SharedPreferencesKeys.profileImageKey) ??
            '';
        String avatarId =
            sharedPreferences.getString(SharedPreferencesKeys.avatarIdKey) ??
                '';

        if (avatarImage.isEmpty) {
          avatarImage = profileImage;
        }
        if (avatarImage.isEmpty) {
          avatarImage = avatarId;
        }

        if (avatarImage.isNotEmpty && avatarImage.startsWith('http')) {
          _meMarkerIcon = await markerService.createAvatarMarker(avatarImage,
              size: const Size(120, 120));
        } else {
          // Use our robust service instead of standard asset loading
          _meMarkerIcon = await markerService.createCircularAssetMarker(
            "assets/markers/avatar.png",
            size: const Size(120, 120),
          );
        }

        final meMarker = Marker(
          markerId: const MarkerId('my_custom_location'),
          position: location,
          icon: _meMarkerIcon ?? BitmapDescriptor.defaultMarker,
          anchor: const Offset(0.5, 0.5),
          zIndex: 1000, // Ensure it's always on top
        );

        // Fetch address in background (non-blocking for camera)
        String? address;
        final addressResult =
            await repository.getAddressFromCoordinates(location);
        addressResult.fold(
          (failure) => debugPrint("Failed to get address: ${failure.message}"),
          (addr) => address = addr,
        );
        emit(state.copyWith(
          myLocationAddress: address,
          markers: _appendMeMarker(state.markers, forceMarker: meMarker),
        ));
        
        add(FetchIncidentsEvent(
          lat: location.latitude,
          lng: location.longitude,
          km: 10,
        ));

        // After initial load, wait a moment before enabling bursts to avoid startup spam
        Future.delayed(const Duration(seconds: 3), () {
          _isReadyForBursts = true;
        });
      },
    );
  }

  bool _isIncidentRecent(Incident incident) {
    if (incident.time == null)
      return true; // Default to showing if no time provided
    try {
      final incidentTime = DateTime.parse(incident.time!);
      final now = DateTime.now();
      // Only burst if created in the last 30 seconds
      return now.difference(incidentTime).inSeconds < 30;
    } catch (e) {
      return true; // Fallback to showing if parsing fails
    }
  }

  Future<void> _onGetRoute(
    GetRouteEvent event,
    Emitter<MapState> emit,
  ) async {
    final result =
        await getRoute(GetRouteParams(start: event.start, end: event.end));

    await result.fold(
      (failure) async =>
          emit(state.copyWith(errorMessage: "Failed to get route")),
      (routeInfo) async {
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
            70,
          );
          endIcon = await markerService.bitmapFromIncidentAsset(
            "assets/markers/destination-marker.png",
            70,
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
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet:
                "${routeInfo.distanceKm.toStringAsFixed(2)} km, ${routeInfo.durationMinutes} min",
          ),
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
    if (event.isFeedOnly) return;

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

          final Set<Marker> newMarkers = {};
          const int batchSize =
              20; // Increased batch size for better performance

          for (int i = 0; i < incidents.length; i += batchSize) {
            final end = (i + batchSize < incidents.length)
                ? i + batchSize
                : incidents.length;
            final batch = incidents.sublist(i, end);

            final List<Future<Marker>> batchFutures =
                batch.map((incident) async {
              BitmapDescriptor icon = BitmapDescriptor.defaultMarker;

              if (incident.markerType == 'icon') {
                final iconType =
                    _resolveIconType(incident.type ?? incident.alertType);
                String assetPath =
                    markerIcons[iconType] ?? markerIcons['accident']!;
                icon = await markerService.bitmapResize(assetPath,
                    width: kIncidentMarkerSize);
              } else if (incident.markerType == 'news' ||
                  incident.markerType == 'content') {
                try {
                  icon = await markerService.createContentMarker(
                    incident.image ?? '',
                    size: kContentMarkerSize,
                    mediaType: incident.mediaType,
                  );
                } catch (e) {
                  icon = BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueViolet);
                }
              }

              final markerId = (incident.markerType == 'content' ||
                      incident.markerType == 'news')
                  ? 'news_${incident.id}'
                  : 'alert_${incident.id}';

              return Marker(
                markerId: MarkerId(markerId),
                position: incident.position,
                alpha: 0.0,
                icon: icon,
                onTap: () {
                  add(SetSelectedIncidentEvent(incident));
                },
              );
            }).toList();

            final batchMarkers = await Future.wait(batchFutures);
            newMarkers.addAll(batchMarkers);

            // Only emit updates if we have finished a significant batch or reached the end
            if (i + batchSize >= incidents.length || (i / batchSize) % 2 == 0) {
              emit(state.copyWith(
                isLoadingNews: i + batchSize >= incidents.length ? false : true,
                newsList: incidents,
                markers: _appendMeMarker({...state.markers, ...newMarkers}),
              ));
            }
          }

          debugPrint("DEBUG: Created ${newMarkers.length} markers for news.");
          emit(state.copyWith(
            isLoadingNews: false,
            newsList: incidents,
            markers: _appendMeMarker({...state.markers, ...newMarkers}),
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
      km: 10,
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
        km: _convertDistanceToKm(event.distance),
        category: event.category ?? 'all',
      ));
      add(FetchIncidentsEvent(
        lat: state.searchedLocation?.latitude ?? state.myLocation!.latitude,
        lng: state.searchedLocation?.longitude ?? state.myLocation!.longitude,
        km: _convertDistanceToKm(event.distance),
        category: event.category ?? 'all',
      ));
    }
  }

  double _convertDistanceToKm(String? distance) {
    if (distance == null) return 10.0;
    try {
      final value = double.parse(distance.split(' ')[0]);
      return value * 1.60934;
    } catch (e) {
      return 10.0;
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
      incidentSocketDataSource.emitAlert(
        alertType: event.type,
        position: event.position,
        address: state.myLocationAddress ?? "",
        userId: userId,
      );
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

    if (state.showGetDirectionCard) {
      add(SetMapSelectedLocationEvent(
        position: event.incident.position,
        address: event.incident.address ??
            event.incident.title ??
            "${event.incident.position.latitude}, ${event.incident.position.longitude}",
        isOrigin: false,
      ));
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

  void _onSetDragging(
    SetDraggingEvent event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(isDragging: event.isDragging));
  }

  Future<void> _onFetchIncidents(
    FetchIncidentsEvent event,
    Emitter<MapState> emit,
  ) async {
    final result = await repository.getIncidents(
      lat: event.lat,
      lng: event.lng,
      km: event.km,
      category: event.category,
    );
    await result.fold(
      (failure) async {
        debugPrint("Failed to fetch incidents: ${failure.message}");
      },
      (incidents) async {
        debugPrint("Fetched ${incidents.length} incidents");

        final List<Future<Marker>> markerFutures =
            incidents.map((incident) async {
          BitmapDescriptor icon;
          if (incident.markerType == 'content' ||
              incident.markerType == 'news') {
            icon = await markerService.createContentMarker(
              incident.image ?? '',
              size: kContentMarkerSize,
              mediaType: incident.mediaType,
            );
          } else {
            final iconType =
                _resolveIconType(incident.type ?? incident.alertType);
            String assetPath =
                markerIcons[iconType] ?? markerIcons['accident']!;
            icon = await markerService.bitmapResize(assetPath,
                width: kIncidentMarkerSize);
          }

          final markerId = (incident.markerType == 'content' ||
                  incident.markerType == 'news')
              ? 'news_${incident.id}'
              : 'alert_${incident.id}';

          return Marker(
            markerId: MarkerId(markerId),
            position: incident.position,
            alpha: 0.0,
            icon: icon,
            onTap: () {
              add(SetSelectedIncidentEvent(incident));
            },
          );
        }).toList();

        final List<Marker> newMarkersList = await Future.wait(markerFutures);
        final Set<Marker> newsMarkers = newMarkersList.toSet();

        if (!emit.isDone) {
          emit(state.copyWith(
            markers: _appendMeMarker({...state.markers, ...newsMarkers}),
          ));
        }
      },
    );
  }

  Set<Marker> _appendMeMarker(Set<Marker> markers, {Marker? forceMarker}) {
    // 1. Find the "Me" marker in the new set, or the provided forced marker
    Marker me = forceMarker ??
        markers.firstWhere(
          (m) => m.markerId.value == 'my_custom_location',
          orElse: () => state.markers.firstWhere(
            (m) => m.markerId.value == 'my_custom_location',
            orElse: () {
              if (state.myLocation != null && _meMarkerIcon != null) {
                return Marker(
                  markerId: const MarkerId('my_custom_location'),
                  position: state.myLocation!,
                  icon: _meMarkerIcon!,
                  anchor: const Offset(0.5, 0.5),
                  zIndex: 1000,
                );
              }
              return const Marker(markerId: MarkerId('none'), visible: false);
            },
          ),
        );

    // 2. Remove any existing "my_custom_location" markers to avoid duplicates
    final filtered =
        markers.where((m) => m.markerId.value != 'my_custom_location').toSet();

    // 3. Add the "Me" marker back if it's valid
    if (me.markerId.value != 'none') {
      filtered.add(me);
    }

    return filtered;
  }

  void _onToggleAnimatedMarkers(
      ToggleAnimatedMarkersEvent event, Emitter<MapState> emit) {
    final bool newValue = !state.showAnimatedMarkers;

    // We must update all existing markers to flip their alpha
    final updatedMarkers = state.markers.map((m) {
      if (m.markerId.value.startsWith('alert_') ||
          m.markerId.value.startsWith('news_') ||
          m.markerId.value.startsWith('weather_')) {
        return m.copyWith(alphaParam: newValue ? 0.0 : 1.0);
      }
      return m;
    }).toSet();

    emit(state.copyWith(
      showAnimatedMarkers: newValue,
      markers: updatedMarkers,
    ));
  }
}
