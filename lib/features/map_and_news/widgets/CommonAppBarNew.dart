import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:presshop/utils/CommonSharedPrefrence.dart';
import 'package:presshop/view/menuScreen/MenuScreen.dart';
import 'package:presshop/view/menuScreen/Notification/MyNotifications.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/main.dart';

/// ================= HEIGHT CONSTANTS =================
const double _headerHeight = 80;
const double _tabsHeight = 32;
const double kToolbarHeightIpad = 80;

/// ===================================================
/// COMMON APP BAR (NEW UI + OLD FEATURES)
/// ===================================================
class CommonAppBarNew extends StatefulWidget implements PreferredSizeWidget {
  const CommonAppBarNew({
    super.key,

    /// -------- NEW ----------
    this.showMediaTabs = false,

    /// -------- OLD ----------
    this.title,
    this.centerTitle = false,
    this.elevation = 0,
    this.titleSpacing = 0,
    this.showActions = false,
    this.actionWidget,
    this.hideLeading = true,
    this.leadingFxn,
    this.leadingLeftSPace,
    this.appBarbackgroundColor = Colors.white,
    this.leadingIconColor = Colors.black,
  });

  /// ========== NEW ==========
  final bool showMediaTabs;

  /// ========== OLD ==========
  final Widget? title;
  final bool centerTitle;
  final double elevation;
  final double titleSpacing;
  final bool showActions;
  final List<Widget>? actionWidget;
  final bool hideLeading;
  final VoidCallback? leadingFxn;
  final double? leadingLeftSPace;
  final Color appBarbackgroundColor;
  final Color leadingIconColor;

  @override
  Size get preferredSize => Size.fromHeight(
        (sharedPreferences?.getBool('isIpad') ?? false)
            ? kToolbarHeightIpad + (showMediaTabs ? _tabsHeight : 0)
            : _headerHeight + (showMediaTabs ? _tabsHeight : 0),
      );

  @override
  State<CommonAppBarNew> createState() => _CommonAppBarNewState();
}

class _CommonAppBarNewState extends State<CommonAppBarNew> {
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
    final size = MediaQuery.of(context).size;
    final isIpadDevice = sharedPreferences?.getBool('isIpad') ?? false;

    return AppBar(
      elevation: widget.elevation,
      backgroundColor: widget.appBarbackgroundColor,
      automaticallyImplyLeading: false,

      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),

      /// ========== LEADING (OLD) ==========
      leading: widget.hideLeading
          ? null
          : isIpadDevice
              ? IconButton(
                  onPressed: widget.leadingFxn,
                  icon: Icon(
                    Icons.arrow_back_sharp,
                    color: widget.leadingIconColor,
                  ),
                )
              : InkWell(
                  onTap: widget.leadingFxn,
                  child: Container(
                    margin: EdgeInsets.only(
                      left: widget.leadingLeftSPace ?? 0,
                      top: size.width * numD01,
                    ),
                    padding: EdgeInsets.all(size.width * numD043),
                    child: Image.asset(
                      "${iconsPath}ic_arrow_left.png",
                      height: size.width * numD025,
                      width: size.width * numD025,
                      color: widget.leadingIconColor,
                    ),
                  ),
                ),

      leadingWidth:
          widget.leadingLeftSPace != null && widget.leadingLeftSPace! > 0
              ? size.width * numD19
              : size.width * numD14,

      /// ========== TITLE ==========
      title: widget.title ??
          _Header(
            firstName: firstName,
            profileImage: profileImage,
            greeting: greeting,
            size: size,
          ),

      titleSpacing: widget.titleSpacing,
      centerTitle: widget.centerTitle,

      /// ========== ACTIONS ==========
      actions: widget.showActions ? widget.actionWidget : null,

      /// ========== MEDIA TABS ==========
      bottom: widget.showMediaTabs
          ? PreferredSize(
              preferredSize: const Size.fromHeight(_tabsHeight),
              child: _MediaTabs(size: size),
            )
          : null,
    );
  }
}

/// ===================================================
/// HEADER (NEW UI)
/// ===================================================
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
          radius: size.width * numD055,
          backgroundImage:
              profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
          backgroundColor: Colors.grey.shade300,
          child: profileImage.isEmpty
              ? Icon(Icons.person,
                  color: Colors.grey, size: size.width * numD06)
              : null,
        ),
        SizedBox(width: size.width * numD03),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Hello $firstName,",
              style: TextStyle(
                fontSize: size.width * numD04,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Text(
              greeting,
              style: TextStyle(
                fontSize: size.width * numD035,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const Spacer(),
        _iconButton(
          Icons.notifications_none_rounded,
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
          Icons.menu_rounded,
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
      IconData icon, VoidCallback onTap, bool isBgColor, Size size) {
    return InkWell(
      borderRadius: BorderRadius.circular(size.width * numD035),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(size.width * numD025),
        decoration: BoxDecoration(
          color: isBgColor ? Colors.grey.shade200 : Colors.transparent,
          borderRadius: BorderRadius.circular(size.width * numD035),
        ),
        child: Icon(icon, size: size.width * numD06, color: Colors.black),
      ),
    );
  }
}

/// ===================================================
/// MEDIA TABS
/// ===================================================
class _MediaTabs extends StatelessWidget {
  final Size size;
  const _MediaTabs({required this.size});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * numD05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _TabText('Scan'),
          _TabText('Photo'),
          _TabText('Video'),
          _TabText('Audio'),
        ],
      ),
    );
  }
}

class _TabText extends StatelessWidget {
  final String text;
  const _TabText(this.text);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
