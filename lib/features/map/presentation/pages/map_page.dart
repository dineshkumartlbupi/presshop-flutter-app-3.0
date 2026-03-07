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
import 'package:go_router/go_router.dart';
import 'package:presshop/features/news/presentation/pages/news_page.dart';
import 'package:presshop/features/news/presentation/bloc/news_bloc.dart';

import 'package:presshop/features/map/constants/map_news_constants.dart';
import 'package:presshop/features/map/presentation/bloc/map_bloc.dart';
import 'package:presshop/features/map/presentation/bloc/map_event.dart';
import 'package:presshop/features/map/presentation/bloc/map_state.dart';
import 'package:presshop/features/map/presentation/widgets/alert_button_map.dart';
import 'package:presshop/features/map/presentation/widgets/alert_panel.dart';
import 'package:presshop/features/map/presentation/widgets/burst_animation.dart';
import 'package:presshop/features/map/presentation/widgets/content_marker_popup.dart';
import 'package:presshop/features/map/presentation/widgets/custom_info_window.dart';
import 'package:presshop/features/map/data/models/marker_model.dart';
import 'package:presshop/features/map/presentation/widgets/danger_zone_info_window.dart';
import 'package:presshop/features/map/presentation/widgets/serarch_filter_widget.dart';
import 'package:presshop/features/map/presentation/widgets/side_action_panal.dart';
import 'package:presshop/features/map/presentation/widgets/get_direction_card.dart';
import 'package:presshop/features/map/presentation/widgets/route_info_window.dart';
import 'package:custom_info_window/custom_info_window.dart' as ciw;
import 'package:presshop/features/map/domain/repositories/map_repository.dart';

import 'package:presshop/core/widgets/new_home_app_bar.dart';
import 'package:presshop/core/analytics/analytics_mixin.dart';
import 'package:presshop/core/analytics/analytics_constants.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key, this.hideLeading = false, this.showAppBar = false})
      : super(key: key);
  final bool hideLeading;
  final bool showAppBar;

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
      child: _MapPageContent(
          hideLeading: widget.hideLeading, showAppBar: widget.showAppBar),
    );
  }
}

class _MapPageContent extends StatefulWidget {
  const _MapPageContent(
      {Key? key, this.hideLeading = false, this.showAppBar = false})
      : super(key: key);
  final bool hideLeading;
  final bool showAppBar;

  @override
  State<_MapPageContent> createState() => _MapPageContentState();
}

