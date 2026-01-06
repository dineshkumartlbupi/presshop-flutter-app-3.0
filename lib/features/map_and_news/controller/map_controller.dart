import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presshop/main.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonSharedPrefrence.dart';
import 'package:presshop/view/map_and_news/models/map_state.dart';
import 'package:presshop/view/map_and_news/models/marker_model.dart';
import 'package:presshop/view/map_and_news/services/socket_service.dart';
import 'package:presshop/view/map_and_news/services/news_service.dart';

import '../services/marker_service.dart';
import '../services/map_service.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class MapController extends StateNotifier<MapState> {
  final MapService mapService;
  final MarkerService markerService;
  final SocketService socketService;
  final NewsDetailsService newsService;
  Timer? _demoRouteTimer;
  int _demoRouteIndex = 0;
  String _demoRouteInfo = '';
  DateTime? _lastDragEndTime;
  Timer? _allowMarkerSelectionTimer;

  final String _userId = sharedPreferences!.getString(hopperIdKey).toString();

  MapController({required this.mapService, required this.markerService})
      : socketService = SocketService(),
        newsService = NewsDetailsService(),
        super(MapState()) {
    socketService.onIncidentNew = (data) {
      _handleNewIncident(data);
    };

    socketService.onIncidentUpdated = (data) {
      _handleUpdatedIncident(data);
    };

    socketService.onIncidentCreated = (data) {
      _handleNewIncident(data);
    };

    socketService.initSocket(
      userId: _userId,
      joinAs: "hopper",
    );

    // Initial fetch
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchInitialIncidents();
    await fetchAggregatedNews();
  }

  Future<void> fetchAggregatedNews() async {
    try {
      state = state.copyWith(isLoadingNews: true); // Start laoding

      // Determine center location: searched, then myLocation, then default
      double lat = 51.5135893;
      double lng = -0.1285953;

      if (state.searchedLocation != null) {
        lat = state.searchedLocation!.latitude;
        lng = state.searchedLocation!.longitude;
      } else if (state.myLocation != null) {
        lat = state.myLocation!.latitude;
        lng = state.myLocation!.longitude;
      }

      // Determine radius
      double km = 10;
      if (state.selectedDistance != null) {
        // _parseDistance returns meters, convert to km
        km = _parseDistance(state.selectedDistance!) / 1000;
      }
      if (km < 1) km = 1; // Minimum 1km

      final String category =
          state.selectedCategory == "Category" || state.selectedCategory == null
              ? "all"
              : state.selectedCategory!;

      final newsList = await newsService.getAggregatedNews(
        lat: lat,
        lng: lng,
        km: km,
        category: category,
      );

      if (newsList != null) {
        final Set<Marker> newMarkers = {};

        for (final incident in newsList) {
          try {
            BitmapDescriptor icon;
            Future<BitmapDescriptor> getFallbackIcon() async {
              String typeKey = 'content';
              final iType = incident.type?.toLowerCase() ??
                  incident.category?.toLowerCase() ??
                  '';

              if (iType.contains('accident') || iType.contains('crash')) {
                typeKey = 'accident';
              } else if (iType.contains('fire')) {
                typeKey = 'fire';
              } else if (iType.contains('medical')) {
                typeKey = 'medical';
              } else if (iType.contains('gun')) {
                typeKey = 'gun';
              } else if (iType.contains('knife')) {
                typeKey = 'knife';
              } else if (iType.contains('fight')) {
                typeKey = 'fight';
              } else if (iType.contains('protest')) {
                typeKey = 'protest';
              }

              final assetPath = markerService.markerIcons[typeKey] ??
                  markerService.markerIcons['content']!;
              return await markerService.bitmapFromIncidentAsset(
                  assetPath, 142);
            }

            if (incident.image != null && incident.image!.isNotEmpty) {
              try {
                icon = await bitmapFromNetwork(incident.image!, size: 150);
              } catch (e) {
                icon = await getFallbackIcon();
              }
            } else {
              icon = await getFallbackIcon();
            }

            final marker = Marker(
              markerId: MarkerId(incident.id.toString()),
              position: incident.position,
              icon: icon,
              onTap: () {
                // Start selecting marker
                print(":::Marker tapped: ${incident.id}");
                selectMarker(incident);
              },
            );

            newMarkers.add(marker);
          } catch (e) {
            debugPrint(":::Error parsing news item details: $e");
          }
        }

        print(":::Adding ${newMarkers.length} news markers to map");

        state = state.copyWith(
          markers: {...state.markers, ...newMarkers},
          newsList: newsList,
        );
      }
    } catch (e) {
      debugPrint("Error fetching aggregated news: $e");
    } finally {
      state = state.copyWith(isLoadingNews: false); // Stop loading
    }
  }

  void setSearchedLocation(LatLng location) {
    state = state.copyWith(
      searchedLocation: location,
      clearSearchedLocation: false,
    );
    // Fetch news again for this new location
    fetchAggregatedNews();
  }

  void _handleNewIncident(dynamic data) {
    try {
      final incident = Incident.fromJson(data);
      // Avoid duplicates
      if (state.markers.any((m) => m.markerId.value == incident.id)) {
        return;
      }
      _addIncidentToMap(incident);
    } catch (e) {
      debugPrint("Error handling new incident: $e");
    }
  }

  void _handleUpdatedIncident(dynamic data) {
    try {
      final updatedIncident = Incident.fromJson(data);

      // To properly update, we should probably just re-add it
      _addIncidentToMap(updatedIncident);
    } catch (e) {
      debugPrint("Error handling updated incident: $e");
    }
  }

  Future<void> _addIncidentToMap(Incident incident) async {
    const markerIconSize = 142;
    String? iconType;
    final type = incident.type ?? incident.alertType ?? 'accident';

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
      position: incident.position,
      icon: icon,
      onTap: () {
        selectMarker(incident);
      },
    );

    state = state.copyWith(markers: {...state.markers, marker});
  }

  Future<void> setMyLocation(LatLng location) async {
    state = state.copyWith(
      myLocation: location,
      initialCamera: CameraPosition(target: location, zoom: 14),
    );
  }

  void toggleAlertPanel() {
    final willOpen = !state.showAlertPanel;
    state = state.copyWith(
      showAlertPanel: willOpen,
      showGetDirectionCard: willOpen ? false : state.showGetDirectionCard,
    );
  }

  void toggleGetDirectionCard() {
    final willOpen = !state.showGetDirectionCard;
    state = state.copyWith(
      showGetDirectionCard: willOpen,
      showAlertPanel: willOpen ? false : state.showAlertPanel,
    );
  }

  void addMarker(Marker marker) {
    state = state.copyWith(markers: {...state.markers, marker});
  }

  void toggleNewsLike(String id) {
    final updatedNews = state.newsList.map((item) {
      if (item.id == id) {
        final newIsLiked = !(item.isLiked ?? false);
        final newCount = (item.likesCount ?? 0) + (newIsLiked ? 1 : -1);

        socketService.likeNews(userId: _userId, contentId: id);

        return item.copyWith(
          isLiked: newIsLiked,
          likesCount: newCount < 0 ? 0 : newCount,
        );
      }
      return item;
    }).toList();

    state = state.copyWith(newsList: updatedNews);
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

    // 🔹 White Rounded Rectangle background
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble());
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(28));

    canvas.drawRRect(rrect, bgPaint);

    // 🔹 Clip image to rounded rectangle
    final clipPath = Path()..addRRect(rrect);
    canvas.clipPath(clipPath);

    // 🔹 Draw image
    // Maintain aspect ratio or center crop
    final srcSize = Size(img.width.toDouble(), img.height.toDouble());
    final dstSize = Size(size.toDouble(), size.toDouble());

    final srcRect = _centerCrop(srcSize, dstSize);

    canvas.drawImageRect(
      img,
      srcRect,
      rect,
      Paint(),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color.fromARGB(170, 158, 158, 158)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20,
    );

    // 🔹 Load and Draw Overlay Icon (Image Icon)
    try {
      final overlayData =
          await rootBundle.load('assets/markers/image-icon.png');
      final overlayBytes = overlayData.buffer.asUint8List();
      final overlayCodec =
          await ui.instantiateImageCodec(overlayBytes, targetWidth: 40);
      final overlayFrame = await overlayCodec.getNextFrame();
      final ui.Image overlayImg = overlayFrame.image;

      final overlaySize =
          Size(overlayImg.width.toDouble(), overlayImg.height.toDouble());
      final overlayOffset = Offset(
        (size - overlaySize.width) / 2,
        (size - overlaySize.height) / 2,
      );

      canvas.drawImage(overlayImg, overlayOffset, Paint());
    } catch (e) {
      debugPrint("Error loading overlay icon: $e");
    }

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

  Rect _centerCrop(Size src, Size dst) {
    // Calculate scaling factor to cover the destination
    double scale = math.max(dst.width / src.width, dst.height / src.height);

    double newWidth = src.width * scale;
    double newHeight = src.height * scale;

    // Calculate offset to center the crop
    double dx = (newWidth - dst.width) / 2;
    double dy = (newHeight - dst.height) / 2;

    // Convert destination rect back to source coordinates
    return Rect.fromLTWH(
        dx / scale, dy / scale, dst.width / scale, dst.height / scale);
  }

  void setDragging(bool isDragging) {
    state = state.copyWith(isDragging: isDragging);
    if (isDragging) {
      _allowMarkerSelectionTimer?.cancel();
      _allowMarkerSelectionTimer = null;
    } else {
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

    socketService.emitAlert(
      alertType: iconType,
      position: position,
      userId: _userId,
    );
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
      // Add marker to map
      await _createAndAddAlertMarker(
        state.previewAlertType!,
        state.previewAlertPosition!,
      );

      // Emit alert via socket
      socketService.emitAlert(
        alertType: state.previewAlertType!,
        position: state.previewAlertPosition!,
        userId: _userId,
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
    // addNearbyMarkers();
    fetchAggregatedNews();
  }

  double _parseDistance(String distanceStr) {
    if (distanceStr.contains('1 mile')) return 1609.34;
    if (distanceStr.contains('2 miles')) return 3218.68;
    if (distanceStr.contains('5 miles')) return 8046.72;
    if (distanceStr.contains('10 miles')) return 16093.4;
    if (distanceStr.contains('15 miles')) return 24140.1;
    if (distanceStr.contains('20 miles')) return 32186.8;
    if (distanceStr.contains('25 miles')) return 40233.5;
    if (distanceStr.contains('30 miles')) return 48280.2;
    if (distanceStr.contains('50 miles')) return 80467.0;
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

      // Load custom icons
      final startIcon = await markerService.bitmapFromIncidentAsset(
        "assets/markers/starting_markers.png",
        100,
      );

      final destinationIcon = await markerService.bitmapFromIncidentAsset(
        "assets/markers/destination-marker.png",
        100,
      );

      // Add start marker
      final startMarker = Marker(
        markerId: const MarkerId('start'),
        position: start,
        infoWindow: const InfoWindow(title: 'Start Location'),
        icon: startIcon,
      );

      // Add destination marker
      final destinationMarker = Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        infoWindow: InfoWindow(
          title: 'Destination',
          snippet: routeInfo.formattedInfo,
        ),
        icon: destinationIcon,
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
            ..removeWhere((m) =>
                m.markerId.value == 'destination' ||
                m.markerId.value == 'start'),
          startMarker,
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
        ..removeWhere((m) =>
            m.markerId.value == 'destination' || m.markerId.value == 'start'),
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

    if (state.routeInfo != null && state.routeInfo!.points.isNotEmpty) {
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
    socketService.dispose();
    super.dispose();
  }

  Future<void> fetchInitialIncidents() async {
    try {
      final String token = sharedPreferences!.getString(tokenKey).toString();

      final res = await http.get(
        Uri.parse("${baseUrl}hopper/getAlertIncidents"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print(":::fetchInitialIncidents ${res.body}");

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        print("::: Fetch Incidents SUCCESS ::: Count: ${data.length}");

        final List<Incident> incidents =
            data.map((j) => Incident.fromJson(j)).toList();

        final Set<Marker> newMarkers = {};
        const markerIconSize = 142;

        for (final incident in incidents) {
          String? iconType;
          final type = incident.type ?? incident.alertType ?? 'accident';

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

          newMarkers.add(
            Marker(
              markerId: MarkerId(incident.id),
              position: incident.position,
              icon: icon,
              onTap: () {
                selectMarker(incident);
              },
            ),
          );
        }

        state = state.copyWith(markers: {...state.markers, ...newMarkers});
      } else {
        print("::: Fetch Incidents FAILURE ::: Status: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching incidents: $e");
      print("::: Fetch Incidents FAILURE ::: Error: $e");
    }
  }
}

final mapControllerProvider = StateNotifierProvider<MapController, MapState>(
  (ref) => MapController(
    mapService: MapService(
      googleApiKey: 'AIzaSyAI46rVhROb5Dztv1aIDLvGH6QtGe3Addk',
    ),
    markerService: MarkerService(),
  ),
);
