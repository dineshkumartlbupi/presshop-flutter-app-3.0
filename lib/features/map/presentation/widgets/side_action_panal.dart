import 'package:flutter/material.dart';

class SideActionPanel extends StatelessWidget {

  const SideActionPanel({
    super.key,
    this.onCurrentLocation,
    this.onZoomIn,
    this.onZoomOut,
  });
  final VoidCallback? onCurrentLocation;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Current Location
        Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBDBDBD)),
            ),
            child: _buildButton(Icons.my_location_sharp, onCurrentLocation)),

        const SizedBox(height: 10),

        // Zoom Buttons
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBDBDBD)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 5),
              _buildButton(Icons.add, onZoomIn),
              _buildButton(Icons.remove, onZoomOut),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButton(IconData icon, VoidCallback? onPressed) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: const Color(0xFFEC4E54)),
        onPressed: onPressed,
      ),
    );
  }
}
