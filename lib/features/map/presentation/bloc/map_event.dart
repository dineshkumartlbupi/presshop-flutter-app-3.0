import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presshop/features/map/data/models/marker_model.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object> get props => [];
}

class GetCurrentLocationEvent extends MapEvent {
  const GetCurrentLocationEvent();
}

class GetRouteEvent extends MapEvent {
  final LatLng start;
  final LatLng end;

  const GetRouteEvent({required this.start, required this.end});

  @override
  List<Object> get props => [start, end];
}

class SearchPlacesEvent extends MapEvent {
  final String query;

  const SearchPlacesEvent({required this.query});

  @override
  List<Object> get props => [query];
}

class OnIncidentNewEvent extends MapEvent {
  final dynamic data;
  const OnIncidentNewEvent(this.data);
  @override
  List<Object> get props => [data];
}

class OnIncidentUpdatedEvent extends MapEvent {
  final dynamic data;
  const OnIncidentUpdatedEvent(this.data);
  @override
  List<Object> get props => [data];
}

class FetchNewsEvent extends MapEvent {
  final double lat;
  final double lng;
  final double km;
  final String category;

  const FetchNewsEvent({
    required this.lat,
    required this.lng,
    required this.km,
    this.category = "all",
  });

  @override
  List<Object> get props => [lat, lng, km, category];
}

class SetSearchedLocationEvent extends MapEvent {
  final LatLng location;
  const SetSearchedLocationEvent(this.location);
  @override
  List<Object> get props => [location];
}

class SetSelectedPositionEvent extends MapEvent {
  final LatLng position;
  const SetSelectedPositionEvent(this.position);
  @override
  List<Object> get props => [position];
}

class ToggleAlertPanelEvent extends MapEvent {
  const ToggleAlertPanelEvent();
}

class ClearSelectedMarkerEvent extends MapEvent {
  const ClearSelectedMarkerEvent();
}

class ClearSelectedPolygonEvent extends MapEvent {
  const ClearSelectedPolygonEvent();
}

class UpdateFiltersEvent extends MapEvent {
  final String? alertType;
  final String? distance;
  final String? category;

  const UpdateFiltersEvent({this.alertType, this.distance, this.category});

  @override
  List<Object> get props => [alertType ?? '', distance ?? '', category ?? ''];
}

class AddAlertMarkerEvent extends MapEvent {
  final String type;
  final LatLng position;

  const AddAlertMarkerEvent({required this.type, required this.position});

  @override
  List<Object> get props => [type, position];
}

class SetPreviewAlertMarkerEvent extends MapEvent {
  final String type;
  final LatLng position;

  const SetPreviewAlertMarkerEvent(
      {required this.type, required this.position});

  @override
  List<Object> get props => [type, position];
}

class SetSelectedIncidentEvent extends MapEvent {
  final Incident incident;
  const SetSelectedIncidentEvent(this.incident);
  @override
  List<Object> get props => [incident];
}

class SetMapSelectedLocationEvent extends MapEvent {
  final LatLng position;
  final String address;
  final bool isOrigin;

  const SetMapSelectedLocationEvent({
    required this.position,
    required this.address,
    required this.isOrigin,
  });

  @override
  List<Object> get props => [position, address, isOrigin];
}

class ClearMapSelectedLocationEvent extends MapEvent {
  const ClearMapSelectedLocationEvent();
}

class StartNavigationEvent extends MapEvent {
  const StartNavigationEvent();
}

class StopNavigationEvent extends MapEvent {
  const StopNavigationEvent();
}

class ToggleGetDirectionCardEvent extends MapEvent {
  const ToggleGetDirectionCardEvent();
}

class SetDestinationSelectionModeEvent extends MapEvent {
  final bool isSelectionMode;
  final bool isOrigin;

  const SetDestinationSelectionModeEvent({
    required this.isSelectionMode,
    this.isOrigin = false,
  });

  @override
  List<Object> get props => [isSelectionMode, isOrigin];
}

class ClearRouteEvent extends MapEvent {
  const ClearRouteEvent();
}

class UpdatePulseCircleEvent extends MapEvent {
  final double radiusMultiplier;
  final double opacity;
  final double zoomLevel;

  const UpdatePulseCircleEvent({
    required this.radiusMultiplier,
    required this.opacity,
    required this.zoomLevel,
  });

  @override
  List<Object> get props => [radiusMultiplier, opacity, zoomLevel];
}
