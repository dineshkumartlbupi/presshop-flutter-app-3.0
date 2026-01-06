import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:presshop/utils/CommonSharedPrefrence.dart';
import 'package:presshop/view/menuScreen/MenuScreen.dart';
import 'package:presshop/view/menuScreen/Notification/MyNotifications.dart';

import 'package:presshop/utils/Common.dart';

/// ================= HEIGHT CONSTANTS =================
/// These match actual content, not random numbers
const double _headerHeight = 80;
const double _tabsHeight = 20;

class CommonAppBarNew2 extends StatefulWidget implements PreferredSizeWidget {
  const CommonAppBarNew2({
    super.key,
    this.showMediaTabs = false,
  });

  final bool showMediaTabs;

  @override
  Size get preferredSize => Size.fromHeight(
        _headerHeight + (showMediaTabs ? _tabsHeight : 0),
      );

  @override
  State<CommonAppBarNew2> createState() => _CommonAppBarNewState();
}

class _CommonAppBarNewState extends State<CommonAppBarNew2> {
  String firstName = "Guest";
  String profileImage = "";
  late final String greeting;

  @override
  void initState() {
    super.initState();
    greeting = _getGreeting();
    _loadUserData();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning!";
    if (hour < 17) return "Good Afternoon!";
    return "Good Evening!";
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      firstName = prefs.getString(firstNameKey) ?? "Guest";
      profileImage = prefs.getString(profileImageKey) ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),

      /// ================= HEADER =================
      title: _Header(
        firstName: firstName,
        profileImage: profileImage,
        greeting: greeting,
        size: size,
      ),

      /// ================= MEDIA TABS =================
      bottom: widget.showMediaTabs
          ? PreferredSize(
              preferredSize: Size.fromHeight(_tabsHeight),
              child: _MediaTabs(size: size),
            )
          : null,
    );
  }
}

/// ================= HEADER =================

class _Header extends StatelessWidget {
  final String firstName;
  final String profileImage;
  final String greeting;
  final Size size;

  const _Header({
    required this.firstName,
    required this.profileImage,
    required this.greeting,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: size.width * numD055, // approx 20-22
          backgroundImage:
              profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
          backgroundColor: Colors.grey.shade300,
          child: profileImage.isEmpty
              ? Icon(Icons.person,
                  color: Colors.grey, size: size.width * numD06)
              : null,
        ),
        SizedBox(width: size.width * numD03),

        /// Name + greeting
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Hello ",
                    style: TextStyle(
                      fontSize: size.width * numD04,
                      fontWeight: FontWeight.w400, // thin
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: "$firstName,",
                    style: TextStyle(
                      fontSize: size.width * numD04,
                      fontWeight: FontWeight.w700, // bold
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              greeting,
              style: TextStyle(
                fontSize: size.width * numD025,
                fontWeight: FontWeight.w400,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),

        const Spacer(),

        _iconButton(
          Image.asset(
            'assets/icons/notification.png',
            width: size.width * numD06,
            height: size.width * numD06,
          ),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MyNotificationScreen(count: 0),
              ),
            );
          },
          false,
          size,
        ),
        SizedBox(width: size.width * numD025),

        _iconButton(
          Image.asset(
            'assets/icons/menu1.png',
            width: size.width * numD06,
            height: size.width * numD06,
          ),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MenuScreen()),
            );
          },
          true,
          size,
        ),
      ],
    );
  }

  static Widget _iconButton(
      Widget icon, VoidCallback onTap, bool isBgColor, Size size) {
    return InkWell(
      borderRadius: BorderRadius.circular(size.width * numD035),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(size.width * numD025),
        decoration: BoxDecoration(
          color: isBgColor ? Colors.grey.shade200 : Colors.transparent,
          borderRadius: BorderRadius.circular(size.width * numD035),
        ),
        child: icon,
      ),
    );
  }
}

/// ================= MEDIA TABS =================

class _MediaTabs extends StatelessWidget {
  final Size size;
  const _MediaTabs({required this.size});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: size.width * numD05,
          right: size.width * numD05,
          top: size.width * numD05,
          bottom: size.width * numD04),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _TabText('Scan', size),
          _TabText('Photo', size),
          _TabText('Video', size),
          _TabText('Audio', size),
        ],
      ),
    );
  }
}

class _TabText extends StatelessWidget {
  final String text;
  final Size size;
  const _TabText(this.text, this.size);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: size.width * numD035,
        color: Colors.black,
      ),
    );
  }
}
