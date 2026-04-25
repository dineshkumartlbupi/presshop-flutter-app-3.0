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
import 'package:presshop/core/widgets/common_widgets.dart' as CommonWidgetsNew;
import 'package:visibility_detector/visibility_detector.dart';
import 'package:presshop/features/news/presentation/pages/news_page.dart';
import 'package:presshop/features/news/presentation/bloc/news_bloc.dart';

import 'package:presshop/features/map/constants/map_news_constants.dart';
import 'package:presshop/features/map/data/models/marker_model.dart';
import 'package:presshop/features/map/presentation/bloc/map_bloc.dart';
import 'package:presshop/features/map/presentation/bloc/map_event.dart';
import 'package:presshop/features/map/presentation/bloc/map_state.dart';
import 'package:presshop/features/map/presentation/widgets/alert_button_map.dart';
import 'package:presshop/features/map/presentation/widgets/alert_panel.dart';
import 'package:presshop/features/map/presentation/widgets/content_marker_popup.dart';
import 'package:presshop/features/map/presentation/widgets/custom_info_window.dart';
import 'package:presshop/features/map/presentation/widgets/danger_zone_info_window.dart';
import 'package:presshop/features/map/presentation/widgets/serarch_filter_widget.dart';
import 'package:presshop/features/map/presentation/widgets/side_action_panal.dart';
import 'package:presshop/features/map/presentation/widgets/get_direction_card.dart';
import 'package:presshop/features/map/presentation/widgets/route_info_window.dart';
import 'package:custom_info_window/custom_info_window.dart' as ciw;
import 'package:presshop/features/map/domain/repositories/map_repository.dart';
import 'package:presshop/features/map/presentation/widgets/map_view_widget.dart';
import 'package:presshop/features/map/presentation/widgets/burst_particles_overlay.dart';

import 'package:presshop/main.dart';
import 'package:presshop/core/widgets/dialogs.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/new_home_app_bar.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, this.hideLeading = false, this.showAppBar = false});
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
    _mapBloc = sl<MapBloc>();
    // Only fetch if we don't have a location yet (i.e., first-time initialization)
    if (_mapBloc.state.myLocation == null) {
      _mapBloc.add(const GetCurrentLocationEvent());
    }
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
  const _MapPageContent({this.hideLeading = false, this.showAppBar = false});
  final bool hideLeading;
  final bool showAppBar;

  @override
  State<_MapPageContent> createState() => _MapPageContentState();
}

