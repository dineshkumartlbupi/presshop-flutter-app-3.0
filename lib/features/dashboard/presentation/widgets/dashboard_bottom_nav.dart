import 'package:flutter/material.dart';
import 'package:presshop/core/core_export.dart';

class DashboardBottomNavBar extends StatelessWidget {

  const DashboardBottomNavBar({
    super.key,
    required this.size,
    required this.currentIndex,
    required this.onTap,
  });
  final Size size;
  final int currentIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
          Theme.of(context).cardColor,
      currentIndex: currentIndex,
      showUnselectedLabels: true,
      showSelectedLabels: true,
      unselectedItemColor: Theme.of(context).unselectedWidgetColor,
      selectedItemColor: AppColorTheme.colorThemePink,
      elevation: 0,
      iconSize: size.width * AppDimensions.numD05,
      selectedFontSize: size.width * AppDimensions.numD03,
      unselectedFontSize: size.width * AppDimensions.numD03,
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
      items: [
        const BottomNavigationBarItem(
          icon: ImageIcon(AssetImage("assets/icons/ic_content1.png")),
          label: "Content",
        ),
        const BottomNavigationBarItem(
          icon: ImageIcon(AssetImage("assets/icons/ic_task1.png")),
          label: "Tasks",
        ),
        BottomNavigationBarItem(
          icon: Transform.scale(
            scale: 1.3,
            child: const ImageIcon(AssetImage("assets/icons/ic_camera1.png")),
          ),
          label: "Camera",
        ),
        const BottomNavigationBarItem(
          icon: ImageIcon(AssetImage("assets/icons/ic_alert2.png")),
          label: "Alerts",
        ),
        BottomNavigationBarItem(
          icon: Transform.scale(
              scale: 1.2,
              child: ImageIcon(AssetImage("assets/icons/menu3.png"))),
          label: "Menu",
        ),
      ],
    );
  }
}
