import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      this.appBarbackgroundColor,
      this.leadingIconColor,
      this.leadingWidget,
      this.bottom});

  final double elevation;
  final Widget title;
  final bool centerTitle;
  final bool hideLeading;
  final double titleSpacing;
  final Size size;
  final Color? leadingIconColor;
  final Color? appBarbackgroundColor;
  final bool showActions;
  final VoidCallback leadingFxn;
  final List<Widget>? actionWidget;
  double? leadingLeftSPace;
  final Widget? leadingWidget;
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
    final double scalingWidth = isIpad ? 550 : widget.size.width;

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
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            title: widget.title,
            titleSpacing:
                widget.hideLeading ? 0 : scalingWidth * AppDimensions.numD03,
            centerTitle: widget.centerTitle,
            titleTextStyle: TextStyle(
              fontSize: scalingWidth * AppDimensions.numD015,
              color: Colors.black,
            ),
            automaticallyImplyLeading: false,
            leadingWidth: widget.leadingWidget != null
                ? scalingWidth * AppDimensions.numD19
                : (widget.leadingLeftSPace != null &&
                        widget.leadingLeftSPace! > 0
                    ? scalingWidth * AppDimensions.numD19
                    : scalingWidth * AppDimensions.numD12),
            actions: widget.showActions ? widget.actionWidget : null,
            bottom: widget.bottom,
            leading: widget.leadingWidget ??
                (widget.hideLeading
                    ? null
                    : IconButton(
                        onPressed: widget.leadingFxn,
                        icon: Icon(
                          Icons.arrow_back_sharp,
                          size: scalingWidth * AppDimensions.numD04,
                          color: widget.leadingIconColor,
                        ))),
          )
        : AppBar(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  Theme.of(context).brightness == Brightness.dark
                      ? Brightness.light
                      : Brightness.dark,
              statusBarBrightness: Theme.of(context).brightness,
            ),
            elevation: widget.elevation,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            backgroundColor: widget.appBarbackgroundColor ??
                Theme.of(context).appBarTheme.backgroundColor,
            leading: widget.leadingWidget ??
                (!widget.hideLeading
                    ? InkWell(
                        onTap: widget.leadingFxn,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(
                            left: widget.leadingLeftSPace ??
                                widget.size.width * AppDimensions.numD025,
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            size: widget.size.width * AppDimensions.numD06,
                            color: widget.leadingIconColor ??
                                Theme.of(context).iconTheme.color,
                          ),
                        ),
                      )
                    : null),
            leadingWidth: widget.leadingWidget != null
                ? widget.size.width * AppDimensions.numD19
                : (widget.leadingLeftSPace != null &&
                        widget.leadingLeftSPace! > 0
                    ? widget.size.width * AppDimensions.numD19
                    : widget.size.width * AppDimensions.numD12),
            title: widget.title,
            centerTitle: widget.centerTitle,
            titleSpacing: widget.titleSpacing,
            automaticallyImplyLeading: false,
            actions: widget.showActions ? widget.actionWidget : null,
            bottom: widget.bottom,
          );
  }
}