class _MapPageContentState extends State<_MapPageContent>
    with
        TickerProviderStateMixin,
        AnalyticsPageMixin,
        AutomaticKeepAliveClientMixin {
  final Completer<GoogleMapController> _controller = Completer();
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

  bool _isUserDragging = false;
  bool _isProgrammaticMovement = false;
  LatLng? _lastSelectedPosition;
  String? _lastDistanceFilter;

  final ciw.CustomInfoWindowController _customInfoWindowController =
      ciw.CustomInfoWindowController();

  final Map<String, Offset> _markerPositions = {};
  final Map<String, ciw.CustomInfoWindowController> _markerControllers = {};
  final Set<String> _initializedMarkerIds = {};

  // Removed _updateMarkerPositions manually projected markers — now handled natively by alpha: 1.0 in MapBloc

  bool _isDisposed = false;
  MapState? _lastState;

  Offset? _routeInfoOffset;

  // Stable key for the map to prevent disposal/re-creation
  final GlobalKey _mapGlobalKey = GlobalKey();

  @override
  bool get wantKeepAlive => true;

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
    ); // No listener — _updateParticles was empty; burst is one-shot via forward()

    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        context.read<MapBloc>().add(const SetShowDropdownEvent(false));
      }
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    if (context.read<MapBloc>().state.isVisible) {
      _pulseController.repeat();
    }

    // Start a timer to detect location acquisition timeout
    context.read<MapBloc>().add(const SetLocationTimeoutEvent(false));
    _locationTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && context.read<MapBloc>().state.myLocation == null) {
        context.read<MapBloc>().add(const SetLocationTimeoutEvent(true));
      }
    });
    // _updateMarkerPositions removed - markers are now handled natively
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
    for (var ctrl in _markerControllers.values) {
      ctrl.dispose();
    }
    _markerControllers.clear();
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
      });
      context.read<MapBloc>().add(const SetShowDropdownEvent(false));
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
      });
      context.read<MapBloc>().add(SetShowDropdownEvent(preds.isNotEmpty));
    } else {
      setState(() {
        _predictions = [];
      });
      context.read<MapBloc>().add(const SetShowDropdownEvent(false));
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

      context.read<MapBloc>().add(const SetShowDropdownEvent(false));
      setState(() {
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
    _particles.clear();

    final assetPath = burstIcons[type] ?? burstIcons['accident']!;

    _burstImage = await _loadImage(assetPath);

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

  String _getResolvedIconPath(String? type) {
    if (type == null) return markerIcons['accident']!;
    final lowerType = type.toLowerCase();

    if (lowerType.contains('accident') || lowerType.contains('crash')) {
      return markerIcons['accident']!;
    } else if (lowerType.contains('fire')) {
      return markerIcons['fire']!;
    } else if (lowerType.contains('gun')) {
      return markerIcons['gun']!;
    } else if (lowerType.contains('knife') ||
        lowerType.contains('safety') ||
        lowerType.contains('safty')) {
      return markerIcons['knife']!;
    } else if (lowerType.contains('fight')) {
      return markerIcons['fight']!;
    } else if (lowerType.contains('protest')) {
      return markerIcons['protest']!;
    } else if (lowerType.contains('medicine') ||
        lowerType.contains('medical')) {
      return markerIcons['medical']!;
    } else if (lowerType.contains('police')) {
      return markerIcons['police']!;
    } else if (lowerType.contains('flood')) {
      return markerIcons['floods']!;
    } else if (lowerType.contains('road') || lowerType.contains('block')) {
      return markerIcons['road-block']!;
    } else if (lowerType.contains('snow')) {
      return markerIcons['snow']!;
    } else if (lowerType.contains('storm')) {
      return markerIcons['storm']!;
    } else if (lowerType.contains('earthquake')) {
      return markerIcons['earthquake']!;
    }
    return markerIcons['nomarker'] ?? markerIcons['accident']!;
  }

  void _syncAnimatedMarkers(MapState state) {
    if (_isDisposed || !mounted) return;

    final currentAnimatedMarkers = state.newsList
        .where((incident) =>
            incident.markerType == 'icon' || incident.markerType == 'news')
        .toList();

    final currentIds = currentAnimatedMarkers.map((m) => m.id).toSet();

    // 1. Remove controllers for icons no longer in the list
    _markerControllers.removeWhere((id, controller) {
      if (!currentIds.contains(id)) {
        controller.onCameraMove = null;
        controller.addInfoWindow = null;
        controller.hideInfoWindow = null;
        controller.googleMapController = null;
        try {
          controller.dispose();
        } catch (e) {
          debugPrint("Error disposing marker controller $id: $e");
        }
        _initializedMarkerIds.remove(id);
        return true;
      }
      return false;
    });

    // 2. Add/Sync controllers for current icons
    _controller.future.then((mapCtrl) {
      if (_isDisposed || !mounted) return;
      for (var incident in currentAnimatedMarkers) {
        final markerId = incident.id;
        if (!_markerControllers.containsKey(markerId)) {
          final ctrl = ciw.CustomInfoWindowController();
          ctrl.googleMapController = mapCtrl;
          _markerControllers[markerId] = ctrl;
        }

        final ctrl = _markerControllers[markerId]!;
        if (ctrl.googleMapController == null) {
          ctrl.googleMapController = mapCtrl;
        }

        if (!_initializedMarkerIds.contains(markerId)) {
          _tryAddInfoWindow(ctrl, incident, incident.position, markerId, 0);
        }
      }
    });

    if (mounted) setState(() {});
  }

  void _tryAddInfoWindow(ciw.CustomInfoWindowController controller,
      Incident incident, LatLng position, String markerId, int retryCount) {
    if (_isDisposed || !mounted || _initializedMarkerIds.contains(markerId)) {
      return;
    }

    if (controller.addInfoWindow != null) {
      _addInfoWindowToController(controller, incident, position, markerId);
      return;
    }

    if (retryCount < 15) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && !_isDisposed) {
          _tryAddInfoWindow(
              controller, incident, position, markerId, retryCount + 1);
        }
      });
    }
  }

  void _addInfoWindowToController(ciw.CustomInfoWindowController controller,
      Incident incident, LatLng position, String markerId) {
    if (controller.addInfoWindow == null ||
        _initializedMarkerIds.contains(markerId)) {
      return;
    }

    final assetPath = _getResolvedIconPath(incident.type ?? incident.alertType);

    try {
      controller.addInfoWindow!(
        GestureDetector(
          onTap: () {
            // Select marker and show detail
            context.read<MapBloc>().add(SetSelectedIncidentEvent(incident));
          },
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
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
              padding: const EdgeInsets.all(2),
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error);
                },
              ),
            ),
          ),
        ),
        position,
      );

      _initializedMarkerIds.add(markerId);
      if (controller.onCameraMove != null) {
        controller.onCameraMove!();
      }
    } catch (e) {
      debugPrint("Error adding info window for $markerId: $e");
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
    super.build(context);
    var size = MediaQuery.of(context).size;
    final double responsiveWidth = size.width > 600 ? 500 : size.width;

    return BlocConsumer<MapBloc, MapState>(
      buildWhen: (previous, current) {
        return previous.markers != current.markers ||
            previous.newsList != current.newsList ||
            previous.polylines != current.polylines ||
            previous.circles != current.circles ||
            previous.myLocation != current.myLocation ||
            previous.selectedAlertType != current.selectedAlertType ||
            previous.selectedDistance != current.selectedDistance ||
            previous.selectedCategory != current.selectedCategory ||
            previous.showAlertPanel != current.showAlertPanel ||
            previous.showGetDirectionCard != current.showGetDirectionCard ||
            previous.isNavigating != current.isNavigating ||
            previous.isLoadingNews != current.isLoadingNews ||
            previous.showDropdown != current.showDropdown ||
            previous.isVisible != current.isVisible;
      },
      listener: (context, state) {
        if (state.errorMessage != null) {
          final msg = state.errorMessage!;
          if (msg.contains("Location permissions are denied") ||
              msg.contains("Location permissions are permanently denied")) {
            _showLocationPermissionDialog();
          }
        }
        if (state.myLocation != null && _lastState?.myLocation == null) {
          _goToCurrentLocation();
        }

        if (state.selectedDistance != _lastDistanceFilter) {
          _lastDistanceFilter = state.selectedDistance;
          if (_lastDistanceFilter != null) {
            _animateToDistance(_lastDistanceFilter!);
          }
        }

        // Handle Info Window updates
        if (_lastState?.selectedIncident?.id != state.selectedIncident?.id) {
          if (state.selectedIncident != null &&
              state.selectedPosition != null) {
            _customInfoWindowController.hideInfoWindow?.call();
            _customInfoWindowController.addInfoWindow?.call(
              state.selectedIncident!.markerType == 'content' ||
                      state.selectedIncident!.markerType == 'news' ||
                      (state.selectedIncident!.markerType == 'icon' &&
                          state.selectedIncident!.title != null &&
                          state.selectedIncident!.title!.isNotEmpty)
                  ? ContentMarkerPopup(
                      key: ValueKey('popup_${state.selectedIncident!.id}'),
                      incident: state.selectedIncident!,
                      onViewPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => sl<NewsBloc>(),
                              child: NewsPage(
                                hideFilters: true,
                                appBarTitle: 'All News',
                                fromMap: true,
                                prioritizedContentId:
                                    state.selectedIncident!.id,
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : CustomInfoWindow(
                      key: ValueKey('popup_${state.selectedIncident!.id}'),
                      incident: state.selectedIncident!,
                      onPressed: () {},
                    ),
              state.selectedPosition!,
            );
          } else {
            _customInfoWindowController.hideInfoWindow?.call();
          }
        }

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
              debugPrint("Error moving camera to navigation: $e");
            }
          });
        }

        // Trigger overlay update when icons change
        if (_lastState?.newsList != state.newsList) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _syncAnimatedMarkers(state);
          });
        }

        if (state.routeInfo != null &&
            !state.isNavigating &&
            state.routeInfo!.points.isNotEmpty &&
            _lastState?.routeInfo != state.routeInfo) {
          _fitBounds(state.routeInfo!.points);
        }
        if (_lastState?.newlyCreatedIncident != state.newlyCreatedIncident &&
            state.newlyCreatedIncident != null) {
          final incident = state.newlyCreatedIncident!;
          final type = incident.type ?? incident.alertType ?? "accident";
          _addBurst(incident.position, type);
        }
        _lastState = state;
      },
      listenWhen: (previous, current) => true,
      builder: (context, state) {
        if (state.myLocation == null) {
          return Scaffold(
              body: Container(
            color: Colors.white.withOpacity(0.5),
            child: Center(
              child: CommonWidgetsNew.showAnimatedLoader(size),
            ),
          ));
        }
        // if (state.myLocation == null) {
        //   if (_locationTimeout) {
        //     return Scaffold(
        //       body: Center(
        //         child: Column(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [
        //             const Icon(Icons.location_off, size: 48, color: Colors.red),
        //             const SizedBox(height: 16),
        //             const Text(
        //               'Unable to get your location.',
        //               style: TextStyle(fontSize: 18),
        //             ),
        //             const SizedBox(height: 16),
        //             ElevatedButton(
        //               onPressed: () {
        //                 setState(() {
        //                   _locationTimeout = false;
        //                 });
        //                 context.read<MapBloc>().add(GetCurrentLocationEvent());
        //                 _locationTimer?.cancel();
        //                 _locationTimer = Timer(const Duration(seconds: 5), () {
        //                   if (mounted &&
        //                       context.read<MapBloc>().state.myLocation ==
        //                           null) {
        //                     setState(() {
        //                       _locationTimeout = true;
        //                     });
        //                   }
        //                 });
        //               },
        //               child: const Text('Retry'),
        //             ),
        //           ],
        //         ),
        //       ),
        //     );
        //   }
        // }

        return VisibilityDetector(
          key: const Key('map-visibility-key'),
          onVisibilityChanged: (info) {
            final isVisible = info.visibleFraction > 0;
            context.read<MapBloc>().add(SetVisibilityEvent(isVisible));
            if (isVisible) {
              if (!_pulseController.isAnimating) {
                _pulseController.repeat();
              }

              // Show alert popup if not shown yet
              bool isShown = sharedPreferences
                      ?.getBool(SharedPreferencesKeys.alertInfoPopupShownKey) ??
                  false;
              if (!isShown) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  AllDialogs.showAlertInfoPopupForMap(size);
                });
              }
            } else {
              _pulseController.stop();
            }
          },
          child: Scaffold(
            appBar: NewHomeAppBar(
              size: size,
              hideLeading: widget.hideLeading,
              showFilter: false,
            ),
            body: Stack(
              children: [
                RepaintBoundary(
                  child: BlocBuilder<MapBloc, MapState>(
                    buildWhen: (previous, current) {
                      return previous.markers != current.markers ||
                          previous.polylines != current.polylines ||
                          previous.circles != current.circles ||
                          previous.myLocation != current.myLocation ||
                          previous.isVisible != current.isVisible ||
                          previous.isSelectingAlertLocation !=
                              current.isSelectingAlertLocation;
                    },
                    builder: (context, mapState) {
                      return MapViewWidget(
                        state: mapState,
                        mapGlobalKey: _mapGlobalKey,
                        controller: _controller,
                        customInfoWindowController: _customInfoWindowController,
                        pulseController: _pulseController,
                        isProgrammaticMovement: _isProgrammaticMovement,
                        initialZoom: 16.0,
                        onMapCreated: (c) async {
                          if (!_controller.isCompleted) {
                            _controller.complete(c);
                            _customInfoWindowController.googleMapController = c;
                          }
                          for (var ctrl in _markerControllers.values) {
                            ctrl.googleMapController = c;
                          }
                          _syncAnimatedMarkers(mapState);
                          if (mounted) {
                            unawaited(_updateInfoWindow());
                          }
                        },
                        onCameraMoveStarted: () {
                          if (!_isProgrammaticMovement) {
                            _isUserDragging = true;
                            context
                                .read<MapBloc>()
                                .add(const SetDraggingEvent(true));
                          }
                          _customInfoWindowController.onCameraMove?.call();
                        },
                        onCameraMove: (pos) {
                          _currentZoom = pos.zoom;
                          _customInfoWindowController.onCameraMove?.call();
                          for (var ctrl in _markerControllers.values) {
                            ctrl.onCameraMove?.call();
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
                          _customInfoWindowController.hideInfoWindow?.call();
                          context.read<MapBloc>().add(ClearRouteEvent());

                          if (mapState.isSelectingAlertLocation &&
                              mapState.pendingAlertType != null) {
                            context.read<MapBloc>().add(
                                SetPreviewAlertMarkerEvent(
                                    type: mapState.pendingAlertType!,
                                    position: pos));
                            context.read<MapBloc>().add(
                                const SetSelectingAlertLocationEvent(
                                    isSelecting: false));
                            return;
                          }

                          if (mapState.showAlertPanel) {
                            context
                                .read<MapBloc>()
                                .add(ToggleAlertPanelEvent());
                            return;
                          }

                          if (mapState.isDestinationSelectionMode) {
                            final repo = sl<MapRepository>();
                            String address =
                                "${pos.latitude}, ${pos.longitude}";

                            final result =
                                await repo.getAddressFromCoordinates(pos);
                            result.fold(
                              (failure) => debugPrint(
                                  "Failed to get address: ${failure.message}"),
                              (addr) => address = addr,
                            );

                            context.read<MapBloc>().add(
                                SetMapSelectedLocationEvent(
                                    position: pos,
                                    address: address,
                                    isOrigin: mapState.isSelectingOrigin));

                            context.read<MapBloc>().add(
                                SetDestinationSelectionModeEvent(
                                    isSelectionMode: false));
                            return;
                          }

                          if (mapState.showGetDirectionCard) {
                            final repo = sl<MapRepository>();
                            String address =
                                "${pos.latitude}, ${pos.longitude}";

                            final result =
                                await repo.getAddressFromCoordinates(pos);
                            result.fold(
                              (failure) => debugPrint(
                                  "Failed to get address: ${failure.message}"),
                              (addr) => address = addr,
                            );

                            context.read<MapBloc>().add(
                                SetMapSelectedLocationEvent(
                                    position: pos,
                                    address: address,
                                    isOrigin: false));
                            return;
                          }

                          context
                              .read<MapBloc>()
                              .add(ClearSelectedMarkerEvent());
                          context
                              .read<MapBloc>()
                              .add(ClearSelectedPolygonEvent());
                          setState(() {
                            _infoOffset = null;
                            _polygonInfoOffset = null;
                          });
                        },
                      );
                    },
                  ),
                ),

                // Consolidate all overlays inside a BlocBuilder to ensure access to MapState
                BlocBuilder<MapBloc, MapState>(
                  builder: (context, state) {
                    return Stack(
                      children: [
                        // perfectly pinned animated markers from reference code
                        ..._markerControllers.entries.map((entry) {
                          return KeyedSubtree(
                            key: ValueKey('animated_marker_${entry.key}'),
                            child: ciw.CustomInfoWindow(
                              controller: entry.value,
                              height: MapBloc.kAlertMarkerSize.toDouble(),
                              width: MapBloc.kAlertMarkerSize.toDouble(),
                              offset: 0,
                            ),
                          );
                        }),

                        // Main info window for popups
                        ciw.CustomInfoWindow(
                          controller: _customInfoWindowController,
                          height: responsiveWidth * 0.85,
                          width: responsiveWidth * 0.75,
                          offset: responsiveWidth * 0.14,
                        ),

                        if (_routeInfoOffset != null &&
                            state.routeInfo != null &&
                            state.routeMidpoint != null)
                          Positioned(
                            left: _routeInfoOffset!.dx - 150,
                            top: _routeInfoOffset!.dy - 150,
                            child: RouteInfoWindow(
                              distance:
                                  "${state.routeInfo!.distanceKm.toStringAsFixed(2)} km",
                              duration:
                                  "${state.routeInfo!.durationMinutes} min",
                              onClose: () {
                                context.read<MapBloc>().add(ClearRouteEvent());
                              },
                            ),
                          ),

                        if (_polygonInfoOffset != null &&
                            state.selectedPolygonId != null)
                          Positioned(
                            left: _polygonInfoOffset!.dx - 110,
                            top: _polygonInfoOffset!.dy - 140,
                            child: DangerZoneInfoWindow(
                              name: "Danger Zone",
                              description:
                                  "High risk area - proceed with caution",
                              onPressed: () {
                                context
                                    .read<MapBloc>()
                                    .add(ClearSelectedPolygonEvent());
                                setState(() => _polygonInfoOffset = null);
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
                Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: RepaintBoundary(
                    child: SearchAndFilterBar(
                      searchController: _searchController,
                      searchFocusNode: _searchFocusNode,
                      onPressedOnNavigation: () {
                        context
                            .read<MapBloc>()
                            .add(ToggleGetDirectionCardEvent());
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
                ),
                if (state.showDropdown && _predictions.isNotEmpty)
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
                                context.read<MapBloc>().add(
                                    const SetSelectingAlertLocationEvent(
                                        isSelecting: false));
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
                      scale: state.showGetDirectionCard ? 1.0 : 0.0,
                      child: IgnorePointer(
                        ignoring: !state.showGetDirectionCard,
                        child: const GetDirectionCard(),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 15,
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 150),
                    tween: Tween<double>(
                        begin: 1.0, end: state.showAlertPanel ? 0.95 : 1.0),
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.read<MapBloc>().add(ToggleAlertPanelEvent());
                      },
                      child: const AlertButtonMap(),
                    ),
                  ),
                ),
                if (state.isLoadingNews)
                  // Loading animation
                  Container(
                    color: Colors.white.withOpacity(0.5),
                    child: Center(
                      child: CommonWidgetsNew.showAnimatedLoader(size),
                    ),
                  ),

                Positioned(
                  right: 20,
                  bottom: 20,
                  child: SideActionPanel(
                    onCurrentLocation: _goToCurrentLocation,
                    onZoomIn: _zoomIn,
                    onZoomOut: _zoomOut,
                  ),
                ),

                // Dimmer and tap-to-close for AlertPanel
                if (state.showAlertPanel)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        context.read<MapBloc>().add(ToggleAlertPanelEvent());
                      },
                      child: Container(
                        color: Colors.black.withOpacity(0.05), // Subtle dim
                      ),
                    ),
                  ),
                if (state.showAlertPanel)
                  Positioned(
                    bottom: 63,
                    left: 0,
                    child: AlertPanel(
                      onClose: () {
                        context.read<MapBloc>().add(ToggleAlertPanelEvent());
                      },
                      onAlertSelected: (type) async {
                        try {
                          if (!state.isSelectingAlertLocation) {
                            context.read<MapBloc>().add(
                                SetSelectingAlertLocationEvent(
                                    isSelecting: true, type: type));
                            _customInfoWindowController.hideInfoWindow?.call();
                          }
                          debugPrint("AlertSelected: $type");
                          final myLoc =
                              context.read<MapBloc>().state.myLocation;
                          if (myLoc != null) {
                            _addBurst(myLoc, type);
                            context.read<MapBloc>().add(AddAlertMarkerEvent(
                                type: type, position: myLoc));
                          }
                        } catch (e) {
                          debugPrint("Error adding alert marker: $e");
                        }
                      },
                    ),
                  ),

                BurstParticlesOverlay(
                  controller: _burstController,
                  burstImage: _burstImage,
                ),

                // ======================= Locate Me / Retry Button =======================
                if (state.myLocation == null)
                  Positioned(
                    bottom: 120,
                    right: 16,
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      mini: true,
                      onPressed: () {
                        context
                            .read<MapBloc>()
                            .add(const GetCurrentLocationEvent());
                      },
                      child: const Icon(Icons.my_location,
                          color: Color(0xffEC4E54)),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
