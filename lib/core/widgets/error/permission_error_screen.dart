
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:presshop/features/dashboard/presentation/pages/Dashboard.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_widgets.dart';

class PermissionErrorScreen extends StatefulWidget {
  Map<Permission, bool> permissionsStatus;

  PermissionErrorScreen({super.key, required this.permissionsStatus});
  @override
  _PermissionErrorScreenState createState() =>
      _PermissionErrorScreenState(permissionsStatus);
}

class _PermissionErrorScreenState extends State<PermissionErrorScreen>
    with WidgetsBindingObserver {
  Map<Permission, bool> permissionsStatus;
  _PermissionErrorScreenState(this.permissionsStatus);

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    checkPermissions();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("LifecycleState: $state");
    if (state == AppLifecycleState.inactive) {
    } else if (state == AppLifecycleState.resumed) {
      if (mounted) {
        checkPermissions();
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> checkPermissions() async {
    Map<Permission, bool> updatedStatus = {};
    for (var permission in permissionsStatus.keys) {
      updatedStatus[permission] = await permission.isGranted;
    }

    setState(() {
      permissionsStatus = updatedStatus;
    });

    var allGranted = permissionsStatus.values.every((status) => status == true);
    if (allGranted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => Dashboard(initialPosition: 2)),
            (route) => false);
      });
    }
  }

  Future<void> requestPermissions() async {
    for (var permission in permissionsStatus.keys) {
      if (!permissionsStatus[permission]!) {
        var data = await permission.request();
        if (data.isDenied || data.isPermanentlyDenied) {
          commonErrorDialogDialog(
            isFromNetworkError: false,
            actionButton: "Open Settings",
            MediaQuery.of(context).size,
            "This app needs access to your ${permission.toString().split('.').last.toTitleCase()} to provide its features. Please enable the permission in your app settings.",
            "${permission.toString().split('.').last.toTitleCase()} Permission Required",
            () {
              openAppSettings().then((value) => {Navigator.pop(context, true)});
            },
          );
        }
        break;
      }
    }

    await checkPermissions();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    // checkPermissions();
    return WillPopScope(
      onWillPop: () async {
        // Prevent back press
        return false;
      },
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(size.width * numD05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Icon(
                  Icons.lock,
                  size: 80,
                  color: Colors.red,
                ),
                SizedBox(height: size.height * numD02),
                Text(
                  'Permissions Required',
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD04,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: size.height * numD01),
                Text(
                  'We need access below permissions to continue using the app. Please allow the permissions to proceed.',
                  textAlign: TextAlign.center,
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD035,
                      color: Colors.black,
                      fontWeight: FontWeight.w400),
                ),
                SizedBox(height: size.height * numD03),
                Column(
                  spacing: size.height * numD015,
                  children: permissionsStatus.keys.map((permission) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                permission == Permission.camera
                                    ? "Camera"
                                    : permission == Permission.microphone
                                        ? "Microphone"
                                        : "Gallery",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD04,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                permission == Permission.camera
                                    ? "Allow PressHop to use the camera for taking photos and videos for news content submissions"
                                    : permission == Permission.microphone
                                        ? "Allow PressHop to record audio during video capture or interviews."
                                        : "Allow saving captured content to your device's gallery.",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD035,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          permissionsStatus[permission]!
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: permissionsStatus[permission]!
                              ? Colors.green
                              : Colors.red,
                          size: size.width * numD08,
                        ),
                        // SizedBox(
                        //   width: size.width * numD04,
                        //   child: CupertinoSwitch(
                        //     value: permissionsStatus[permission]!,
                        //     onChanged: (value) {},
                        //   ),
                        // ),
                        //),
                      ],
                    );
                  }).toList(),
                ),
                SizedBox(height: size.height * numD04),
                SizedBox(
                  height: size.width * numD12,
                  width: size.width * numD80,
                  child: commonElevatedButton(
                    "Allow Permissions",
                    size,
                    commonButtonTextStyle(size),
                    commonButtonStyle(size, colorThemePink),
                    () async {
                      await requestPermissions();
                    },
                  ),
                ),
                SizedBox(height: size.height * numD02),
                SizedBox(
                  height: size.width * numD12,
                  width: size.width * numD80,
                  child: commonElevatedButton(
                    "My Content",
                    size,
                    commonButtonTextStyle(size),
                    commonButtonStyle(size, Colors.black),
                    () async {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) =>
                                  Dashboard(initialPosition: 0)),
                          (route) => false);
                    },
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
