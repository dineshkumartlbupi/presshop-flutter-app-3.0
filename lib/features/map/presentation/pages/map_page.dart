import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import 'package:presshop/core/di/injection_container.dart';

import 'package:presshop/features/map/constants/map_news_constants.dart';
import 'package:presshop/features/map/presentation/bloc/map_bloc.dart';
import 'package:presshop/features/map/presentation/bloc/map_event.dart';
import 'package:presshop/features/map/presentation/bloc/map_state.dart';
import 'package:presshop/features/map/presentation/widgets/alert_button_map.dart';
import 'package:presshop/features/map/presentation/widgets/alert_panel.dart';
import 'package:presshop/features/map/presentation/widgets/burst_animation.dart';
import 'package:presshop/features/map/presentation/widgets/content_marker_popup.dart';
import 'package:presshop/features/map/presentation/widgets/custom_info_window.dart';
import 'package:presshop/features/map/presentation/widgets/danger_zone_info_window.dart';
import 'package:presshop/features/map/presentation/widgets/serarch_filter_widget.dart';
import 'package:presshop/features/map/presentation/widgets/side_action_panal.dart';
import 'package:presshop/features/map/presentation/widgets/get_direction_card.dart';
import 'package:presshop/features/map/presentation/widgets/route_info_window.dart';
import 'package:presshop/features/news/presentation/pages/news_details_screen_legacy.dart';
import 'package:presshop/features/map/domain/repositories/map_repository.dart';

import 'package:presshop/core/widgets/new_home_app_bar.dart';

class MapPage extends StatefulWidget {
  final bool hideLeading;
  const MapPage({Key? key, this.hideLeading = false}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapBloc _mapBloc;

  @override
  void initState() {
    super.initState();
    _mapBloc = sl<MapBloc>()..add(GetCurrentLocationEvent());
  }

  @override
  void dispose() {
    _mapBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _mapBloc,
      child: _MapPageContent(hideLeading: widget.hideLeading),
    );
  }
}

class _MapPageContent extends StatefulWidget {
  final bool hideLeading;
  const _MapPageContent({Key? key, this.hideLeading = false}) : super(key: key);

  @override
  State<_MapPageContent> createState() => _MapPageContentState();
}

