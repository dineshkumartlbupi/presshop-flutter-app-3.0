import 'package:flutter/material.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/main.dart';

class MyCommon {
  void referralDisclaimerDialog(
      Size size, BuildContext context, VoidCallback onConfirm) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              contentPadding: EdgeInsets.zero,
              insetPadding: EdgeInsets.symmetric(
                  horizontal: size.width * AppDimensions.numD04),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  final textColor = isDark ? Colors.white : Colors.black;
                  final borderColor =
                      isDark ? Colors.white24 : AppColorTheme.colorGreyNew;

                  return Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
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
                                (sharedPreferences?.getString(
                                                SharedPreferencesKeys
                                                    .referredDialogTitleKey) ??
                                            "")
                                        .isNotEmpty
                                    ? sharedPreferences!.getString(
                                        SharedPreferencesKeys
                                            .referredDialogTitleKey)!
                                    : "Referral Disclaimer",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: size.width * AppDimensions.numD05,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: textColor,
                                    size: size.width * AppDimensions.numD06,
                                  )),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * AppDimensions.numD04),
                          child: Divider(
                            color: borderColor,
                            thickness: 1.0,
                          ),
                        ),
                        Flexible(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * AppDimensions.numD04,
                                  vertical: size.width * AppDimensions.numD02),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              size.width *
                                                  AppDimensions.numD04),
                                          border:
                                              Border.all(color: borderColor),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              size.width *
                                                  AppDimensions.numD04),
                                          child: (sharedPreferences?.getString(
                                                          SharedPreferencesKeys
                                                              .referredDialogRabbitImageKey) ??
                                                      "")
                                                  .isNotEmpty
                                              ? Image.network(
                                                  sharedPreferences!.getString(
                                                      SharedPreferencesKeys
                                                          .referredDialogRabbitImageKey)!,
                                                  height: size.width *
                                                      AppDimensions.numD30,
                                                  width: size.width *
                                                      AppDimensions.numD35,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Image.asset(
                                                    "assets/rabbits/student_beans_rabbit2.png",
                                                    height: size.width *
                                                        AppDimensions.numD30,
                                                    width: size.width *
                                                        AppDimensions.numD35,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : Image.asset(
                                                  "assets/rabbits/student_beans_rabbit2.png",
                                                  height: size.width *
                                                      AppDimensions.numD30,
                                                  width: size.width *
                                                      AppDimensions.numD35,
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            size.width * AppDimensions.numD04,
                                      ),
                                      Expanded(
                                        child: Text(
                                          textAlign: TextAlign.justify,
                                          (sharedPreferences?.getString(
                                                          SharedPreferencesKeys
                                                              .referredDialogDescriptionKey) ??
                                                      "")
                                                  .isNotEmpty
                                              ? sharedPreferences!.getString(
                                                  SharedPreferencesKeys
                                                      .referredDialogDescriptionKey)!
                                              : "By sharing your referral link, you confirm that you have a personal relationship with the recipient and that they have consented to receive this invitation.",
                                          style: TextStyle(
                                            color: textColor.withValues(
                                                alpha: 0.8),
                                            fontSize: size.width *
                                                AppDimensions.numD037,
                                            fontWeight: FontWeight.w500,
                                            height: 1.5,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                                      "No",
                                      size,
                                      commonButtonTextStyle(size),
                                      commonButtonStyle(size, Colors.black),
                                      () {
                                    Navigator.pop(context);
                                  }),
                                ),
                              ),
                              SizedBox(
                                width: size.width * AppDimensions.numD04,
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: size.width * AppDimensions.numD12,
                                  child: commonElevatedButton(
                                      "Yes",
                                      size,
                                      commonButtonTextStyle(size),
                                      commonButtonStyle(
                                          size, AppColorTheme.colorThemePink),
                                      () {
                                    onConfirm();
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
}
