import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:presshop/view/mapView/models/marker_model.dart';
import 'package:presshop/view/mapView/services/map_service.dart';

class MapState {
  final LatLng? myLocation;
  final CameraPosition? initialCamera;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Set<Polygon> polygons;
  final Set<Circle> circles;
  final bool showAlertPanel;
  final bool showGetDirectionCard;
  final LatLng? destination;
  final RouteInfo? routeInfo;
  final Incident? selectedIncident;
  final LatLng? selectedPosition;
  final bool isDragging;
  final String? selectedPolygonId;
  final LatLng? selectedPolygonPosition;
  final String? selectedAlertType;
  final String? selectedDistance;
  final String? selectedCategory;
  final bool isDestinationSelectionMode;
  final bool isSelectingOrigin;
  final bool isNavigating;
  final LatLng? currentNavigationPosition;
  final LatLng? mapSelectedLocation;
  final String? mapSelectedAddress;
  final bool? mapSelectedIsOrigin;

  final String? previewAlertMarkerId;
  final String? previewAlertType;
  final LatLng? previewAlertPosition;

  MapState({
    this.myLocation,
    this.initialCamera,
    this.markers = const {},
    this.polylines = const {},
    this.polygons = const {},
    this.circles = const {},
    this.showAlertPanel = false,
    this.showGetDirectionCard = false,
    this.destination,
    this.routeInfo,
    this.selectedIncident,
    this.selectedPosition,
    this.isDragging = false,
    this.selectedPolygonId,
    this.selectedPolygonPosition,
    this.selectedAlertType,
    this.selectedDistance,
    this.selectedCategory,
    this.isDestinationSelectionMode = false,
    this.isSelectingOrigin = false,
    this.isNavigating = false,
    this.currentNavigationPosition,
    this.mapSelectedLocation,
    this.mapSelectedAddress,
    this.mapSelectedIsOrigin,
    this.previewAlertMarkerId,
    this.previewAlertType,
    this.previewAlertPosition,
  });

  MapState copyWith({
    LatLng? myLocation,
    CameraPosition? initialCamera,
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    Set<Polygon>? polygons,
    Set<Circle>? circles,
    bool? showAlertPanel,
    bool? showGetDirectionCard,
    LatLng? destination,
    RouteInfo? routeInfo,
    Incident? selectedIncident,
    LatLng? selectedPosition,
    bool? isDragging,
    String? selectedPolygonId,
    LatLng? selectedPolygonPosition,
    String? selectedAlertType,
    String? selectedDistance,
    String? selectedCategory,
    bool? isDestinationSelectionMode,
    bool? isSelectingOrigin,
    bool? isNavigating,
    LatLng? currentNavigationPosition,
    LatLng? mapSelectedLocation,
    String? mapSelectedAddress,
    bool? mapSelectedIsOrigin,
    String? previewAlertMarkerId,
    String? previewAlertType,
    LatLng? previewAlertPosition,
    bool clearDestination = false,
    bool clearRouteInfo = false,
    bool clearSelectedIncident = false,
    bool clearSelectedPosition = false,
    bool clearSelectedPolygonId = false,
    bool clearSelectedPolygonPosition = false,
    bool clearCurrentNavigationPosition = false,
    bool clearMapSelectedLocation = false,
    bool clearMapSelectedAddress = false,
    bool clearMapSelectedIsOrigin = false,
    bool clearPreviewAlert = false,
  }) {
    return MapState(
      myLocation: myLocation ?? this.myLocation,
      initialCamera: initialCamera ?? this.initialCamera,
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      polygons: polygons ?? this.polygons,
      circles: circles ?? this.circles,
      showAlertPanel: showAlertPanel ?? this.showAlertPanel,
      showGetDirectionCard: showGetDirectionCard ?? this.showGetDirectionCard,
      destination: clearDestination ? null : (destination ?? this.destination),
      routeInfo: clearRouteInfo ? null : (routeInfo ?? this.routeInfo),
      selectedIncident: clearSelectedIncident
          ? null
          : (selectedIncident ?? this.selectedIncident),
      selectedPosition: clearSelectedPosition
          ? null
          : (selectedPosition ?? this.selectedPosition),
      isDragging: isDragging ?? this.isDragging,
      selectedPolygonId: clearSelectedPolygonId
          ? null
          : (selectedPolygonId ?? this.selectedPolygonId),
      selectedPolygonPosition: clearSelectedPolygonPosition
          ? null
          : (selectedPolygonPosition ?? this.selectedPolygonPosition),
      selectedAlertType: selectedAlertType ?? this.selectedAlertType,
      selectedDistance: selectedDistance ?? this.selectedDistance,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isDestinationSelectionMode:
          isDestinationSelectionMode ?? this.isDestinationSelectionMode,
      isSelectingOrigin: isSelectingOrigin ?? this.isSelectingOrigin,
      isNavigating: isNavigating ?? this.isNavigating,
      currentNavigationPosition: clearCurrentNavigationPosition
          ? null
          : (currentNavigationPosition ?? this.currentNavigationPosition),
      mapSelectedLocation: clearMapSelectedLocation
          ? null
          : (mapSelectedLocation ?? this.mapSelectedLocation),
      mapSelectedAddress: clearMapSelectedAddress
          ? null
          : (mapSelectedAddress ?? this.mapSelectedAddress),
      mapSelectedIsOrigin: clearMapSelectedIsOrigin
          ? null
          : (mapSelectedIsOrigin ?? this.mapSelectedIsOrigin),
      previewAlertMarkerId: clearPreviewAlert
          ? null
          : (previewAlertMarkerId ?? this.previewAlertMarkerId),
      previewAlertType: clearPreviewAlert
          ? null
          : (previewAlertType ?? this.previewAlertType),
      previewAlertPosition: clearPreviewAlert
          ? null
          : (previewAlertPosition ?? this.previewAlertPosition),
    );
  }
}
