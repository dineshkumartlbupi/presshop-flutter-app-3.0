import 'package:flutter/material.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/utils/shared_preferences.dart';

import 'package:presshop/core/analytics/analytics_constants.dart';
import 'package:presshop/core/analytics/analytics_mixin.dart';
import 'package:presshop/core/router/router_constants.dart';
import 'package:go_router/go_router.dart';

// ignore: must_be_immutable
class WelcomeScreen extends StatefulWidget {
  WelcomeScreen({
    super.key,
    required this.hideLeading,
    required this.screenType,
    this.isSocialLogin = false,
    this.sourceDataType = "",
    this.sourceDataIsOpened = false,
    this.sourceDataUrl = "",
    this.sourceDataHeading = "",
    this.sourceDataDescription = "",
    this.isClick = false,
  });
  bool hideLeading = false;
  String screenType = "";
  bool isSocialLogin = false;
  String? sourceDataType = "";
  bool? sourceDataIsOpened = false;
  String? sourceDataUrl = "";
  String? sourceDataHeading = "";
  String? sourceDataDescription = "";
  bool isClick = false;

  @override
  State<StatefulWidget> createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> with AnalyticsPageMixin {
  String userName =
      sharedPreferences!.getString(SharedPreferencesKeys.userNameKey) ?? '';

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    print("Data for source2343243423423 ");
    print(widget.sourceDataType ?? "");
    print(widget.sourceDataIsOpened ?? "");
    print(widget.sourceDataUrl ?? "");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Form(
          child: ListView(
            padding: EdgeInsets.symmetric(
                horizontal: size.width * AppDimensions.numD06,
                vertical: size.width * AppDimensions.numD05),
            children: [
              Text(
                '${greeting()} ${userName.toCapitalized()},',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontFamily: "AirbnbCereal",
                    fontSize: size.width * AppDimensions.numD07),
              ),
              SizedBox(
                height: size.width * AppDimensions.numD02,
              ),
              Text(
                AppStrings.welcomeSubTitleText,
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: "AirbnbCereal",
                    fontSize: size.width * AppDimensions.numD035),
              ),
              SizedBox(
                height: size.width * AppDimensions.numD08,
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(
                        size.width * AppDimensions.numD03)),
                padding: EdgeInsets.all(size.width * AppDimensions.numD04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.welcomeSubTitle1Text,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: size.width * AppDimensions.numD04,
                    ),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColorTheme.colorThemePink,
                            size: size.width * AppDimensions.numD06,
                          ),
                          SizedBox(
                            width: size.width * AppDimensions.numD02,
                          ),
                          Expanded(
                            child: Text(AppStrings.acceptedTermsText,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize:
                                        size.width * AppDimensions.numD035,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400)),
                          ),
                        ]),
                    SizedBox(
                      height: size.width * AppDimensions.numD03,
                    ),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColorTheme.colorThemePink,
                            size: size.width * AppDimensions.numD06,
                          ),
                          SizedBox(
                            width: size.width * AppDimensions.numD02,
                          ),
                          Expanded(
                            child: Text(
                                widget.isSocialLogin
                                    ? "Verified your email id"
                                    : "Verify your mobile number",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize:
                                        size.width * AppDimensions.numD035,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400)),
                          ),
                        ]),
                    SizedBox(
                      height: size.width * AppDimensions.numD06,
                    ),
                    Text(
                      "* Set up your Stripe account now to receive payments within 2-7 days when your content is purchased. Just tap the CTA below to get started - it takes less than a minute.",
                      textAlign: TextAlign.start,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD035,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    // Row(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Icon(
                    //         Icons.check_circle,
                    //         color: AppColorTheme.colorThemePink,
                    //         size: size.width * AppDimensions.numD06,
                    //       ),
                    //       SizedBox(
                    //         width: size.width * AppDimensions.numD02,
                    //       ),
                    //       Expanded(
                    //         child: Text(
                    //             "Added your bank details to start receiving money",
                    //             style: commonTextStyle(
                    //                 size: size,
                    //                 fontSize: size.width * AppDimensions.numD035,
                    //                 color: Colors.black,
                    //                 fontWeight: FontWeight.w400)),
                    //       ),
                    //     ]),
                    // SizedBox(
                    //   height: size.width * AppDimensions.numD03,
                    // ),
                    // Row(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Icon(
                    //         Icons.check_circle,
                    //         color: AppColorTheme.colorThemePink,
                    //         size: size.width * AppDimensions.numD06,
                    //       ),
                    //       SizedBox(
                    //         width: size.width * AppDimensions.numD02,
                    //       ),
                    //       Expanded(
                    //         child: Text(
                    //             "Uploaded documents for your bank verification*",
                    //             style: commonTextStyle(
                    //                 size: size,
                    //                 fontSize: size.width * AppDimensions.numD035,
                    //                 color: Colors.black,
                    //                 fontWeight: FontWeight.w400)),
                    //       ),
                    //     ]),
                    //SizedBox(height: size.width * AppDimensions.numD04),
                    // Text(
                    //   "* Your documents are in, and Stripe is now reviewing them. This process usually takes 2-3 days. Sit tight – we'll notify you once the verification is complete, and you'll be ready to receive your funds.",
                    //   textAlign: TextAlign.start,
                    //   style: TextStyle(
                    //       color: Colors.black,
                    //       fontFamily: "AirbnbCereal",
                    //       fontSize: size.width * AppDimensions.numD032),
                    // ),
                  ],
                ),
              ),
              SizedBox(
                height: size.width * AppDimensions.numD15,
              ),
              SizedBox(
                height: size.width * AppDimensions.numD13,
                child: commonElevatedButton(
                    widget.screenType == "publish"
                        ? "Submit Your Content"
                        : "Finish",
                    size,
                    commonButtonTextStyle(size),
                    commonButtonStyle(size, AppColorTheme.colorThemePink), () {
                  if (widget.screenType == "publish") {
                    context.pushNamed(AppRoutes.myDraftName, extra: {
                      'publishedContent': false,
                      'screenType': "welcome"
                    });
                  } else {
                    // facebookAppEvents.setUserData(
                    //   email: sharedPreferences!.getString(emailKey) ?? "",
                    //   phone: sharedPreferences!.getString(phoneKey),
                    //   firstName: sharedPreferences!.getString(firstNameKey),
                    //   lastName: sharedPreferences!.getString(lastNameKey),
                    // );
                    // );
                    context.goNamed(AppRoutes.dashboardName, extra: {
                      'initialPosition': 2,
                      'sourceDataIsOpened': widget.sourceDataIsOpened,
                      'sourceDataType': widget.sourceDataType,
                      'sourceDataUrl': widget.sourceDataUrl,
                      'sourceDataHeading': widget.sourceDataHeading,
                      'sourceDataDescription': widget.sourceDataDescription,
                      'isClick': widget.isClick
                    });
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement pageName
  String get pageName => PageNames.welcomeScreen;
}
