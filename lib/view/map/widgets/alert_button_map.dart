import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class AlertButtonMap extends StatelessWidget {
  const AlertButtonMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Row(
        spacing: 10,
        children: [
          Container(
            margin: EdgeInsets.only(left: 6, top: 6, bottom: 6),
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Color(0xffEC4E54),
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              LucideIcons.triangle_alert,
              color: Colors.white,
              size: 16,
            ),
          ),
          Text(
            "Share Alert",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
