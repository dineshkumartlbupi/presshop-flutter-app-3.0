import 'dart:math';
import 'dart:ui';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:presshop/main.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonModel.dart';
import 'package:presshop/view/boardcastScreen/BroardcastScreen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../view/menuScreen/MyDraftScreen.dart';
import '../view/menuScreen/feedScreen/feedDataModel.dart';
import 'countdownTimerScreen.dart';

Size globalSize = MediaQuery.of(navigatorKey.currentContext!).size;

Widget commonElevatedButton(String buttonText, Size size, TextStyle textStyle,
    ButtonStyle buttonStyle, VoidCallback fxn) {
  return ElevatedButton(
    onPressed: fxn,
    style: buttonStyle,
    child: Text(
      buttonText,
      style: textStyle,
    ),
  );
}

ButtonStyle commonButtonStyle(Size size, Color color) {
  return ElevatedButton.styleFrom(
      backgroundColor: color,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * numD04)));
}

TextStyle commonButtonTextStyle(Size size) {
  return TextStyle(
      color: Colors.white,
      fontSize: size.width * numD037,
      fontFamily: "AirbnbCereal",
      fontWeight: FontWeight.bold);
}

TextStyle commonTextStyle(
    {required Size size,
      required fontSize,
      required Color color,
      double? lineHeight,
      required FontWeight fontWeight}) {
  return TextStyle(
    fontWeight: fontWeight,
    fontSize: fontSize,
    height: lineHeight,
    color: color,
  );
}

TextStyle commonBigTitleTextStyle(Size size, Color color) {
  return TextStyle(
      fontFamily:"AirbnbCereal",
      color: color, fontSize: size.width * numD08, fontWeight: FontWeight.bold);
}

Widget commonLeading(Size size) {
  return Row(
    children: [
      Icon(
        Icons.arrow_back_rounded,
        color: Colors.black,
        size: size.width * numD08,
      ),
    ],
  );
}

String? checkRequiredValidator(String? value) {
  if (value!.trim().isEmpty) {
    return requiredText;
  }
  return null;
}

String? checkEmailValidator(String? value) {
  if (value!.isEmpty) {
    return requiredText;
  } else if (!emailExpression.hasMatch(value)) {
    return emailErrorText;
  }
  return null;
}

String? checkPhoneValidator(String? value) {
  //<-- add String? as a return type
  if (value!.isEmpty) {
    return requiredText;
  } else if (value.length < 10) {
    return phoneErrorText;
  }
  return null;
}

String? checkPasswordValidator(String? value) {
  //<-- add String? as a return type
  if (value!.trim().isEmpty) {
    return requiredText;
  }
  return null;
}

String? checkConfirmPasswordValidator(String? value, String password) {
  //<-- add String? as a return type
  if (value!.isEmpty) {
    return requiredText;
  } else if (value.length < 8) {
    return passwordErrorText;
  } else if (password != value) {
    return confirmPasswordErrorText;
  }
  return null;
}

void commonDialog(BuildContext context, String message, pressed) {
  var screenWidth =
  (window.physicalSize.shortestSide / window.devicePixelRatio);
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

///:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
///:::::::::::::::::::::::: BROAD CAST DIALOG ::::::::::::::::::::::::::::::::
void broadcastDialog({
  required Size size,
  required TaskDetailModel taskDetail,
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
                                          ) /*Text(
                                            "1h: 21m: 11s",
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD03,
                                                color: Colors.black,
                                                fontWeight: FontWeight.normal),
                                          ),*/
                                      ),
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
                                    taskDetail.isNeedPhoto
                                        ? "$euroUniqueCode${formatDouble(double.parse(taskDetail.photoPrice))}"
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
                                          color:Colors.white,
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
                                    taskDetail.isNeedInterview
                                        ? "$euroUniqueCode${formatDouble(double.parse(taskDetail.interviewPrice))}"
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
                                    taskDetail.isNeedVideo
                                 ? "$euroUniqueCode${formatDouble(double.parse(taskDetail.videoPrice))}"

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

///:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
///:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

void commonErrorDialogDialog(
    Size size, String message, String errorCode, VoidCallback callback) {
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
                              "$errorDialogText $errorCode!",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * numD05,
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
                            okText,
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
                            text:"Please complete your pending onboarding process to register on ",
                            style: TextStyle(
                                fontSize: size.width * numD038,
                                color: Colors.black,
                                fontFamily: "AirbnbCereal",
                                fontWeight: FontWeight.w400,
                                height: 1.5),
                            children: [
                              TextSpan(
                                text:"PRESS",
                                style: TextStyle(
                                    fontSize: size.width * numD038,
                                    color: Colors.black,
                                    fontFamily: "AirbnbCereal",
                                    fontWeight: FontWeight.w400,
                                    height: 1.5),
                              ),
                              TextSpan(
                                text:"HOP",
                                style: TextStyle(
                                    fontSize: size.width * numD038,
                                    color: Colors.black,
                                    fontFamily: "AirbnbCereal",
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w400,
                                    height: 1.5),
                              )
                            ],
                          ),
                        )



                      ),
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

