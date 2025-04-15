import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Common.dart';

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
      this.leadingLeftSPace});

  final double elevation;
  final Widget title;
  final bool centerTitle;
  final bool hideLeading;
  final double titleSpacing;
  final Size size;
  final bool showActions;
  final VoidCallback leadingFxn;
  final List<Widget>? actionWidget;
  double? leadingLeftSPace;

  @override
  State<StatefulWidget> createState() {
    return CommonAppBarState();
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CommonAppBarState extends State<CommonAppBar> {
  @override
  Widget build(BuildContext context) {
    debugPrint("LeadingLeftSpace: ${widget.leadingLeftSPace}");
    return AppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness:
            Brightness.light,
      ),
      elevation: widget.elevation,
      backgroundColor: Colors.transparent,
      leading: !widget.hideLeading
          ? InkWell(
              onTap: widget.leadingFxn,
              child: Container(
                margin: EdgeInsets.only(
                  left: widget.leadingLeftSPace ?? 0,
                  top: widget.size.width * numD01,
                ),
                padding: EdgeInsets.all(
                  widget.size.width * numD043,
                ),
                child: Image.asset(
                  "${iconsPath}ic_arrow_left.png",
                  height: widget.size.width * numD025,
                  width: widget.size.width * numD025,
                ),
              ),
            )
          : null,
      leadingWidth:
          widget.leadingLeftSPace != null && widget.leadingLeftSPace! > 0
              ? widget.size.width * numD19
              : widget.size.width * numD14,
      title: widget.title,
      centerTitle: widget.centerTitle,
      titleSpacing: widget.titleSpacing,
      automaticallyImplyLeading: false,
      actions: widget.showActions ? widget.actionWidget : null,
    );
  }


}
