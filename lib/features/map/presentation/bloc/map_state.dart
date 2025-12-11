part of 'map_bloc.dart';

enum MapStatus { initial, loading, success, failure }

class MapState extends Equatable {
  final MapStatus status;
  final String errorMessage;
  
  // Domain State
  final GeoPoint? myLocation;
  final List<IncidentEntity> incidents;
  final IncidentEntity? selectedIncident;
  final RouteInfoEntity? routeInfo;
  final List<PlaceSuggestionEntity> searchPredictions;
  
  // UI State (kept here for performance/compatibility)
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Set<Polygon> polygons;
  final Set<Circle> circles;
  final CameraPosition? initialCamera;
  
  final bool showAlertPanel;
  final bool showGetDirectionCard;
  
  final String? selectedAlertType;
  final String? selectedDistance;
  final String? selectedCategory;
  
  // Internal/Transient
  final bool isNavigating;
  final bool isDragging;

  const MapState({
    this.status = MapStatus.initial,
    this.errorMessage = '',
    this.myLocation,
    this.incidents = const [],
    this.selectedIncident,
    this.routeInfo,
    this.searchPredictions = const [],
    this.markers = const {},
    this.polylines = const {},
    this.polygons = const {},
    this.circles = const {},
    this.initialCamera,
    this.showAlertPanel = false,
    this.showGetDirectionCard = false,
    this.selectedAlertType,
    this.selectedDistance,
    this.selectedCategory,
    this.isNavigating = false,
    this.isDragging = false,
  });

  MapState copyWith({
    MapStatus? status,
    String? errorMessage,
    GeoPoint? myLocation,
    List<IncidentEntity>? incidents,
    IncidentEntity? selectedIncident,
    bool clearSelectedIncident = false,
    RouteInfoEntity? routeInfo,
    bool clearRouteInfo = false,
    List<PlaceSuggestionEntity>? searchPredictions,
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    Set<Polygon>? polygons,
    Set<Circle>? circles,
    CameraPosition? initialCamera,
    bool? showAlertPanel,
    bool? showGetDirectionCard,
    String? selectedAlertType,
    String? selectedDistance,
    String? selectedCategory,
    bool? isNavigating,
    bool? isDragging,
  }) {
    return MapState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      myLocation: myLocation ?? this.myLocation,
      incidents: incidents ?? this.incidents,
      selectedIncident: clearSelectedIncident ? null : (selectedIncident ?? this.selectedIncident),
      routeInfo: clearRouteInfo ? null : (routeInfo ?? this.routeInfo),
      searchPredictions: searchPredictions ?? this.searchPredictions,
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      polygons: polygons ?? this.polygons,
      circles: circles ?? this.circles,
      initialCamera: initialCamera ?? this.initialCamera,
      showAlertPanel: showAlertPanel ?? this.showAlertPanel,
      showGetDirectionCard: showGetDirectionCard ?? this.showGetDirectionCard,
      selectedAlertType: selectedAlertType ?? this.selectedAlertType,
      selectedDistance: selectedDistance ?? this.selectedDistance,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isNavigating: isNavigating ?? this.isNavigating,
      isDragging: isDragging ?? this.isDragging,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        myLocation,
        incidents,
        selectedIncident,
        routeInfo,
        searchPredictions,
        markers,
        polylines,
        polygons,
        circles,
        initialCamera,
        showAlertPanel,
        showGetDirectionCard,
        selectedAlertType,
        selectedDistance,
        selectedCategory,
        isNavigating,
        isDragging,
      ];
}
