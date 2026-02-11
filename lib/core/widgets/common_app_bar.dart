import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presshop/core/constants/app_assets.dart';
import 'package:presshop/core/constants/app_dimensions.dart';
import 'package:presshop/core/utils/ui_utils.dart';
import 'package:presshop/main.dart';

const double kToolbarHeightIpad = 80.0; // Define the iPad toolbar height

// ignore: must_be_immutable
class CommonAppBar extends StatefulWidget implements PreferredSizeWidget {
  CommonAppBar(
      {super.key,
      required this.elevation,
      required this.title,
      required this.centerTitle,
      required this.titleSpacing,
      required this.size,
      required this.showActions,
      required this.leadingFxn,
      required this.actionWidget,
      required this.hideLeading,
      this.leadingLeftSPace,
      this.appBarbackgroundColor = Colors.transparent,
      this.leadingIconColor = Colors.black,
      this.bottom});

  final double elevation;
  final Widget title;
  final bool centerTitle;
  final bool hideLeading;
  final double titleSpacing;
  final Size size;
  final Color leadingIconColor;
  final Color appBarbackgroundColor;
  final bool showActions;
  final VoidCallback leadingFxn;
  final List<Widget>? actionWidget;
  double? leadingLeftSPace;
  final PreferredSizeWidget? bottom;

  @override
  State<StatefulWidget> createState() {
    return CommonAppBarState();
  }

  @override
  Size get preferredSize =>
      Size.fromHeight((sharedPreferences?.getBool('isIpad') ?? false
              ? kToolbarHeightIpad
              : kToolbarHeight) +
          (bottom?.preferredSize.height ?? 0));
}

class CommonAppBarState extends State<CommonAppBar> {
  @override
  Widget build(BuildContext context) {
    //debugPrint("LeadingLeftSpace: ${widget.leadingLeftSPace}");
    return isIpad
        ? AppBar(
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
            backgroundColor: widget.appBarbackgroundColor == Colors.transparent
                ? Colors.white
                : widget.appBarbackgroundColor,
            elevation: 8,
            title: widget.title,
            titleSpacing: widget.hideLeading
                ? 0
                : widget.size.width * AppDimensions.numD03,
            centerTitle: widget.centerTitle,
            titleTextStyle: TextStyle(
              fontSize: widget.size.width * AppDimensions.numD015,
              color: Colors.black,
            ),
            automaticallyImplyLeading: false,
            actions: widget.showActions ? widget.actionWidget : null,
            bottom: widget.bottom,
            leading: widget.hideLeading
                ? null
                : IconButton(
                    onPressed: widget.leadingFxn,
                    icon: Icon(
                      Icons.arrow_back_sharp,
                      size: widget.size.width * AppDimensions.numD04,
                      color: widget.leadingIconColor,
                    )),
          )
        : AppBar(
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
            elevation: widget.elevation,
            backgroundColor: widget.appBarbackgroundColor,
            leading: !widget.hideLeading
                ? InkWell(
                    onTap: widget.leadingFxn,
                    child: Container(
                      margin: EdgeInsets.only(
                        left: widget.leadingLeftSPace ?? 0,
                        top: widget.size.width * AppDimensions.numD01,
                      ),
                      padding: EdgeInsets.all(
                        widget.size.width * AppDimensions.numD043,
                      ),
                      child: Image.asset(
                        "${iconsPath}ic_arrow_left.png",
                        height: widget.size.width * AppDimensions.numD025,
                        width: widget.size.width * AppDimensions.numD025,
                        color: widget.leadingIconColor,
                      ),
                    ),
                  )
                : null,
            leadingWidth:
                widget.leadingLeftSPace != null && widget.leadingLeftSPace! > 0
                    ? widget.size.width * AppDimensions.numD19
                    : widget.size.width * AppDimensions.numD14,
            title: widget.title,
            centerTitle: widget.centerTitle,
            titleSpacing: widget.titleSpacing,
            automaticallyImplyLeading: false,
            actions: widget.showActions ? widget.actionWidget : null,
            bottom: widget.bottom,
          );
  }
}
