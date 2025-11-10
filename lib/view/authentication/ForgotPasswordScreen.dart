import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:presshop/utils/AnalyticsConstants.dart';
import 'package:presshop/utils/AnalyticsMixin.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonTextField.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/networkOperations/NetworkClass.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:presshop/view/authentication/ResetPassword.dart';
import '../../utils/CommonAppBar.dart';
import 'package:otp_pin_field/otp_pin_field.dart';
// import 'package:flutter/material.dart';
// import '../../utils/Common.dart';
// import '../../utils/CommonTextField.dart';
// import '../../utils/CommonWigdets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<StatefulWidget> createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with AnalyticsPageMixin
    implements NetworkResponse {
  // Analytics Mixin Requirements
  @override
  String get pageName => PageNames.forgotPassword;

  var formKey = GlobalKey<FormState>();
  Timer? myTimer;
  String expireTimeValue = "5:00";
  bool showResend = false;
  TextEditingController emailAddressController = TextEditingController();

  @override
  void dispose() {
    if (myTimer != null) {
      myTimer!.cancel();
    }
    super.dispose();
  }

  void startResendTime() {
    var startTime = DateTime.now();
    var endTime = DateTime.now().add(const Duration(minutes: 5));
    debugPrint("NewStartTime: $startTime");
    debugPrint("CurrentTime: ${DateTime.now()}");

    myTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      var diff = endTime.difference(DateTime.now());
      if (diff.inSeconds > 0) {
        debugPrint("Difference:$diff");

        int minutesDiff = diff.inMinutes < 60 ? diff.inMinutes : 0;
        String secondsDiff = (diff.inSeconds % 60).toString().padLeft(2, '0');
        debugPrint("minutesDiff:$minutesDiff");
        debugPrint("secondsDiff:$secondsDiff");

        String mDiff =
            minutesDiff < 10 ? "0$minutesDiff" : minutesDiff.toString();

        expireTimeValue = "$mDiff:$secondsDiff";
        debugPrint("expireTimeValue:$expireTimeValue");
      } else {
        expireTimeValue = "00:00";
        showResend = true;
        setState(() {});
        myTimer!.cancel();
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CommonAppBar(
        elevation: 0,
        title: Text(
          "",
          style: commonBigTitleTextStyle(size, Colors.black),
        ),
        centerTitle: false,
        titleSpacing: 0,
        size: size,
        showActions: false,
        hideLeading: false,
        leadingFxn: () {
          Navigator.pop(context);
        },
        actionWidget: null,
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.width * numD25,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * numD06),
                child: Text(
                  forgotPasswordText.toTitleCase(),
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'AirbnbCereal',
                      fontSize: size.width * numD07),
                ),
              ),
              SizedBox(
                height: size.width * numD02,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * numD06),
                child: Text(forgotPasswordSubHeading,
                    style: TextStyle(
                        fontFamily: 'AirbnbCereal',
                        color: Colors.black,
                        fontSize: size.width * numD035)),
              ),
              SizedBox(
                height: size.width * numD08,
              ),

              /// Email Controller
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * numD06),
                child: CommonTextField(
                  size: size,
                  maxLines: 1,
                  borderColor: colorTextFieldBorder,
                  controller: emailAddressController,
                  hintText: emailAddressHintText,
                  textInputFormatters: null,
                  prefixIcon: ImageIcon(
                    AssetImage(
                      "${iconsPath}ic_email.png",
                    ),
                    size: size.width * numD045,
                  ),
                  prefixIconHeight: size.width * numD045,
                  suffixIconIconHeight: 0,
                  suffixIcon: null,
                  hidePassword: false,
                  keyboardType: TextInputType.emailAddress,
                  validator: checkEmailValidator,
                  enableValidations: true,
                  filled: false,
                  filledColor: Colors.transparent,
                  autofocus: false,
                ),
              ),
              const Spacer(),

              /// Submit Button
              Container(
                width: size.width,
                height: size.width * (isIpad ? numD1 : numD14),
                padding: EdgeInsets.symmetric(horizontal: size.width * numD08),
                child: commonElevatedButton(
                    submitText,
                    size,
                    commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),
                    commonButtonStyle(size, colorThemePink), () {
                  if (formKey.currentState!.validate()) {
                    forgotPasswordApi();
                  }
                }),
              ),
              isIpad
                  ? SizedBox(
                      height: size.height * numD02,
                    )
                  : SizedBox.shrink(),
              Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(signInText,
                        style: TextStyle(
                            color: colorThemePink,
                            fontSize: size.width * numD035,
                            fontFamily: 'AirbnbCereal',
                            fontWeight: FontWeight.w700)),
                  )),
              isIpad
                  ? SizedBox(
                      height: size.height * numD04,
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  ///--------Apis Section------------

  void forgotPasswordApi() {
    Map<String, String> params = {
      "email": emailAddressController.text.trim(),
    };
    debugPrint("ForgotPasswordParams: $params");
    NetworkClass.fromNetworkClass(
            forgotPasswordUrl, this, forgotPasswordUrlRequest, params)
        .callRequestServiceHeader(true, "post", null);
  }

  void verifyForgotPasswordOtpApi(String email, String otp) {
    Map<String, String> params = {
      "email": email,
      "otp": otp,
    };
    debugPrint("VerifyOTPParams: $params");

    NetworkClass.fromNetworkClass(
      verifyForgotPasswordOTPUrl,
      this,
      verifyForgotPasswordOtpRequest,
      params,
    ).callRequestServiceHeader(true, "post", null);
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case forgotPasswordUrlRequest:
          var map = jsonDecode(response);
          debugPrint("ForgotPasswordResponse: $response");

          if (map["code"] == 200) {
            showSnackBar("Message", map["data"] ?? "Invalid OTP", Colors.green);

            showOtpBottomSheet(context, emailAddressController.text.trim());
          }
          break;

        case verifyForgotPasswordOtpRequest:
          var map = jsonDecode(response);
          debugPrint("VerifyForgotPasswordOTPResponse: $response");

          if (map["otp_match"]) {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ResetPasswordScreen(
                  emailAddressValue: emailAddressController.text.trim(),
                ),
              ),
            );
          } else {
            showSnackBar("Error", map["message"] ?? "Invalid OTP", Colors.red);
          }
          break;
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case forgotPasswordUrlRequest:
          debugPrint("ForgotPasswordError: $response");
          var map = jsonDecode(response);
          showSnackBar(
            "Error",
            map["errors"]["msg"]
                .toString()
                .replaceAll("_", " ")
                .toCapitalized(),
            Colors.red,
          );
          break;

        case verifyForgotPasswordOtpRequest:
          debugPrint("VerifyForgotPasswordOTPError: $response");
          var map = jsonDecode(response);

          // Navigator.pop(context);
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (_) => ResetPasswordScreen(
          //       emailAddressValue: emailAddressController.text.trim(),
          //     ),
          //   ),
          // );
          showSnackBar(
            "Error",
            map["errors"]["msg"]
                .toString()
                .replaceAll("_", " ")
                .toCapitalized(),
            Colors.red,
          );
          break;
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  void showOtpBottomSheet(BuildContext context, String email) {
    bool _isBottomSheetOpen = false;

    final otpPinController = GlobalKey<OtpPinFieldState>();

    if (_isBottomSheetOpen) return;
    _isBottomSheetOpen = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (bottomSheetContext) {
        var size = MediaQuery.of(bottomSheetContext).size;

        int secondsLeft = 30; // set your desired timer duration here
        Timer? localTimer;

        return StatefulBuilder(
          builder: (context, setModalState) {
            // Start timer once
            localTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
              if (secondsLeft > 0) {
                secondsLeft--;
                setModalState(() {});
              } else {
                timer.cancel();
                setModalState(() {});
              }
            });

            String minutes = (secondsLeft ~/ 60).toString().padLeft(2, '0');
            String seconds = (secondsLeft % 60).toString().padLeft(2, '0');
            String expireTimeValue = "$minutes:$seconds";

            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black54),
                        onPressed: () {
                          Navigator.pop(context); // close manually
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: size.width * numD06,
                    right: size.width * numD06,
                    top: size.width * numD02,
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// Top drag handle + close icon

                      SizedBox(height: size.width * numD05),
                      // Center(
                      //   child: Container(
                      //     width: 40,
                      //     height: 5,
                      //     decoration: BoxDecoration(
                      //       color: Colors.grey[300],
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: size.width * numD05),
                      Text(
                        "Verify OTP",
                        style: TextStyle(
                          fontFamily: 'AirbnbCereal_W_Bd',
                          fontSize: size.width * numD06,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: size.width * numD02),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "We’ve sent a 5-digit verification code to ",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: size.width * numD036,
                                fontFamily: 'AirbnbCereal_W_Lt',
                              ),
                            ),
                            TextSpan(
                              text: email,
                              style: TextStyle(
                                color: colorThemePink,
                                fontFamily: 'AirbnbCereal_W_Bd',
                                fontSize: size.width * numD036,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.width * numD08),

                      // OTP input
                      OtpPinField(
                        key: otpPinController,
                        onSubmit: (pin) => debugPrint("Entered OTP: $pin"),
                        onChange: (pin) => debugPrint("OTP Changed: $pin"),
                        otpPinFieldStyle: OtpPinFieldStyle(
                          defaultFieldBorderColor: colorTextFieldBorder,
                          activeFieldBorderColor: colorTextFieldIcon,
                          defaultFieldBackgroundColor: colorLightGrey,
                          activeFieldBackgroundColor: colorLightGrey,
                          fieldBorderRadius: size.width * numD02,
                          fieldBorderWidth: 0.5,
                        ),
                        maxLength: 5,
                        showCursor: true,
                        cursorColor: colorTextFieldIcon,
                        showCustomKeyboard: false,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        otpPinFieldDecoration: OtpPinFieldDecoration.custom,
                      ),

                      SizedBox(height: size.width * numD1),

                      // Verify button
                      SizedBox(
                        width: size.width,
                        height: size.width * (isIpad ? numD1 : numD14),
                        child: commonElevatedButton(
                          "Verify OTP",
                          size,
                          commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          commonButtonStyle(size, colorThemePink),
                          () {
                            String otpValue = otpPinController
                                    .currentState?.controller.text ??
                                "";
                            if (otpValue.isEmpty || otpValue.length < 5) {
                              showSnackBar(
                                "Error",
                                "Please enter the 5-digit OTP",
                                Colors.red,
                              );
                              return;
                            }
                            verifyForgotPasswordOtpApi(email, otpValue);
                          },
                        ),
                      ),

                      SizedBox(height: size.width * numD07),

                      // Countdown timer
                      if (secondsLeft != 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "${iconsPath}ic_time.png",
                              height: size.width * numD06,
                            ),
                            SizedBox(width: size.width * numD02),
                            Text(
                              "$otpExpireText $expireTimeValue $minutesText",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: size.width * numD035,
                                fontFamily: 'AirbnbCereal_W_Bk',
                              ),
                            ),
                          ],
                        ),

                      if (secondsLeft != 0)
                        SizedBox(height: size.width * numD06),

                      // Resend OTP
                      if (secondsLeft == 0)
                        TextButton(
                          onPressed: () {
                            // ✅ Close only bottom sheet, not screen
                            Navigator.pop(bottomSheetContext);

                            // ✅ Stop timer
                            localTimer?.cancel();

                            // ✅ Call resend logic
                            forgotPasswordApi();

                            // ✅ Restart resend timer logic
                            myTimer?.cancel();
                            startResendTime();
                          },
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: otpNotReceivedText,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: size.width * numD04),
                                ),
                                WidgetSpan(
                                    child: SizedBox(width: size.width * 0.01)),
                                TextSpan(
                                  text: clickHereText,
                                  style: TextStyle(
                                    color: colorThemePink,
                                    fontSize: size.width * numD038,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                WidgetSpan(
                                    child: SizedBox(width: size.width * 0.01)),
                                TextSpan(
                                  text: anotherOneText,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: size.width * numD04,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      SizedBox(height: size.width * numD06),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      // Cleanup when sheet is closed
      _isBottomSheetOpen = false;
    });
  }
}
