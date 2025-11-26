import 'dart:math' as math;
import 'package:flutter/material.dart';

class AlertPanel extends StatelessWidget {
  final VoidCallback onClose;
  final Function(String alertType)? onAlertSelected;
  const AlertPanel({super.key, required this.onClose, this.onAlertSelected});

  @override
  Widget build(BuildContext context) {
    final alertItems = [
      {'icon': 'assets/markers/fire.gif', 'label': 'Accident'},
      {'icon': 'assets/markers/car-crash.gif', 'label': 'Crash'},
      {'icon': 'assets/markers/fight.gif', 'label': 'Fight'},
      {'icon': 'assets/markers/fire.gif', 'label': 'Fire Alert'},
      {'icon': 'assets/markers/knife.gif', 'label': 'Knife'},
      {'icon': 'assets/markers/medicine.gif', 'label': 'Medicine'},
      {'icon': 'assets/markers/protesters.gif', 'label': 'Protest'},
      {'icon': 'assets/markers/gun.gif', 'label': 'Gun Fire'},
    ];

    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            width: 176,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      "Send Alerts",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  height: 2,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "Tap to instantly alert the community",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 🔥 Grid of GIF icons
                GridView.builder(
                  shrinkWrap: true,
                  itemCount: alertItems.length,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemBuilder: (context, i) {
                    final item = alertItems[i];
                    return GestureDetector(
                      onTap: () {
                        onAlertSelected?.call(item['label']!);
                        onClose();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              item['icon']!,
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item['label']!,
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.grey.shade700,
                              ),

                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Pointer arrow
        Positioned(
          left: 40,
          bottom: 6,
          child: Transform.rotate(
            angle: math.pi / 4, // 45 degrees
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
