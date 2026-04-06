import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SimpleMapPage extends StatefulWidget {
  const SimpleMapPage({Key? key}) : super(key: key);

  @override
  State<SimpleMapPage> createState() => _SimpleMapPageState();
}

class _SimpleMapPageState extends State<SimpleMapPage> {
  GoogleMapController? _controller;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(26.8467, 80.9462), // Lucknow
    zoom: 14,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Map'),
      ),
      body: Center(
        child: SizedBox.expand(
          child: GoogleMap(
            initialCameraPosition: _initialPosition,
            onMapCreated: (controller) {
              _controller = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
          ),
        ),
      ),
    );
  }
}
