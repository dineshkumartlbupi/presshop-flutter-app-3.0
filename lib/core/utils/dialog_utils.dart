import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:presshop/core/constants/app_dimensions_new.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/features/task/domain/entities/task_assigned_entity.dart';
import 'package:audioplayers/audioplayers.dart';

AlertDialog? alertDialog;

void commonDialog(BuildContext context, String message, VoidCallback pressed) {
  var screenWidth = MediaQuery.of(context).size.width;
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            contentPadding: EdgeInsets.symmetric(
                horizontal: screenWidth * AppDimensions.numD04),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                          screenWidth * AppDimensions.numD015)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: screenWidth * AppDimensions.numD04,
                            right: screenWidth * AppDimensions.numD04,
                            top: screenWidth * AppDimensions.numD05),
                        child: Text(
                          message,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: screenWidth * AppDimensions.numD04),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(
                            top: screenWidth * AppDimensions.numD06,
                            left: screenWidth * AppDimensions.numD04,
                            right: screenWidth * AppDimensions.numD04,
                            bottom: screenWidth * AppDimensions.numD04),
                        child: ElevatedButton(
                          onPressed: pressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColorTheme.colorThemePink,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text(
                            "Ok",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * AppDimensions.numD04,
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
  required TaskAssignedEntity taskDetail,
  required VoidCallback onTapView,
}) {
  showDialog(
      context: navigatorKey.currentState!.context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: AlertDialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              contentPadding: EdgeInsets.zero,
              insetPadding: EdgeInsets.symmetric(
                  horizontal: size.width * AppDimensions.numD04),
              content: StatefulBuilder(
                builder: (context, setState) {
                  return Container(
                    width: size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            size.width * AppDimensions.numD045)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// Heading
                        Padding(
                          padding: EdgeInsets.only(
                            left: size.width * AppDimensions.numD04,
                            right: size.width * AppDimensions.numD03,
                            top: size.width * AppDimensions.numD04,
                          ),
                          child: Row(
                            children: [
                              Text(
                                AppStrings.newBroadcastedTask.toTitleCase(),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: size.width * AppDimensions.numD04,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              SizedBox(
                                height: size.width * AppDimensions.numD07,
                                width: size.width * AppDimensions.numD07,
                                child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      if (player.state == PlayerState.playing) {
                                        player.stop();
                                      }
                                      context.pop();
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.black,
                                      size: size.width * AppDimensions.numD06,
                                    )),
                              )
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

                        /// Image, Title , des
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
                                    child: Image.network(
                                      taskDetail.task.mediaHouse.profileImage,
                                      height: size.width * AppDimensions.numD20,
                                      width: size.width * AppDimensions.numD20,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, object, stacktrace) {
                                        return Padding(
                                          padding: EdgeInsets.all(size.width *
                                              AppDimensions.numD02),
                                          child: Image.asset(
                                            "${commonImagePath}rabbitLogo.png",
                                            height: size.width *
                                                AppDimensions.numD20,
                                            width: size.width *
                                                AppDimensions.numD20,
                                          ),
                                        );
                                      },
                                    )),
                              ),
                              SizedBox(
                                width: size.width * AppDimensions.numD04,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: size.width * AppDimensions.numD01,
                                    ),

                                    /// Heading
                                    Text(
                                      taskDetail.task.heading,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: size.width *
                                              AppDimensions.numD035,
                                          fontWeight: FontWeight.w700),
                                    ),

                                    /// Description
                                    Text(
                                      taskDetail.task.description,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize:
                                              size.width * AppDimensions.numD03,
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
                            top: size.width * AppDimensions.numD03,
                            bottom: size.width * AppDimensions.numD05,
                            left: size.width * AppDimensions.numD04,
                            right: size.width * AppDimensions.numD04,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: size.width * AppDimensions.numD20,
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                          size.width * AppDimensions.numD03,
                                      horizontal:
                                          size.width * AppDimensions.numD02),
                                  decoration: BoxDecoration(
                                      color: AppColorTheme.colorLightGrey,
                                      borderRadius: BorderRadius.circular(
                                          size.width * AppDimensions.numD03)),
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
                                            size: size.width *
                                                AppDimensions.numD04,
                                          ),
                                          SizedBox(
                                            width: size.width *
                                                AppDimensions.numD01,
                                          ),
                                          Text(
                                            AppStrings.deadlineText,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD03,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width:
                                            size.width * AppDimensions.numD01,
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(
                                            left: size.width *
                                                AppDimensions.numD01,
                                            top: size.width *
                                                AppDimensions.numD01,
                                          ),
                                          child: TimerCountdown(
                                            endTime:
                                                taskDetail.task.deadlineDate,
                                            spacerWidth: 3,
                                            enableDescriptions: false,
                                            countDownFormatter:
                                                (day, hour, min, sec) {
                                              if (taskDetail.task.deadlineDate
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
                                                fontSize: size.width *
                                                    AppDimensions.numD03,
                                                color: Colors.black,
                                                fontWeight: FontWeight.normal),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: size.width * AppDimensions.numD05,
                              ),
                              Expanded(
                                child: Container(
                                  height: size.width * AppDimensions.numD20,
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                          size.width * AppDimensions.numD03,
                                      horizontal:
                                          size.width * AppDimensions.numD02),
                                  decoration: BoxDecoration(
                                      color: AppColorTheme.colorLightGrey,
                                      borderRadius: BorderRadius.circular(
                                          size.width * AppDimensions.numD03)),
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
                                            width: size.width *
                                                AppDimensions.numD03,
                                          ),
                                          SizedBox(
                                            width: size.width *
                                                AppDimensions.numD01,
                                          ),
                                          Text(
                                            AppStrings.locationText
                                                .toUpperCase(),
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD03,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),

                                      /// Location Data
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left:
                                              size.width * AppDimensions.numD01,
                                          top:
                                              size.width * AppDimensions.numD01,
                                        ),
                                        child: Text(
                                          taskDetail.task.location,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width *
                                                  AppDimensions.numD03,
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
                                    taskDetail.task.isNeedPhoto &&
                                            (double.tryParse(taskDetail
                                                        .task.photoPrice) ??
                                                    0) >
                                                0
                                        ? "$currencySymbol${formatDouble(double.parse(taskDetail.task.photoPrice))}"
                                        : "-",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD058,
                                        color: AppColorTheme.colorThemePink,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    AppStrings.offeredText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD035,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    height: size.width * AppDimensions.numD04,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            size.width * AppDimensions.numD06,
                                        vertical:
                                            size.width * AppDimensions.numD02),
                                    decoration: BoxDecoration(
                                        color: AppColorTheme.colorThemePink,
                                        borderRadius: BorderRadius.circular(
                                            size.width * AppDimensions.numD02)),
                                    child: Text(
                                      AppStrings.photoText.toUpperCase(),
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width *
                                              AppDimensions.numD035,
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
                                    taskDetail.task.isNeedInterview &&
                                            (double.tryParse(taskDetail
                                                        .task.interviewPrice) ??
                                                    0) >
                                                0
                                        ? "$currencySymbol${formatDouble(double.parse(taskDetail.task.interviewPrice))}"
                                        : "-",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD058,
                                        color: AppColorTheme.colorThemePink,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    AppStrings.offeredText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD035,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    height: size.width * AppDimensions.numD04,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical:
                                            size.width * AppDimensions.numD02,
                                        horizontal:
                                            size.width * AppDimensions.numD03),
                                    decoration: BoxDecoration(
                                        color: AppColorTheme.colorThemePink,
                                        borderRadius: BorderRadius.circular(
                                            size.width * AppDimensions.numD02)),
                                    child: Text(
                                      AppStrings.interviewText.toUpperCase(),
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width *
                                              AppDimensions.numD035,
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
                                    taskDetail.task.isNeedVideo &&
                                            (double.tryParse(taskDetail
                                                        .task.videoPrice) ??
                                                    0) >
                                                0
                                        ? "$currencySymbol${formatDouble(double.parse(taskDetail.task.videoPrice))}"
                                        : "-",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD058,
                                        color: AppColorTheme.colorThemePink,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    AppStrings.offeredText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD035,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    height: size.width * AppDimensions.numD04,
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            size.width * AppDimensions.numD06,
                                        vertical:
                                            size.width * AppDimensions.numD02),
                                    decoration: BoxDecoration(
                                        color: AppColorTheme.colorThemePink,
                                        borderRadius: BorderRadius.circular(
                                            size.width * AppDimensions.numD02)),
                                    child: Text(
                                      AppStrings.videoText.toUpperCase(),
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width *
                                              AppDimensions.numD035,
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
                          height: size.width * AppDimensions.numD02,
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * AppDimensions.numD04,
                              vertical: size.width * AppDimensions.numD04),
                          child: SizedBox(
                            height: size.width * AppDimensions.numD12,
                            child: commonElevatedButton(
                              "View Details",
                              size,
                              commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                              commonButtonStyle(
                                  size, AppColorTheme.colorThemePink),
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
                            left: size.width * AppDimensions.numD04,
                            top: size.width * AppDimensions.numD02),
                        child: Row(
                          children: [
                            Text(
                              isFromNetworkError
                                  ? "${AppStrings.errorDialogText} $errorCode!"
                                  : errorCode,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * AppDimensions.numD04,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            if (shouldShowClosedButton)
                              IconButton(
                                  onPressed: () {
                                    context.pop();
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
                              ),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      size.width * AppDimensions.numD04),
                                  child: Image.asset(
                                    "${commonImagePath}dog.png",
                                    height: size.width * AppDimensions.numD25,
                                    width: size.width * AppDimensions.numD35,
                                    fit: BoxFit.cover,
                                  )),
                            ),
                            SizedBox(
                              width: size.width * AppDimensions.numD04,
                            ),
                            Expanded(
                              child: Text(
                                message,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        size.width * AppDimensions.numD035,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD08,
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD12,
                        width: size.width * AppDimensions.numD35,
                        child: commonElevatedButton(
                            actionButton,
                            size,
                            commonButtonTextStyle(size),
                            commonButtonStyle(
                                size, AppColorTheme.colorThemePink),
                            callback),
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD05,
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
                      SizedBox(
                        height: size.width * AppDimensions.numD02,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: size.width * AppDimensions.numD04),
                        child: Row(
                          children: [
                            Text(
                              "Complete your onboarding",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * AppDimensions.numD05,
                                  fontFamily: "AirbnbCereal",
                                  fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            IconButton(
                                onPressed: () {
                                  context.pop();
                                },
                                icon: Image.asset(
                                  "${iconsPath}cross.png",
                                  width: size.width * AppDimensions.numD065,
                                  height: size.width * AppDimensions.numD065,
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
                        height: size.width * AppDimensions.numD02,
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              left: size.width * AppDimensions.numD04,
                              right: size.width * AppDimensions.numD04),
                          child: RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                              text:
                                  "Please complete your pending onboarding process to register on ",
                              style: TextStyle(
                                  fontSize: size.width * AppDimensions.numD038,
                                  color: Colors.black,
                                  fontFamily: "AirbnbCereal",
                                  fontWeight: FontWeight.w400,
                                  height: 1.5),
                              children: [
                                TextSpan(
                                  text: "Press",
                                  style: TextStyle(
                                      fontSize:
                                          size.width * AppDimensions.numD038,
                                      color: Colors.black,
                                      fontFamily: "AirbnbCereal",
                                      fontWeight: FontWeight.w400,
                                      height: 1.5),
                                ),
                                TextSpan(
                                  text: "Hop",
                                  style: TextStyle(
                                      fontSize:
                                          size.width * AppDimensions.numD038,
                                      color: Colors.black,
                                      fontFamily: "AirbnbCereal",
                                      fontWeight: FontWeight.w400,
                                      height: 1.5),
                                )
                              ],
                            ),
                          )),
                      SizedBox(
                        height: size.width * AppDimensions.numD06,
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD13,
                        width: size.width * AppDimensions.numD45,
                        child: commonElevatedButton(
                            "Let's go",
                            size,
                            commonButtonTextStyle(size),
                            commonButtonStyle(
                                size, AppColorTheme.colorThemePink), () {
                          func();
                        }),
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD05,
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
    context.pop();
  }
  alertDialog = AlertDialog(
    elevation: 0,
    backgroundColor: Colors.white.withOpacity(0),
    content: const Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          color: AppColorTheme.colorThemePink,
        ),
      ],
    ),
  );
  showDialog(
    barrierDismissible: false,
    barrierColor: Colors.white.withOpacity(0),
    context: context,
    builder: (context) {
      return alertDialog!;
    },
  );
}
