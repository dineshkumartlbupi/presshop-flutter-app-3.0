import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:presshop/core/constants/app_dimensions.dart';

class AlertButtonMap extends StatelessWidget {
  const AlertButtonMap({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(right: size.width * AppDimensions.numD04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
            Radius.circular(size.width * AppDimensions.numD53)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: size.width * AppDimensions.numD01,
            offset: Offset(0.0, size.width * AppDimensions.numD005),
          ),
        ],
      ),
      child: Row(
        spacing: size.width * AppDimensions.numD026,
        children: [
          Container(
            margin: EdgeInsets.only(
              left: size.width * AppDimensions.numD016,
              top: size.width * AppDimensions.numD016,
              bottom: size.width * AppDimensions.numD016,
            ),
            padding: EdgeInsets.all(size.width * AppDimensions.numD024),
            decoration: BoxDecoration(
              color: Color(0xffEC4E54),
              borderRadius:
                  BorderRadius.circular(size.width * AppDimensions.numD26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: size.width * AppDimensions.numD01,
                  offset: Offset(0.0, size.width * AppDimensions.numD005),
                ),
              ],
            ),
            child: Icon(
              LucideIcons.triangle_alert,
              color: Colors.white,
              size: size.width * AppDimensions.numD042,
            ),
          ),
          Text(
            "Share Alerts",
            style: TextStyle(
              color: Colors.black87,
              fontSize: size.width * AppDimensions.numD032,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
