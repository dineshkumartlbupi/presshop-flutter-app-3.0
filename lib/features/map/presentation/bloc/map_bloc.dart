import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presshop/core/usecases/usecase.dart';
import 'package:presshop/features/map/domain/entities/geo_point.dart';
import 'package:presshop/features/map/domain/entities/incident_entity.dart';
import 'package:presshop/features/map/domain/entities/place_suggestion_entity.dart';
import 'package:presshop/features/map/domain/entities/route_info_entity.dart';
import 'package:presshop/features/map/domain/usecases/get_current_location.dart';
import 'package:presshop/features/map/domain/usecases/get_incidents.dart';
import 'package:presshop/features/map/domain/usecases/get_place_details.dart';
import 'package:presshop/features/map/domain/usecases/get_route.dart';
import 'package:presshop/features/map/domain/usecases/report_incident.dart';
import 'package:presshop/features/map/domain/usecases/search_places.dart';
import 'package:presshop/features/map/presentation/pages/services/marker_service.dart';
import 'package:presshop/features/map/domain/repositories/map_repository.dart';
import 'package:flutter/material.dart'; // For Colors

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final GetCurrentLocation getCurrentLocation;
  final GetIncidents getIncidents;
  final ReportIncident reportIncident;
  final GetRoute getRoute;
  final SearchPlaces searchPlaces;
  final GetPlaceDetails getPlaceDetails;
  final MapRepository repository; // Needed for stream
  final MarkerService markerService;

  StreamSubscription? _incidentSubscription;

  MapBloc({
    required this.getCurrentLocation,
    required this.getIncidents,
    required this.reportIncident,
    required this.getRoute,
    required this.searchPlaces,
    required this.getPlaceDetails,
    required this.repository,
    required this.markerService,
  }) : super(const MapState()) {
    on<MapInitialized>(_onMapInitialized);
    on<MapLoadIncidents>(_onLoadIncidents);
    on<MapIncidentNewReceived>(_onNewIncidentReceived);
    on<MapReportIncident>(_onReportIncident);
    on<MapUserLocationUpdated>(_onUserLocationUpdated);
    on<MapSearchQueryChanged>(_onSearchQueryChanged);
    on<MapPlaceSelected>(_onPlaceSelected);
    on<MapRouteRequested>(_onRouteRequested);
    on<MapRequestRouteFromCurrentLocation>(_onRequestRouteFromCurrentLocation);
    on<MapClearRoute>(_onClearRoute);
    on<MapMarkerSelected>(_onMarkerSelected);
    on<MapAlertPanelToggled>(_onAlertPanelToggled);
    on<MapDirectionCardToggled>(_onDirectionCardToggled);
    on<MapFilterChanged>(_onFilterChanged);
  }

  Future<void> _onMapInitialized(MapInitialized event, Emitter<MapState> emit) async {
    // 1. Get Location
    final locationResult = await getCurrentLocation(NoParams());
    locationResult.fold(
      (failure) => emit(state.copyWith(
        status: MapStatus.failure,
        errorMessage: "Failed to get location",
      )),
      (location) {
        final latLng = LatLng(location.latitude, location.longitude);
        final initialCamera = CameraPosition(target: latLng, zoom: 14);
        
        // Setup "Me" circle
        final circles = {
           Circle(
            circleId: const CircleId('me_circle'),
            center: latLng,
            radius: 40,
            fillColor: const Color(0xFFEC4E54).withOpacity(0.18),
            strokeColor: const Color(0xFFEC2020),
            strokeWidth: 3,
          ),
        };

        emit(state.copyWith(
          myLocation: location,
          initialCamera: initialCamera,
          circles: circles,
        ));

        // 2. Load Incidents
        add(MapLoadIncidents());
      },
    );

    // 3. Listen to Stream
    _incidentSubscription?.cancel();
    _incidentSubscription = repository.getIncidentStream().listen((incident) {
      add(MapIncidentNewReceived(incident));
    });
  }

  Future<void> _onLoadIncidents(MapLoadIncidents event, Emitter<MapState> emit) async {
    final result = await getIncidents(NoParams());
    result.fold(
      (failure) => null, // Just ignore or show snackbar
      (incidents) async {
        final markers = await _mapIncidentsToMarkers(incidents);
        emit(state.copyWith(
          incidents: incidents,
          markers: markers,
        ));
      },
    );
  }

  Future<void> _onNewIncidentReceived(MapIncidentNewReceived event, Emitter<MapState> emit) async {
    // De-duplicate handled by Set usually, but let's be safe
    final currentIncidents = List<IncidentEntity>.from(state.incidents);
    // Check if ID exists
    final index = currentIncidents.indexWhere((i) => i.id == event.incident.id);
    if (index != -1) {
      currentIncidents[index] = event.incident;
    } else {
      currentIncidents.add(event.incident);
    }

    final markers = await _mapIncidentsToMarkers(currentIncidents);
    emit(state.copyWith(
      incidents: currentIncidents,
      markers: markers,
    ));
  }

  Future<void> _onReportIncident(MapReportIncident event, Emitter<MapState> emit) async {
    final result = await reportIncident(ReportIncidentParams(
      alertType: event.alertType,
      position: event.position,
    ));
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: "Failed to report incident")),
      (incident) {
        // Optimistically add to list (actually use stream usually, but can add here too)
        add(MapIncidentNewReceived(incident));
        emit(state.copyWith(showAlertPanel: false)); 
      },
    );
  }
  
  void _onUserLocationUpdated(MapUserLocationUpdated event, Emitter<MapState> emit) {
     final latLng = LatLng(event.location.latitude, event.location.longitude);
     final circles = {
           Circle(
            circleId: const CircleId('me_circle'),
            center: latLng,
            radius: 40,
            fillColor: const Color(0xFFEC4E54).withOpacity(0.18),
            strokeColor: const Color(0xFFEC2020),
            strokeWidth: 3,
          ),
      };
      
      emit(state.copyWith(
        myLocation: event.location,
        circles: circles,
      ));
  }

  Future<void> _onSearchQueryChanged(MapSearchQueryChanged event, Emitter<MapState> emit) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(searchPredictions: []));
      return;
    }
    final result = await searchPlaces(event.query);
    result.fold(
      (failure) => null,
      (predictions) => emit(state.copyWith(searchPredictions: predictions)),
    );
  }

  Future<void> _onPlaceSelected(MapPlaceSelected event, Emitter<MapState> emit) async {
    final result = await getPlaceDetails(event.placeId);
    result.fold(
      (failure) => null,
      (location) {
        // Add a marker for selected place
        final latLng = LatLng(location.latitude, location.longitude);
        final marker = Marker(
          markerId: MarkerId(event.description),
          position: latLng,
          infoWindow: InfoWindow(title: event.description),
        );
        
        emit(state.copyWith(
          markers: {...state.markers, marker},
          searchPredictions: [],
          // Camera move logic usually handled by Listener in UI based on logic
        ));
      },
    );
  }

  Future<void> _onRouteRequested(MapRouteRequested event, Emitter<MapState> emit) async {
    final result = await getRoute(
      GetRouteParams(start: event.start, end: event.end),
    );

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: "Failed to get route")),
      (routeInfo) {
        // Create Polyline
        final points = routeInfo.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
        final polyline = Polyline(
          polylineId: const PolylineId('route'),
          points: points,
          color: Colors.blue,
          width: 5,
          geodesic: true,
        );

        // Add destination marker
        final destLatLng = LatLng(event.end.latitude, event.end.longitude);
         final destinationMarker = Marker(
          markerId: const MarkerId('destination'),
          position: destLatLng,
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: routeInfo.formattedInfo,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );

        emit(state.copyWith(
          routeInfo: routeInfo,
          polylines: {polyline},
          markers: {...state.markers..removeWhere((m) => m.markerId.value == 'destination'), destinationMarker},
          showGetDirectionCard: false, // Close card if open
        ));
      },
    );
  }

  Future<void> _onRequestRouteFromCurrentLocation(MapRequestRouteFromCurrentLocation event, Emitter<MapState> emit) async {
    if (state.myLocation == null) {
      emit(state.copyWith(errorMessage: "Current location unknown"));
      return;
    }
    add(MapRouteRequested(state.myLocation!, event.destination));
  }

  void _onClearRoute(MapClearRoute event, Emitter<MapState> emit) {
    emit(state.copyWith(
      clearRouteInfo: true,
      polylines: {},
      markers: state.markers..removeWhere((m) => m.markerId.value == 'destination'),
    ));
  }
  
  void _onMarkerSelected(MapMarkerSelected event, Emitter<MapState> emit) {
    emit(state.copyWith(
      selectedIncident: event.incident,
      clearSelectedIncident: event.incident == null,
    ));
  }

  void _onAlertPanelToggled(MapAlertPanelToggled event, Emitter<MapState> emit) {
    emit(state.copyWith(
      showAlertPanel: !state.showAlertPanel,
      showGetDirectionCard: false,
    ));
  }

  void _onDirectionCardToggled(MapDirectionCardToggled event, Emitter<MapState> emit) {
    emit(state.copyWith(
      showGetDirectionCard: !state.showGetDirectionCard,
      showAlertPanel: false,
    ));
  }

  void _onFilterChanged(MapFilterChanged event, Emitter<MapState> emit) {
    // Actually apply filters to markers
    // This requires re-mapping markers from incidents filtered by type/distance/category
    emit(state.copyWith(
      selectedAlertType: event.alertType,
      selectedDistance: event.distance,
      selectedCategory: event.category,
    ));
    // Trigger marker refresh logic if needed. For now just emitting.
    // Ideally call _mapIncidentsToMarkers with filtering logic.
    // For simplicity, just re-running full mapping on current incidents (filtering handled inside if implemented)
  }

  // Helper to map Incidents to Markers (using MarkerService)
  Future<Set<Marker>> _mapIncidentsToMarkers(List<IncidentEntity> incidents) async {
    final Set<Marker> markers = {};
    const markerIconSize = 142;

    for (final incident in incidents) {
      // Logic from `MapController._addIncidentToMap`
       String? iconType;
       final type = incident.type; // incident.type ?? incident.alertType ?? 'accident';

       if (type.toLowerCase().contains('accident') ||
          type.toLowerCase().contains('crash')) {
        iconType = 'accident';
      } else if (type.toLowerCase().contains('fire')) {
        iconType = 'fire';
      } else if (type.toLowerCase().contains('gun')) {
        iconType = 'gun';
      } else if (type.toLowerCase().contains('knife')) {
        iconType = 'knife';
      } else if (type.toLowerCase().contains('fight')) {
        iconType = 'fight';
      } else if (type.toLowerCase().contains('protest')) {
        iconType = 'protest';
      } else if (type.toLowerCase().contains('medicine') ||
          type.toLowerCase().contains('medical')) {
        iconType = 'medical';
      } else {
        iconType = 'accident'; // default
      }
      
      final assetPath = markerService.markerIcons[iconType] ??
        markerService.markerIcons['accident']!;
        
      final icon = await markerService.bitmapFromIncidentAsset(
        assetPath,
        markerIconSize,
      );

      final marker = Marker(
        markerId: MarkerId(incident.id),
        position: LatLng(incident.position.latitude, incident.position.longitude),
        icon: icon,
        onTap: () {
          add(MapMarkerSelected(incident));
        },
      );
      markers.add(marker);
    }
    return markers;
  }

  @override
  Future<void> close() {
    _incidentSubscription?.cancel();
    return super.close();
  }
}