class _MapPageContentState extends State<_MapPageContent>
    with TickerProviderStateMixin {
  final Completer<GoogleMapController> _controller = Completer();
  double _currentZoom = 14.0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final String googleApiKey = 'AIzaSyClF12i0eHy7Nrig6EYu8Z4U5DA2zC09OI';
  Offset? infoWindowOffset;
  Offset? _infoOffset;
  Offset? _polygonInfoOffset;

  late AnimationController _burstController;
  late AnimationController _pulseController;
  List<BurstParticle> _particles = [];

  ui.Image? _burstImage;

  List<dynamic> _predictions = [];
  bool _showDropdown = false;

  bool _isSelectingAlertLocation = false;
  String? _pendingAlertType;
  Offset? _routeInfoOffset;

  void _checkPulseAnimation(double zoom) {
    if (zoom < 13.0) {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        // Clear circle
        context.read<MapBloc>().add(UpdatePulseCircleEvent(
              radiusMultiplier: 1.0,
              opacity: 0.0,
              zoomLevel: zoom,
            ));
      }
    } else {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..addListener(_updateParticles);

    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        setState(() {
          _showDropdown = false;
        });
      }
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        final val = Curves.easeOutQuad.transform(_pulseController.value);
        context.read<MapBloc>().add(UpdatePulseCircleEvent(
              radiusMultiplier: 1.0 + val * 0.5,
              opacity: 1.0 - val,
              zoomLevel: _currentZoom,
            ));
      });
    _pulseController.repeat();
  }

  @override
  void dispose() {
    _burstController.dispose();
    _pulseController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _goToCurrentLocation() async {
    try {
      final mapCtrl = await _controller.future;
      if (!mounted) return;
      final state = context.read<MapBloc>().state;
      if (state.myLocation != null) {
        _currentZoom = 17.0; // Zoom in when going to current location
        await mapCtrl.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: state.myLocation!, zoom: _currentZoom),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error going to current location: $e");
    }
  }

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
        "&key=$googleApiKey"
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
        "&key=$googleApiKey";

    final response = await http.get(Uri.parse(url));

    if (!mounted) return;

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final location = data['result']['geometry']['location'];
      final latLng = LatLng(location['lat'], location['lng']);

      // Trigger news search for this location
      context.read<MapBloc>().add(SetSearchedLocationEvent(latLng));

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
    try {
      _currentZoom += 1;
      final mapCtrl = await _controller.future;
      if (!mounted) return;
      await mapCtrl.animateCamera(CameraUpdate.zoomTo(_currentZoom));
    } catch (e) {
      debugPrint("Error zooming in: $e");
    }
  }

  Future<void> _zoomOut() async {
    try {
      _currentZoom -= 1;
      final mapCtrl = await _controller.future;
      if (!mounted) return;
      await mapCtrl.animateCamera(CameraUpdate.zoomTo(_currentZoom));
    } catch (e) {
      debugPrint("Error zooming out: $e");
    }
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
    final assetPath = burstIcons[type] ?? burstIcons['accident']!;

    _burstImage = await _loadImage(assetPath);

    for (int i = 0; i < 40; i++) {
      double randomX = Random().nextDouble() * size.width;
      double randomY = size.height +
          Random().nextDouble() * 300; // Staggered start below screen

      _particles.add(
        BurstParticle(
          position: Offset(randomX, randomY),
          scale: 0.4 + Random().nextDouble() * 0.8,
          opacity: 1.0,
          speed: 1.0 + Random().nextDouble() * 1.5, // Random speed 1.0 - 2.5
          // rotation: Random().nextDouble() * 2 * pi, // Removed rotation
        ),
      );
    }

    _burstController.forward(from: 0);
  }

  Future<void> _updateInfoWindow() async {
    if (!mounted) return;
    final state = context.read<MapBloc>().state;

    try {
      if (state.selectedPosition != null) {
        final controller = await _controller.future;
        if (!mounted) return;
        final screen = await controller.getScreenCoordinate(
          state.selectedPosition!,
        );

        if (mounted) {
          setState(() {
            _infoOffset = Offset(screen.x.toDouble(), screen.y.toDouble());
          });
        }
      }

      if (state.selectedPolygonPosition != null) {
        final controller = await _controller.future;
        if (!mounted) return;
        final screen = await controller.getScreenCoordinate(
          state.selectedPolygonPosition!,
        );

        if (mounted) {
          setState(() {
            _polygonInfoOffset =
                Offset(screen.x.toDouble(), screen.y.toDouble());
          });
        }
      }

      if (state.routeMidpoint != null) {
        final controller = await _controller.future;
        if (!mounted) return;
        final screen =
            await controller.getScreenCoordinate(state.routeMidpoint!);

        if (mounted) {
          setState(() {
            _routeInfoOffset = Offset(screen.x.toDouble(), screen.y.toDouble());
          });
        }
      }
    } catch (e) {
      debugPrint("Error updating info window: $e");
    }
  }

  Future<void> _fitBounds(List<LatLng> points) async {
    if (points.isEmpty) return;
    try {
      final controller = await _controller.future;
      if (!mounted) return;

      double minLat = points.first.latitude;
      double maxLat = points.first.latitude;
      double minLng = points.first.longitude;
      double maxLng = points.first.longitude;

      for (var point in points) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }

      await controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50,
      ));
    } catch (e) {
      debugPrint("Error fitting bounds: $e");
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
            'This app needs location access to function properly. Please enable it in settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return BlocConsumer<MapBloc, MapState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          if (state.errorMessage == "Location permissions are denied" ||
              state.errorMessage ==
                  "Location permissions are permanently denied") {
            _showLocationPermissionDialog();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        }
        if (state.myLocation != null && !_controller.isCompleted) {
          // Initial location set
        }

        // Listen for selection changes to update info window position
        if (state.selectedPosition != null) {
          _controller.future.then((ctrl) async {
            try {
              if (mounted) {
                // Calculate adjusted position to counter the bottom padding and popup space
                // Moving camera HIGHER (latitude) puts the marker LOWER on the screen.
                double zoom = _currentZoom;
                double lat = state.selectedPosition!.latitude;
                double cosLat = cos(lat * pi / 180);
                double metersPerPixel = 156543.03392 * cosLat / pow(2, zoom);
                double metersPerDegreeLat = 111319.49;

                // Shift camera focus UP by 220 pixels to move marker DOWN on screen
                double pixels = 220;
                double deltaLat = pixels * metersPerPixel / metersPerDegreeLat;
                LatLng adjusted =
                    LatLng(lat + deltaLat, state.selectedPosition!.longitude);

                await ctrl.animateCamera(CameraUpdate.newLatLng(adjusted));
                _updateInfoWindow();
              }
            } catch (e) {
              debugPrint("Error moving camera to selected position: $e");
            }
          });
        }

        // Handle Navigation Camera
        if (state.isNavigating && state.myLocation != null) {
          _controller.future.then((ctrl) async {
            try {
              if (mounted) {
                await ctrl.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: state.myLocation!,
                    zoom: 19,
                    tilt: 60,
                    bearing: 0,
                  ),
                ));
              }
            } catch (e) {
              debugPrint("Error moving camera for navigation: $e");
            }
          });
        }

        // Fit bounds for route if not navigating
        // Note: Logic to prevent continuous fitting while user drags map might be needed
        // For now, simpler implementation
        if (state.routeInfo != null &&
            !state.isNavigating &&
            state.routeInfo!.points.isNotEmpty) {
          _fitBounds(state.routeInfo!.points);
        }
      },
      listenWhen: (previous, current) {
        // Add custom logic if needed to filter updates
        return true;
      },
      builder: (context, state) {
        if (state.myLocation == null) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          appBar: NewHomeAppBar(
            size: size,
            hideLeading: widget.hideLeading,
          ),
          body: Stack(
            children: [
              GoogleMap(
                onMapCreated: (c) {
                  if (!_controller.isCompleted) {
                    _controller.complete(c);
                  }
                  _updateInfoWindow();
                },
                onCameraMoveStarted: () {
                  // mapController.setDragging(true); // Add event if needed
                },
                onCameraMove: (pos) {
                  _currentZoom = pos.zoom;
                  _checkPulseAnimation(pos.zoom);
                  _updateInfoWindow();
                },
                onCameraIdle: () {
                  if (mounted) {
                    // mapController.setDragging(false); // Add event if needed
                    _updateInfoWindow();
                  }
                },
                onTap: (pos) async {
                  if (_isSelectingAlertLocation && _pendingAlertType != null) {
                    context.read<MapBloc>().add(SetPreviewAlertMarkerEvent(
                        type: _pendingAlertType!, position: pos));
                    setState(() {
                      _isSelectingAlertLocation = false;
                      _pendingAlertType = null;
                    });
                    return;
                  }

                  if (state.showAlertPanel) {
                    context.read<MapBloc>().add(ToggleAlertPanelEvent());
                    return;
                  }

                  // Destination Selection Mode
                  if (state.isDestinationSelectionMode) {
                    final repo = sl<MapRepository>();
                    String address = "${pos.latitude}, ${pos.longitude}";

                    final result = await repo.getAddressFromCoordinates(pos);
                    result.fold(
                      (failure) => debugPrint(
                          "Failed to get address: ${failure.message}"),
                      (addr) => address = addr,
                    );

                    context.read<MapBloc>().add(SetMapSelectedLocationEvent(
                          position: pos,
                          address: address,
                          isOrigin: state.isSelectingOrigin,
                        ));

                    context
                        .read<MapBloc>()
                        .add(SetDestinationSelectionModeEvent(
                          isSelectionMode: false,
                        ));
                    return;
                  }

                  context.read<MapBloc>().add(ClearSelectedMarkerEvent());
                  context.read<MapBloc>().add(ClearSelectedPolygonEvent());
                  setState(() {
                    _infoOffset = null;
                    _polygonInfoOffset = null;
                  });
                },
                initialCameraPosition: state.initialCamera ??
                    CameraPosition(
                        target: state.myLocation!, zoom: _currentZoom),
                markers: state.markers,
                polylines: state.polylines,
                polygons: state.polygons,
                circles: state.circles,
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                zoomControlsEnabled: false,
                padding: const EdgeInsets.only(bottom: 220),
              ),
              if (_infoOffset != null && state.selectedIncident != null)
                Positioned(
                  left: _infoOffset!.dx -
                      ((state.selectedIncident!.markerType == 'content' ||
                              state.selectedIncident!.markerType == 'news')
                          ? 32
                          : 140),
                  top: _infoOffset!.dy -
                      ((state.selectedIncident!.markerType == 'content' ||
                              state.selectedIncident!.markerType == 'news')
                          ? 245 // Reduced from 260
                          : 180), // Reduced from 195
                  child: (state.selectedIncident!.markerType == 'content' ||
                          state.selectedIncident!.markerType == 'news')
                      ? ContentMarkerPopup(
                          key: ValueKey('info_${state.selectedIncident!.id}'),
                          incident: state.selectedIncident!,
                          onViewPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewsDetailsScreen(
                                  newsId: state.selectedIncident!.id,
                                ),
                              ),
                            );
                          },
                        )
                      : CustomInfoWindow(
                          key: ValueKey('info_${state.selectedIncident!.id}'),
                          incident: state.selectedIncident!,
                          onPressed: () {},
                        ),
                ),

              // ======================= Polygon Info =======================
              if (_polygonInfoOffset != null && state.selectedPolygonId != null)
                Positioned(
                  left: _polygonInfoOffset!.dx - 110,
                  top: _polygonInfoOffset!.dy - 140,
                  child: DangerZoneInfoWindow(
                    name: "Danger Zone",
                    description: "High risk area - proceed with caution",
                    onPressed: () {
                      context.read<MapBloc>().add(ClearSelectedPolygonEvent());
                      setState(() => _polygonInfoOffset = null);
                    },
                  ),
                ),

              // ======================= Route Info =======================
              if (_routeInfoOffset != null &&
                  state.routeInfo != null &&
                  state.routeMidpoint != null)
                Positioned(
                  left: _routeInfoOffset!.dx -
                      100, // Center horizontally (width 200/2)
                  top: _routeInfoOffset!.dy - 100, // Position above the route
                  child: RouteInfoWindow(
                    distance:
                        "${state.routeInfo!.distanceKm.toStringAsFixed(2)} km",
                    duration: "${state.routeInfo!.durationMinutes} min",
                    onClose: () {
                      context.read<MapBloc>().add(ClearRouteEvent());
                    },
                  ),
                ),

              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: SearchAndFilterBar(
                  searchController: _searchController,
                  searchFocusNode: _searchFocusNode,
                  onPressedOnNavigation: () {
                    context.read<MapBloc>().add(ToggleGetDirectionCardEvent());
                  },
                  onChange: (value) {
                    _searchPlaces(value);
                  },
                  selectedAlertType: state.selectedAlertType,
                  selectedDistance: state.selectedDistance,
                  selectedCategory: state.selectedCategory,
                  onAlertTypeChanged: (value) {
                    context.read<MapBloc>().add(UpdateFiltersEvent(
                          alertType: value,
                          distance: state.selectedDistance,
                          category: state.selectedCategory,
                        ));
                  },
                  onDistanceChanged: (value) {
                    context.read<MapBloc>().add(UpdateFiltersEvent(
                          alertType: state.selectedAlertType,
                          distance: value,
                          category: state.selectedCategory,
                        ));
                  },
                  onCategoryChanged: (value) {
                    context.read<MapBloc>().add(UpdateFiltersEvent(
                          alertType: state.selectedAlertType,
                          distance: state.selectedDistance,
                          category: value,
                        ));
                  },
                ),
              ),

              // Dropdown overlaps filters and starts right under the search bar
              if (_showDropdown && _predictions.isNotEmpty)
                Positioned(
                  left: 12,
                  right: 55,
                  top: 60, // Adjusted to start below search bar
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

              // ======================= Get Direction Card =======================
              Positioned(
                top: 65,
                right: 15, // Aligned to the right button
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: state.showGetDirectionCard ? 1 : 0,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutBack,
                    alignment: Alignment.topRight,
                    scale: state.showGetDirectionCard ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: !state.showGetDirectionCard,
                      child: const GetDirectionCard(),
                    ),
                  ),
                ),
              ),

              // ======================================> Alert Button
              Positioned(
                left: 16,
                bottom: 15,
                child: GestureDetector(
                  onTap: () {
                    context.read<MapBloc>().add(ToggleAlertPanelEvent());
                  },
                  child: const AlertButtonMap(),
                ),
              ),

              // ======================= Side Action Panel =======================
              Positioned(
                right: 20,
                bottom: 20,
                child: SideActionPanel(
                  onCurrentLocation: _goToCurrentLocation,
                  onZoomIn: _zoomIn,
                  onZoomOut: _zoomOut,
                ),
              ),

              // ======================= Alert Panel =======================
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
                        onClose: () {
                          context.read<MapBloc>().add(ToggleAlertPanelEvent());
                        },
                        onAlertSelected: (type) async {
                          try {
                            debugPrint("AlertSelected: $type");
                            if (state.myLocation != null) {
                              _addBurst(state.myLocation!, type);
                              context.read<MapBloc>().add(AddAlertMarkerEvent(
                                  type: type, position: state.myLocation!));
                            } else {
                              debugPrint(
                                  "AlertSelected: Location not available");
                            }
                          } catch (e) {
                            debugPrint("Error adding alert marker: $e");
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                child: CustomPaint(
                  painter: BurstPainter(_particles, _burstImage),
                  child: Container(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
