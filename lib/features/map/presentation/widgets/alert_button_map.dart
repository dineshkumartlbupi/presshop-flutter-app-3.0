import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:presshop/core/constants/app_dimensions.dart';
import 'package:presshop/core/utils/ui_utils.dart';

class AlertButtonMap extends StatelessWidget {
  const AlertButtonMap({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double scalingWidth = isIpad ? 550 : size.width;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.all(
            Radius.circular(scalingWidth * AppDimensions.numD53)),
        border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white12
                : Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: scalingWidth * AppDimensions.numD02,
            offset: Offset(0.0, scalingWidth * AppDimensions.numD005),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(
              left: scalingWidth * AppDimensions.numD016,
              top: scalingWidth * AppDimensions.numD016,
              bottom: scalingWidth * AppDimensions.numD016,
            ),
            padding: EdgeInsets.all(scalingWidth * AppDimensions.numD024),
            decoration: BoxDecoration(
              color: const Color(0xffEC4E54),
              borderRadius:
                  BorderRadius.circular(scalingWidth * AppDimensions.numD10),
            ),
            child: Icon(
              LucideIcons.triangle_alert,
              color: Colors.white,
              size: scalingWidth * AppDimensions.numD042,
            ),
          ),
          SizedBox(width: scalingWidth * AppDimensions.numD016),
          Text(
            "Share Alerts",
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: scalingWidth * AppDimensions.numD032,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: scalingWidth * AppDimensions.numD02),
        ],
      ),
    );
  }
}
