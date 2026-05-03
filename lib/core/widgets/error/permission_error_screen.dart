import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/core/services/permission_service.dart';
import 'package:presshop/core/di/injection_container.dart';

class PermissionErrorScreen extends StatefulWidget {
  final Map<Permission, bool> permissionsStatus;

  const PermissionErrorScreen({super.key, required this.permissionsStatus});

  @override
  State<PermissionErrorScreen> createState() => _PermissionErrorScreenState();
}

class _PermissionErrorScreenState extends State<PermissionErrorScreen>
    with WidgetsBindingObserver {
  final PermissionService _permissionService = sl<PermissionService>();
  late Map<Permission, bool> _currentStatuses;
  bool _isPermanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentStatuses = Map.from(widget.permissionsStatus);
    _checkInitialState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkInitialState();
    }
  }

  Future<void> _checkInitialState() async {
    final result = await _permissionService.checkCameraAndGalleryPermissions();

    if (result == PermissionResult.granted) {
      if (mounted) {
        context.goNamed(AppRoutes.dashboardName, extra: {'initialPosition': 2});
      }
    } else {
      if (mounted) {
        setState(() {
          _isPermanentlyDenied = result == PermissionResult.permanentlyDenied;
        });
      }
    }
  }

  Future<void> _handleAction() async {
    if (_isPermanentlyDenied) {
      await _permissionService.openSettings();
    } else {
      final result =
          await _permissionService.requestCameraAndGalleryPermissions();
      if (result == PermissionResult.granted) {
        if (mounted) {
          context
              .goNamed(AppRoutes.dashboardName, extra: {'initialPosition': 2});
        }
      } else {
        if (mounted) {
          setState(() {
            _isPermanentlyDenied = result == PermissionResult.permanentlyDenied;
          });
        }
      }
    }
  }

  Widget _buildPermissionItem(Size size, String title, String description, bool isError) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: commonTextStyle(
                  size: size,
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: commonTextStyle(
                  size: size,
                  fontSize: size.width * 0.032,
                  color: Colors.grey[600]!,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Icon(
          isError ? Icons.cancel : Icons.check_circle,
          color: isError ? Colors.red : Colors.green,
          size: 28,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock,
                  size: 80,
                  color: Colors.red,
                ),
                SizedBox(height: size.height * 0.02),
                Text(
                  'Permissions Required',
                  style: commonTextStyle(
                    size: size,
                    fontSize: size.width * 0.055,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.015),
                Text(
                  'We need access below permissions to continue using the app. Please allow the permissions to proceed.',
                  textAlign: TextAlign.center,
                  style: commonTextStyle(
                    size: size,
                    fontSize: size.width * 0.038,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                
                // Permission List Items
                _buildPermissionItem(
                  size,
                  "Camera",
                  "Allow PressHop to use the camera for taking photos and videos for news content submissions",
                  true,
                ),
                SizedBox(height: size.height * 0.02),
                _buildPermissionItem(
                  size,
                  "Microphone",
                  "Allow PressHop to record audio during video capture or interviews.",
                  true,
                ),
                
                SizedBox(height: size.height * 0.05),
                
                // Buttons
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: commonElevatedButton(
                    _isPermanentlyDenied ? "Open Settings" : "Allow Permissions",
                    size,
                    commonButtonTextStyle(size),
                    commonButtonStyle(size, AppColorTheme.colorThemePink),
                    _handleAction,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: commonElevatedButton(
                    "Return to Feed",
                    size,
                    commonButtonTextStyle(size),
                    commonButtonStyle(size, Colors.black),
                    () {
                      context.goNamed(AppRoutes.dashboardName, extra: {'initialPosition': 0});
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
