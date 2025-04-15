import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:otp_pin_field/otp_pin_field.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonTextField.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import '../../utils/CommonAppBar.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../../utils/networkOperations/NetworkResponse.dart';

class ResetPasswordScreen extends StatefulWidget {
  String emailAddressValue = "";

  ResetPasswordScreen({super.key, required this.emailAddressValue});

  @override
  State<StatefulWidget> createState() => ResetPasswordScreenState();
}

class ResetPasswordScreenState extends State<ResetPasswordScreen>
    implements NetworkResponse {
  final _otpPinFieldController = GlobalKey<OtpPinFieldState>();
  var formKey = GlobalKey<FormState>();

  Timer? myTimer;

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  String passwordStrengthValue = "", expireTimeValue = "5:00";

  bool hidePassword = true,
      hideConfirmPassword = true,
      enableNotifications = false,
      showResend = false,
      showLowercase=false,
      showSpecialcase=false,
      showUppercase=false,
      showMincase=false,
      showNumber=false;

  @override
  void initState() {
    super.initState();
    startResendTime();
    setPasswordListener();
  }

  @override
  void dispose() {
    if (myTimer != null) {
      myTimer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
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
        actionWidget: null,
        leadingFxn: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.only(
                left: size.width * numD04,
                right: size.width * numD04,
                top: size.width * numD20),
            children: [
              Text(
                resetPasswordText,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'AirbnbCereal_W_Bd',
                    fontSize: size.width * numD07),
              ),
              SizedBox(
                height: size.width * numD02,
              ),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: resetPasswordSubHeading,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: size.width * numD036,
                          fontFamily: 'AirbnbCereal_W_Lt')),
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: SizedBox(
                        width: size.width * numD01,
                      )),
                  TextSpan(
                      text: widget.emailAddressValue,
                      style: TextStyle(
                          color: colorThemePink,
                          fontFamily: 'AirbnbCerea',
                          fontSize: size.width * numD036))
                ]),
              ),
              SizedBox(
                height: size.width * numD08,
              ),

              /// OTP Controller
              OtpPinField(
                key: _otpPinFieldController,

                /// to clear the Otp pin Controller
                onSubmit: (text) {
                  debugPrint('Entered pin is $text');

                  /// return the entered pin
                },
                onChange: (text) {
                  debugPrint('Enter on change pin is $text');

                  /// return the entered pin
                },

                /// to decorate your Otp_Pin_Field
                otpPinFieldStyle: OtpPinFieldStyle(
                  // border color for inactive/unfocused Otp_Pin_Field
                  defaultFieldBorderColor: colorTextFieldBorder,
                  // border color for active/focused Otp_Pin_Field
                  activeFieldBorderColor: colorTextFieldIcon,

                  /// Background Color for inactive/unfocused Otp_Pin_Field
                  defaultFieldBackgroundColor: colorLightGrey,
                  activeFieldBackgroundColor: colorLightGrey,
                  fieldBorderRadius: size.width * numD02,
                  fieldBorderWidth: 0.5,
                ),
                maxLength: 5,
                showCursor: true,
                cursorColor: colorTextFieldIcon,
                showCustomKeyboard: false,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                otpPinFieldDecoration: OtpPinFieldDecoration.custom,
              ),
              SizedBox(
                height: size.width * numD08,
              ),
              SizedBox(
                height: size.width * numD06,
              ),

              CommonTextField(
                size: size,
                maxLines: 1,
                borderColor: colorTextFieldBorder,
                controller: passwordController,
                hintText: enterNewPasswordHint,
                textInputFormatters: null,
                prefixIcon: const ImageIcon(
                  AssetImage(
                    "${iconsPath}ic_key.png",
                  ),
                ),
                prefixIconHeight: size.width * numD08,
                suffixIconIconHeight: size.width * numD08,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        hidePassword = !hidePassword;
                        setState(() {});
                      },
                      child: ImageIcon(
                        !hidePassword
                            ? const AssetImage(
                                "${iconsPath}ic_show_eye.png",
                              )
                            : const AssetImage(
                                "${iconsPath}ic_block_eye.png",
                              ),
                        color: !hidePassword ? colorTextFieldIcon : colorHint,
                      ),
                    ),
                    SizedBox(
                      width: passwordStrengthValue.isNotEmpty &&
                              passwordStrengthValue == strongText
                          ? size.width * numD02
                          : 0,
                    ),
                    passwordStrengthValue.isNotEmpty &&
                            passwordStrengthValue == strongText
                        ? const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    )
                        : Container(),
                  ],
                ),
                hidePassword: hidePassword,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return requiredText;
                  }else if(!showNumber){
                    return '';
                  }else if(!showSpecialcase){
                    return '';
                  }else if(!showLowercase){
                    return '';
                  }else if(!showUppercase){
                    return '';
                  }else if(!showMincase){
                    return '';
                  }

                  return null; // Password is valid
                },
                onChanged: (text) {
                  if (text.toString().length < 8) {
                    showMincase = false;
                    setState(() {});
                  }else{
                    showMincase = true;
                    setState(() {});
                  }

                  if (!RegExp(r'[A-Z]')
                      .hasMatch(text.toString())) {
                    showUppercase = false;
                    setState(() {});
                  }else{
                    showUppercase = true;
                    setState(() {});
                  }

                  if (!RegExp(r'[a-z]')
                      .hasMatch(text.toString())) {
                    showLowercase = false;
                    setState(() {});
                  }else{
                    showLowercase = true;
                    setState(() {});
                  }

                  if (!RegExp(r'[0-9]')
                      .hasMatch(text.toString())) {
                    showNumber = false;
                    setState(() {});
                  }else{
                    showNumber = true;
                    setState(() {});
                  }

                  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                      .hasMatch(text.toString())) {
                    showSpecialcase = false;
                    setState(() {});
                  }else{
                    showSpecialcase = true;
                    setState(() {});
                  }
                },
                enableValidations: true,
                filled: false,
                filledColor: Colors.transparent,
                autofocus: false,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.width * 0.01,),
                  Text("Minimum password requirement",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: size.width*0.035,

                    ),),
                  SizedBox(height: size.width * 0.02,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            !showLowercase?"${iconsPath}cross.png":"${iconsPath}check.png",
                            width: 15,
                            height: 15,
                          ),
                          Text("Contains at least 01 lowercase character",
                            style: TextStyle(
                                color: !showLowercase?Colors.red:Colors.green,
                                fontSize: size.width*0.03,
                                fontWeight: FontWeight.w500
                            ),)
                        ],
                      ),
                      SizedBox(height: size.width * 0.01,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            !showSpecialcase?"${iconsPath}cross.png":"${iconsPath}check.png",
                            width: 15,
                            height: 15,
                          ),
                          Text("Contains at least 01 special character",
                            style: TextStyle(
                                color: !showSpecialcase?Colors.red:Colors.green,
                                fontSize: size.width*0.03,
                                fontWeight: FontWeight.w500
                            ),)
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: size.width * 0.01,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            !showUppercase?"${iconsPath}cross.png":"${iconsPath}check.png",
                            width: 15,
                            height: 15,
                          ),
                          Text("Contains at least 01 uppercase character",
                            style: TextStyle(
                                color: !showUppercase?Colors.red:Colors.green,
                                fontSize: size.width*0.03,
                                fontWeight: FontWeight.w500
                            ),)
                        ],
                      ),
                      SizedBox(height: size.width * 0.01,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            !showMincase?"${iconsPath}cross.png":"${iconsPath}check.png",
                            width: 15,
                            height: 15,
                          ),
                          Text("Must be at least 08 characters",
                            style: TextStyle(
                                color: !showMincase?Colors.red:Colors.green,
                                fontSize: size.width*0.03,
                                fontWeight: FontWeight.w500
                            ),)
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: size.width * 0.01,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        !showNumber?"${iconsPath}cross.png":"${iconsPath}check.png",
                        width: 15,
                        height: 15,
                      ),
                      Text("Contains at least 01 number",
                        style: TextStyle(
                            color:!showNumber?Colors.red:Colors.green,
                            fontSize: size.width*0.03,
                            fontWeight: FontWeight.w500
                        ),)
                    ],
                  ),



                ],
              ),
              SizedBox(
                height:
                    passwordStrengthValue.isNotEmpty ? size.width * numD02 : 0,
              ),
              passwordStrengthValue.trim().isNotEmpty
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          passwordStrengthText,
                          style: TextStyle(
                              color: colorHint, fontSize: size.width * numD04),
                        ),
                        Text(
                          passwordStrengthValue,
                          style: TextStyle(
                              color: colorThemePink,
                              fontSize: size.width * numD04),
                        ),
                      ],
                    )
                  : Container(),
              SizedBox(
                height: size.width * numD06,
              ),
              CommonTextField(
                size: size,
                maxLines: 1,
                borderColor: colorTextFieldBorder,
                controller: confirmPasswordController,
                hintText: confirmNewPasswordText,
                textInputFormatters: null,
                prefixIcon: const ImageIcon(
                  AssetImage(
                    "${iconsPath}ic_key.png",
                  ),
                ),
                prefixIconHeight: size.width * numD08,
                suffixIconIconHeight: size.width * numD08,
                suffixIcon: InkWell(
                  onTap: () {
                    hideConfirmPassword = !hideConfirmPassword;
                    setState(() {});
                  },
                  child: ImageIcon(
                    !hideConfirmPassword
                        ? const AssetImage(
                            "${iconsPath}ic_show_eye.png",
                          )
                        : const AssetImage(
                            "${iconsPath}ic_block_eye.png",
                          ),
                    color:
                        !hideConfirmPassword ? colorTextFieldIcon : colorHint,
                  ),
                ),
                hidePassword: hideConfirmPassword,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value!.trim().isEmpty) {
                    return requiredText;
                  }/* else if (value.length < 8) {
                    return passwordErrorText;
                  }*/ else if (passwordController.text.trim() != value) {
                    return confirmPasswordErrorText;
                  }
                  return null;
                },
                enableValidations: true,
                filled: false,
                filledColor: Colors.transparent,
                autofocus: false,
              ),
              SizedBox(
                height: size.width * numD07,
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
                          color: Colors.black,
                          fontSize: size.width * numD035,
                          fontFamily: 'AirbnbCereal_W_Bk'))
                ],
              ),
              SizedBox(
                height: size.width * numD04,
              ),
              showResend
                  ? TextButton(
                      onPressed: () {
                        forgotPasswordApi();
                      },
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: otpNotReceivedText,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * numD04)),
                          WidgetSpan(
                              child: SizedBox(
                            width: size.width * 0.01,
                          )),
                          TextSpan(
                              text: clickHereText,
                              style: TextStyle(
                                  color: colorThemePink,
                                  fontSize: size.width * numD038,
                                  fontWeight: FontWeight.w500)),
                          WidgetSpan(
                              child: SizedBox(
                            width: size.width * 0.01,
                          )),
                          TextSpan(
                              text: anotherOneText,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * numD04)),
                        ]),
                      ))
                  : Container(),
              SizedBox(
                height: size.width * numD07,
              ),
              Container(
                width: size.width,
                height: size.width * numD14,
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
                    resetPasswordApi();
                  } else if (passwordController.text.isEmpty) {
                    showSnackBar('Error', "Please enter new password", Colors.red);
                  } else if (confirmPasswordController.text.isEmpty) {
                    showSnackBar(
                        'Error', "Please confirm new password", Colors.red);
                  }
                }),
              ),
              SizedBox(
                height: size.width * numD04,
              ),
              Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text(signInText,
                        style: TextStyle(
                            color: colorThemePink,
                            fontSize: size.width * numD035,
                            fontWeight: FontWeight.w700)),
                  )),
            ],
          ),
        ),
      ),
    );
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

  void setPasswordListener() {
    passwordController.addListener(() {
      var m = passwordExpression.hasMatch(passwordController.text.trim());
      debugPrint("EmailExpression: $m");
      if (passwordController.text.isNotEmpty &&
          passwordController.text.length >= 8 &&
          !passwordExpression.hasMatch(passwordController.text.trim())) {
        passwordStrengthValue = weakText;
      } else if (passwordController.text.isNotEmpty &&
          passwordController.text.length >= 8 &&
          passwordExpression.hasMatch(passwordController.text.trim())) {
        passwordStrengthValue = strongText;
      } else {
        passwordStrengthValue = "";
      }

      setState(() {});
    });
  }

  ///--------Apis Section------------

  void resetPasswordApi() {
    Map<String, String> params = {
      "email": widget.emailAddressValue,
      "otp": _otpPinFieldController.currentState!.controller.text,
      "password": passwordController.text.trim(),
    };
    debugPrint("ChangePasswordParams: $params");
    NetworkClass.fromNetworkClass(
            resetPasswordUrl, this, resetPasswordUrlRequest, params)
        .callRequestServiceHeader(true, "post", null);
  }

  void forgotPasswordApi() {
    Map<String, String> params = {
      "email": widget.emailAddressValue,
    };
    debugPrint("ForgotPasswordParams: $params");
    NetworkClass.fromNetworkClass(
            forgotPasswordUrl, this, forgotPasswordUrlRequest, params)
        .callRequestServiceHeader(true, "post", null);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case resetPasswordUrlRequest:
          debugPrint("resetPasswordUrlRequestError: $response");
          var map = jsonDecode(response);
          showSnackBar("Error", map['errors']['msg']['msg'].toString(), Colors.red);

          if(map['errors']['msg']['msg']=="IS_EMPTY"){
            showSnackBar("Error", "Please enter your OTP", Colors.red);
          }

          break;
        case forgotPasswordUrlRequest:
          var map = jsonDecode(response);
          showSnackBar("Error", map["errors"]["msg"].toString(), Colors.red);
          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case resetPasswordUrlRequest:
          var map = jsonDecode(response);
          debugPrint("resetPasswordUrlRequestResponse: $response");

          if (map["code"] == 200) {
            Navigator.pop(context);
            Navigator.pop(context);
            showSnackBar(
                "Password Updated!",
                "Your password has been changed successfully!",
                colorOnlineGreen);
          }
          break;
        case forgotPasswordUrlRequest:
          var map = jsonDecode(response);
          if (map["code"] == 200) {
            expireTimeValue = "05:00";
            setState(() {});
            startResendTime();
          }
          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }
}