void showSnackBar(String title, String message, Color color) {
  Flushbar(
    title: title,
    message: message,
    duration: const Duration(seconds: 2),
    backgroundColor: color,
    flushbarPosition: FlushbarPosition.TOP,
    titleColor: Colors.white,
    messageColor: Colors.white,

  ).show(navigatorKey.currentContext!);

/*
  ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(
    content: Text(
      message,
      style: TextStyle(color: Colors.white, fontSize: screenWidth * numD04),
    ),
    backgroundColor: color,
    duration: const Duration(seconds: 3),
  ));*/
}

AlertDialog? alertDialog;

/*showLoaderDialog() {
  if (alertDialog != null) {
    Navigator.of(navigatorKey.currentState!.context, rootNavigator: true).pop();
  }

  alertDialog = AlertDialog(
    elevation: 0,
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.all(0),
    contentPadding: const EdgeInsets.all(0),
    actionsPadding: const EdgeInsets.all(0),
    buttonPadding: const EdgeInsets.all(0),
    titlePadding: const EdgeInsets.all(0),
    content: SizedBox(
        width: MediaQuery.of(navigatorKey.currentState!.context).size.width,
        child: const SpinKitSpinningLines(
          color: colorThemePink,
        )),
  );

  showDialog(
    barrierColor: Colors.white.withOpacity(0),
    useSafeArea: false,
    barrierDismissible: false,
    context: navigatorKey.currentState!.context,
    builder: (BuildContext context) {
      return alertDialog!;
    },
  );
}*/

