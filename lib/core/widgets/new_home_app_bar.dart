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
    final double scalingWidth = isIpad ? 550 : size.width;

    return CommonAppBar(
      elevation: 0,
      hideLeading: hideLeading,
      appBarbackgroundColor: appBarbackgroundColor,
      leadingWidget: (showLogo && hideLeading)
          ? InkWell(
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
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: LogoWidget.buildLogo(size),
                ),
              ),
            )
          : null,
      title: appBarTitle != null
          ? Text(
              appBarTitle!,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: scalingWidth * AppDimensions.numD05,
                fontWeight: FontWeight.w700,
                fontFamily: "AirbnbCereal",
              ),
            )
          : (showLogo && !hideLeading)
              ? InkWell(
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
        if (!hideHamburger)
          GestureDetector(
              onTap: () {
                context.pushNamed(AppRoutes.newsName, extra: {
                  'hideFilters': true,
                  'fromMap': isFromMap,
                  'latitude': latitude,
                  'longitude': longitude
                });
              },
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  "Click to view local news",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w500,
                    fontSize: scalingWidth * AppDimensions.numD032,
                    decoration: TextDecoration.underline,
                  ),
                ),
              )),
        if (!hideHamburger)
          InkWell(
            onTap: () {
              context.pushNamed(AppRoutes.newsName, extra: {
                'fromMap': isFromMap,
                'latitude': latitude,
                'longitude': longitude
              });
            },
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(scalingWidth * AppDimensions.numD025),
              child: Image.asset(
                'assets/icons/ic_news2.png',
                color: Theme.of(context).textTheme.bodyLarge?.color ??
                    Colors.black,
                width: scalingWidth * AppDimensions.numD06,
                height: scalingWidth * AppDimensions.numD06,
              ),
            ),
          ),
        if (showFilter)
          InkWell(
            onTap: () {
              if (onFilterTap != null) {
                onFilterTap!();
              }
            },
            child: commonFilterIcon(context, Size(scalingWidth, scalingWidth)),
          ),
        SizedBox(
          width: scalingWidth * AppDimensions.numD04,
        )
      ],
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight((isIpad ? 450 : size.width) * AppDimensions.numD15 +
          (bottom?.preferredSize.height ?? 0));
}
