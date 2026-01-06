import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:presshop/core/constants/app_dimensions.dart';

class AlertButtonMap extends StatelessWidget {
  const AlertButtonMap({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(right: size.width * numD04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(size.width * numD53)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: size.width * numD01,
            offset: Offset(0.0, size.width * numD005),
          ),
        ],
      ),
      child: Row(
        spacing: size.width * numD026,
        children: [
          Container(
            margin: EdgeInsets.only(
              left: size.width * numD016,
              top: size.width * numD016,
              bottom: size.width * numD016,
            ),
            padding: EdgeInsets.all(size.width * numD024),
            decoration: BoxDecoration(
              color: Color(0xffEC4E54),
              borderRadius: BorderRadius.circular(size.width * numD26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: size.width * numD01,
                  offset: Offset(0.0, size.width * numD005),
                ),
              ],
            ),
            child: Icon(
              LucideIcons.triangle_alert,
              color: Colors.white,
              size: size.width * numD042,
            ),
          ),
          Text(
            "Share Alert",
            style: TextStyle(
              color: Colors.black87,
              fontSize: size.width * numD032,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
