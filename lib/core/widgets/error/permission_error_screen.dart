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
  Map<Permission, bool> _currentStatuses = {};
  bool _isPermanentlyDenied = false;
  bool _isGalleryGranted = false;

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
    final cameraStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;
    final isGalleryGranted =
        await _permissionService.checkCameraAndGalleryPermissions() ==
            PermissionResult.granted;

    if (mounted) {
      setState(() {
        _currentStatuses[Permission.camera] = cameraStatus.isGranted;
        _currentStatuses[Permission.microphone] = micStatus.isGranted;
        _isGalleryGranted = isGalleryGranted;
      });
    }

    final detail = await _permissionService.getDetailedStatus();

    if (detail.cameraAndGalleryGranted) {
      if (mounted) {
        context.goNamed(AppRoutes.dashboardName, extra: {'initialPosition': 2});
      }
    } else {
      if (mounted) {
        setState(() {
          _isPermanentlyDenied = detail.isAnyPermanentlyDenied;
        });
      }
    }
  }

  Future<void> _handleAction() async {
    if (_isPermanentlyDenied) {
      await _permissionService.openSettings();
    } else {
      await _permissionService.requestCameraAndGalleryPermissions();
      final detail = await _permissionService.getDetailedStatus();
      
      if (detail.cameraAndGalleryGranted) {
        if (mounted) {
          context
              .goNamed(AppRoutes.dashboardName, extra: {'initialPosition': 2});
        }
      } else {
        if (mounted) {
          setState(() {
            _isPermanentlyDenied = detail.isAnyPermanentlyDenied;
          });
        }
      }
    }
  }

  Widget _buildPermissionItem(
      Size size, String title, String description, bool isError) {
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
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: commonTextStyle(
                  size: size,
                  fontSize: size.width * 0.032,
                  color: Theme.of(context).textTheme.bodySmall?.color ??
                      Colors.grey[600]!,
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: size.height * 0.015),
                Text(
                  'We need access below permissions to continue using the app. Please allow the permissions to proceed.',
                  textAlign: TextAlign.center,
                  style: commonTextStyle(
                    size: size,
                    fontSize: size.width * 0.038,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: size.height * 0.04),

                // Permission List Items
                _buildPermissionItem(
                  size,
                  "Camera",
                  "Allow PressHop to use the camera for taking photos and videos for news content submissions",
                  !(_currentStatuses[Permission.camera] ?? false),
                ),
                SizedBox(height: size.height * 0.02),
                _buildPermissionItem(
                  size,
                  "Microphone",
                  "Allow PressHop to record audio during video capture or interviews.",
                  !(_currentStatuses[Permission.microphone] ?? false),
                ),
                SizedBox(height: size.height * 0.02),
                _buildPermissionItem(
                  size,
                  "Photos & Gallery",
                  "Allow PressHop to access your gallery to upload existing photos and videos.",
                  !_isGalleryGranted,
                ),

                SizedBox(height: size.height * 0.05),

                // Buttons
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: commonElevatedButton(
                    _isPermanentlyDenied
                        ? "Open Settings"
                        : "Allow Permissions",
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
                    "My Content",
                    size,
                    commonButtonTextStyle(size,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white),
                    commonButtonStyle(
                        size,
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black),
                    () {
                      context.goNamed(AppRoutes.dashboardName,
                          extra: {'initialPosition': 0});
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
