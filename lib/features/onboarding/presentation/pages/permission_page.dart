import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:presshop/core/core_export.dart';
import 'package:go_router/go_router.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage>
    with WidgetsBindingObserver {
  Map<Permission, PermissionStatus> statuses = {};

  final List<PermissionInfo> _permissions = [
    PermissionInfo(
      permission: Permission.location,
      title: "Location",
      description: "Required to find latest news and alerts near you.",
      icon: Icons.location_on_outlined,
    ),
    PermissionInfo(
      permission: Permission.camera,
      title: "Camera",
      description: "Required to capture and upload news content.",
      icon: Icons.camera_alt_outlined,
    ),
    PermissionInfo(
      permission: Permission.notification,
      title: "Notifications",
      description: "Stay updated with real-time alerts and news.",
      icon: Icons.notifications_none_outlined,
    ),
    PermissionInfo(
      permission: Permission.microphone,
      title: "Microphone",
      description: "Required for recording audio and videos.",
      icon: Icons.mic_none_outlined,
    ),
    PermissionInfo(
      permission: Permission.photos,
      title: "Gallery",
      description: "Required to upload content from your phone.",
      icon: Icons.photo_library_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  bool get _allRequiredGranted {
    return _permissions
        .every((p) => statuses[p.permission]?.isGranted ?? false);
  }

  Future<void> _checkPermissions() async {
    for (var p in _permissions) {
      statuses[p.permission] = await p.permission.status;
    }
    if (mounted) {
      if (_allRequiredGranted) {
        context.goNamed(AppRoutes.dashboardName);
      } else {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    "${commonImagePath}rabbitLogo.png",
                    height: size.width * 0.12,
                    width: size.width * 0.12,
                  ),
                  const SizedBox.shrink(),
                ],
              ),
              SizedBox(height: size.height * 0.03),
              Text(
                "Permissions",
                style: commonTextStyle(
                  size: size,
                  fontSize: size.width * 0.08,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                "Please enable following permissions to have a better experience.",
                style: commonTextStyle(
                  fontWeight: FontWeight.w500,
                  size: size,
                  fontSize: size.width * 0.038,
                  color: Colors.grey[600]!,
                ),
              ),
              SizedBox(height: size.height * 0.04),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _permissions.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: size.height * 0.015),
                  itemBuilder: (context, index) {
                    final item = _permissions[index];
                    final status = statuses[item.permission];
                    final isGranted = status?.isGranted ?? false;
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                        vertical: size.width * 0.03,
                      ),
                      decoration: BoxDecoration(
                        color: isGranted
                            ? Colors.green.withOpacity(0.03)
                            : Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isGranted
                              ? Colors.green.withOpacity(0.2)
                              : Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isGranted
                                  ? Colors.green.withOpacity(0.1)
                                  : AppColorTheme.colorThemePink
                                      .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.icon,
                              size: 20,
                              color: isGranted
                                  ? Colors.green
                                  : AppColorTheme.colorThemePink,
                            ),
                          ),
                          SizedBox(width: size.width * 0.04),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: commonTextStyle(
                                    color: Colors.black,
                                    size: size,
                                    fontSize: size.width * 0.04,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  item.description,
                                  style: commonTextStyle(
                                    size: size,
                                    fontWeight: FontWeight.w500,
                                    fontSize: size.width * 0.032,
                                    color: Colors.grey[600]!,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isGranted)
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 24)
                          else
                            InkWell(
                              onTap: () async {
                                final result = await item.permission.request();
                                setState(() {
                                  statuses[item.permission] = result;
                                });
                                if (result.isPermanentlyDenied) {
                                  openAppSettings();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColorTheme.colorThemePink,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "Allow",
                                  style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * 0.03,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: size.height * 0.03),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_allRequiredGranted) {
                        context.goNamed(AppRoutes.dashboardName);
                      } else {
                        // ScaffoldMessenger.of(context)
                        //     .showSnackBar(const SnackBar(
                        //   content: Text(
                        //       "Please allow Location and Camera permissions to proceed."),
                        //   backgroundColor: Colors.redAccent,
                        // ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _allRequiredGranted
                          ? AppColorTheme.colorThemePink
                          : Colors.grey[400],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Allow all & Continue",
                      style: commonTextStyle(
                        size: size,
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PermissionInfo {
  PermissionInfo({
    required this.permission,
    required this.title,
    required this.description,
    required this.icon,
  });
  final Permission permission;
  final String title;
  final String description;
  final IconData icon;
}
