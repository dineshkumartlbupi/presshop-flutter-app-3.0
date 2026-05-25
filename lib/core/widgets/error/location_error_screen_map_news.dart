import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:location/location.dart' as lc;
import 'package:permission_handler/permission_handler.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/services/location_service.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/core/widgets/common_widgets.dart';

class LocationErrorScreenMapNews extends StatefulWidget {
  final Function(lc.LocationData)? onLocationEnabled;

  const LocationErrorScreenMapNews({super.key, this.onLocationEnabled});

  @override
  State<LocationErrorScreenMapNews> createState() =>
      _LocationErrorScreenStateMapNews();
}

class _LocationErrorScreenStateMapNews
    extends State<LocationErrorScreenMapNews> with WidgetsBindingObserver {
  late LocationService _locationService;
  bool isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _locationService = sl<LocationService>();
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
    // Delay to allow Android OS to propagate permission state after returning from Settings
    await Future.delayed(const Duration(milliseconds: 500));
    final status = await Permission.location.status;
    if (status.isGranted || status.isLimited) {
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
        if (widget.onLocationEnabled != null) {
          widget.onLocationEnabled!(locationData);
        } else {
          Navigator.pop(context, locationData);
        }
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

    return PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * AppDimensions.numD04,
                    vertical: size.width * AppDimensions.numD04),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * AppDimensions.numD04,
                            vertical: size.width * AppDimensions.numD04),
                        decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColorTheme.colorItemDividerForDarkTheme
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
                                    "${rabbitImagePath}logout_rabbit.png",
                                    height: size.width * AppDimensions.numD30,
                                    width: size.width * AppDimensions.numD30,
                                    fit: BoxFit.cover)),
                            SizedBox(width: size.width * AppDimensions.numD05),
                            Flexible(
                              child: Text(
                                'Help us help you stay informed',
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * AppDimensions.numD04,
                                    color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color ??
                                        Colors.black,
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
                          color: Theme.of(context).textTheme.bodyLarge?.color ??
                              Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    SizedBox(height: size.height * AppDimensions.numD04),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: size.width * AppDimensions.numD12,
                            child: commonElevatedButton(
                              "Back",
                              size,
                              commonButtonTextStyle(size,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.black
                                      : Colors.white),
                              commonButtonStyle(
                                  size,
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black),
                              () async {
                                context.goNamed(AppRoutes.dashboardName,
                                    extra: {'initialPosition': 0});
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: size.width * AppDimensions.numD04),
                        Expanded(
                          child: SizedBox(
                            height: size.width * AppDimensions.numD12,
                            child: commonElevatedButton(
                              "Enable Location",
                              size,
                              commonButtonTextStyle(size, color: Colors.white),
                              commonButtonStyle(
                                  size,
                                  isFetchingLocation
                                      ? Colors.grey
                                      : AppColorTheme.colorThemePink),
                              () async {
                                // 1. Check & Request Permission
                                var status = await Permission.location.status;
                                if (!status.isGranted) {
                                  status = await Permission.location.request();
                                }

                                // 2. If still denied/permanently denied, open App Settings
                                if (status.isDenied ||
                                    status.isPermanentlyDenied) {
                                  await openAppSettings();
                                  return;
                                }

                                if (status.isGranted || status.isLimited) {
                                  _fetchLocation();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isFetchingLocation) ...[
                      SizedBox(height: size.height * AppDimensions.numD04),
                      showLoader(isForLocation: true),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
