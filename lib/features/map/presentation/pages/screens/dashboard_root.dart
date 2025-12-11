import 'package:flutter/material.dart';

import 'package:presshop/core/core_export.dart';
import 'package:presshop/features/map/presentation/pages/screens/marketplace_screen.dart';
import 'package:presshop/features/map/presentation/pages/widgets/custom_app_bar.dart';

class DashboardRoot extends StatefulWidget {
  const DashboardRoot({super.key});

  @override
  State<DashboardRoot> createState() => _DashboardRootState();
}

class _DashboardRootState extends State<DashboardRoot> {
  int _selectedIndex = 4; // Default - Map tab

  final List<Widget> _screens = const [
    MarketplaceScreen(),
    MarketplaceScreen(),
    MarketplaceScreen(),
    MarketplaceScreen(),
    MarketplaceScreen(),
  ];

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: _screens[_selectedIndex],
      // bottomNavigationBar: CustomBottomNavBar(
      //   currentIndex: _selectedIndex,
      //   onTabChange: _onTabChange,
      // ),
      appBar: const CustomMapAppBar(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        unselectedItemColor: Colors.black,
        selectedItemColor: colorThemePink,
        elevation: 0,
        iconSize: size.width * numD05,
        selectedFontSize: size.width * numD03,
        unselectedFontSize: size.width * numD03,
        type: BottomNavigationBarType.fixed,
        onTap: _onTabChange,
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage("${iconsPath}ic_content.png")),
            label: contentText,
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage("${iconsPath}ic_task.png")),
            label: taskText,
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage("${iconsPath}ic_camera.png")),
            label: cameraText,
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage("${iconsPath}ic_chat.png")),
            label: chatText,
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage("${iconsPath}ic_menu.png")),
            label: menuText,
          ),
        ],
      ),
    );
  }
}
