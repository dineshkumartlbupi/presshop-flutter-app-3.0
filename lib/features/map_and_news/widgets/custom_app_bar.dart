import 'package:flutter/material.dart';
import 'package:presshop/utils/CommonSharedPrefrence.dart';
import 'package:presshop/view/menuScreen/MenuScreen.dart';
import 'package:presshop/view/menuScreen/Notification/MyNotifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomMapAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomMapAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  State<CustomMapAppBar> createState() => _CustomMapAppBarState();
}

class _CustomMapAppBarState extends State<CustomMapAppBar> {
  String firstName = "";
  String profileImage = "";
  String greeting = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setGreeting();
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        firstName = prefs.getString(firstNameKey) ?? "Guest";
        profileImage = prefs.getString(profileImageKey) ?? "";
      });
    }
  }

  void _setGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      greeting = 'Good Morning!';
    } else if (hour < 17) {
      greeting = 'Good Afternoon!';
    } else {
      greeting = 'Good Evening!';
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: (profileImage.isNotEmpty)
                      ? NetworkImage(profileImage)
                      : null,
                  backgroundColor: Colors.grey.shade300,
                  child: (profileImage.isEmpty)
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: 'Hello ',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87),
                        children: [
                          TextSpan(
                            text: '$firstName,',
                            style: TextStyle(fontWeight: FontWeight.values[5]),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      greeting,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
                const Spacer(),
                _notificationButton(Icons.notifications_none_rounded,
                    onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyNotificationScreen(
                                count: 10,
                              )));
                }),
                const SizedBox(width: 10),
                _menuButton(Icons.menu_rounded, onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MenuScreen()));
                }),
              ],
            ),

            const SizedBox(height: 15),

            // Tabs row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text(
                  'Scan',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                ),
                Text(
                  'Photo',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                ),
                Text(
                  'Video',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                ),
                Text(
                  'Audio',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _notificationButton(
    IconData icon, {
    required VoidCallback onPressed,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  static Widget _menuButton(
    IconData icon, {
    required VoidCallback onPressed,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}
