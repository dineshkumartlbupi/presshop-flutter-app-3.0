import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/view/mapView/controller/map_controller.dart';
import 'package:presshop/view/mapView/models/map_state.dart';
import 'package:presshop/view/mapView/widgets/custom_app_bar.dart';
import 'package:presshop/view/mapView/widgets/custom_info_window.dart';
import 'package:presshop/view/mapView/widgets/danger_zone_info_window.dart';
import 'package:presshop/view/mapView/widgets/serarch_filter_widget.dart';
import 'package:presshop/view/mapView/widgets/side_action_panal.dart';

import '../services/map_service.dart';
import '../services/marker_service.dart';
import '../widgets/alert_button_map.dart';
import '../widgets/alert_panel.dart';
import '../widgets/get_direction_card.dart';
import 'package:http/http.dart' as http;
import '../widgets/content_marker_popup.dart';
import 'news_details_screen.dart';

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

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  double _currentZoom = 14.0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final String googleApiKey = 'AIzaSyAI46rVhROb5Dztv1aIDLvGH6QtGe3Addk';
  Offset? infoWindowOffset;
  Offset? _infoOffset;
  Offset? _polygonInfoOffset;

  @override
  void initState() {
    super.initState();
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
    await mapController.addNearbyMarkers();
    mapController.addDemoPolygon();
    final start = LatLng(37.785834, -122.406417);
    final end = LatLng(37.7843755, -122.429);
    await mapController.addDemoRoute(start, end);
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
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _showLocationSelectionDialog(
    BuildContext context,
    String alertType,
  ) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.my_location),
              title: const Text('Use Current Location'),
              onTap: () => Navigator.pop(context, 'current'),
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Select on Map'),
              onTap: () => Navigator.pop(context, 'map'),
            ),
          ],
        ),
      ),
    );

    if (result == 'current') {
      final mapController = ref.read(mapControllerProvider.notifier);
      final state = ref.read(mapControllerProvider);
      if (state.myLocation != null) {
        await mapController.addAlertMarker(alertType, state.myLocation!);
      }
    } else if (result == 'map') {
      setState(() {
        _isSelectingAlertLocation = true;
        _pendingAlertType = alertType;
      });
    }

    // Close alert panel if open
    final state = ref.read(mapControllerProvider);
    if (state.showAlertPanel) {
      ref.read(mapControllerProvider.notifier).toggleAlertPanel();
    }
  }

  bool _isSelectingAlertLocation = false;
  String? _pendingAlertType;

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
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapControllerProvider);
    final mapController = ref.read(mapControllerProvider.notifier);

    ref.listen(mapControllerProvider, (previous, next) {
      if (previous?.selectedPosition != next.selectedPosition ||
          previous?.selectedPolygonPosition != next.selectedPolygonPosition) {
        _updateInfoWindow();
      }
    });

    if (state.myLocation == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: CustomMapAppBar(),
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
        // onTap: _onBottomBarItemTapped,
        items: const [
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("${iconsPath}ic_content.png"),
              ),
              label: contentText),
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("${iconsPath}ic_task.png"),
              ),
              label: taskText),
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage(
                  "${iconsPath}ic_camera.png",
                ),
              ),
              label: cameraText),
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("${iconsPath}ic_chat.png"),
              ),
              label: chatText),
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage("${iconsPath}map2.png"),
              ),
              label: "Map"),
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
                scale: state.showAlertPanel ? 1 : 0.6,
                child: AlertPanel(
                  onClose: mapController.toggleAlertPanel,
                  onAlertSelected: (alertType) async {
                    await _showLocationSelectionDialog(context, alertType);
                  },
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
                scale: state.showGetDirectionCard ? 1 : 0.6,
                child: const GetDirectionCard(),
              ),
            ),
          ),

          // Route Info Card
          if (state.routeInfo != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.route,
                                size: 20,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Route',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.straighten,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                state.routeInfo!.formattedDistance,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                state.routeInfo!.formattedDuration,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        ref.read(mapControllerProvider.notifier).clearRoute();
                      },
                      color: Colors.grey[600],
                    ),
                  ],
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

          // Preview Alert Confirmation UI
          if (state.previewAlertMarkerId != null)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Long press and drag marker to adjust position',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          mapController.cancelPreviewAlert();
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Cancel'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          mapController.finalizeAlertMarker();
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Send Alert'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
