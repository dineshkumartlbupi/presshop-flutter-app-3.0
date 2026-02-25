import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/router/router_constants.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/widgets/logo_widget.dart';
import 'package:presshop/main.dart';

class CommonBrandedAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final Size size;
  final List<Widget>? actionWidgets;
  final VoidCallback? leadingFxn;
  final double elevation;
  final bool hideLeading;
  final int? notificationCount;
  final bool showLogo;

  const CommonBrandedAppBar({
    super.key,
    required this.title,
    required this.size,
    this.actionWidgets,
    this.leadingFxn,
    this.elevation = 0,
    this.hideLeading = false,
    this.notificationCount,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      elevation: elevation,
      title: Text(
        title,
        style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: size.width * AppDimensions.appBarHeadingFontSize),
      ),
      centerTitle: false,
      titleSpacing: 0,
      size: size,
      showActions: true,
      leadingFxn: leadingFxn ??
          () {
            context.pop();
          },
          
      actionWidget: [
        if (actionWidgets != null)
          ...actionWidgets!.map((w) => Center(child: w)),
        if (notificationCount != null)
          Center(
            child: Container(
              margin: EdgeInsets.only(right: size.width * AppDimensions.numD04),
              width: size.width * AppDimensions.numD075,
              height: size.width * AppDimensions.numD075,
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    height: size.width * AppDimensions.numD06,
                    width: size.width * AppDimensions.numD06,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.2),
                      borderRadius: BorderRadius.circular(
                          size.width * AppDimensions.numD015),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(size.width * 0.002),
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: Icon(
                            Icons.circle,
                            color: AppColorTheme.colorThemePink,
                            size: size.width * AppDimensions.numD04,
                          ),
                        ),
                        Text(
                          notificationCount.toString(),
                          style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD025,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (showLogo)
          Center(
            child: InkWell(
              onTap: () {
                context.goNamed(
                  AppRoutes.dashboardName,
                  extra: {'initialPosition': 2},
                );
              },
              child:  LogoWidget.buildLogo(size),
              
            ),
          ),
        if (showLogo)
          SizedBox(
            width: size.width * AppDimensions.numD02,
          )
      ],
      hideLeading: hideLeading,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight((sharedPreferences?.getBool('isIpad') ?? false
          ? kToolbarHeightIpad
          : kToolbarHeight));
}
