import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presshop/features/map/presentation/bloc/map_state.dart';
import 'package:custom_info_window/custom_info_window.dart' as ciw;

class MapViewWidget extends StatefulWidget {
  final MapState state;
  final GlobalKey mapGlobalKey;
  final Completer<GoogleMapController> controller;
  final ciw.CustomInfoWindowController customInfoWindowController;
  final Map<String, ciw.CustomInfoWindowController> markerControllers;
  final AnimationController pulseController;
  final bool isProgrammaticMovement;
  final double initialZoom;
  final Future<void> Function(GoogleMapController) onMapCreated;
  final VoidCallback onCameraMoveStarted;
  final void Function(CameraPosition) onCameraMove;
  final VoidCallback onCameraIdle;
  final Future<void> Function(LatLng) onTap;

  const MapViewWidget({
    Key? key,
    required this.state,
    required this.mapGlobalKey,
    required this.controller,
    required this.customInfoWindowController,
    required this.markerControllers,
    required this.pulseController,
    required this.isProgrammaticMovement,
    required this.initialZoom,
    required this.onMapCreated,
    required this.onCameraMoveStarted,
    required this.onCameraMove,
    required this.onCameraIdle,
    required this.onTap,
  }) : super(key: key);

  @override
  State<MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {
  Circle? _pulseCircle;
  double _currentZoom = 16.0;

  @override
  void initState() {
    super.initState();
    _currentZoom = widget.initialZoom;
    widget.pulseController.addListener(_updatePulseCircle);
  }

  @override
  void dispose() {
    widget.pulseController.removeListener(_updatePulseCircle);
    super.dispose();
  }

  void _updatePulseCircle() {
    if (!mounted) return;
    final val = Curves.easeOutQuad.transform(widget.pulseController.value);
    if (widget.state.myLocation != null && _currentZoom >= 13.0) {
      final double baseRadiusAtZoom14 = 400.0;
      final double safeZoom = _currentZoom.roundToDouble();
      final double scaleFactor = pow(2, 14 - safeZoom).toDouble();
      final double dynamicRadius = baseRadiusAtZoom14 * scaleFactor;
      final double radius = dynamicRadius * (1.0 + val * 0.5);
      final opacity = 1.0 - val;

      setState(() {
        _pulseCircle = Circle(
          circleId: const CircleId('my_location_pulse'),
          center: widget.state.myLocation!,
          radius: radius,
          fillColor: const Color.fromARGB(255, 247, 70, 70)
              .withOpacity(opacity * 0.5),
          strokeColor:
              const Color.fromARGB(255, 255, 84, 84).withOpacity(opacity),
          strokeWidth: 1,
        );
      });
    } else {
      if (_pulseCircle != null) {
        setState(() {
          _pulseCircle = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Set<Circle> allCircles = Set.from(widget.state.circles);
    if (_pulseCircle != null) {
      allCircles.add(_pulseCircle!);
    }

    return GoogleMap(
      key: widget.mapGlobalKey,
      initialCameraPosition: widget.state.initialCamera ??
          CameraPosition(
            target: widget.state.myLocation ?? const LatLng(0, 0),
            zoom: widget.initialZoom,
          ),
      onMapCreated: widget.onMapCreated,
      markers: widget.state.markers,
      polylines: widget.state.polylines,
      polygons: widget.state.polygons,
      circles: allCircles,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      onCameraMoveStarted: widget.onCameraMoveStarted,
      onCameraMove: (pos) {
        _currentZoom = pos.zoom;
        widget.onCameraMove(pos);
      },
      onCameraIdle: widget.onCameraIdle,
      onTap: widget.onTap,
    );
  }
}
