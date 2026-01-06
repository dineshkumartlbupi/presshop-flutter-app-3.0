import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object> get props => [];
}

class GetCurrentLocationEvent extends MapEvent {}

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
