import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/location_service.dart';

import '../utils/Common.dart';

class LocationErrorScreen extends StatefulWidget {
  @override
  _LocationErrorScreenState createState() => _LocationErrorScreenState();
}

class _LocationErrorScreenState extends State<LocationErrorScreen> {
  double latitude = 22.5744, longitude = 88.3629;
  late LocationService _locationService;
  bool isFetchingLocation =
      false; // To manage the state of the "Try Again" button

  @override
  Widget build(BuildContext context) {
    _locationService = LocationService();
    var size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        // Prevent back press
        return false;
      },
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Icon(
                  Icons.location_off,
                  size: 80,
                  color: Colors.red,
                ),
                SizedBox(height: size.height * numD02),
                Text(
                  'Location Not Found',
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD035,
                      color: Colors.black,
                      fontWeight: FontWeight.w400),
                ),
                SizedBox(height: size.height * numD01),
                Text(
                  'We are unable to get your location. Until we have access to your location, We cannot proceed further. Sorry for the inconvenience.',
                  textAlign: TextAlign.center,
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD035,
                      color: Colors.black,
                      fontWeight: FontWeight.w400),
                ),
                SizedBox(height: size.height * numD08),
                SizedBox(
                  height: size.width * numD12,
                  width: size.width * numD80,
                  child: commonElevatedButton(
                    isFetchingLocation ? "Fetching..." : "Try Again",
                    size,
                    commonButtonTextStyle(size),
                    commonButtonStyle(size,
                        isFetchingLocation ? Colors.grey : colorThemePink),
                    () async {
                      // if (isFetchingLocation) {
                      //   return; // Prevent multiple taps while fetching location
                      // }
                      setState(() {
                        isFetchingLocation = true;
                      });

                      late LocationData? locationData;

                      locationData =
                          await _locationService.getCurrentLocation(context);
                      // if (!kDebugMode) {
                      //   showSnackBar(
                      //     "Fetching Location...",
                      //     "Please wait while we are trying to fetch your location. Be with us.",
                      //     Colors.black,
                      //     duration: Duration(seconds: 3),
                      //   );
                      //   locationData =
                      //       await _locationService.getCurrentLocation(context);
                      // } else {
                      //   locationData = LocationData.fromMap({
                      //     'latitude': latitude,
                      //     'longitude': longitude,
                      //     'accuracy': 100.0,
                      //   });
                      // }

                      if (locationData != null) {
                        // Navigate to the next screen or perform the desired action
                        Navigator.pop(context, locationData);
                      } else {
                        setState(() {
                          isFetchingLocation = false;
                          showSnackBar(
                            "Location Failed.",
                            "Sorry, we are unable to fetch your location. Kindly check your permission and turn on your GPS. Then please try again later.",
                            Colors.red,
                            duration: Duration(seconds: 3),
                          );
                        });
                      }
                    },
                  ),
                ),
                SizedBox(height: size.height * numD02),
                SizedBox(
                  height: size.width * numD12,
                  width: size.width * numD80,
                  child: commonElevatedButton(
                    "Exit",
                    size,
                    commonButtonTextStyle(size),
                    commonButtonStyle(size, Colors.black),
                    () async {
                      if (Platform.isIOS) {
                        await SystemChannels.platform
                            .invokeMethod<void>('SystemNavigator.pop');
                      } else {
                        SystemNavigator.pop();
                      }
                    },
                  ),
                ),
                Spacer(),
                if (isFetchingLocation)
                  Text(
                    "Fetching Location. Please wait while we are trying to fetch your location. Be with us.",
                    textAlign: TextAlign.center,
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD03,
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
