import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:presshop/core/services/background_location_service.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/utils/ui_utils.dart';
import 'package:presshop/core/constants/app_dimensions.dart';
import 'package:presshop/core/theme/app_colors.dart';

class TaskGrabbingScreen extends StatefulWidget {
  const TaskGrabbingScreen({Key? key}) : super(key: key);

  @override
  State<TaskGrabbingScreen> createState() => _TaskGrabbingScreenState();
}

class _TaskGrabbingScreenState extends State<TaskGrabbingScreen> {
  bool isServiceRunning = false;
  Timer? _statusCheckTimer;

  // Keys from old CommonSharedPrefrence.dart
  static const customLocationHeadingKey = "custom_location_heading";
  static const customLocationDescriptionKey = "custom_location_description";
  static const customPopupImageKey = "custom_popup_image";
  static const isCustomLocationPopupKey = "is_custom_location_popup";
  static const locationSharingDescriptionKey = "location_sharing_description";

  @override
  void initState() {
    super.initState();
    _checkServiceStatus();
    _startStatusPoller();
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  void _startStatusPoller() {
    _stopStatusPoller();
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkServiceStatus();
    });
  }

  void _stopStatusPoller() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = null;
  }

  void _checkServiceStatus() async {
    try {
      debugPrint("TaskGrabbingScreen: Checking service status...");
      bool isRunning = await BackgroundLocationService.service.isRunning();
      debugPrint("TaskGrabbingScreen: Service isRunning: $isRunning");

      // Double check with SharedPreferences as fallback or confirmation
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload(); // crucial for isolate sync
      bool isActivePref = prefs.getBool('is_task_grabbing_active') ?? false;
      bool isManuallyStopped =
          prefs.getBool('manually_stopped_service') ?? false;

      debugPrint(
        "TaskGrabbingScreen: Pref is_task_grabbing_active: $isActivePref, manual: $isManuallyStopped",
      );

      if (mounted) {
        setState(() {
          if (isManuallyStopped) {
            // User explicitly stopped it. Force UI OFF.
            isServiceRunning = false;
            // Enforce: If service is actually running (zombie?), kill it.
            if (isRunning) {
              debugPrint(
                "TaskGrabbingScreen: Enforcing STOP for manually stopped service.",
              );
              BackgroundLocationService.stopService();
            }
          } else if (isActivePref) {
            isServiceRunning = true;
          } else {
            // Fallback: If service is running but no pref set, adopt it.
            isServiceRunning = isRunning;
            if (isRunning) {
              // Sync back to prefs so subsequent checks know it's active
              prefs.setBool('is_task_grabbing_active', true);
            }
          }
          debugPrint(
            "TaskGrabbingScreen: UI isServiceRunning set to: $isServiceRunning",
          );
        });
      }
    } catch (e) {
      debugPrint("TaskGrabbingScreen: Error checking service status: $e");
    }
  }

  void _onToggleService(bool value) async {
    _stopStatusPoller();
    final prefs = await SharedPreferences.getInstance();
    debugPrint(
      "TaskGrabbingScreen: Toggling service. New value: $value. Current UI state: $isServiceRunning",
    );

    try {
      if (!value) {
        // Turn OFF logic
        debugPrint("TaskGrabbingScreen: Flow -> Stop Service");

        try {
          debugPrint("TaskGrabbingScreen: Confirmed Stop Service");
          await BackgroundLocationService.stopService();

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_task_grabbing_active', false);
          await prefs.setBool('manually_stopped_service', true);
          debugPrint(
            "TaskGrabbingScreen: Saved is_task_grabbing_active = false",
          );

          if (mounted) {
            setState(() {
              isServiceRunning = false;
            });
          }
        } catch (e) {
          debugPrint("TaskGrabbingScreen: Error stopping service: $e");
        }
      } else {
        // Turn ON logic
        debugPrint("TaskGrabbingScreen: Flow -> Start Service");

        // 1. Check if Location Services are enabled
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          debugPrint("TaskGrabbingScreen: Location services are disabled.");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    "Location services are disabled.\nPlease enable them."),
                backgroundColor: Colors.red,
              ),
            );

            // Optionally open settings
            await Geolocator.openLocationSettings();
          }
          _startStatusPoller();
          return;
        }

        String? dialogTitle = prefs.getString(customLocationHeadingKey);
        String? dialogContent = prefs.getString(customLocationDescriptionKey);
        String? dialogImage = prefs.getString(customPopupImageKey);
        // bool isCustomPopup = prefs.getBool(isCustomLocationPopupKey) ?? false;

        bool started = await BackgroundLocationService.initService(
          context: context,
          showPrePermissionDialog: true, // Always show dialog for manual enable
          dialogTitle: dialogTitle ?? "Enable Task Grabbing",
          dialogContent: dialogContent, // Pass the server-provided description
          dialogImage: dialogImage, // Pass the server-provided image
          dialogButtonText: "Okay",
          dialogCancelText: "Cancel",
        );

        if (started) {
          // Save valid state
          await prefs.setBool('is_task_grabbing_active', true);
          await prefs.setBool('manually_stopped_service', false);
          debugPrint(
            "TaskGrabbingScreen: Saved is_task_grabbing_active = true",
          );

          // Give it a moment to start, then update UI state
          await Future.delayed(const Duration(milliseconds: 500));
          _checkServiceStatus();
        } else {
          debugPrint("TaskGrabbingScreen: Service start cancelled or failed.");
          // If cancelled, ensure toggle snaps back to off
          if (mounted) {
            setState(() {
              isServiceRunning = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("TaskGrabbingScreen: Error toggling service: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
      if (mounted) {
        setState(() {
          isServiceRunning = false;
        });
      }
    } finally {
      _startStatusPoller();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(
          "Location sharing",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: size.width * AppDimensions.appBarHeadingFontSize,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        size: size,
        showActions: true,
        leadingFxn: () {
          /*  if (widget.editProfileScreen) {
              widget.editProfileScreen = false;
            }*/
          Navigator.pop(context);
        },
        actionWidget: [],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.commonPaddingSize(size)),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: size.width * 0.03),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isServiceRunning
                        ? "Disable location sharing"
                        : "Enable location sharing",
                    style: commonTextStyle(
                      size: size,
                      fontSize: size.width * AppDimensions.numD036,
                      color: AppColorTheme.colorThemePink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Transform.scale(
                    scale: 1,
                    child: Switch(
                      value: isServiceRunning,
                      onChanged: _onToggleService,
                      activeColor: AppColorTheme.colorThemePink,
                      activeTrackColor: Colors.grey.shade300,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.width * 0.2),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FutureBuilder<SharedPreferences>(
                  future: SharedPreferences.getInstance(),
                  builder: (context, snapshot) {
                    String description =
                        "To send you nearby tasks that are broadcasted by the press, we need your location. If you disable your location, we can’t match you to local tasks and that means fewer chances to earn. Keep your location on to get more tasks, more stories, and more money 💰";

                    if (snapshot.hasData) {
                      String? serverDesc = snapshot.data!.getString(
                        locationSharingDescriptionKey,
                      );
                      if (serverDesc != null && serverDesc.isNotEmpty) {
                        description = serverDesc;
                      }
                    }

                    return Column(
                      children: [
                        if (isServiceRunning)
                          SizedBox(height: size.width * 0.05),
                        if (!isServiceRunning)
                          Text(
                            description,
                            style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD03,
                              color: Colors.red,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: size.width * 0.05),
          ],
        ),
      ),
    );
  }
}
