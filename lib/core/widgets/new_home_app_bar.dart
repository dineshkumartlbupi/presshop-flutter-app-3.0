import 'package:flutter/material.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/features/menu/presentation/pages/menu_screen.dart';
import 'package:presshop/features/dashboard/presentation/pages/Dashboard.dart';

class NewHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NewHomeAppBar({
    Key? key,
    required this.size,
    this.hideLeading = false,
    this.onFilterTap,
    this.showFilter = true,
    this.bottom,
  }) : super(key: key);
  final Size size;
  final bool hideLeading;
  final Function()? onFilterTap;
  final bool showFilter;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      elevation: 0,
      hideLeading: hideLeading,
      title: Padding(
        padding: EdgeInsets.only(left: hideLeading ? size.width * AppDimensions.numD04 : 0),
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => Dashboard(initialPosition: 2)),
                (route) => false);
          },
          child: Image.asset(
            "${commonImagePath}rabbitLogo.png",
            height: size.width * AppDimensions.numD11,
            width: size.width * AppDimensions.numD11,
          ),
        ),
      ),
      centerTitle: false,
      titleSpacing: 0,
      size: size,
      showActions: true,
      leadingFxn: () {
        Navigator.pop(context);
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
        Center(
          child: InkWell(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => MenuScreen()));
            },
            child: Container(
              padding: EdgeInsets.all(size.width * AppDimensions.numD025),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(size.width * AppDimensions.numD035),
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
