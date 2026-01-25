import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/features/task/domain/entities/task_detail.dart';
import 'package:audioplayers/audioplayers.dart';

AlertDialog? alertDialog;

void commonDialog(BuildContext context, String message, VoidCallback pressed) {
  var screenWidth = MediaQuery.of(context).size.width;
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            contentPadding:
                EdgeInsets.symmetric(horizontal: screenWidth * numD04),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(screenWidth * numD015)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: screenWidth * numD04,
                            right: screenWidth * numD04,
                            top: screenWidth * numD05),
                        child: Text(
                          message,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: screenWidth * numD04),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(
                            top: screenWidth * numD06,
                            left: screenWidth * numD04,
                            right: screenWidth * numD04,
                            bottom: screenWidth * numD04),
                        child: ElevatedButton(
                          onPressed: pressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorThemePink,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text(
                            "Ok",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * numD04,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ));
      });
}

void broadcastDialog({
  required Size size,
  required TaskDetail taskDetail,
  required VoidCallback onTapView,
}) {
  showDialog(
      context: navigatorKey.currentState!.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: AlertDialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              contentPadding: EdgeInsets.zero,
              insetPadding:
                  EdgeInsets.symmetric(horizontal: size.width * numD04),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Container(
                    width: size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(size.width * numD045)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// Heading
                        Padding(
                          padding: EdgeInsets.only(
                            left: size.width * numD04,
                            right: size.width * numD03,
                            top: size.width * numD04,
                          ),
                          child: Row(
                            children: [
                              Text(
                                newBroadcastedTask.toTitleCase(),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: size.width * numD04,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              SizedBox(
                                height: size.width * numD07,
                                width: size.width * numD07,
                                child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      if (player.state == PlayerState.playing) {
                                        player.stop();
                                      }
                                      Navigator.pop(context);
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.black,
                                      size: size.width * numD06,
                                    )),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * numD04),
                          child: const Divider(
                            color: Colors.black,
                            thickness: 0.5,
                          ),
                        ),
                        SizedBox(
                          height: size.width * numD02,
                        ),

                        /// Image, Title , des
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * numD04),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD04),
                                    border: Border.all(color: Colors.black)),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD04),
                                    child: Image.network(
                                      taskDetail.mediaHouseImage,
                                      height: size.width * numD20,
                                      width: size.width * numD20,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, object, stacktrace) {
                                        return Padding(
                                          padding: EdgeInsets.all(
                                              size.width * numD02),
                                          child: Image.asset(
                                            "${commonImagePath}rabbitLogo.png",
                                            height: size.width * numD20,
                                            width: size.width * numD20,
                                          ),
                                        );
                                      },
                                    )),
                              ),
                              SizedBox(
                                width: size.width * numD04,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: size.width * numD01,
                                    ),

                                    /// Heading
                                    Text(
                                      taskDetail.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: size.width * numD035,
                                          fontWeight: FontWeight.w700),
                                    ),

                                    /// Description
                                    Text(
                                      taskDetail.description,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: size.width * numD03,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// Location or deadline
                        Container(
                          margin: EdgeInsets.only(
                            top: size.width * numD03,
                            bottom: size.width * numD05,
                            left: size.width * numD04,
                            right: size.width * numD04,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: size.width * numD20,
                                  padding: EdgeInsets.symmetric(
                                      vertical: size.width * numD03,
                                      horizontal: size.width * numD02),
                                  decoration: BoxDecoration(
                                      color: colorLightGrey,
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD03)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            color: Colors.black,
                                            size: size.width * numD04,
                                          ),
                                          SizedBox(
                                            width: size.width * numD01,
                                          ),
                                          Text(
                                            deadlineText,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD03,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: size.width * numD01,
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(
                                            left: size.width * numD01,
                                            top: size.width * numD01,
                                          ),
                                          child: TimerCountdown(
                                            endTime: taskDetail.deadLine,
                                            spacerWidth: 3,
                                            enableDescriptions: false,
                                            countDownFormatter:
                                                (day, hour, min, sec) {
                                              if (taskDetail.deadLine
                                                      .difference(
                                                          DateTime.now())
                                                      .inDays >
                                                  0) {
                                                return "${day}d:${hour}h:${min}m:${sec}s";
                                              } else {
                                                return "${hour}h:${min}m:${sec}s";
                                              }
                                            },
                                            format: CountDownTimerFormat
                                                .customFormats,
                                            timeTextStyle: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD03,
                                                color: Colors.black,
                                                fontWeight: FontWeight.normal),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: size.width * numD05,
                              ),
                              Expanded(
                                child: Container(
                                  height: size.width * numD20,
                                  padding: EdgeInsets.symmetric(
                                      vertical: size.width * numD03,
                                      horizontal: size.width * numD02),
                                  decoration: BoxDecoration(
                                      color: colorLightGrey,
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD03)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            "${iconsPath}ic_location.png",
                                            width: size.width * numD03,
                                          ),
                                          SizedBox(
                                            width: size.width * numD01,
                                          ),
                                          Text(
                                            locationText.toUpperCase(),
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD03,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),

                                      /// Location Data
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: size.width * numD01,
                                          top: size.width * numD01,
                                        ),
                                        child: Text(
                                          taskDetail.location,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width * numD03,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    taskDetail.isNeedPhoto &&
                                            (double.tryParse(taskDetail
                                                        .photoPrice) ??
                                                    0) >
                                                0
                                        ? "$currencySymbol${formatDouble(double.parse(taskDetail.photoPrice))}"
                                        : "-",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD058,
                                        color: colorThemePink,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    offeredText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD035,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    height: size.width * numD04,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: size.width * numD06,
                                        vertical: size.width * numD02),
                                    decoration: BoxDecoration(
                                        color: colorThemePink,
                                        borderRadius: BorderRadius.circular(
                                            size.width * numD02)),
                                    child: Text(
                                      photoText.toUpperCase(),
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD035,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    taskDetail.isNeedInterview &&
                                            (double.tryParse(taskDetail
                                                        .interviewPrice) ??
                                                    0) >
                                                0
                                        ? "$currencySymbol${formatDouble(double.parse(taskDetail.interviewPrice))}"
                                        : "-",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD058,
                                        color: colorThemePink,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    offeredText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD035,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    height: size.width * numD04,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: size.width * numD02,
                                        horizontal: size.width * numD03),
                                    decoration: BoxDecoration(
                                        color: colorThemePink,
                                        borderRadius: BorderRadius.circular(
                                            size.width * numD02)),
                                    child: Text(
                                      interviewText.toUpperCase(),
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD035,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    taskDetail.isNeedVideo &&
                                            (double.tryParse(taskDetail
                                                        .videoPrice) ??
                                                    0) >
                                                0
                                        ? "$currencySymbol${formatDouble(double.parse(taskDetail.videoPrice))}"
                                        : "-",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD058,
                                        color: colorThemePink,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    offeredText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD035,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    height: size.width * numD04,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: size.width * numD06,
                                        vertical: size.width * numD02),
                                    decoration: BoxDecoration(
                                        color: colorThemePink,
                                        borderRadius: BorderRadius.circular(
                                            size.width * numD02)),
                                    child: Text(
                                      videoText.toUpperCase(),
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD035,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),

                        SizedBox(
                          height: size.width * numD02,
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * numD04,
                              vertical: size.width * numD04),
                          child: SizedBox(
                            height: size.width * numD12,
                            child: commonElevatedButton(
                              "View Details",
                              size,
                              commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                              commonButtonStyle(size, colorThemePink),
                              onTapView,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )),
        );
      });
}

