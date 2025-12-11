import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_pin_field/otp_pin_field.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/features/authentication/presentation/pages/WelcomeScreen.dart';
import 'package:presshop/core/di/injection_container.dart';
import '../bloc/verification_bloc.dart';
import '../bloc/verification_event.dart';
import '../bloc/verification_state.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';

class VerifyAccountScreen extends StatefulWidget {
  final String mobileNumberValue;
  final String emailAddressValue;
  final String countryCode;
  final String imagePath;
  final Map<String, String>? params;
  final bool sociallogin;

  const VerifyAccountScreen({
    super.key,
    required this.emailAddressValue,
    required this.mobileNumberValue,
    required this.countryCode,
    required this.params,
    required this.imagePath,
    required this.sociallogin,
  });

  @override
  State<StatefulWidget> createState() => VerifyAccountScreenState();
}

class VerifyAccountScreenState extends State<VerifyAccountScreen> {
  Timer? myTimer;
  final _otpPinFieldMobileController = GlobalKey<OtpPinFieldState>();
  String expireTimeValue = "05:00";
  bool showResend = false;

  @override
  void initState() {
    super.initState();
    startResendTime();
  }

  @override
  void dispose() {
    myTimer?.cancel();
    super.dispose();
  }

  void startResendTime() {
    var endTime = DateTime.now().add(const Duration(minutes: 5));
    myTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!mounted) return;
      var diff = endTime.difference(DateTime.now());
      if (diff.inSeconds > 0) {
        int minutesDiff = diff.inMinutes < 60 ? diff.inMinutes : 0;
        String secondsDiff = (diff.inSeconds % 60).toString().padLeft(2, '0');
        String mDiff = minutesDiff < 10 ? "0$minutesDiff" : minutesDiff.toString();
        setState(() {
          expireTimeValue = "$mDiff:$secondsDiff";
        });
      } else {
        setState(() {
          expireTimeValue = "00:00";
          showResend = true;
        });
        myTimer!.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => sl<VerificationBloc>(),
      child: BlocConsumer<VerificationBloc, VerificationState>(
        listener: (context, state) {
          if (state is VerificationError) {
             showSnackBar("Error", state.message, Colors.red);
          } else if (state is ResendOtpSuccess) {
             showSnackBar("OTP Sent", state.message, Colors.green);
             setState(() {
               showResend = false;
               expireTimeValue = "05:00";
             });
             startResendTime();
          } else if (state is VerifyOtpSuccess) {
             // OTP Verified, now Register
             context.read<VerificationBloc>().add(RegistrationRequested(
               params: widget.params ?? {},
               isSocial: widget.sociallogin,
               imagePath: widget.imagePath,
             ));
          } else if (state is RegistrationSuccess) {
             Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => WelcomeScreen(
                          hideLeading: false,
                          screenType: '',
                          sourceDataIsOpened: state.isSourceDataOpened, 
                          sourceDataType: state.sourceDataType,
                          sourceDataUrl: "", // Assuming handled by WelcomeScreen or logic
                          sourceDataHeading: "",
                          sourceDataDescription: "",
                          isClick: false,
                        )),
                (route) => false);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: CommonAppBar(
              elevation: 0,
              hideLeading: false,
              title: Text(
                "",
                style: commonBigTitleTextStyle(size, Colors.black),
              ),
              centerTitle: false,
              titleSpacing: 0,
              size: size,
              showActions: false,
              leadingFxn: () {
                Navigator.pop(context);
              },
              actionWidget: null,
            ),
            bottomNavigationBar: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: size.width * numD04, vertical: size.width * numD08),
              width: size.width,
              height: size.width * numD13,
              child: commonElevatedButton(
                  nextText,
                  size,
                  commonTextStyle(
                      size: size,
                      fontSize: size.width * numD035,
                      color: Colors.white,
                      fontWeight: FontWeight.w700),
                  commonButtonStyle(size, colorThemePink), () {
                // Submit OTP
                final otp = _otpPinFieldMobileController.currentState?.controller.text ?? "";
                 if (otp.length < 4) {
                    showSnackBar("Error", "Please enter valid OTP", Colors.red);
                    return;
                 }
                context.read<VerificationBloc>().add(VerifyOtpSubmitted(
                  phone: widget.countryCode + widget.mobileNumberValue,
                  email: widget.emailAddressValue,
                  otp: otp,
                ));
              }),
            ),
            body: Stack(
              children: [
                SafeArea(
                  child: Form(
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * numD04, vertical: size.width * numD25),
                      children: [
                        Text(
                          "Verify Your Mobile Number",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: size.width * numD07),
                        ),
                        SizedBox(
                          height: size.width * numD05,
                        ),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: verifyMobileSubHeadingText,
                                style: TextStyle(
                                    color: Colors.black, fontSize: size.width * numD035)),
                            WidgetSpan(
                                child: SizedBox(
                              width: size.width * numD01,
                            )),
                            TextSpan(
                                text: "${widget.countryCode}${widget.mobileNumberValue}",
                                style: TextStyle(
                                    color: colorThemePink,
                                    fontSize: size.width * numD035))
                          ]),
                        ),
                        SizedBox(
                          height: size.width * numD07,
                        ),
                        OtpPinField(
                          key: _otpPinFieldMobileController,
                          otpPinInputCustom: "0",
                          onSubmit: (text) {},
                          onChange: (text) {},
                          otpPinFieldStyle: OtpPinFieldStyle(
                            defaultFieldBorderColor: colorTextFieldBorder,
                            activeFieldBorderColor: colorTextFieldBorder,
                            defaultFieldBackgroundColor: colorLightGrey,
                            activeFieldBackgroundColor: colorLightGrey,
                            fieldBorderRadius: size.width * numD025,
                            fieldBorderWidth: 0.4,
                          ),
                          maxLength: 5,
                          showCursor: true,
                          keyboardType: TextInputType.number,
                          cursorColor: colorTextFieldIcon,
                          showCustomKeyboard: false,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          otpPinFieldDecoration: OtpPinFieldDecoration.custom,
                        ),
                        SizedBox(
                          height: size.width * numD065,
                        ),
                        Row(
                          children: [
                            Image.asset(
                              "${iconsPath}ic_time.png",
                              height: size.width * numD06,
                            ),
                            SizedBox(
                              width: size.width * numD02,
                            ),
                            Text("$otpExpireText $expireTimeValue $minutesText",
                                style: TextStyle(
                                    color: Colors.black, fontSize: size.width * numD035))
                          ],
                        ),
                        SizedBox(
                          height: size.width * numD06,
                        ),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: otpNotReceivedText,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: size.width * numD035,
                                    fontFamily: 'AirbnbCereal',
                                    fontWeight: FontWeight.normal)),
                            TextSpan(
                              text: " ${clickHereText.toLowerCase()} ",
                              style: TextStyle(
                                  color: colorThemePink,
                                  fontSize: size.width * numD035,
                                  fontFamily: 'AirbnbCereal',
                                  fontWeight: FontWeight.bold),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  if (showResend) {
                                    context.read<VerificationBloc>().add(ResendOtpRequested({
                                       "phone": widget.countryCode + widget.mobileNumberValue,
                                       "email": widget.emailAddressValue,
                                    }));
                                  } else {
                                     showSnackBar("Wait", "Please wait for timer to expire", Colors.black);
                                  }
                                },
                            ),
                            TextSpan(
                                text: anotherOneText,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: size.width * numD035,
                                    fontFamily: 'AirbnbCereal',
                                    fontWeight: FontWeight.normal)),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
                if (state is VerificationLoading)
                   Positioned.fill(
                     child: Container(
                       color: Colors.black26,
                       child: const Center(
                         child: CircularProgressIndicator(),
                       ),
                     ),
                   ),
              ],
            ),
          );
        },
      ),
    );
  }
}
