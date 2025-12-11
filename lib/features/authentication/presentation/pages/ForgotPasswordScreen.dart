import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/analytics/analytics_constants.dart';
import 'package:presshop/core/analytics/analytics_mixin.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_text_field.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:otp_pin_field/otp_pin_field.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'ResetPasswordScreen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<StatefulWidget> createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with AnalyticsPageMixin {
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
        // debugPrint("Difference:$diff");
        int minutesDiff = diff.inMinutes < 60 ? diff.inMinutes : 0;
        String secondsDiff = (diff.inSeconds % 60).toString().padLeft(2, '0');

        String mDiff =
            minutesDiff < 10 ? "0$minutesDiff" : minutesDiff.toString();

        expireTimeValue = "$mDiff:$secondsDiff";
        // debugPrint("expireTimeValue:$expireTimeValue");
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
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            showSnackBar("Error", state.message, Colors.red);
          } else if (state is ForgotPasswordSent) {
            showSnackBar("Message", "OTP Sent Successfully", Colors.green);
            showOtpBottomSheet(context, emailAddressController.text.trim());
          }
        },
        child: Scaffold(
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
            child: Builder(
              builder: (context) {
                return Form(
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
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            if (state is AuthLoading) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            return commonElevatedButton(
                                submitText,
                                size,
                                commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD035,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                                commonButtonStyle(size, colorThemePink), () {
                              if (formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(ForgotPasswordRequested(emailAddressController.text.trim()));
                              }
                            });
                          },
                        ),
                      ),
                      isIpad
                          ? SizedBox(
                              height: size.height * numD02,
                            )
                          : const SizedBox.shrink(),
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
                          : const SizedBox.shrink(),
                    ],
                  ),
                );
              }
            ),
          ),
        ),
      ),
    );
  }

  void showOtpBottomSheet(BuildContext context, String email) {
    final authBloc = context.read<AuthBloc>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: authBloc,
          child: OtpBottomSheet(
            email: email,
            onResend: () {
              Navigator.pop(bottomSheetContext);
              authBloc.add(ForgotPasswordRequested(email));
              myTimer?.cancel();
              startResendTime();
            },
          ),
        );
      },
    );
  }
}

class OtpBottomSheet extends StatefulWidget {
  final String email;
  final VoidCallback onResend;

  const OtpBottomSheet({
    super.key,
    required this.email,
    required this.onResend,
  });

  @override
  State<OtpBottomSheet> createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends State<OtpBottomSheet> {
  int secondsLeft = 300;
  Timer? _timer;
  final GlobalKey<OtpPinFieldState> _otpPinController =
      GlobalKey<OtpPinFieldState>();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsLeft > 0) {
        setState(() {
          secondsLeft--;
        });
      } else {
        _timer?.cancel();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    String minutes = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    String seconds = (secondsLeft % 60).toString().padLeft(2, '0');
    String expireTimeValue = "$minutes:$seconds";

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ForgotPasswordOtpVerified) {
           Navigator.pop(context); // Close sheet
           Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ResetPasswordScreen(
                  emailAddressValue: widget.email,
                ),
              ),
            );
        } else if (state is AuthError) {
          showSnackBar("Error", state.message, Colors.red);
        }
      },
      child: Stack(
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
                    Navigator.pop(context);
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
                SizedBox(height: size.width * numD05),
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
                        text: "We’ve sent a 5-digit verification code to ",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: size.width * numD035,
                          fontFamily: 'AirbnbCereal_W_Lt',
                        ),
                      ),
                      TextSpan(
                        text: widget.email,
                        style: TextStyle(
                          color: colorThemePink,
                          fontFamily: 'AirbnbCereal_W_Bd',
                          fontSize: size.width * numD035,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.width * numD08),
                OtpPinField(
                  key: _otpPinController,
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
                SizedBox(
                  width: size.width,
                  height: size.width * (isIpad ? numD1 : numD14),
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                         return const Center(child: CircularProgressIndicator());
                      }
                      return commonElevatedButton(
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
                          String otpValue =
                              _otpPinController.currentState?.controller.text ?? "";
                          if (otpValue.isEmpty || otpValue.length < 5) {
                            showSnackBar(
                              "Error",
                              "Please enter the 5-digit OTP",
                              Colors.red,
                            );
                            return;
                          }
                           context.read<AuthBloc>().add(VerifyForgotPasswordOtpRequested(email: widget.email, otp: otpValue));
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: size.width * numD07),
                if (secondsLeft != 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "${iconsPath}ic_time.png",
                        height: size.width * numD06,
                      ),
                      SizedBox(width: size.width * numD02),
                      Text("$otpExpireText $expireTimeValue $minutesText",
                          style: TextStyle(
                              fontFamily: 'AirbnbCereal',
                              color: Colors.black,
                              fontSize: size.width * numD035)),
                    ],
                  ),
                if (secondsLeft != 0) SizedBox(height: size.width * numD06),
                if (secondsLeft == 0)
                  TextButton(
                    onPressed: widget.onResend,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: otpNotReceivedText,
                              style: TextStyle(
                                  fontFamily: 'AirbnbCereal',
                                  color: Colors.black,
                                  fontSize: size.width * numD035)),
                          WidgetSpan(child: SizedBox(width: size.width * 0.01)),
                          TextSpan(
                            text: clickHereText,
                            style: TextStyle(
                              fontFamily: 'AirbnbCereal',
                              color: colorThemePink,
                              fontSize: size.width * numD038,
                            ),
                          ),
                          WidgetSpan(child: SizedBox(width: size.width * 0.01)),
                          TextSpan(
                            text: anotherOneText,
                            style: TextStyle(
                                fontFamily: 'AirbnbCereal',
                                color: Colors.black,
                                fontSize: size.width * numD035),
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
      ),
    );
  }
}
