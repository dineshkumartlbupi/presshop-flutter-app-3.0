import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:presshop/core/constants/app_dimensions.dart';
import 'package:presshop/core/theme/app_colors.dart';
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
            width: size.width * AppDimensions.numD65,
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
                        fontSize: size.width * AppDimensions.numD032,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "assets/icons/ic_v_cam.png",
                          height: size.width * AppDimensions.numD05,
                          width: size.width * AppDimensions.numD05,
                          color: AppColorTheme.colorThemePink,
                        ),
                        SizedBox(width: size.width * AppDimensions.numD01),
                        Text(
                          "Share Video",
                          style: TextStyle(
                            fontSize: size.width * AppDimensions.numD032,
                            fontWeight: FontWeight.w500,
                            color: AppColorTheme.colorThemePink,
                          ),
                        ),
                      ],
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
                        color: Color(0xFF4F4F4F),
                        fontSize: size.width * AppDimensions.numD028,
                        fontWeight: FontWeight.w500,
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
                    crossAxisSpacing: size.width * AppDimensions.numD012,
                    mainAxisSpacing: size.width * AppDimensions.numD012,
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
                              width: size.width * AppDimensions.numD09,
                              height: size.width * AppDimensions.numD09,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(
                                height: size.width * AppDimensions.numD016),
                            Text(
                              item['label']!,
                              style: TextStyle(
                                fontSize: size.width * AppDimensions.numD029,
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
                // GridView.builder(
                //   shrinkWrap: true,
                //   itemCount: alertTypes.length,
                //   physics: const NeverScrollableScrollPhysics(),
                //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                //     crossAxisCount: 3,
                //     childAspectRatio: 1.1,
                //     crossAxisSpacing: size.width * AppDimensions.numD016,
                //     mainAxisSpacing: size.width * AppDimensions.numD016,
                //   ),
                //   itemBuilder: (context, i) {
                //     final item = alertTypes[i];
                //     return GestureDetector(
                //       onTap: () {
                //         onAlertSelected?.call(item['type']!);
                //         onClose();
                //       },
                //       child: Container(
                //         decoration: BoxDecoration(
                //           color: Colors.white,
                //           borderRadius: BorderRadius.circular(
                //             size.width * AppDimensions.numD021,
                //           ),
                //           border: Border.all(color: Colors.grey.shade200),
                //         ),
                //         child: Column(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             Image.asset(
                //               item['icon']!,
                //               width: size.width * AppDimensions.numD095 * 0.9,
                //               height: size.width * AppDimensions.numD095 * 0.9,
                //               fit: BoxFit.contain,
                //             ),
                //             const SizedBox(height: 4),
                //             Text(
                //               item['label']!,
                //               style: TextStyle(
                //                 fontSize:
                //                     size.width * AppDimensions.numD021 * 1.25,
                //                 color: Colors.grey.shade700,
                //                 fontWeight: FontWeight.normal,
                //               ),
                //               textAlign: TextAlign.center,
                //             ),
                //           ],
                //         ),
                //       ),
                //     );
                //   },
                // ),
                SizedBox(height: size.width * AppDimensions.numD042),
                // Warning section
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
                          fontSize: size.width * AppDimensions.numD028,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
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
