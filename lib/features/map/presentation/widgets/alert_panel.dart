import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:presshop/core/constants/app_dimensions_new.dart';
import 'package:presshop/features/map/constants/map_news_constants.dart';

class AlertPanel extends StatelessWidget {
  final VoidCallback onClose;
  final Function(String alertType)? onAlertSelected;
  const AlertPanel({super.key, required this.onClose, this.onAlertSelected});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.all(size.width * AppDimensions.numD042),
            padding: EdgeInsets.symmetric(
                horizontal: size.width * AppDimensions.numD026,
                vertical: size.width * AppDimensions.numD026),
            width: size.width * AppDimensions.numD47,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(size.width * AppDimensions.numD05),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: size.width * AppDimensions.numD026,
                  offset: Offset(0.0, size.width * AppDimensions.numD01),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      "Send Alerts",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: size.width * AppDimensions.numD026,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.width * AppDimensions.numD026),
                Container(
                  height: size.width * AppDimensions.numD005,
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: size.width * AppDimensions.numD026),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(size.width * AppDimensions.numD005),
                  ),
                ),
                SizedBox(height: size.width * AppDimensions.numD01),
                Row(
                  children: [
                    Text(
                      "Tap to instantly alert the community",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: size.width * AppDimensions.numD021,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.width * AppDimensions.numD042),
                GridView.builder(
                  shrinkWrap: true,
                  itemCount: alertTypes.length,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: size.width * AppDimensions.numD016,
                    mainAxisSpacing: size.width * AppDimensions.numD016,
                  ),
                  itemBuilder: (context, i) {
                    final item = alertTypes[i];
                    return GestureDetector(
                      onTap: () {
                        onAlertSelected?.call(item['type']!);
                        onClose();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            size.width * AppDimensions.numD021,
                          ),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              item['icon']!,
                              width: size.width * AppDimensions.numD065,
                              height: size.width * AppDimensions.numD065,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: size.width * AppDimensions.numD016),
                            Text(
                              item['label']!,
                              style: TextStyle(
                                fontSize: size.width * AppDimensions.numD021,
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
                SizedBox(height: size.width * AppDimensions.numD04),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/icons/mapalert.png',
                      width: size.width * AppDimensions.numD04,
                      height: size.width * AppDimensions.numD04,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: size.width * AppDimensions.numD016),
                    Expanded(
                      child: Text(
                        "False or misleading reports may lead to account suspension.",
                        style: TextStyle(
                          color: Color(0xFF4F4F4F),
                          fontSize: size.width * AppDimensions.numD021,
                          fontWeight: FontWeight.w500,
                        ),
                        // textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Pointer arrow
        Positioned(
          left: size.width * AppDimensions.numD1,
          bottom: size.width * AppDimensions.numD016,
          child: Transform.rotate(
            angle: math.pi / 4, // 45 degrees
            child: Container(
              width: size.width * AppDimensions.numD05,
              height: size.width * AppDimensions.numD05,
              decoration: BoxDecoration(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
