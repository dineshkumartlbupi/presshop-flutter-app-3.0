part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class MapInitialized extends MapEvent {}

class MapLoadIncidents extends MapEvent {}

class MapIncidentNewReceived extends MapEvent {
  final IncidentEntity incident;
  const MapIncidentNewReceived(this.incident);
  @override
  List<Object> get props => [incident];
}

class MapUserLocationUpdated extends MapEvent {
  final GeoPoint location;
  const MapUserLocationUpdated(this.location);
  @override
  List<Object> get props => [location];
}

class MapTrafficUpdated extends MapEvent {
  final bool showTraffic;
  const MapTrafficUpdated(this.showTraffic);
  @override
  List<Object> get props => [showTraffic];
}

class MapReportIncident extends MapEvent {
  final String alertType;
  final GeoPoint position;
  const MapReportIncident(this.alertType, this.position);
  @override
  List<Object> get props => [alertType, position];
}

class MapRouteRequested extends MapEvent {
  final GeoPoint start;
  final GeoPoint end;
  const MapRouteRequested(this.start, this.end);
  @override
  List<Object> get props => [start, end];
}

class MapRequestRouteFromCurrentLocation extends MapEvent {
  final GeoPoint destination;
  const MapRequestRouteFromCurrentLocation(this.destination);
  @override
  List<Object> get props => [destination];
}

class MapClearRoute extends MapEvent {}

class MapSearchQueryChanged extends MapEvent {
  final String query;
  const MapSearchQueryChanged(this.query);
  @override
  List<Object> get props => [query];
}

class MapPlaceSelected extends MapEvent {
  final String placeId;
  final String description;
  const MapPlaceSelected(this.placeId, this.description);
  @override
  List<Object> get props => [placeId, description];
}

class MapMarkerSelected extends MapEvent {
  final IncidentEntity? incident;
  const MapMarkerSelected(this.incident);
  @override
  List<Object?> get props => [incident];
}

class MapAlertPanelToggled extends MapEvent {}

class MapFilterChanged extends MapEvent {
  final String? alertType;
  final String? distance;
  final String? category;
  const MapFilterChanged({this.alertType, this.distance, this.category});
  @override
  List<Object?> get props => [alertType, distance, category];
}

class MapDirectionCardToggled extends MapEvent {}
class MapGetDirectionCardToggled extends MapEvent {} // Alias if needed, or stick to one. existing had request logic mixed.
