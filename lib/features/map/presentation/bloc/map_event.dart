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

  const GetRouteEvent({required this.start, required this.end});
  final LatLng start;
  final LatLng end;

  @override
  List<Object> get props => [start, end];
}

class SearchPlacesEvent extends MapEvent {

  const SearchPlacesEvent({required this.query});
  final String query;

  @override
  List<Object> get props => [query];
}

class OnIncidentNewEvent extends MapEvent {
  const OnIncidentNewEvent(this.data);
  final dynamic data;
  @override
  List<Object> get props => [data];
}

class OnIncidentUpdatedEvent extends MapEvent {
  const OnIncidentUpdatedEvent(this.data);
  final dynamic data;
  @override
  List<Object> get props => [data];
}

class FetchNewsEvent extends MapEvent {

  const FetchNewsEvent({
    required this.lat,
    required this.lng,
    required this.km,
    this.category = "all",
  });
  final double lat;
  final double lng;
  final double km;
  final String category;

  @override
  List<Object> get props => [lat, lng, km, category];
}

class SetSearchedLocationEvent extends MapEvent {
  const SetSearchedLocationEvent(this.location);
  final LatLng location;
  @override
  List<Object> get props => [location];
}

class SetSelectedPositionEvent extends MapEvent {
  const SetSelectedPositionEvent(this.position);
  final LatLng position;
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

  const UpdateFiltersEvent({this.alertType, this.distance, this.category});
  final String? alertType;
  final String? distance;
  final String? category;

  @override
  List<Object> get props => [alertType ?? '', distance ?? '', category ?? ''];
}

class AddAlertMarkerEvent extends MapEvent {

  const AddAlertMarkerEvent({required this.type, required this.position});
  final String type;
  final LatLng position;

  @override
  List<Object> get props => [type, position];
}

class SetPreviewAlertMarkerEvent extends MapEvent {

  const SetPreviewAlertMarkerEvent(
      {required this.type, required this.position});
  final String type;
  final LatLng position;

  @override
  List<Object> get props => [type, position];
}

class SetSelectedIncidentEvent extends MapEvent {
  const SetSelectedIncidentEvent(this.incident);
  final Incident incident;
  @override
  List<Object> get props => [incident];
}

class SetMapSelectedLocationEvent extends MapEvent {

  const SetMapSelectedLocationEvent({
    required this.position,
    required this.address,
    required this.isOrigin,
  });
  final LatLng position;
  final String address;
  final bool isOrigin;

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

  const SetDestinationSelectionModeEvent({
    required this.isSelectionMode,
    this.isOrigin = false,
  });
  final bool isSelectionMode;
  final bool isOrigin;

  @override
  List<Object> get props => [isSelectionMode, isOrigin];
}

class ClearRouteEvent extends MapEvent {
  const ClearRouteEvent();
}

class UpdatePulseCircleEvent extends MapEvent {

  const UpdatePulseCircleEvent({
    required this.radiusMultiplier,
    required this.opacity,
    required this.zoomLevel,
  });
  final double radiusMultiplier;
  final double opacity;
  final double zoomLevel;

  @override
  List<Object> get props => [radiusMultiplier, opacity, zoomLevel];
}
