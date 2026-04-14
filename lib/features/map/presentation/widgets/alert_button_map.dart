import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:presshop/core/constants/app_dimensions.dart';

class AlertButtonMap extends StatelessWidget {
  const AlertButtonMap({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: size.width * AppDimensions.numD016,
          vertical: size.width * AppDimensions.numD01),
      decoration: BoxDecoration(
        color: const Color(0xffEC4E54),
        borderRadius: BorderRadius.all(
            Radius.circular(size.width * AppDimensions.numD53)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: size.width * AppDimensions.numD02,
            offset: Offset(0.0, size.width * AppDimensions.numD005),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(size.width * AppDimensions.numD018),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.triangle_alert,
              color: Colors.white,
              size: size.width * AppDimensions.numD04,
            ),
          ),
          SizedBox(width: size.width * AppDimensions.numD02),
          Text(
            "Share Alerts",
            style: TextStyle(
              color: Colors.white,
              fontSize: size.width * AppDimensions.numD035,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: size.width * AppDimensions.numD02),
        ],
      ),
    );
  }
}
