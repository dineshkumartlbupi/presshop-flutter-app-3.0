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
  List<Circle> _pulseCircles = [];
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
    final opacity = 1.0 - val;

    List<Circle> newCircles = [];

    // 1. Current Location Pulse
    if (widget.state.myLocation != null && _currentZoom >= 13.0) {
      final double baseRadiusAtZoom14 = 400.0;
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

    // 2. Animated Markers Pulse (Alerts & News)
    if (_currentZoom >= 11.0) {
      final double baseMarkerRadius = 150.0;
      final double scaleFactor = pow(2, 14 - _currentZoom).toDouble();
      final double markerRadius = baseMarkerRadius * scaleFactor * (1.0 + val * 0.3);

      final animatedMarkers = widget.state.markers
          .where((m) =>
              m.markerId.value.startsWith('alert_') ||
              m.markerId.value.startsWith('news_'))
          .toList();

      for (var marker in animatedMarkers) {
        final isNews = marker.markerId.value.startsWith('news_');
        final color = isNews ? const Color(0xFFFFB400) : const Color(0xFFFF5A5F);

        newCircles.add(
          Circle(
            circleId: CircleId('pulse_${marker.markerId.value}'),
            center: marker.position,
            radius: markerRadius,
            fillColor: color.withOpacity(opacity * 0.2),
            strokeColor: color.withOpacity(opacity * 0.4),
            strokeWidth: 1,
            zIndex: 1,
          ),
        );
      }
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
