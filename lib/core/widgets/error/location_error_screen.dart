import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:presshop/core/widgets/common_widgets.dart';

import 'package:presshop/core/core_export.dart';
import 'package:go_router/go_router.dart';

class LocationErrorScreen extends StatefulWidget {
  const LocationErrorScreen({super.key});

  @override
  _LocationErrorScreenState createState() => _LocationErrorScreenState();
}

class _LocationErrorScreenState extends State<LocationErrorScreen>
    with WidgetsBindingObserver {
  double latitude = 22.5744, longitude = 88.3629;
  late LocationService _locationService;
  bool isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _locationService = LocationService();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionAndAutoPop();
    }
  }

  Future<void> _checkPermissionAndAutoPop() async {
    final status = await Permission.location.status;
    if (status.isGranted || status.isLimited) {
      debugPrint(
          "🚀 LocationErrorScreen: Permission detected on resume. Fetching location...");
      _fetchLocation();
    }
  }

  Future<void> _fetchLocation() async {
    if (isFetchingLocation) return;
    setState(() {
      isFetchingLocation = true;
    });

    try {
      final locationData = await _locationService.getCurrentLocation(context);
      if (locationData != null && mounted) {
        context.pop(locationData);
      }
    } catch (e) {
      debugPrint("Error fetching location on auto-pop: $e");
    } finally {
      if (mounted) {
        setState(() {
          isFetchingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * AppDimensions.numD05),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () {
                      context.goNamed(AppRoutes.dashboardName,
                          extra: {'initialPosition': 0});
                    },
                    icon: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          shape: BoxShape.circle),
                      child: Icon(
                        Icons.close,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
                        size: size.width * AppDimensions.numD06,
                      ),
                    ),
                  ),
                ),
                Spacer(),
                Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * AppDimensions.numD04,
                        vertical: size.width * AppDimensions.numD04),
                    decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColorTheme.colorDarkThemeCard
                            : AppColorTheme.colorLightGrey,
                        borderRadius: BorderRadius.circular(
                            size.width * AppDimensions.numD04)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(
                                size.width * AppDimensions.numD06),
                            child: Image.asset(
                                "assets/rabbits/update_rabbit.png",
                                height: size.width * AppDimensions.numD30,
                                width: size.width * AppDimensions.numD30,
                                fit: BoxFit.cover)),
                        SizedBox(width: size.width * AppDimensions.numD05),
                        Flexible(
                          child: Text(
                            'Oops! We’ll need access to your location before you can proceed.',
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD04,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    )),
                SizedBox(height: size.height * AppDimensions.numD04),
                Text(
                  'Note: The press needs to know where a photo or video was taken, and without your location, we can’t submit and help sell your content. Pop it on and you’re good to go!',
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * AppDimensions.numD035,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.w400),
                ),
                SizedBox(height: size.height * AppDimensions.numD04),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: size.width * AppDimensions.numD12,
                      width: size.width * AppDimensions.numD44,
                      child: commonElevatedButton(
                        "Back",
                        size,
                        commonButtonTextStyle(size,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.black
                                    : Colors.white),
                        commonButtonStyle(
                            size,
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black),
                        () async {
                          context.goNamed(AppRoutes.dashboardName,
                              extra: {'initialPosition': 0});
                        },
                      ),
                    ),
                    SizedBox(
                      height: size.width * AppDimensions.numD12,
                      width: size.width * AppDimensions.numD44,
                      child: commonElevatedButton(
                        "Enable Location",
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(
                            size,
                            isFetchingLocation
                                ? Colors.grey
                                : AppColorTheme.colorThemePink),
                        () async {
                          if (isFetchingLocation) return;
                          var status = await Permission.location.status;
                          if (!status.isGranted) {
                            status = await Permission.location.request();
                          }
                          if (status.isPermanentlyDenied) {
                            PermissionUI.show(
                              message:
                                  "Location permission is permanently denied. Please enable it in settings to proceed.",
                              isPermanent: true,
                              permissionType: Permission.location,
                            );
                            return;
                          }

                          if (status.isDenied) {
                            return;
                          }

                          _fetchLocation();
                        },
                      ),
                    ),
                  ],
                ),
                Spacer(),
                if (isFetchingLocation)
                  Text(
                    "Fetching Location. Please wait while we are trying to fetch your location. Be with us.",
                    textAlign: TextAlign.center,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * AppDimensions.numD03,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
