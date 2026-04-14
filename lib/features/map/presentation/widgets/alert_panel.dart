import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:presshop/core/constants/app_dimensions.dart';
import 'package:presshop/features/map/constants/map_news_constants.dart';

class AlertPanel extends StatelessWidget {
  const AlertPanel({super.key, required this.onClose, this.onAlertSelected});
  final VoidCallback onClose;
  final Function(String alertType)? onAlertSelected;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.only(
                bottom: size.width * AppDimensions.numD042,
                left: 10,
                right: 10),
            padding: EdgeInsets.symmetric(
                horizontal: size.width * AppDimensions.numD026,
                vertical: size.width * AppDimensions.numD026),
            width: size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(size.width * AppDimensions.numD05),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Send Alerts",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: size.width * AppDimensions.numD031 * 1.2,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.videocam_outlined,
                          color: Color(0xFFEC4E54), size: 20),
                      label: Text(
                        "Share Video",
                        style: TextStyle(
                          color: const Color(0xFFEC4E54),
                          fontWeight: FontWeight.bold,
                          fontSize: size.width * AppDimensions.numD031,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.width * AppDimensions.numD022),

                Container(
                  height: size.width * AppDimensions.numD005,
                  width: double.infinity,
                  margin: EdgeInsets.only(
                      bottom: size.width * AppDimensions.numD026),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(
                        size.width * AppDimensions.numD005),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "Tap to instantly alert the community",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: size.width * AppDimensions.numD021 * 1.1,
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
                    childAspectRatio: 1.1,
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
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              item['icon']!,
                              width: size.width * AppDimensions.numD095 * 0.9,
                              height: size.width * AppDimensions.numD095 * 0.9,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['label']!,
                              style: TextStyle(
                                fontSize:
                                    size.width * AppDimensions.numD021 * 1.25,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: size.width * AppDimensions.numD042),
                // Warning section
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_rounded,
                          color: Color(0xFFFBBC05), size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "False or misleading reports may lead to account suspension.",
                          style: TextStyle(
                            color: const Color(0xFF4F4F4F),
                            fontSize: size.width * AppDimensions.numD021 * 1.1,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Pointer arrow at the left corner
        Positioned(
          left: size.width * 0.15,
          bottom: size.width * AppDimensions.numD016,
          child: Transform.rotate(
            angle: math.pi / 4, // 45 degrees
            child: Container(
              width: size.width * AppDimensions.numD05,
              height: size.width * AppDimensions.numD05,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
