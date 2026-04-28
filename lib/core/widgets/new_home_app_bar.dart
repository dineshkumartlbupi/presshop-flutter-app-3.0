import 'package:flutter/material.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/core/widgets/logo_widget.dart';
import 'package:presshop/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:presshop/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NewHomeAppBar({
    super.key,
    required this.size,
    this.hideLeading = false,
    this.onFilterTap,
    this.showFilter = true,
    this.bottom,
    this.appBarTitle,
    this.hideHamburger = false,
    this.appBarbackgroundColor,
    this.isFromMap = false,
    this.latitude,
    this.longitude,
    this.showLogo = true,
  });
  final Size size;
  final bool hideLeading;
  final Function()? onFilterTap;
  final bool showFilter;
  final PreferredSizeWidget? bottom;
  final String? appBarTitle;
  final bool hideHamburger;
  final Color? appBarbackgroundColor;
  final bool isFromMap;
  final double? latitude;
  final double? longitude;
  final bool showLogo;

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
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: size.width * AppDimensions.numD05,
                fontWeight: FontWeight.w700,
                fontFamily: "AirbnbCereal",
              ),
            )
          : (showLogo)
              ? Padding(
                  padding: EdgeInsets.only(
                      left: hideLeading
                          ? size.width * AppDimensions.numD018
                          : 0),
                  child: InkWell(
                    onTap: () {
                      print("logo tapped");
                      try {
                        context
                            .read<DashboardBloc>()
                            .add(const ChangeDashboardTabEvent(2));
                      } catch (e) {
                        context.goNamed(AppRoutes.dashboardName,
                            extra: {'initialPosition': 2});
                      }
                    },
                    child: LogoWidget.buildLogo(size),
                  ),
                )
              : const SizedBox.shrink(),
      centerTitle: false,
      titleSpacing: 0,
      size: size,
      showActions: true,
      leadingFxn: () {
        context.pop();
      },
      actionWidget: [
        // if (showFilter)
        //   InkWell(
        //     onTap: () {
        //       if (onFilterTap != null) {
        //         onFilterTap!();
        //       }
        //     },
        //     child: commonFilterIcon(size),
        //   ),
        if (showFilter)
          SizedBox(
            width: size.width * AppDimensions.numD02,
          ),
        if (!hideHamburger)
          Center(
              child: GestureDetector(
                  onTap: () {
                    context.pushNamed(AppRoutes.newsName,
                        extra: {
                          'hideFilters': true,
                          'fromMap': isFromMap,
                          'latitude': latitude,
                          'longitude': longitude
                        });
                  },
                  child: Text(
                    "Click to view local news",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.w500,
                      fontSize: size.width * 0.03,
                      decoration: TextDecoration.underline,
                    ),
                  ))),
        if (!hideHamburger)
          Center(
            child: InkWell(
              onTap: () {
                // context.pushNamed(AppRoutes.menuName);
                    context.pushNamed(AppRoutes.newsName,
                        extra: {
                          'fromMap': isFromMap,
                          'latitude': latitude,
                          'longitude': longitude
                        });
              },
              child: Container(
                padding: EdgeInsets.all(size.width * AppDimensions.numD025),
                decoration: BoxDecoration(
                  // color: Colors.grey.shade200,
                  borderRadius:
                      BorderRadius.circular(size.width * AppDimensions.numD035),
                ),
                child: Image.asset(
                  // 'assets/icons/menu3.png',
                  'assets/icons/ic_news2.png',
                  width: size.width * AppDimensions.numD06,
                  height: size.width * AppDimensions.numD06,
                ),
              ),
            ),
          ),
        if (hideHamburger)
          Padding(
            padding: EdgeInsets.only(right: size.width * AppDimensions.numD02),
            child: InkWell(
              onTap: () {
                try {
                  context
                      .read<DashboardBloc>()
                      .add(const ChangeDashboardTabEvent(2));
                } catch (e) {
                  context.goNamed(AppRoutes.dashboardName,
                      extra: {'initialPosition': 2});
                }
              },
              child: LogoWidget.buildLogo(size),
            ),
          ),
        if (showFilter)
          InkWell(
            onTap: () {
              if (onFilterTap != null) {
                onFilterTap!();
              }
            },
            child: commonFilterIcon(size),
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
