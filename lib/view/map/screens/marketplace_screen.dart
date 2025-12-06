import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/view/map/controller/map_controller.dart';
import 'package:presshop/view/map/models/map_state.dart';
import 'package:presshop/view/map/widgets/custom_app_bar.dart';
import 'package:presshop/view/map/widgets/custom_info_window.dart';
import 'package:presshop/view/map/widgets/danger_zone_info_window.dart';
import 'package:presshop/view/map/widgets/serarch_filter_widget.dart';
import 'package:presshop/view/map/widgets/side_action_panal.dart';
import '../services/map_service.dart';
import '../services/marker_service.dart';
import '../widgets/alert_button_map.dart';
import '../widgets/alert_panel.dart';
import '../widgets/get_direction_card.dart';
import 'package:http/http.dart' as http;
import '../widgets/content_marker_popup.dart';
import 'news_details_screen.dart';
import '../widgets/burst_animation.dart';

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

final mapControllerProvider = StateNotifierProvider<MapController, MapState>(
  (ref) => MapController(
    mapService: MapService(
      googleApiKey: 'AIzaSyAI46rVhROb5Dztv1aIDLvGH6QtGe3Addk',
    ),
    markerService: MarkerService(),
  ),
);

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> _controller = Completer();
  double _currentZoom = 14.0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  // final String googleApiKey = 'AIzaSyAI46rVhROb5Dztv1aIDLvGH6QtGe3Addk';
  final String googleApiKey = 'AIzaSyClF12i0eHy7Nrig6EYu8Z4U5DA2zC09OI';
  Offset? infoWindowOffset;
  Offset? _infoOffset;
  Offset? _polygonInfoOffset;

  late AnimationController _burstController;
  List<BurstParticle> _particles = [];

  ui.Image? _burstImage;

  @override
  void initState() {
    super.initState();
    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..addListener(_updateParticles);

    _initMap();

    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        setState(() {
          _showDropdown = false;
        });
      }
    });
  }

  Future<void> _initMap() async {
    final mapController = ref.read(mapControllerProvider.notifier);
    final myLocation = await mapController.mapService.getCurrentLocation();
    if (myLocation != null) {
      await mapController.setMyLocation(myLocation);
    }
    // await mapController.addNearbyMarkers();
    // mapController.addDemoPolygon();
    // final start = LatLng(37.785834, -122.406417);
    // final end = LatLng(37.7843755, -122.429);
    // await mapController.addDemoRoute(start, end);
  }

  Future<void> _goToCurrentLocation() async {
    final mapCtrl = await _controller.future;
    final state = ref.read(mapControllerProvider);
    if (state.myLocation != null) {
      mapCtrl.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: state.myLocation!, zoom: _currentZoom),
        ),
      );
    }
  }

  List<dynamic> _predictions = [];
  bool _showDropdown = false;

  String selectedAlert = 'Alert';
  String selectedDistance = '2 miles';
  String selectedCategory = 'Category';

  Future<void> _searchPlaces(String input) async {
    if (input.isEmpty) {
      setState(() {
        _predictions = [];
        _showDropdown = false;
      });
      return;
    }

    final url = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        "?input=$input"
        "&key=${googleApiKey}"
        "&types=geocode";

    final response = await http.get(Uri.parse(url));

    if (!mounted) return;

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final preds = data['predictions'] as List<dynamic>? ?? [];

      setState(() {
        _predictions = preds;
        _showDropdown = preds.isNotEmpty;
      });
    } else {
      setState(() {
        _predictions = [];
        _showDropdown = false;
      });
    }
  }

  Future<void> _selectPlace(String placeId, String description) async {
    final url = "https://maps.googleapis.com/maps/api/place/details/json"
        "?place_id=$placeId"
        "&key=${googleApiKey}";

    final response = await http.get(Uri.parse(url));

    if (!mounted) return;

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final location = data['result']['geometry']['location'];
      final latLng = LatLng(location['lat'], location['lng']);

      final marker = Marker(
        markerId: MarkerId(description),
        position: latLng,
        infoWindow: InfoWindow(title: description),
      );

      ref.read(mapControllerProvider.notifier).addMarker(marker);
      _controller.future.then((ctrl) {
        ctrl.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
      });

      setState(() {
        _showDropdown = false;
        _predictions = [];
        _searchController.text = description;
      });
      _searchFocusNode.unfocus();
    }
  }

  Future<void> _zoomIn() async {
    _currentZoom += 1;
    final mapCtrl = await _controller.future;
    mapCtrl.animateCamera(CameraUpdate.zoomTo(_currentZoom));
  }

  Future<void> _zoomOut() async {
    _currentZoom -= 1;
    final mapCtrl = await _controller.future;
    mapCtrl.animateCamera(CameraUpdate.zoomTo(_currentZoom));
  }

  @override
  void dispose() {
    _burstController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _updateParticles() {
    final t = _burstController.value;
    final size = MediaQuery.of(context).size;

    for (var p in _particles) {
      p.scale = 0.6 + t * 0.5;
      p.opacity = (1 - t).clamp(0.0, 1.0);

      // Move upward with individual speed
      p.position = p.position.translate(
        (p.position.dx - size.width / 2) * 0.02 * t, // Spread outwards
        -size.height * 0.01 * p.speed, // Move up based on speed
      );
    }

    if (t == 1) _particles.clear();
    setState(() {});
  }

  Future<ui.Image?> _loadImage(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      final list = Uint8List.view(data.buffer);
      final completer = Completer<ui.Image>();
      ui.decodeImageFromList(list, (img) {
        completer.complete(img);
      });
      return completer.future;
    } catch (e) {
      debugPrint("Error loading burst image: $e");
      return null;
    }
  }

  Future<void> _addBurst(LatLng position, String type) async {
    final size = MediaQuery.of(context).size;
    // _burstType = type;
    _particles.clear();

    // Load image
    final mapController = ref.read(mapControllerProvider.notifier);
    final assetPath = mapController.markerService.markerIcons[type] ??
        mapController.markerService.markerIcons['accident']!;

    _burstImage = await _loadImage(assetPath);

    for (int i = 0; i < 40; i++) {
      double randomX = Random().nextDouble() * size.width;
      double randomY = size.height +
          Random().nextDouble() * 300; // Staggered start below screen

      _particles.add(
        BurstParticle(
          position: Offset(randomX, randomY),
          scale: 0.5 + Random().nextDouble() * 0.5,
          opacity: 1.0,
          speed: 1.0 + Random().nextDouble() * 1.5, // Random speed 1.0 - 2.5
          // rotation: Random().nextDouble() * 2 * pi, // Removed rotation
        ),
      );
    }

    _burstController.forward(from: 0);
  }

  bool _isSelectingAlertLocation = false;
  String? _pendingAlertType;
  Offset? _routeInfoOffset;

  Future<void> _updateInfoWindow() async {
    final state = ref.read(mapControllerProvider);
    if (state.selectedPosition != null) {
      final controller = await _controller.future;
      final screen = await controller.getScreenCoordinate(
        state.selectedPosition!,
      );

      setState(() {
        _infoOffset = Offset(screen.x.toDouble(), screen.y.toDouble());
      });
    }

    if (state.selectedPolygonPosition != null) {
      final controller = await _controller.future;
      final screen = await controller.getScreenCoordinate(
        state.selectedPolygonPosition!,
      );

      setState(() {
        _polygonInfoOffset = Offset(screen.x.toDouble(), screen.y.toDouble());
      });
    }

    if (state.routeMidpoint != null) {
      final controller = await _controller.future;
      final screen = await controller.getScreenCoordinate(state.routeMidpoint!);

      setState(() {
        _routeInfoOffset = Offset(screen.x.toDouble(), screen.y.toDouble());
      });
    } else {
      if (_routeInfoOffset != null) {
        setState(() {
          _routeInfoOffset = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapControllerProvider);
    final mapController = ref.read(mapControllerProvider.notifier);

    // Listen for selection changes to update info window position
    ref.listen(mapControllerProvider, (previous, next) {
      if (previous?.selectedPosition != next.selectedPosition ||
          previous?.selectedPolygonPosition != next.selectedPolygonPosition) {
        // Update info window when selection changes
        _updateInfoWindow();
      }
    });

    if (state.myLocation == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: const CustomMapAppBar(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: 4,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        unselectedItemColor: Colors.black,
        selectedItemColor: colorThemePink,
        elevation: 0,
        iconSize: size.width * numD05,
        selectedFontSize: size.width * numD03,
        unselectedFontSize: size.width * numD03,
        type: BottomNavigationBarType.fixed,
        // onTap: _onTabChange,
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage("${iconsPath}ic_content.png")),
            label: contentText,
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage("${iconsPath}ic_task.png")),
            label: taskText,
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage("${iconsPath}ic_camera.png")),
            label: cameraText,
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage("${iconsPath}ic_chat.png")),
            label: chatText,
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage("${iconsPath}ic_menu.png")),
            label: menuText,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            // onMapCreated: (GoogleMapController controller) {
            //   if (!_controller.isCompleted) _controller.complete(controller);
            // },
            onMapCreated: (c) {
              if (!_controller.isCompleted) {
                _controller.complete(c);
              }
              _updateInfoWindow();
            },

            //////
            onCameraMoveStarted: () {
              mapController.setDragging(true);
              // Don't close info window when dragging starts
              // setState(() => _infoOffset = null);
            },
            onCameraMove: (_) => _updateInfoWindow(),
            onCameraIdle: () {
              if (mounted) {
                mapController.setDragging(false);
                _updateInfoWindow();
              }
            },
            onTap: (pos) async {
              // Handle alert location selection
              if (_isSelectingAlertLocation && _pendingAlertType != null) {
                await mapController.setPreviewAlertMarker(
                  _pendingAlertType!,
                  pos,
                );
                setState(() {
                  _isSelectingAlertLocation = false;
                  _pendingAlertType = null;
                });
                return;
              }

              // Close alert panel if open when clicking on map
              if (state.showAlertPanel) {
                mapController.toggleAlertPanel();
                return;
              }

              // Handle origin/destination selection for navigation
              if (state.isDestinationSelectionMode) {
                final mapController = ref.read(mapControllerProvider.notifier);
                final isOrigin = state.isSelectingOrigin;

                // Get address from coordinates
                final address = await mapController.getAddressFromCoordinates(
                  pos,
                );

                // Update the appropriate field in get_direction_card
                // We'll use a callback approach - store the selection in state
                mapController.setMapSelectedLocation(
                  position: pos,
                  address: address,
                  isOrigin: isOrigin,
                );

                mapController.setDestinationSelectionMode(false);

                // If destination is selected, get route
                if (!isOrigin) {
                  await mapController.addRoute(null, pos);
                }
                return;
              }

              if (state.showGetDirectionCard) {
                await mapController.addRoute(null, pos);
                return;
              }

              // Close info window when tapping on map
              mapController.clearSelectedMarker();
              mapController.clearSelectedPolygon();
              setState(() {
                _infoOffset = null;
                _polygonInfoOffset = null;
              });
            },
            initialCameraPosition: state.initialCamera ??
                CameraPosition(target: state.myLocation!, zoom: _currentZoom),
            markers: state.markers,
            polylines: state.polylines,
            polygons: state.polygons,
            circles: state.circles,
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            // onTap: (pos) async {
            //   // Set destination on map tap
            // final mapController = ref.read(mapControllerProvider.notifier);
            // await mapController.addRoute(null, pos);
            // },
            padding: const EdgeInsets.only(bottom: 220),
          ),
          if (_infoOffset != null && state.selectedIncident != null)
            Positioned(
              left: _infoOffset!.dx -
                  (state.selectedIncident!.markerType == 'content' ? 90 : 140),
              top: _infoOffset!.dy -
                  (state.selectedIncident!.markerType == 'content' ? 230 : 195),
              child: state.selectedIncident!.markerType == 'content'
                  ? ContentMarkerPopup(
                      incident: state.selectedIncident!,
                      onViewPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewsDetailsScreen(
                              incident: state.selectedIncident!,
                            ),
                          ),
                        );
                      },
                    )
                  : CustomInfoWindow(
                      incident: state.selectedIncident!,
                      onPressed: () {},
                    ),
            ),
          if (_polygonInfoOffset != null && state.selectedPolygonId != null)
            Positioned(
              left: _polygonInfoOffset!.dx - 110,
              top: _polygonInfoOffset!.dy - 140,
              child: DangerZoneInfoWindow(
                name: "Danger Zone",
                description: "High risk area - proceed with caution",
                onPressed: () {
                  mapController.clearSelectedPolygon();
                  setState(() => _polygonInfoOffset = null);
                },
              ),
            ),

          if (_routeInfoOffset != null && state.routeInfo != null)
            Positioned(
              left: _routeInfoOffset!.dx - 75, // Center width 150/2
              top: _routeInfoOffset!.dy -
                  60 -
                  12, // Above line (container + triangle)
              child: Column(
                children: [
                  Container(
                    width: 150,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.routeInfo!.formattedDistance,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 1,
                          height: 12,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          state.routeInfo!.formattedDuration,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(mapControllerProvider.notifier)
                                .clearRoute();
                          },
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomPaint(
                    size: const Size(20, 12),
                    painter: _TrianglePainter(),
                  ),
                ],
              ),
            ),

          // Search + Filter Bar
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 390,
              child: Stack(
                children: [
                  // Replace the SearchAndFilterBar's input field with a TextField and connect controller/focus below!
                  SearchAndFilterBar(
                    searchController: _searchController,
                    searchFocusNode: _searchFocusNode,
                    onPressedOnNavigation: mapController.toggleGetDirectionCard,
                    onChange: (value) {
                      _searchPlaces(value);
                    },
                    selectedAlertType: state.selectedAlertType,
                    selectedDistance: state.selectedDistance,
                    selectedCategory: state.selectedCategory,
                    onAlertTypeChanged: (value) {
                      mapController.updateFilters(
                        alertType: value,
                        distance: state.selectedDistance,
                        category: state.selectedCategory,
                      );
                    },
                    onDistanceChanged: (value) {
                      mapController.updateFilters(
                        alertType: state.selectedAlertType,
                        distance: value,
                        category: state.selectedCategory,
                      );
                    },
                    onCategoryChanged: (value) {
                      mapController.updateFilters(
                        alertType: state.selectedAlertType,
                        distance: state.selectedDistance,
                        category: value,
                      );
                    },
                  ),
                  // Dropdown overlaps filters and starts right under the search bar
                  if (_showDropdown && _predictions.isNotEmpty)
                    Positioned(
                      left: 12,
                      right: 55,
                      top: 50,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: _predictions.length,
                            itemBuilder: (context, index) {
                              final prediction = _predictions[index];
                              return InkWell(
                                onTap: () {
                                  _selectPlace(
                                    prediction['place_id'],
                                    prediction['description'],
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Text(prediction['description']),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ======================================> Alert Button
          Positioned(
            left: 16,
            bottom: 15,
            child: GestureDetector(
              onTap: mapController.toggleAlertPanel,
              child: const AlertButtonMap(),
            ),
          ),

          // Side Action Panel
          Positioned(
            right: 20,
            bottom: 20,
            child: SideActionPanel(
              onCurrentLocation: _goToCurrentLocation,
              onZoomIn: _zoomIn,
              onZoomOut: _zoomOut,
            ),
          ),

          // Alert Panel
          Positioned(
            bottom: 56,
            left: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: state.showAlertPanel ? 1 : 0,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutBack,
                alignment: Alignment.bottomLeft,
                scale: state.showAlertPanel ? 1 : 0.0,
                child: IgnorePointer(
                  ignoring: !state.showAlertPanel,
                  child: AlertPanel(
                    onClose: mapController.toggleAlertPanel,
                    onAlertSelected: (alertType) async {
                      if (state.myLocation != null) {
                        await mapController.addAlertMarker(
                          alertType,
                          state.myLocation!,
                        );

                        _addBurst(state.myLocation!, alertType);

                        mapController.socketService.emitAlert(
                          alertType: alertType,
                          position: state.myLocation!,
                          userId: "67ed646cd9889612efdd464c",
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 65,
            right: 10,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: state.showGetDirectionCard ? 1 : 0,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutBack,
                alignment: Alignment.topRight,
                scale: state.showGetDirectionCard ? 1 : 0.0,
                child: IgnorePointer(
                  ignoring: !state.showGetDirectionCard,
                  child: const GetDirectionCard(),
                ),
              ),
            ),
          ),

          // Selection Mode Status Banner
          if (_isSelectingAlertLocation || state.isDestinationSelectionMode)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isSelectingAlertLocation
                            ? 'Tap on map to place ${_pendingAlertType ?? "alert"}'
                            : 'Tap on map to select location',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () {
                        if (_isSelectingAlertLocation) {
                          setState(() {
                            _isSelectingAlertLocation = false;
                            _pendingAlertType = null;
                          });
                        } else {
                          mapController.setDestinationSelectionMode(false);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

          // Burst Animation Layer
          IgnorePointer(
            child: CustomPaint(
              painter: BurstPainter(_particles, _burstImage),
              size: MediaQuery.of(context).size,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
