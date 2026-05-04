import 'package:flutter/material.dart';
import 'package:presshop/core/theme/app_colors.dart';

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
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white24
                      : Colors.grey.shade400,
                  width: 1.2),
            ),
            child: _buildButton(
                context, Icons.my_location_sharp, onCurrentLocation)),

        const SizedBox(height: 10),

        // Zoom Buttons
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white24
                    : Colors.grey.shade400,
                width: 1.2),
          ),
          child: Column(
            children: [
              const SizedBox(height: 5),
              _buildButton(context, Icons.add, onZoomIn),
              _buildButton(context, Icons.remove, onZoomOut),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
      BuildContext context, IconData icon, VoidCallback? onPressed) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: AppColorTheme.colorThemePink),
        onPressed: onPressed,
      ),
    );
  }
}
