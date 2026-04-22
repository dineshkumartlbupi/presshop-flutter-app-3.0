import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:presshop/core/constants/app_dimensions.dart';
import 'package:presshop/core/theme/app_colors.dart';
import 'package:presshop/features/map/constants/map_news_constants.dart';

class AlertPanel extends StatefulWidget {
  const AlertPanel({super.key, required this.onClose, this.onAlertSelected});
  final VoidCallback onClose;
  final Function(String alertType)? onAlertSelected;

  @override
  State<AlertPanel> createState() => _AlertPanelState();
}

class _AlertPanelState extends State<AlertPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        alignment: Alignment.bottomLeft,
        child: Stack(
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
                            widget.onAlertSelected?.call(item['type']!);
                            widget.onClose();
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
                                    fontSize:
                                        size.width * AppDimensions.numD029,
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
                    SizedBox(height: size.width * AppDimensions.numD042),
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
            Positioned(
              left: size.width * 0.15,
              bottom: size.width * AppDimensions.numD016,
              child: Transform.rotate(
                angle: math.pi / 4,
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
        ),
      ),
    );
  }
}
