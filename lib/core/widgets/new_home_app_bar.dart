import 'package:flutter/material.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/core/router/router_constants.dart';
import 'package:presshop/core/widgets/logo_widget.dart';

class NewHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const   NewHomeAppBar({
    super.key,
    required this.size,
    this.hideLeading = false,
    this.onFilterTap,
    this.showFilter = true,
    this.bottom,
    this.appBarTitle,
    this.hideHamburger = false,
    this.appBarbackgroundColor = Colors.white,
  });
  final Size size;
  final bool hideLeading;
  final Function()? onFilterTap;
  final bool showFilter;
  final PreferredSizeWidget? bottom;
  final String? appBarTitle;
  final bool hideHamburger;
  final Color appBarbackgroundColor;

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      elevation: 0,
      hideLeading: hideLeading,
      appBarbackgroundColor: appBarbackgroundColor,
      title: appBarTitle != null
          ? Text(
              appBarTitle!,
              style: TextStyle(
                color: Colors.black,
                fontSize: size.width * AppDimensions.numD05,
                fontWeight: FontWeight.w700,
                fontFamily: "AirbnbCereal",
              ),
            )
          : Padding(
              padding: EdgeInsets.only(
                  left: hideLeading ? size.width * AppDimensions.numD018 : 0),
              child: InkWell(
                onTap: () {
                  context.goNamed(AppRoutes.dashboardName,
                      extra: {'initialPosition': 2});
                },
                child: LogoWidget.buildLogo(size),
                // child: Image.asset(
                //   "${commonImagePath}rabbitLogo.png",
                //   height: size.width * AppDimensions.numD11,
                //   width: size.width * AppDimensions.numD11,
                // ),
              ),
            ),
      centerTitle: false,
      titleSpacing: 0,
      size: size,
      showActions: true,
      leadingFxn: () {
        context.pop();
      },
      actionWidget: [
        if (showFilter)
          InkWell(
            onTap: () {
              if (onFilterTap != null) {
                onFilterTap!();
              }
            },
            child: commonFilterIcon(size),
          ),
        if (showFilter)
          SizedBox(
            width: size.width * AppDimensions.numD02,
          ),
        if (!hideHamburger)
          Center(
            child: InkWell(
              onTap: () {
                context.pushNamed(AppRoutes.menuName);
              },
              child: Container(
                padding: EdgeInsets.all(size.width * AppDimensions.numD025),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius:
                      BorderRadius.circular(size.width * AppDimensions.numD035),
                ),
                child: Image.asset(
                  'assets/icons/menu3.png',
                  width: size.width * AppDimensions.numD06,
                  height: size.width * AppDimensions.numD06,
                ),
              ),
            ),
          ),
        SizedBox(
          width: size.width * AppDimensions.numD04,
        )
      ],
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(size.width * AppDimensions.numD15 +
      (bottom?.preferredSize.height ??
          0)); // Adjust height as per NewCommonAppBar
}
