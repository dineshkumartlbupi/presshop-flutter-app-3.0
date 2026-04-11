import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:presshop/features/map/presentation/bloc/map_state.dart';
import 'package:custom_info_window/custom_info_window.dart' as ciw;

class MapViewWidget extends StatefulWidget {
  const MapViewWidget({
    super.key,
    required this.state,
    required this.mapGlobalKey,
    required this.controller,
    required this.customInfoWindowController,
    required this.pulseController,
    required this.isProgrammaticMovement,
    required this.initialZoom,
    required this.onMapCreated,
    required this.onCameraMoveStarted,
    required this.onCameraMove,
    required this.onCameraIdle,
    required this.onTap,
  });
  final MapState state;
  final GlobalKey mapGlobalKey;
  final Completer<GoogleMapController> controller;
  final ciw.CustomInfoWindowController customInfoWindowController;
  final AnimationController pulseController;
  final bool isProgrammaticMovement;
  final double initialZoom;
  final Future<void> Function(GoogleMapController) onMapCreated;
  final VoidCallback onCameraMoveStarted;
  final void Function(CameraPosition) onCameraMove;
  final VoidCallback onCameraIdle;
  final Future<void> Function(LatLng) onTap;

  @override
  State<MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {
  List<Circle> _pulseCircles = [];
  double _currentZoom = 16.0;
  double _lastPulseVal = -1.0;

  @override
  void initState() {
    super.initState();
    _currentZoom = widget.initialZoom;
    _lastPulseVal = -1.0;
    widget.pulseController.addListener(_updatePulseCircle);
  }

  @override
  void didUpdateWidget(MapViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.pulseController.removeListener(_updatePulseCircle);
    super.dispose();
  }

  void _updatePulseCircle() {
    if (!mounted || !widget.state.isVisible) return;

    final rawVal = widget.pulseController.value;
    // Throttle: only rebuild if value changed by more than 5% — significantly reduces rebuild frequency
    if ((rawVal - _lastPulseVal).abs() < 0.05) return;
    _lastPulseVal = rawVal;

    final val = Curves.easeOutQuad.transform(rawVal);
    final opacity = 1.0 - val;

    List<Circle> newCircles = [];

    // 1. Current Location Pulse
    if (widget.state.myLocation != null && _currentZoom >= 13.0) {
      const double baseRadiusAtZoom14 = 400.0;
      final double scaleFactor = pow(2, 14 - _currentZoom).toDouble();
      final double dynamicRadius = baseRadiusAtZoom14 * scaleFactor;
      final double radius = dynamicRadius * (1.0 + val * 0.5);

      newCircles.add(
        Circle(
          circleId: const CircleId('my_location_pulse'),
          center: widget.state.myLocation!,
          radius: radius,
          fillColor: const Color(0xFFFF5A5F).withOpacity(opacity * 0.3),
          strokeColor: const Color(0xFFFF5A5F).withOpacity(opacity * 0.5),
          strokeWidth: 1,
          zIndex: 1,
        ),
      );
    }

    setState(() {
      _pulseCircles = newCircles;
    });
  }

  @override
  Widget build(BuildContext context) {
    Set<Circle> allCircles = Set.from(widget.state.circles);
    allCircles.addAll(_pulseCircles);

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
      myLocationEnabled: false, // Prevents blue dot overlap with avatar
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
