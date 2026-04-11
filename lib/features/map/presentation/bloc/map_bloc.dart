import 'dart:async';
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
    on<SetSelectingAlertLocationEvent>((event, emit) {
      emit(state.copyWith(
          isSelectingAlertLocation: event.isSelecting,
          pendingAlertType: event.type));
    });
    on<SetShowDropdownEvent>((event, emit) {
      emit(state.copyWith(showDropdown: event.show));
    });
    on<SetLocationTimeoutEvent>((event, emit) {
      emit(state.copyWith(locationTimeout: event.isTimeout));
    });
    on<SetVisibilityEvent>((event, emit) {
      emit(state.copyWith(isVisible: event.isVisible));
    });

    // Internal events for non-blocking background result delivery
    on<EmitAvatarMarkerEvent>((event, emit) {
      emit(state.copyWith(
        markers: _appendMeMarker(state.markers, forceMarker: event.marker),
      ));
    });
    on<EmitAddressEvent>((event, emit) {
      emit(state.copyWith(myLocationAddress: event.address));
    });

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
  static const int kIncidentMarkerSize = 120;

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

      debugPrint(
          "Processing new incident: ${incident.id} | Type: ${incident.type} | MarkerID: $markerId");

      final updatedMarkers = Set<Marker>.from(state.markers);
      final bool markerAlreadyExists =
          updatedMarkers.any((m) => m.markerId.value == markerId);

      if (!markerAlreadyExists) {
        BitmapDescriptor icon;
        try {
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
            icon = await markerService.createCircularAssetMarker(
              assetPath,
              size: Size(kIncidentMarkerSize.toDouble(),
                  kIncidentMarkerSize.toDouble()),
            );
          }
        } catch (e) {
          debugPrint("Error creating icon for incident ${incident.id}: $e");
          icon =
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
        }

        final marker = Marker(
          markerId: MarkerId(markerId),
          position: incident.position,
          icon: icon,
          alpha: 1.0,
          onTap: () {
            add(SetSelectedIncidentEvent(incident));
          },
        );
        updatedMarkers.add(marker);
      }

      final bool isRecent = _isIncidentRecent(incident);

      // CRITICAL: Always ensure the incident is in the news list for the animated overlay to find it
      final updatedNewsList = List<Incident>.from(state.newsList);
      final existingIndex =
          updatedNewsList.indexWhere((i) => i.id == incident.id);
      if (existingIndex == -1) {
        updatedNewsList.add(incident);
      } else {
        updatedNewsList[existingIndex] = incident;
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
    } catch (e, stack) {
      debugPrint("Error handling new incident: $e");
      debugPrint(stack.toString());
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
      try {
        if (incident.markerType == 'content' || incident.markerType == 'news') {
          icon = await markerService.createContentMarker(
            incident.image ?? '',
            size: kContentMarkerSize,
            mediaType: incident.mediaType,
          );
        } else {
          final iconType =
              _resolveIconType(incident.type ?? incident.alertType);
          String assetPath = markerIcons[iconType] ?? markerIcons['accident']!;
          icon = await markerService.createCircularAssetMarker(
            assetPath,
            size: Size(
                kIncidentMarkerSize.toDouble(), kIncidentMarkerSize.toDouble()),
          );
        }
      } catch (e) {
        debugPrint(
            "Error creating icon for updated incident ${incident.id}: $e");
        icon =
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      }

      final marker = Marker(
        markerId: MarkerId(markerId),
        position: incident.position,
        icon: icon,
        alpha: 1.0,
        onTap: () {
          add(SetSelectedIncidentEvent(incident));
        },
      );

      final updatedMarkers =
          state.markers.where((m) => m.markerId.value != markerId).toSet();
      updatedMarkers.add(marker);

      final updatedNewsList = List<Incident>.from(state.newsList);
      final existingIndex =
          updatedNewsList.indexWhere((i) => i.id == incident.id);
      if (existingIndex == -1) {
        updatedNewsList.add(incident);
      } else {
        updatedNewsList[existingIndex] = incident;
      }

      emit(state.copyWith(
        markers: _appendMeMarker(updatedMarkers),
        newsList: updatedNewsList,
      ));
    } catch (e, stack) {
      debugPrint("Error handling updated incident: $e");
      debugPrint(stack.toString());
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
    // Prevent triggering a second location request if one returned a valid location
    if (state.myLocation != null) {
      debugPrint("GetCurrentLocation: skipped — location already acquired.");
      return;
    }

    final result = await getCurrentLocation(NoParams())
        .timeout(
      const Duration(seconds: 25),
      onTimeout: () => throw TimeoutException('Location timed out'),
    )
        .catchError((e) async {
      debugPrint("GetCurrentLocation outer error: $e");
      return null;
    });

    await result.fold(
      (failure) async {
        debugPrint("Location error: ${failure.message}");
        emit(state.copyWith(myLocation: null));
      },
      (location) async {
        // STEP 1: Emit location immediately — unblocks the UI and camera animation
        emit(state.copyWith(
          myLocation: location,
          initialCamera: CameraPosition(target: location, zoom: 14),
        ));

        // STEP 2: Kick off news & incidents — these go into the event queue
        //         and are processed independently (non-blocking here)
        add(FetchNewsEvent(
            lat: location.latitude, lng: location.longitude, km: 10));
        add(FetchIncidentsEvent(
            lat: location.latitude, lng: location.longitude, km: 10));

        // STEP 3: Load avatar marker in background — fire-and-forget
        //         Emits separately via a microtask so it never blocks this handler
        unawaited(_loadAvatarAndEmit(location));

        // STEP 4: Fetch address in background — fire-and-forget with timeout
        unawaited(_fetchAddressAndEmit(location));

        // Enable burst effect after a short delay
        Future.delayed(const Duration(seconds: 3), () {
          _isReadyForBursts = true;
        });
      },
    );
  }

  /// Loads the user avatar marker in the background and emits a state update.
  Future<void> _loadAvatarAndEmit(LatLng location) async {
    try {
      String avatarImage =
          sharedPreferences.getString(SharedPreferencesKeys.avatarKey) ?? '';
      final String profileImage =
          sharedPreferences.getString(SharedPreferencesKeys.profileImageKey) ??
              '';
      final String avatarId =
          sharedPreferences.getString(SharedPreferencesKeys.avatarIdKey) ?? '';

      if (avatarImage.isEmpty) avatarImage = profileImage;
      if (avatarImage.isEmpty) avatarImage = avatarId;

      if (avatarImage.isNotEmpty && avatarImage.startsWith('http')) {
        _meMarkerIcon = await markerService
            .createAvatarMarker(avatarImage, size: const Size(120, 120))
            .timeout(const Duration(seconds: 6));
      } else {
        _meMarkerIcon = await markerService
            .createCircularAssetMarker(
              "assets/markers/avatar.png",
              size: const Size(120, 120),
            )
            .timeout(const Duration(seconds: 4));
      }

      final meMarker = Marker(
        markerId: const MarkerId('my_custom_location'),
        position: location,
        icon: _meMarkerIcon ?? BitmapDescriptor.defaultMarker,
        anchor: const Offset(0.5, 0.5),
        zIndex: 1000,
      );

      if (!isClosed) {
        add(EmitAvatarMarkerEvent(meMarker));
      }
    } catch (e) {
      debugPrint("Avatar marker load failed (ignored): $e");
    }
  }

  /// Fetches reverse-geocoded address in the background and emits a state update.
  Future<void> _fetchAddressAndEmit(LatLng location) async {
    try {
      final addressResult = await repository
          .getAddressFromCoordinates(location)
          .timeout(const Duration(seconds: 8));

      addressResult.fold(
        (failure) => debugPrint("Address fetch failed: ${failure.message}"),
        (address) {
          if (!isClosed) {
            add(EmitAddressEvent(address));
          }
        },
      );
    } catch (e) {
      debugPrint("Address fetch timed out or failed (ignored): $e");
    }
  }

  bool _isIncidentRecent(Incident incident) {
    if (incident.time == null) {
      return true; // Default to showing if no time provided
    }
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

    // Guard: skip if already loading to prevent concurrent fetches
    if (state.isLoadingNews) {
      debugPrint("DEBUG: FetchNews skipped — already loading.");
      return;
    }

    emit(state.copyWith(isLoadingNews: true));

    try {
      final result = await newsRepository
          .getAggregatedNews(
            lat: event.lat,
            lng: event.lng,
            km: event.km,
            category: event.category,
          )
          .timeout(const Duration(seconds: 20));

      await result.fold(
        (failure) async {
          debugPrint("DEBUG: FetchNews Failed: ${failure.message}");
        },
        (newsList) async {
          debugPrint(
              "DEBUG: FetchNews Success. Items found: ${newsList.length}");
          try {
            // HARD LIMIT: cap at 40 markers to prevent ANR/freeze
            const int maxMarkers = 40;
            final limitedList = newsList.take(maxMarkers).toList();

            final List<Incident> incidents = limitedList.map((news) {
              double lat = news.latitude ?? 0.0;
              double lng = news.longitude ?? 0.0;

              if (lat == 0.0 && lng == 0.0) {
                lat =
                    double.tryParse(news.location?.split(',')[0] ?? '0') ?? 0.0;
                lng =
                    double.tryParse(news.location?.split(',')[1] ?? '0') ?? 0.0;
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
            // Smaller batches to keep UI responsive
            const int batchSize = 10;

            for (int i = 0; i < incidents.length; i += batchSize) {
              if (emit.isDone) break; // Bloc was closed; stop

              final end = (i + batchSize < incidents.length)
                  ? i + batchSize
                  : incidents.length;
              final batch = incidents.sublist(i, end);

              final List<Future<Marker>> batchFutures =
                  batch.map((incident) async {
                BitmapDescriptor icon = BitmapDescriptor.defaultMarker;

                try {
                  if (incident.markerType == 'icon') {
                    final iconType =
                        _resolveIconType(incident.type ?? incident.alertType);
                    String assetPath =
                        markerIcons[iconType] ?? markerIcons['accident']!;
                    icon = await markerService
                        .createCircularAssetMarker(
                          assetPath,
                          size: Size(kIncidentMarkerSize.toDouble(),
                              kIncidentMarkerSize.toDouble()),
                        )
                        .timeout(const Duration(seconds: 10));
                  } else if (incident.markerType == 'news' ||
                      incident.markerType == 'content') {
                    icon = await markerService
                        .createContentMarker(
                          incident.image ?? '',
                          size: kContentMarkerSize,
                          mediaType: incident.mediaType,
                        )
                        .timeout(const Duration(seconds: 10));
                  }
                } catch (_) {
                  icon = BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueViolet);
                }

                final markerId = _getMarkerId(incident);
                return Marker(
                  markerId: MarkerId(markerId),
                  position: incident.position,
                  alpha: 1.0,
                  icon: icon,
                  onTap: () => add(SetSelectedIncidentEvent(incident)),
                );
              }).toList();

              final batchMarkers = await Future.wait(batchFutures);
              newMarkers.addAll(batchMarkers);

              // Yield to event loop: keeps UI responsive between batches
              await Future.delayed(Duration.zero);
            }

            debugPrint("DEBUG: Created ${newMarkers.length} markers for news.");

            if (!emit.isDone) {
              final remainingMarkers = state.markers.where((m) {
                return !m.markerId.value.startsWith('news_') &&
                    !m.markerId.value.startsWith('weather_');
              }).toSet();
              final survivingAlerts =
                  state.newsList.where((i) => i.markerType == 'icon').toList();

              emit(state.copyWith(
                isLoadingNews: false,
                newsList: [...survivingAlerts, ...incidents],
                markers: _appendMeMarker({...remainingMarkers, ...newMarkers}),
              ));
            }
          } catch (e, stack) {
            debugPrint("Error parsing news for map: $e\n$stack");
          }
        },
      );
    } on TimeoutException catch (_) {
      debugPrint("DEBUG: FetchNews timed out after 20s.");
    } catch (e) {
      debugPrint("DEBUG: FetchNews unexpected error: $e");
    } finally {
      // GUARANTEE: isLoadingNews is ALWAYS cleared — prevents stuck loader/freeze
      if (!emit.isDone) {
        emit(state.copyWith(isLoadingNews: false));
      }
    }
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

        final Set<Marker> alertMarkers = {};
        const int batchSize = 5; // Smaller batch for incidents

        for (int i = 0; i < incidents.length; i += batchSize) {
          if (emit.isDone) break;

          final end = (i + batchSize < incidents.length)
              ? i + batchSize
              : incidents.length;
          final batch = incidents.sublist(i, end);

          final List<Future<Marker>> batchFutures = batch.map((incident) async {
            BitmapDescriptor icon = BitmapDescriptor.defaultMarker;

            try {
              if (incident.markerType == 'content' ||
                  incident.markerType == 'news') {
                icon = await markerService
                    .createContentMarker(
                      incident.image ?? '',
                      size: kContentMarkerSize,
                      mediaType: incident.mediaType,
                    )
                    .timeout(const Duration(seconds: 5));
              } else {
                final iconType =
                    _resolveIconType(incident.type ?? incident.alertType);
                String assetPath =
                    markerIcons[iconType] ?? markerIcons['accident']!;
                icon = await markerService
                    .createCircularAssetMarker(
                      assetPath,
                      size: Size(kIncidentMarkerSize.toDouble(),
                          kIncidentMarkerSize.toDouble()),
                    )
                    .timeout(const Duration(seconds: 10));
              }
            } catch (e) {
              debugPrint("FetchIncidents marker load failed (ignored): $e");
              icon = BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueViolet);
            }

            final markerId = _getMarkerId(incident);

            return Marker(
              markerId: MarkerId(markerId),
              position: incident.position,
              alpha: 1.0,
              icon: icon,
              onTap: () {
                add(SetSelectedIncidentEvent(incident));
              },
            );
          }).toList();

          final batchMarkers = await Future.wait(batchFutures);
          alertMarkers.addAll(batchMarkers);

          // Yield to event loop to keep UI responsive
          await Future.delayed(Duration.zero);
        }

        // 1. Identify and clear previous Alert-domain markers ONLY
        final remainingMarkers = state.markers.where((m) {
          return !m.markerId.value.startsWith('alert_');
        }).toSet();

        // 2. Identify and clear previous Alert-domain incidents in newsList, keep others (news/weather)
        final otherIncidents =
            state.newsList.where((i) => i.markerType != 'icon').toList();

        final combinedNewsList = [...otherIncidents, ...incidents];

        if (!emit.isDone) {
          emit(state.copyWith(
            markers: _appendMeMarker({...remainingMarkers, ...alertMarkers}),
            newsList: combinedNewsList,
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
        return m.copyWith(alphaParam: newValue ? 1.0 : 0.0);
      }
      return m;
    }).toSet();

    emit(state.copyWith(
      showAnimatedMarkers: newValue,
      markers: updatedMarkers,
    ));
  }
}
