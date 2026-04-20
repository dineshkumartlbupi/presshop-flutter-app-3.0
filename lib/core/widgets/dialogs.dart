import 'package:flutter/material.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/services/background_location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllDialogs {
  static void showAlertInfoPopupForMap(Size size) {
    showDialog(
        barrierDismissible: false,
        context: navigatorKey.currentState!.context,
        builder: (BuildContext context) {
          return AlertDialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              contentPadding: EdgeInsets.zero,
              insetPadding: EdgeInsets.symmetric(
                  horizontal: size.width * AppDimensions.numD04),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            size.width * AppDimensions.numD045)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: size.width * AppDimensions.numD02,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: size.width * AppDimensions.numD04),
                          child: Row(
                            children: [
                              Text(
                                "Alert",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * AppDimensions.numD04,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.black,
                                  )),
                              SizedBox(
                                width: size.width * AppDimensions.numD02,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * AppDimensions.numD04),
                          child: const Divider(
                            color: Colors.black,
                            thickness: 0.5,
                          ),
                        ),
                        SizedBox(
                          height: size.width * AppDimensions.numD02,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * AppDimensions.numD04),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 120, // fixed width
                                height: 120, // fixed height
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.black),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    "assets/rabbits/mapalert.jpg",
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: size.width * AppDimensions.numD04,
                              ),
                              Expanded(
                                child: Text(
                                  textAlign: TextAlign.justify,
                                  "These alerts are for informational purposes only, and are not connected with law enforcement. For any emergencies, dial 999, 911, 100, or your local emergency number.",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize:
                                        size.width * AppDimensions.numD035,
                                    fontWeight: FontWeight.w500,
                                    height: 1.2,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: size.width * AppDimensions.numD02,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * AppDimensions.numD04,
                              vertical: size.width * AppDimensions.numD04),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: size.width * AppDimensions.numD12,
                                  child: commonElevatedButton(
                                      "Noted",
                                      size,
                                      commonButtonTextStyle(size),
                                      commonButtonStyle(
                                          size, AppColorTheme.colorThemePink),
                                      () {
                                    sharedPreferences?.setBool(
                                        SharedPreferencesKeys
                                            .alertInfoPopupShownKey,
                                        true);
                                    Navigator.pop(context);
                                  }),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ));
        });
  }

  static void showStopServiceConfirmationNew(Size size) async {
    final prefs = await SharedPreferences.getInstance();
    showDialog(
        context: navigatorKey.currentState!.context,
        builder: (context) {
          return AlertDialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              contentPadding: EdgeInsets.zero,
              insetPadding: EdgeInsets.symmetric(
                  horizontal: size.width * AppDimensions.numD04),
              content: StatefulBuilder(
                builder: (context, setState) {
                  return Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            size.width * AppDimensions.numD045)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: size.width * AppDimensions.numD04),
                          child: Row(
                            children: [
                              Text(
                                "Don’t Miss Nearby Opportunities",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: size.width * AppDimensions.numD04,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.black,
                                    size: size.width * AppDimensions.numD06,
                                  ))
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * AppDimensions.numD04),
                          child: const Divider(
                            color: Colors.black,
                            thickness: 0.5,
                          ),
                        ),
                        SizedBox(
                          height: size.width * AppDimensions.numD02,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * AppDimensions.numD04),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        size.width * AppDimensions.numD04),
                                    border: Border.all(color: Colors.black)),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        size.width * AppDimensions.numD04),
                                    child: Image.asset(
                                      "assets/rabbits/turnofflocationrabbit.png",
                                      height: size.width * AppDimensions.numD30,
                                      width: size.width * AppDimensions.numD35,
                                      fit: BoxFit.cover,
                                    )),
                              ),
                              SizedBox(
                                width: size.width * AppDimensions.numD04,
                              ),
                              Expanded(
                                child: Text(
                                  "💰 Location helps us send you tasks near you in real time. Turn it off and you may miss chances to capture news and earn. Are you sure you want to turn it off?",
                                  softWrap: true,
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          size.width * AppDimensions.numD035,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: size.width * AppDimensions.numD02,
                        ),
                        SizedBox(
                          height: size.width * AppDimensions.numD02,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * AppDimensions.numD04,
                              vertical: size.width * AppDimensions.numD04),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                  child: SizedBox(
                                height: size.width * AppDimensions.numD12,
                                child: commonElevatedButton(
                                    "Turn It Off",
                                    size,
                                    commonButtonTextStyle(size),
                                    commonButtonStyle(size, Colors.black),
                                    () async {
                                  Navigator.pop(context);

                                  await BackgroundLocationService.stopService();
                                  await prefs.setBool(
                                      'is_task_grabbing_active', false);
                                  await prefs.setBool(
                                      'manually_stopped_service', true);
                                }),
                              )),
                              SizedBox(
                                width: size.width * AppDimensions.numD04,
                              ),
                              Expanded(
                                  child: SizedBox(
                                height: size.width * AppDimensions.numD12,
                                child: commonElevatedButton(
                                    "Keep Location On",
                                    size,
                                    commonButtonTextStyle(size),
                                    commonButtonStyle(
                                        size, AppColorTheme.colorThemePink),
                                    () async {
                                  Navigator.pop(context);
                                }),
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ));
        });
  }
}
