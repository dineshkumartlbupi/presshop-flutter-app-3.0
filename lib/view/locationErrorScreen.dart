import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/location_service.dart';

import '../main.dart';
import '../utils/Common.dart';
import '../utils/CommonSharedPrefrence.dart';
import '../utils/networkOperations/NetworkClass.dart';
import '../utils/networkOperations/NetworkResponse.dart';
import 'dashboard/Dashboard.dart';

class LocationErrorScreen extends StatefulWidget {
  @override
  _LocationErrorScreenState createState() => _LocationErrorScreenState();
}

class _LocationErrorScreenState extends State<LocationErrorScreen>
    implements NetworkResponse {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * numD05),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) =>
                                  Dashboard(initialPosition: 0)),
                          (route) => false);
                    },
                    icon: Container(
                      decoration: const BoxDecoration(
                          color: Colors.black, shape: BoxShape.circle),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: size.width * numD06,
                      ),
                    ),
                  ),
                ),
                Spacer(),
                Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * numD04,
                        vertical: size.width * numD04),
                    decoration: BoxDecoration(
                        color: colorLightGrey,
                        borderRadius:
                            BorderRadius.circular(size.width * numD04)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                            borderRadius:
                                BorderRadius.circular(size.width * numD06),
                            child: Image.asset("${commonImagePath}dog.png",
                                height: size.width * numD30,
                                width: size.width * numD30,
                                fit: BoxFit.cover)),
                        SizedBox(width: size.width * numD05),
                        Flexible(
                          child: Text(
                            'Oops! We’ll need access to your location before you can proceed.',
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD04,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    )),
                SizedBox(height: size.height * numD04),
                Text(
                  'Note: The press needs to know where a photo or video was taken, and without your location, we can’t submit and help sell your content. Pop it on and you’re good to go!',
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * numD035,
                      color: Colors.black,
                      fontWeight: FontWeight.w400),
                ),
                SizedBox(height: size.height * numD04),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: size.width * numD12,
                      width: size.width * numD44,
                      child: commonElevatedButton(
                        "Back",
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
                    SizedBox(
                      height: size.width * numD12,
                      width: size.width * numD44,
                      child: commonElevatedButton(
                        "Enable Location",
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

                          locationData = await _locationService
                              .getCurrentLocation(context);

                          if (locationData != null) {
                            // Successfully fetched location, you can now use it
                            // Navigate to the next screen or perform the desired action
                            Navigator.pop(context, locationData);
                          } else {
                            setState(() {
                              isFetchingLocation = false;
                            });
                          }
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

  @override
  void onError({required int requestCode, required String response}) {
    // TODO: implement onError
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    // TODO: implement onResponse
  }
}