void commonErrorDialogDialog(
    Size size, String message, String errorCode, VoidCallback callback,
    {String actionButton = "Ok",
    bool isFromNetworkError = true,
    bool shouldShowClosedButton = true}) {
  showDialog(
      context: navigatorKey.currentState!.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            contentPadding: EdgeInsets.zero,
            insetPadding: EdgeInsets.symmetric(horizontal: size.width * numD04),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(size.width * numD045)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: size.width * numD04,
                            top: size.width * numD02),
                        child: Row(
                          children: [
                            Text(
                              isFromNetworkError
                                  ? "$errorDialogText $errorCode!"
                                  : errorCode,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * numD04,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            if (shouldShowClosedButton)
                              IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.black,
                                    size: size.width * numD06,
                                  ))
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * numD04),
                        child: const Divider(
                          color: Colors.black,
                          thickness: 0.5,
                        ),
                      ),
                      SizedBox(
                        height: size.width * numD02,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * numD04),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04),
                              ),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD04),
                                  child: Image.asset(
                                    "${commonImagePath}dog.png",
                                    height: size.width * numD25,
                                    width: size.width * numD35,
                                    fit: BoxFit.cover,
                                  )),
                            ),
                            SizedBox(
                              width: size.width * numD04,
                            ),
                            Expanded(
                              child: Text(
                                message,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: size.width * numD035,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: size.width * numD08,
                      ),
                      SizedBox(
                        height: size.width * numD12,
                        width: size.width * numD35,
                        child: commonElevatedButton(
                            actionButton,
                            size,
                            commonButtonTextStyle(size),
                            commonButtonStyle(size, colorThemePink),
                            callback),
                      ),
                      SizedBox(
                        height: size.width * numD05,
                      ),
                    ],
                  ),
                );
              },
            ));
      });
}