class _MapPageContentState extends State<_MapPageContent>
    with TickerProviderStateMixin, AnalyticsPageMixin {
  final Completer<GoogleMapController> _controller = Completer();
  bool _locationTimeout = false;
  Timer? _locationTimer;
  double _currentZoom = 14.0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final String googleApiKey = 'AIzaSyClF12i0eHy7Nrig6EYu8Z4U5DA2zC09OI';
  Offset? infoWindowOffset;
  Offset? _infoOffset;
  Offset? _polygonInfoOffset;

  late AnimationController _burstController;
  late AnimationController _pulseController;
  final List<BurstParticle> _particles = [];

  ui.Image? _burstImage;

  List<dynamic> _predictions = [];
  bool _showDropdown = false;

  bool _isSelectingAlertLocation = false;
  String? _pendingAlertType;

  bool _isUserDragging = false;
  bool _isProgrammaticMovement = false;
  LatLng? _lastSelectedPosition;
  String? _lastDistanceFilter;

  final ciw.CustomInfoWindowController _customInfoWindowController =
      ciw.CustomInfoWindowController();

  final Map<String, ciw.CustomInfoWindowController> _markerControllers = {};
  final Set<String> _animatedMarkers = {};
  bool _isDisposed = false;

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

  void _animateToDistance(String distance) {
    double zoom = 12.0;
    if (distance.contains('2')) {
      zoom = 14.0;
    } else if (distance.contains('5')) {
      zoom = 12.5;
    } else if (distance.contains('10')) {
      zoom = 11.5;
    } else if (distance.contains('25')) {
      zoom = 10.0;
    } else if (distance.contains('50')) {
      zoom = 9.0;
    }

    _controller.future.then((ctrl) {
      if (mounted) {
        ctrl.animateCamera(CameraUpdate.zoomTo(zoom));
      }
    });
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
      duration: const Duration(seconds: 2),
    )..addListener(() {
        if (!mounted) return;
        final val = Curves.easeOutQuad.transform(_pulseController.value);
        context.read<MapBloc>().add(UpdatePulseCircleEvent(
              radiusMultiplier: 1.0 + val * 0.5,
              opacity: 1.0 - val,
              zoomLevel: _currentZoom,
            ));
      });
    _pulseController.repeat();

    // Start a timer to detect location acquisition timeout
    _locationTimeout = false;
    _locationTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && context.read<MapBloc>().state.myLocation == null) {
        setState(() {
          _locationTimeout = true;
        });
      }
    });

    _syncAnimatedMarkers(context.read<MapBloc>().state);
  }

  @override
  String get pageName => PageNames.map;

  @override
  void dispose() {
    _isDisposed = true;
    _burstController.stop();
    _pulseController.stop();
    _burstController.dispose();
    _pulseController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _customInfoWindowController.dispose();
    for (var controller in _markerControllers.values) {
      controller.dispose();
    }
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _goToCurrentLocation() async {
    try {
      final mapCtrl = await _controller.future;
      if (!mounted) return;
      final state = context.read<MapBloc>().state;
      if (state.myLocation != null) {
        _currentZoom = 17.0;
        _isProgrammaticMovement = true;
        await mapCtrl.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: state.myLocation!, zoom: _currentZoom),
          ),
        );
        _isProgrammaticMovement = false;
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

      context.read<MapBloc>().add(SetSearchedLocationEvent(latLng));

      _controller.future.then((ctrl) async {
        _isProgrammaticMovement = true;
        await ctrl.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
        _isProgrammaticMovement = false;
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
      _isProgrammaticMovement = true;
      await mapCtrl.animateCamera(CameraUpdate.zoomTo(_currentZoom));
      _isProgrammaticMovement = false;
    } catch (e) {
      debugPrint("Error zooming in: $e");
    }
  }

  Future<void> _zoomOut() async {
    try {
      _currentZoom -= 1;
      final mapCtrl = await _controller.future;
      if (!mounted) return;
      _isProgrammaticMovement = true;
      await mapCtrl.animateCamera(CameraUpdate.zoomTo(_currentZoom));
      _isProgrammaticMovement = false;
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
          speed: 1.0 + Random().nextDouble() * 1.5,
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

      _isProgrammaticMovement = true;
      await controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50,
      ));
      _isProgrammaticMovement = false;
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
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  LatLng _adjustPositionForInfoWindow(LatLng position, double zoom) {
    double lat = position.latitude;
    double cosLat = cos(lat * pi / 180);
    double metersPerPixel = 156543.03392 * cosLat / pow(2, zoom);
    double metersPerDegreeLat = 111319.49 * cosLat;
    double pixels = 150;
    double deltaLat = pixels * metersPerPixel / metersPerDegreeLat;
    return LatLng(lat + deltaLat, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double responsiveWidth = size.width > 600 ? 500 : size.width;

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

        if (state.selectedDistance != _lastDistanceFilter) {
          _lastDistanceFilter = state.selectedDistance;
          if (_lastDistanceFilter != null) {
            _animateToDistance(_lastDistanceFilter!);
          }
        }

        // Listen for selection changes to update info window position
        if (state.selectedPosition == null) {
          _lastSelectedPosition = null;
        } else if (state.selectedPosition != _lastSelectedPosition) {
          _lastSelectedPosition = state.selectedPosition;
          _controller.future.then((ctrl) async {
            try {
              if (mounted) {
                _isProgrammaticMovement = true;

                LatLng adjusted = _adjustPositionForInfoWindow(
                    state.selectedPosition!, _currentZoom);

                await ctrl.animateCamera(CameraUpdate.newLatLng(adjusted));
                _isProgrammaticMovement = false;
                _updateInfoWindow();
              }
            } catch (e) {
              debugPrint("Error moving camera to selected position: $e");
            }
          });
        }

        if (state.isNavigating && state.myLocation != null) {
          _controller.future.then((ctrl) async {
            try {
              if (mounted) {
                _isProgrammaticMovement = true;

                await ctrl.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: state.myLocation!,
                    zoom: 19,
                    tilt: 60,
                    bearing: 0,
                  ),
                ));
                _isProgrammaticMovement = false;
              }
            } catch (e) {
              debugPrint("Error moving camera for navigation: $e");
            }
          });
        }
        if (state.routeInfo != null &&
            !state.isNavigating &&
            state.routeInfo!.points.isNotEmpty) {
          _fitBounds(state.routeInfo!.points);
        }
        if (state.newlyCreatedIncident != null) {
          final incident = state.newlyCreatedIncident!;
          final type = incident.type ?? incident.alertType ?? "accident";
          _addBurst(incident.position, type);
        }
        _syncAnimatedMarkers(state);
        if (mounted && !_isDisposed) setState(() {});
      },
      listenWhen: (previous, current) {
        if (previous.selectedIncident?.id != current.selectedIncident?.id) {
          if (current.selectedIncident != null &&
              current.selectedPosition != null) {
            _customInfoWindowController.hideInfoWindow!();
            _customInfoWindowController.addInfoWindow!(
              current.selectedIncident!.markerType == 'content' ||
                      current.selectedIncident!.markerType == 'news' ||
                      (current.selectedIncident!.markerType == 'icon' &&
                          current.selectedIncident!.title != null &&
                          current.selectedIncident!.title!.isNotEmpty)
                  ? ContentMarkerPopup(
                      key: ValueKey('popup_${current.selectedIncident!.id}'),
                      incident: current.selectedIncident!,
                      onViewPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => sl<NewsBloc>(),
                              child: NewsPage(
                                hideFilters: true,
                                appBarTitle: 'All News',
                                prioritizedContentId:
                                    current.selectedIncident!.id,
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : CustomInfoWindow(
                      key: ValueKey('popup_${current.selectedIncident!.id}'),
                      incident: current.selectedIncident!,
                      onPressed: () {},
                    ),
              current.selectedPosition!,
            );
          } else {
            _customInfoWindowController.hideInfoWindow!();
          }
        }

        return true;
      },
      builder: (context, state) {
        if (state.myLocation == null) {
          if (_locationTimeout) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_off, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Unable to get your location.',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _locationTimeout = false;
                        });
                        context.read<MapBloc>().add(GetCurrentLocationEvent());
                        _locationTimer?.cancel();
                        _locationTimer = Timer(const Duration(seconds: 5), () {
                          if (mounted &&
                              context.read<MapBloc>().state.myLocation ==
                                  null) {
                            setState(() {
                              _locationTimeout = true;
                            });
                          }
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
        }

        return Scaffold(
          appBar: NewHomeAppBar(
            size: size,
            hideLeading: widget.hideLeading,
            showFilter: false,
          ),
          body: Stack(
            children: [
              GoogleMap(
                onMapCreated: (c) async {
                  if (!_controller.isCompleted) {
                    _controller.complete(c);
                    _customInfoWindowController.googleMapController = c;
                  }

                  if (mounted) {
                    unawaited(_updateInfoWindow());
                  }
                },
                onCameraMoveStarted: () {
                  if (!_isProgrammaticMovement) {
                    _isUserDragging = true;
                  }
                  _customInfoWindowController.onCameraMove?.call();
                  for (var controller in _markerControllers.values) {
                    controller.onCameraMove?.call();
                  }
                },
                onCameraMove: (pos) {
                  _currentZoom = pos.zoom;
                  _checkPulseAnimation(pos.zoom);
                  _customInfoWindowController.onCameraMove?.call();
                  for (var controller in _markerControllers.values) {
                    controller.onCameraMove?.call();
                  }
                  _updateInfoWindow();

                  if (_isUserDragging) {
                    // _customInfoWindowController.hideInfoWindow!();
                    context.read<MapBloc>().add(const SetDraggingEvent(true));
                  }
                },
                onCameraIdle: () {
                  if (mounted) {
                    _updateInfoWindow();
                    _isProgrammaticMovement = false;
                    if (_isUserDragging) {
                      context
                          .read<MapBloc>()
                          .add(const SetDraggingEvent(false));
                      _isUserDragging = false;
                    }
                  }
                },
                onTap: (pos) async {
                  _customInfoWindowController.hideInfoWindow!();
                  context.read<MapBloc>().add(ClearRouteEvent());

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

                  if (state.showGetDirectionCard) {
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
                          isOrigin: false,
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
                    const CameraPosition(
                      target: LatLng(51.5074, -0.1278),
                      zoom: 14,
                    ),
                markers: state.markers,
                polylines: state.polylines,
                polygons: state.polygons,
                circles: state.circles,
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                zoomControlsEnabled: false,
                padding: const EdgeInsets.only(bottom: 220),
              ),

              // Interactive marker overlays
              ..._markerControllers.values.map((controller) {
                return ciw.CustomInfoWindow(
                  controller: controller,
                  height: responsiveWidth * 0.12,
                  width: responsiveWidth * 0.12,
                  offset: 4,
                );
              }),

              // CustomInfoWindow overlay for popups
              ciw.CustomInfoWindow(
                controller: _customInfoWindowController,
                height: responsiveWidth * 0.85,
                width: responsiveWidth * 0.75,
                offset: responsiveWidth * 0.14,
              ),

              // Dedicated CustomInfoWindow for Route Details (Smaller)
              // ======================= Route Info (Positioned) =======================
              if (_routeInfoOffset != null &&
                  state.routeInfo != null &&
                  state.routeMidpoint != null)
                Positioned(
                  left: _routeInfoOffset!.dx -
                      100, // Center horizontally (width 200/2)
                  top: _routeInfoOffset!.dy - 130, // Place above marker
                  child: RouteInfoWindow(
                    distance:
                        "${state.routeInfo!.distanceKm.toStringAsFixed(2)} km",
                    duration: "${state.routeInfo!.durationMinutes} min",
                    onClose: () {
                      context.read<MapBloc>().add(ClearRouteEvent());
                    },
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
              if (_showDropdown && _predictions.isNotEmpty)
                Positioned(
                  left: 12,
                  right: 55,
                  top: 60,
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
                right: 10, // Aligned to the right button
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: state.showGetDirectionCard ? 1 : 0,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 450),
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

  void _syncAnimatedMarkers(MapState state) {
    if (_isDisposed) return;

    final currentAnimatedMarkers = state.markers
        .where((m) =>
            m.markerId.value.startsWith('alert_') ||
            m.markerId.value.startsWith('news_') ||
            m.markerId.value.startsWith('weather_'))
        .toList();

    // Remove inactive controllers
    final currentIds =
        currentAnimatedMarkers.map((m) => m.markerId.value).toSet();
    _markerControllers.removeWhere((id, controller) {
      if (!currentIds.contains(id)) {
        controller.dispose();
        _animatedMarkers.remove(id);
        return true;
      }
      return false;
    });

    for (var marker in currentAnimatedMarkers) {
      if (!mounted || _isDisposed) break;
      final markerId = marker.markerId.value;

      if (!_markerControllers.containsKey(markerId)) {
        final controller = ciw.CustomInfoWindowController();
        _controller.future.then((ctrl) {
          if (!mounted || _isDisposed) return;
          controller.googleMapController = ctrl;
        });
        _markerControllers[markerId] = controller;
      }

      if (!_animatedMarkers.contains(markerId)) {
        _addInfoWindowForMarker(marker, state);
      }
    }
  }

  void _addInfoWindowForMarker(Marker marker, MapState state) {
    final markerId = marker.markerId.value;
    final controller = _markerControllers[markerId];
    if (controller == null) return;

    final String incidentId = markerId
        .replaceFirst('alert_', '')
        .replaceFirst('news_', '')
        .replaceFirst('weather_', '');

    if (state.newsList.isEmpty) return;

    final incident = (state.newsList).firstWhere(
      (i) => i.id == incidentId,
      orElse: () => state.newsList.first,
    );

    if (incident.id == incidentId) {
      // Small delay to ensure controller is ready
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted || _isDisposed) return;
        _addInfoWindowToController(
            controller, incident, marker.position, markerId);
        if (mounted && !_isDisposed) setState(() {});
      });
    }
  }

  void _addInfoWindowToController(
    ciw.CustomInfoWindowController controller,
    Incident incident,
    LatLng position,
    String markerId,
  ) {
    if (controller.addInfoWindow == null ||
        _animatedMarkers.contains(markerId)) {
      return;
    }

    final type = (incident.type ?? incident.alertType ?? "").toLowerCase();
    String? assetPath = markerIcons[type] ?? markerIcons['accident'];

    try {
      controller.addInfoWindow!(
        GestureDetector(
          onTap: () {
            context.read<MapBloc>().add(SetSelectedIncidentEvent(incident));
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(0),
              decoration: const BoxDecoration(
                color: Color(0xFFD9D9D9),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: assetPath != null
                    ? Image.asset(
                        assetPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.error),
                      )
                    : const Icon(Icons.location_on),
              ),
            ),
          ),
        ),
        position,
      );

      _animatedMarkers.add(markerId);
      if (controller.onCameraMove != null) {
        controller.onCameraMove!();
      }
    } catch (e) {
      debugPrint("Error adding info window for $markerId: $e");
    }
  }
}
