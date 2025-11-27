import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presshop/view/map/models/map_state.dart';
import 'package:presshop/view/map/models/marker_model.dart';

import '../services/marker_service.dart';
import '../services/map_service.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class MapController extends StateNotifier<MapState> {
  final MapService mapService;
  final MarkerService markerService;
  Timer? _demoRouteTimer;
  int _demoRouteIndex = 0;
  String _demoRouteInfo = '';
  DateTime? _lastDragEndTime;
  Timer? _allowMarkerSelectionTimer;

  MapController({required this.mapService, required this.markerService})
      : super(MapState());

  Future<void> setMyLocation(LatLng location) async {
    final updatedCircles = {
      ...state.circles.where((c) => c.circleId.value != 'me_circle'),
      Circle(
        circleId: const CircleId('me_circle'),
        center: location,
        radius: 40,
        fillColor: const Color(0xFFEC4E54).withOpacity(0.18),
        strokeColor: const Color(0xFFEC2020),
        strokeWidth: 3,
      ),
    };
    state = state.copyWith(
      myLocation: location,
      initialCamera: CameraPosition(target: location, zoom: 14),
      circles: updatedCircles,
    );
  }

  void toggleAlertPanel() {
    state = state.copyWith(showAlertPanel: !state.showAlertPanel);
  }

  void toggleGetDirectionCard() {
    state = state.copyWith(showGetDirectionCard: !state.showGetDirectionCard);
  }

  void addMarker(Marker marker) {
    state = state.copyWith(markers: {...state.markers, marker});
  }

  Future<BitmapDescriptor> bitmapFromNetwork(
    String url, {
    int size = 120,
  }) async {
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;

    // Decode synchronously to UI image
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: size);
    final frame = await codec.getNextFrame();
    final ui.Image img = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final radius = size / 2;

    // 🔹 White circular background
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(radius, radius), radius, bgPaint);

    // 🔹 Clip image to circle
    final clipPath = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius),
      );
    canvas.clipPath(clipPath);

    // 🔹 Draw image
    canvas.drawImageRect(
      img,
      Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
      Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
      Paint(),
    );

    // 🔹 Add white border stroke (optional)
    canvas.drawCircle(
      Offset(radius, radius),
      radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    // Convert to png bytes and release native peer
    final ui.Image finalImage = await recorder.endRecording().toImage(
          size,
          size,
        );

    final byteData = await finalImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  void setDragging(bool isDragging) {
    state = state.copyWith(isDragging: isDragging);
    if (isDragging) {
      // Don't close info window when dragging starts
      // state = state.copyWith(
      //   clearSelectedIncident: true,
      //   clearSelectedPosition: true,
      // );
      // sdf
      // Cancel any pending timer
      _allowMarkerSelectionTimer?.cancel();
      _allowMarkerSelectionTimer = null;
    } else {
      // Record when dragging ended
      _lastDragEndTime = DateTime.now();
      // Set a timer to allow marker selection after a delay
      _allowMarkerSelectionTimer?.cancel();
      _allowMarkerSelectionTimer = Timer(const Duration(milliseconds: 150), () {
        _lastDragEndTime = null; // Clear the drag end time after delay
      });
    }
  }

  void selectMarker(Incident incident) {
    if (state.isDragging) {
      return;
    }
    if (_lastDragEndTime != null) {
      final timeSinceDragEnd = DateTime.now().difference(_lastDragEndTime!);
      if (timeSinceDragEnd.inMilliseconds < 150) {
        return;
      }
    }

    state = state.copyWith(
      selectedIncident: incident,
      selectedPosition: incident.position,
    );
  }

  void clearSelectedMarker() {
    state = state.copyWith(
      clearSelectedIncident: true,
      clearSelectedPosition: true,
    );
    // Reset drag end time when explicitly closing
    _lastDragEndTime = null;
  }

  Future<void> addAlertMarker(String alertType, LatLng position) async {
    // This method is now used for direct addition or finalization
    await _createAndAddAlertMarker(alertType, position);
  }

  Future<void> _createAndAddAlertMarker(
    String alertType,
    LatLng position,
  ) async {
    const markerIconSize = 142;
    BitmapDescriptor icon = BitmapDescriptor.defaultMarker;

    // Map alert type to icon type
    String? iconType;
    if (alertType.toLowerCase().contains('accident') ||
        alertType.toLowerCase().contains('crash')) {
      iconType = 'accident';
    } else if (alertType.toLowerCase().contains('fire')) {
      iconType = 'fire';
    } else if (alertType.toLowerCase().contains('gun')) {
      iconType = 'gun';
    } else if (alertType.toLowerCase().contains('knife')) {
      iconType = 'knife';
    } else if (alertType.toLowerCase().contains('fight')) {
      iconType = 'fight';
    } else if (alertType.toLowerCase().contains('protest')) {
      iconType = 'protest';
    } else if (alertType.toLowerCase().contains('medicine') ||
        alertType.toLowerCase().contains('medical')) {
      iconType = 'medical';
    } else {
      iconType = 'accident'; // default
    }

    final assetPath = markerService.markerIcons[iconType] ??
        markerService.markerIcons['accident']!;
    icon = await markerService.bitmapFromIncidentAsset(
      assetPath,
      markerIconSize,
    );

    final newIncident = Incident(
      id: 'user-alert-${DateTime.now().millisecondsSinceEpoch}',
      markerType: 'icon',
      type: iconType,
      position: position,
      address: 'User reported alert',
      time: DateTime.now().toString().substring(11, 16),
      category: 'User Alert',
      alertType: 'Alert',
    );

    final marker = Marker(
      markerId: MarkerId(newIncident.id),
      position: position,
      icon: icon,
      onTap: () {
        selectMarker(newIncident);
      },
      infoWindow: const InfoWindow(),
    );

    state = state.copyWith(markers: {...state.markers, marker});
  }

  Future<void> setPreviewAlertMarker(String alertType, LatLng position) async {
    const markerIconSize = 142;

    // Use the same icon logic as addAlertMarker
    String? iconType;
    if (alertType.toLowerCase().contains('accident') ||
        alertType.toLowerCase().contains('crash')) {
      iconType = 'accident';
    } else if (alertType.toLowerCase().contains('fire')) {
      iconType = 'fire';
    } else if (alertType.toLowerCase().contains('gun')) {
      iconType = 'gun';
    } else if (alertType.toLowerCase().contains('knife')) {
      iconType = 'knife';
    } else if (alertType.toLowerCase().contains('fight')) {
      iconType = 'fight';
    } else if (alertType.toLowerCase().contains('protest')) {
      iconType = 'protest';
    } else if (alertType.toLowerCase().contains('medicine') ||
        alertType.toLowerCase().contains('medical')) {
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

    final previewMarker = Marker(
      markerId: const MarkerId('preview_alert'),
      position: position,
      icon: icon,
      draggable: true,
      onDragEnd: (newPos) {
        updatePreviewAlertPosition(newPos);
      },
    );

    state = state.copyWith(
      markers: {...state.markers, previewMarker},
      previewAlertMarkerId: 'preview_alert',
      previewAlertType: alertType,
      previewAlertPosition: position,
    );
  }

  void updatePreviewAlertPosition(LatLng position) {
    if (state.previewAlertMarkerId == null) return;

    // Update the marker position in the list
    final updatedMarkers = state.markers.map((m) {
      if (m.markerId.value == 'preview_alert') {
        return m.copyWith(positionParam: position);
      }
      return m;
    }).toSet();

    state = state.copyWith(
      markers: updatedMarkers,
      previewAlertPosition: position,
    );
  }

  void cancelPreviewAlert() {
    if (state.previewAlertMarkerId == null) return;

    state = state.copyWith(
      markers: state.markers
        ..removeWhere((m) => m.markerId.value == 'preview_alert'),
      clearPreviewAlert: true,
    );
  }

  Future<void> finalizeAlertMarker() async {
    if (state.previewAlertMarkerId != null &&
        state.previewAlertType != null &&
        state.previewAlertPosition != null) {
      await _createAndAddAlertMarker(
        state.previewAlertType!,
        state.previewAlertPosition!,
      );
      cancelPreviewAlert();
    }
  }

  void updateFilters({String? alertType, String? distance, String? category}) {
    state = state.copyWith(
      selectedAlertType: alertType,
      selectedDistance: distance,
      selectedCategory: category,
    );
    // Refresh markers with new filters
    addNearbyMarkers();
  }

  double _parseDistance(String distanceStr) {
    if (distanceStr.contains('1 mile')) return 1609.34; // meters
    if (distanceStr.contains('2 miles')) return 3218.68;
    if (distanceStr.contains('5 miles')) return 8046.72;
    return 3218.68; // default 2 miles
  }

  double _calculateDistance(LatLng a, LatLng b) {
    const double earthRadius = 6371000; // meters
    final dLat = (b.latitude - a.latitude) * (math.pi / 180);
    final dLng = (b.longitude - a.longitude) * (math.pi / 180);
    final a1 = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(a.latitude * (math.pi / 180)) *
            math.cos(b.latitude * (math.pi / 180)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a1), math.sqrt(1 - a1));
    return earthRadius * c;
  }

  Future<void> addNearbyMarkers() async {
    if (state.myLocation == null) return;

    const markerIconSize = 142;
    var incidents = markerService.getIncidents();

    // Apply filters
    if (state.selectedAlertType != null && state.selectedAlertType != 'Alert') {
      incidents = incidents.where((incident) {
        return incident.alertType == state.selectedAlertType;
      }).toList();
    }

    if (state.selectedCategory != null &&
        state.selectedCategory != 'Category') {
      incidents = incidents.where((incident) {
        return incident.category == state.selectedCategory;
      }).toList();
    }

    if (state.selectedDistance != null && state.selectedDistance != '2 miles') {
      final maxDistance = _parseDistance(state.selectedDistance!);
      incidents = incidents.where((incident) {
        final distance = _calculateDistance(
          state.myLocation!,
          incident.position,
        );
        return distance <= maxDistance;
      }).toList();
    }

    final List<Marker> markers = [];

    for (var incident in incidents) {
      BitmapDescriptor icon = BitmapDescriptor.defaultMarker;

      if (incident.markerType == 'icon') {
        final assetPath = markerService.markerIcons[incident.type] ??
            markerService.markerIcons['accident']!;
        icon = await markerService.bitmapFromIncidentAsset(
          assetPath,
          markerIconSize,
        );
      } else if (incident.markerType == 'content' ||
          incident.markerType == 'hopper') {
        icon = await bitmapFromNetwork(incident.image!, size: 120);
      }

      markers.add(
        Marker(
          markerId: MarkerId(incident.id),
          position: incident.position,
          icon: icon,
          onTap: () {
            selectMarker(incident);
          },
          infoWindow: const InfoWindow(),
        ),
      );
    }

    // Remove old incident markers, keep user location and demo markers
    final filteredMarkers = state.markers.where((m) {
      return m.markerId.value == 'me' ||
          m.markerId.value == 'demo_route_marker';
    }).toSet();

    state = state.copyWith(markers: {...filteredMarkers, ...markers});
  }

  void addDemoPolygon() {
    final polygon = Polygon(
      polygonId: const PolygonId('demo_area'),
      points: const [
        LatLng(37.7843755, -122.4310937),
        LatLng(37.7780518, -122.4356622),
        LatLng(37.7780518, -122.429),
        LatLng(37.7843755, -122.429),
      ],
      strokeColor: Colors.redAccent,
      strokeWidth: 3,
      fillColor: Colors.redAccent.withOpacity(0.2),
      geodesic: true,
      onTap: () {
        selectPolygon('demo_area');
      },
      consumeTapEvents: true,
    );

    state = state.copyWith(polygons: {...state.polygons, polygon});
  }

  void selectPolygon(String polygonId) {
    if (state.isDragging) return;

    // Find the polygon and calculate center
    final polygon = state.polygons.firstWhere(
      (p) => p.polygonId.value == polygonId,
      orElse: () => state.polygons.first,
    );

    // Calculate center of polygon
    double latSum = 0, lngSum = 0;
    for (var point in polygon.points) {
      latSum += point.latitude;
      lngSum += point.longitude;
    }
    final center = LatLng(
      latSum / polygon.points.length,
      lngSum / polygon.points.length,
    );

    state = state.copyWith(
      selectedPolygonId: polygonId,
      selectedPolygonPosition: center,
    );
  }

  void clearSelectedPolygon() {
    state = state.copyWith(
      clearSelectedPolygonId: true,
      clearSelectedPolygonPosition: true,
    );
  }

  /// Add route from current location to destination
  Future<void> addRoute(LatLng? start, LatLng destination) async {
    if (start == null) {
      start = state.myLocation;
    }
    if (start == null) return;

    try {
      final routeInfo = await mapService.getRouteInfo(start, destination);

      // Add destination marker
      final destinationMarker = Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        infoWindow: InfoWindow(
          title: 'Destination',
          snippet: routeInfo.formattedInfo,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );

      // Create polyline
      final polyline = Polyline(
        polylineId: const PolylineId('route'),
        points: routeInfo.points,
        color: Colors.blue,
        width: 5,
        geodesic: true,
      );

      // Calculate midpoint
      LatLng? midpoint;
      if (routeInfo.points.isNotEmpty) {
        final midIndex = routeInfo.points.length ~/ 2;
        midpoint = routeInfo.points[midIndex];
      }

      // Update state with route info
      state = state.copyWith(
        polylines: {polyline},
        destination: destination,
        routeInfo: routeInfo,
        routeMidpoint: midpoint,
        markers: {
          ...state.markers
            ..removeWhere((m) => m.markerId.value == 'destination'),
          destinationMarker,
        },
      );
    } catch (e) {
      print('Error getting route: $e');
    }
  }

  /// Clear route
  void clearRoute() {
    state = state.copyWith(
      polylines: {},
      clearDestination: true,
      clearRouteInfo: true,
      markers: state.markers
        ..removeWhere((m) => m.markerId.value == 'destination'),
    );
  }

  /// Add demo route polyline
  Future<void> addDemoRoute(LatLng start, LatLng end) async {
    final routePoints = await mapService.getRoutePoints(start, end);
    _demoRouteInfo = mapService.getDistanceText(routePoints);

    final polyline = Polyline(
      polylineId: const PolylineId('demo_route'),
      points: routePoints,
      color: Colors.redAccent,
      width: 6,
    );

    state = state.copyWith(
      polylines: {polyline},
      routeMidpoint:
          routePoints.isNotEmpty ? routePoints[routePoints.length ~/ 2] : null,
    );
    _animateDemoMarker(routePoints);
  }

  void _animateDemoMarker(List<LatLng> routePoints) {
    _demoRouteIndex = 0;
    double fraction = 0.0;
    const stepDuration = Duration(milliseconds: 50);

    _demoRouteTimer?.cancel();
    _demoRouteTimer = Timer.periodic(stepDuration, (timer) {
      if (_demoRouteIndex >= routePoints.length - 1) {
        timer.cancel();
        return;
      }

      final start = routePoints[_demoRouteIndex];
      final end = routePoints[_demoRouteIndex + 1];

      fraction += 0.02;
      if (fraction >= 1.0) {
        fraction = 0.0;
        _demoRouteIndex++;
      }

      final lat = start.latitude + (end.latitude - start.latitude) * fraction;
      final lng =
          start.longitude + (end.longitude - start.longitude) * fraction;

      final marker = Marker(
        markerId: const MarkerId('demo_route_marker'),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: 'Demo Route', snippet: _demoRouteInfo),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );

      state = state.copyWith(
        markers: {
          ...state.markers
            ..removeWhere((m) => m.markerId.value == 'demo_route_marker'),
          marker,
        },
      );
    });
  }

  void setDestinationSelectionMode(bool enabled, {bool isOrigin = false}) {
    state = state.copyWith(
      isDestinationSelectionMode: enabled,
      isSelectingOrigin: enabled && isOrigin,
    );
  }

  void setMapSelectedLocation({
    required LatLng position,
    required String address,
    required bool isOrigin,
  }) {
    state = state.copyWith(
      mapSelectedLocation: position,
      mapSelectedAddress: address,
      mapSelectedIsOrigin: isOrigin,
    );
  }

  void clearMapSelectedLocation() {
    state = state.copyWith(
      clearMapSelectedLocation: true,
      clearMapSelectedAddress: true,
      clearMapSelectedIsOrigin: true,
    );
  }

  Future<String> getAddressFromCoordinates(LatLng position) async {
    try {
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=${mapService.googleApiKey}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'] as String;
        }
      }
      return '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
    } catch (e) {
      return '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
    }
  }

  void startNavigation() {
    state = state.copyWith(isNavigating: true, showGetDirectionCard: false);
  }

  void stopNavigation() {
    state = state.copyWith(
      isNavigating: false,
      clearCurrentNavigationPosition: true,
    );
  }

  void updateNavigationPosition(LatLng position) {
    if (!state.isNavigating) return;

    state = state.copyWith(currentNavigationPosition: position);

    // Update polyline to erase behind user
    if (state.routeInfo != null && state.routeInfo!.points.isNotEmpty) {
      // Find the closest point on the route to current position
      int closestIndex = 0;
      double minDistance = double.infinity;

      for (int i = 0; i < state.routeInfo!.points.length; i++) {
        final distance = _calculateDistance(
          position,
          state.routeInfo!.points[i],
        );
        if (distance < minDistance) {
          minDistance = distance;
          closestIndex = i;
        }
      }

      // Create new polyline with remaining points
      final remainingPoints = state.routeInfo!.points.sublist(closestIndex);

      if (remainingPoints.length > 1) {
        final updatedPolylines = state.polylines.map((polyline) {
          if (polyline.polylineId.value == 'route') {
            return polyline.copyWith(pointsParam: remainingPoints);
          }
          return polyline;
        }).toSet();

        state = state.copyWith(polylines: updatedPolylines);
      }
    }
  }

  @override
  void dispose() {
    _demoRouteTimer?.cancel();
    _allowMarkerSelectionTimer?.cancel();
    super.dispose();
  }
}