void onBoardingCompleteDialog({required Size size, required Function func}) {
  showDialog(
      context: navigatorKey.currentState!.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            contentPadding: EdgeInsets.zero,
            insetPadding: EdgeInsets.symmetric(horizontal: size.width * numD04),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(size.width * numD045)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: size.width * numD02,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: size.width * numD04),
                        child: Row(
                          children: [
                            Text(
                              "Complete your onboarding",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * numD05,
                                  fontFamily: "AirbnbCereal",
                                  fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Image.asset(
                                  "${iconsPath}cross.png",
                                  width: size.width * numD065,
                                  height: size.width * numD065,
                                  color: Colors.black,
                                ))
                          ],
                        ),
                      ),
                      const Divider(
                        color: Colors.black,
                        thickness: 0.5,
                      ),
                      SizedBox(
                        height: size.width * numD02,
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              left: size.width * numD04,
                              right: size.width * numD04),
                          child: RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                              text:
                                  "Please complete your pending onboarding process to register on ",
                              style: TextStyle(
                                  fontSize: size.width * numD038,
                                  color: Colors.black,
                                  fontFamily: "AirbnbCereal",
                                  fontWeight: FontWeight.w400,
                                  height: 1.5),
                              children: [
                                TextSpan(
                                  text: "Press",
                                  style: TextStyle(
                                      fontSize: size.width * numD038,
                                      color: Colors.black,
                                      fontFamily: "AirbnbCereal",
                                      fontWeight: FontWeight.w400,
                                      height: 1.5),
                                ),
                                TextSpan(
                                  text: "Hop",
                                  style: TextStyle(
                                      fontSize: size.width * numD038,
                                      color: Colors.black,
                                      fontFamily: "AirbnbCereal",
                                      fontWeight: FontWeight.w400,
                                      height: 1.5),
                                )
                              ],
                            ),
                          )),
                      SizedBox(
                        height: size.width * numD06,
                      ),
                      SizedBox(
                        height: size.width * numD13,
                        width: size.width * numD45,
                        child: commonElevatedButton(
                            "Let's go",
                            size,
                            commonButtonTextStyle(size),
                            commonButtonStyle(size, colorThemePink), () {
                          func();
                        }),
                      ),
                      SizedBox(
                        height: size.width * numD05,
                      ),
                    ],
                  ),
                );
              },
            ));
      });
}

void showSnackBar(String title, String message, Color color,
    {Duration duration = const Duration(seconds: 2)}) {
  Flushbar(
    title: title,
    message: message,
    duration: duration,
    backgroundColor: color,
    flushbarPosition: FlushbarPosition.TOP,
    titleColor: Colors.white,
    messageColor: Colors.white,
  ).show(navigatorKey.currentContext!);
}

void showLoaderDialog(BuildContext context) {
  if (alertDialog != null) {
    debugPrint("loader False:");
    Navigator.of(context, rootNavigator: true).pop();
  }
  alertDialog = AlertDialog(
    elevation: 0,
    backgroundColor: Colors.white.withOpacity(0),
    content: const Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          color: colorThemePink,
        ),
      ],
    ),
  );
  showDialog(
    barrierDismissible: false,
    barrierColor: Colors.white.withOpacity(0),
    context: context,
    builder: (BuildContext context) {
      return alertDialog!;
    },
  );
}
