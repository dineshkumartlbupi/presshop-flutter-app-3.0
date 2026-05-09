import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:presshop/core/constants/app_dimensions.dart';
import 'package:presshop/core/router/router_constants.dart';
import 'package:presshop/core/theme/app_colors.dart';
import 'package:presshop/core/utils/ui_utils.dart';
import 'package:presshop/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:presshop/features/dashboard/presentation/bloc/dashboard_event.dart';
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
    final double scalingWidth = isIpad ? 550 : size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white24 : Colors.grey.shade400;

    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        alignment: Alignment.bottomLeft,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                margin: EdgeInsets.only(
                    bottom: scalingWidth * AppDimensions.numD042,
                    left: 16,
                    right: 16),
                padding: EdgeInsets.symmetric(
                    horizontal: scalingWidth * AppDimensions.numD026,
                    vertical: scalingWidth * AppDimensions.numD026),
                width: isIpad ? 400 : size.width * AppDimensions.numD65,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(
                      scalingWidth * AppDimensions.numD05),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: scalingWidth * AppDimensions.numD026,
                      offset: Offset(0.0, scalingWidth * AppDimensions.numD01),
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
                            fontSize: scalingWidth * AppDimensions.numD032,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            print('click------------------------>');
                            try {
                              context
                                  .read<DashboardBloc>()
                                  .add(const ChangeDashboardTabEvent(2));
                            } catch (e) {
                              debugPrint(
                                  "DashboardBloc not found in context: $e");
                            }
                            context.goNamed(AppRoutes.dashboardName,
                                extra: {'initialPosition': 2, 'isClick': true});
                          },
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/icons/ic_v_cam.png",
                                height: scalingWidth * AppDimensions.numD05,
                                width: scalingWidth * AppDimensions.numD05,
                                color: AppColorTheme.colorThemePink,
                              ),
                              SizedBox(
                                  width: scalingWidth * AppDimensions.numD01),
                              Text(
                                "Share Video",
                                style: TextStyle(
                                  fontSize:
                                      scalingWidth * AppDimensions.numD032,
                                  fontWeight: FontWeight.w500,
                                  color: AppColorTheme.colorThemePink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: scalingWidth * AppDimensions.numD022),
                    Container(
                      height: scalingWidth * AppDimensions.numD003,
                      width: double.infinity,
                      margin: EdgeInsets.only(
                          bottom: scalingWidth * AppDimensions.numD026),
                      decoration: BoxDecoration(
                        color: borderColor,
                        borderRadius: BorderRadius.circular(
                            scalingWidth * AppDimensions.numD005),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "Tap to instantly alert the community",
                          style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontSize: scalingWidth * AppDimensions.numD028,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: scalingWidth * AppDimensions.numD042),
                    GridView.builder(
                      shrinkWrap: true,
                      itemCount: alertTypes.length,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.95,
                        crossAxisSpacing: scalingWidth * AppDimensions.numD012,
                        mainAxisSpacing: scalingWidth * AppDimensions.numD012,
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
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(
                                scalingWidth * AppDimensions.numD021,
                              ),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  item['icon']!,
                                  width: scalingWidth * AppDimensions.numD09,
                                  height: scalingWidth * AppDimensions.numD09,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(
                                    height:
                                        scalingWidth * AppDimensions.numD016),
                                Text(
                                  item['label']!,
                                  style: TextStyle(
                                    fontSize:
                                        scalingWidth * AppDimensions.numD029,
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
                    SizedBox(height: scalingWidth * AppDimensions.numD042),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/icons/mapalert.png',
                          width: scalingWidth * AppDimensions.numD04,
                          height: scalingWidth * AppDimensions.numD04,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(width: scalingWidth * AppDimensions.numD016),
                        Expanded(
                          child: Text(
                            "False or misleading reports may lead to account suspension.",
                            style: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontSize: scalingWidth * AppDimensions.numD028,
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
              left: isIpad ? 55 : size.width * 0.12,
              bottom: scalingWidth * AppDimensions.numD016,
              child: Transform.rotate(
                angle: math.pi / 4,
                child: Container(
                  width: scalingWidth * AppDimensions.numD05,
                  height: scalingWidth * AppDimensions.numD05,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
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