showLoaderDialog(BuildContext context) {
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
        /*CupertinoActivityIndicator(
            radius: 20,
            color: colorThemePink,)*/
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

/// common amountFormater

amountFormat(String price) {
  var priceAmount = price.isNotEmpty || price != null ? price : "0";
  var formattedNumber =
  NumberFormat("#,##0", "en_US").format(double.parse(price));
  return formattedNumber;
}

double calculateDistance(lat1, lon1, lat2, lon2) {
  debugPrint("DesLat: $lat1");
  debugPrint("DesLong: $lon1");
  debugPrint("StartLat: $lat2");
  debugPrint("StartLong: $lon2");

  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}

/// Show Text If No Data Found
Widget errorMessageWidget(message) {
  return Center(
    child: Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 30),
      child: Text(
        message,
        style: commonTextStyle(
          size: globalSize,
          fontSize: globalSize.width * numD04,
          color: Colors.grey,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
  );
}

/// Smart Refresh

Widget commonRefresherFooter(context, mode) {
  Widget body;
  if (mode == LoadStatus.idle) {
    body = const Text("pull up load");
  } else if (mode == LoadStatus.loading) {
    body = const CircularProgressIndicator(
      color: colorThemePink,
    );
  } else if (mode == LoadStatus.failed) {
    body = const Text("Load Failed!Click retry!");
  } else if (mode == LoadStatus.canLoading) {
    body = const Text("release to load more");
  } else {
    body = const Text("No more Data");
  }
  return SizedBox(
    height: 55.0,
    child: Center(child: body),
  );
}

/// Show Loader
Widget showLoader() {
  var size= MediaQuery.of(navigatorKey.currentContext!).size;
  return  Center(
    child: Lottie.asset(
        "assets/lottieFiles/loader_new.json",
        height: size.width*numD28,
        width: size.width*numD28
    )

    /*
    CircularProgressIndicator(
      color: colorThemePink,
      strokeWidth: 3.5,
    ),*/
  );
}
Widget showAnimatedLoader(var size) {
  return  Center(
    child: Lottie.asset(
        "assets/lottieFiles/loader_new.json",
        height: size.width*numD25,
        width: size.width*numD25
    )
  );
}

/// Calender
Future<String?> commonDatePicker({String? date}) async {
  final DateTime? pickedDate = await showDatePicker(
    context: navigatorKey.currentContext!,
    initialDate: DateTime.now(),
    firstDate: DateTime(1900, 01, 01),
    lastDate: DateTime.now(),
    builder: (context, child) {
      return Theme(
        data: ThemeData.light().copyWith(
            colorScheme:
            const ColorScheme.light().copyWith(primary: colorThemePink)),
        child: child!,
      );
    },
  );

  if (pickedDate != null) {
    final String formatted = pickedDate.toString();
    //dateTimeFormatter(dateTime: pickedDate.toString());
    debugPrint("formatted=======Date===Format====>$formatted");
    return formatted;
  } else {
    return date;
  }
}

/// FilterIcon
commonFilterIcon(Size size) {
  return Container(
      padding: EdgeInsets.all(size.width * numD043),
      child: Image.asset(
        "${iconsPath}ic_filter.png",
        height: size.width * numD04,
      ));
}

/// aditya

String formatMessageTimestamp(DateTime timestamp) {
  final currentTime = DateTime.now();
  final difference = currentTime.difference(timestamp.toLocal());

  if (difference < const Duration(days: 1)) {
    return DateFormat("hh:mm a, dd MMM yyyy").format(timestamp.toLocal()); // Display time
  } else {
    return DateFormat("hh:mm a, dd MMM yyyy").format(timestamp); // Display date
  }
}

/// aditya
String greeting() {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Good morning';
  }
  if (hour < 17) {
    return 'Good afternoon';
  }
  return 'Good evening';
}


/// aditya

String formatDouble(double value) {
  final NumberFormat numberFormat = NumberFormat("#,##0.00");
  if (value == value.toInt()) {
    return NumberFormat("#,##0").format(value);
  } else {
    return numberFormat.format(value);
  }
}

Widget getMediaCountCard(String mediaType, int count,Size size) {
  return Container(
    width: size.width * numD11,
    padding: EdgeInsets.symmetric(vertical: size.width * numD01),
    decoration: BoxDecoration(color: colorLightGreen.withOpacity(0.8), borderRadius: BorderRadius.circular(size.width * numD021)),
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.005,
        vertical: size.width * 0.005,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$count ",
            style: commonTextStyle(size: size, fontSize: size.width * numD038, color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const Padding(padding: EdgeInsets.only(left: 1.5)),
          Container(
            child: Image.asset(
              alignment: Alignment.center,
              mediaType == "image"
                  ? "${iconsPath}ic_camera_publish.png"
                  : mediaType == "video"
                  ? "${iconsPath}ic_v_cam.png"
                  : mediaType == "audio"
                  ? "${iconsPath}new_audio.png"
                  : "${iconsPath}doc_icon.png",
              color: Colors.white,
              height: mediaType == "image"
                  ? size.width * 0.029
                  : mediaType == "video"
                  ? size.width * 0.041
                  : mediaType == "audio"
                  ? size.width * 0.04
                  : size.width * 0.04,
            ),
          ),
        ],
      ),
    ),
  );
}

List<Widget> getMediaCount(List<ContentMediaData> contentMediaList,Size size) {
  final imageCount = contentMediaList.where((item) => item.mediaType == "image").length;
  final videoCount = contentMediaList.where((item) => item.mediaType == "video").length;
  final audioCount = contentMediaList.where((item) => item.mediaType == "audio").length;
  debugPrint("MediaCount $imageCount, $videoCount, $audioCount");
  final widgetList = <Widget>[];
  if (imageCount > 0) {
    widgetList.add(getMediaCountCard("image", imageCount,size));
    widgetList.add(SizedBox(height: 6));
  }
  if (videoCount > 0) {
    widgetList.add(getMediaCountCard("video", videoCount,size));
    widgetList.add(SizedBox(height: 6));
  }
  if (audioCount > 0) {
    widgetList.add(getMediaCountCard("audio", audioCount,size));
    widgetList.add(SizedBox(height: 6));
  }
  return widgetList;
}

List<Widget> getMediaCount2(List<ContentDataModel> contentMediaList,Size size) {
  final imageCount = contentMediaList.where((item) => item.mediaType == "image").length;
  final videoCount = contentMediaList.where((item) => item.mediaType == "video").length;
  final audioCount = contentMediaList.where((item) => item.mediaType == "audio").length;
  debugPrint("MediaCount $imageCount, $videoCount, $audioCount");
  final widgetList = <Widget>[];
  if (imageCount > 0) {
    widgetList.add(getMediaCountCard("image", imageCount,size));
    widgetList.add(SizedBox(height: 6));
  }
  if (videoCount > 0) {
    widgetList.add(getMediaCountCard("video", videoCount,size));
    widgetList.add(SizedBox(height: 6));
  }
  if (audioCount > 0) {
    widgetList.add(getMediaCountCard("audio", audioCount,size));
    widgetList.add(SizedBox(height: 6));
  }
  return widgetList;
}


