import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:otp_pin_field/otp_pin_field.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonSharedPrefrence.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/commonWebView.dart';
import 'package:presshop/view/bankScreens/AddBankScreen.dart';
import '../../main.dart';
import '../../utils/CommonAppBar.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../../utils/networkOperations/NetworkResponse.dart';
/// change by aditya
class VerifyAccountScreen extends StatefulWidget {
  String mobileNumberValue = "";
  String emailAddressValue = "";
  String countryCode = "";
  String imagePath = "";
  Map<String, String>? params;
  bool sociallogin = false;

  VerifyAccountScreen(
      {super.key,
      required this.emailAddressValue,
      required this.mobileNumberValue,
      required this.countryCode,
      required this.params,
      required this.imagePath,
      required this.sociallogin});

  @override
  State<StatefulWidget> createState() => VerifyAccountScreenState();
}

class VerifyAccountScreenState extends State<VerifyAccountScreen>
    implements NetworkResponse {
  Timer? myTimer;

  Duration myDuration = const Duration(minutes: 5);

  final _otpPinFieldMobileController = GlobalKey<OtpPinFieldState>();
  final _otpPinFieldEmailController = GlobalKey<OtpPinFieldState>();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  String passwordStrengthValue = "", expireTimeValue = "5:00";
  bool hidePassword = true,
      hideConfirmPassword = true,
      enableNotifications = false,
      showResend = false;

  @override
  void initState() {
    super.initState();
    startResendTime();
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
        leadingFxn: () {
          Navigator.pop(context);
        },
        actionWidget: null,
      ),
      bottomNavigationBar:Container(
        margin: EdgeInsets.symmetric(horizontal: size.width*numD04,vertical:size.width*numD04),
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
            commonButtonStyle(size, colorThemePink),
                () async {
            verifyOtpApi();

            }),
      ),
      body: SafeArea(
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
                      text:
                          "${widget.countryCode}${widget.mobileNumberValue}",
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
                  defaultFieldBorderColor: colorTextFieldBorder,
                  activeFieldBorderColor: colorTextFieldBorder,

                  /// Background Color for inactive/unfocused Otp_Pin_Field
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
              /*!showResend
                  ? RichText(
                    text: TextSpan(children: [
                      TextSpan(
                          text:otpNotReceivedText ,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * numD038,
                              fontWeight: FontWeight.normal)),
                      TextSpan(
                        text: " ${clickHereText.toLowerCase()} ",
                        style: TextStyle(
                            color: colorThemePink,
                            fontSize: size.width * numD038,
                            fontWeight: FontWeight.bold),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            showResend = false;
                            setState(() {});
                            sendOtpApi();
                          },

                      ),
                      TextSpan(
                          text: "$anotherOneText!",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * numD038,
                              fontWeight: FontWeight.normal)),
                    ]),
                  )
                  : Container(),*/

               RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text:otpNotReceivedText ,
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
                        showResend = false;
                        if (myTimer != null) {
                          myTimer!.cancel();
                        }
                        setState(() {});
                        sendOtpApi();


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

              SizedBox(
                height: size.width * numD05,
              ),
         /*     Align(
                alignment: Alignment.center,
                child: Text("1 of 3",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: size.width * numD035,
                        fontWeight: FontWeight.w500)),
              ),*/
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

  ///ApisSection------------

  void sendOtpApi() {
    try {
      Map<String, String> params = {
        "phone": widget.countryCode+widget.mobileNumberValue,
        "email": widget.emailAddressValue
      };

      debugPrint("map:::::$params");
      NetworkClass.fromNetworkClass(sendOtpUrl, this, sendOtpUrlRequest, params)
          .callRequestServiceHeader(true, "post", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  void verifyOtpApi() {
    try {
      Map<String, String> params = {
        "phone": widget.countryCode+widget.mobileNumberValue,
        "email": widget.emailAddressValue,
        "phone_otp":_otpPinFieldMobileController.currentState!.controller.text.toString(),

      };
      debugPrint("VerifyParams:::::$params");
      NetworkClass.fromNetworkClass(
              verifyOtpUrl, this, verifyOtpUrlRequest, params)
          .callRequestServiceHeader(true, "post", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  void registerApi() {
    try {
      debugPrint("VerifyParams:${widget.params}");
      NetworkClass.fromNetworkClass(registerUrl, this,
              registerUrlRequest, widget.params,)
          .callRequestServiceHeader(true, "post",null);
     /* NetworkClass.multipartNetworkClassFiles(registerUrl, this,
              registerUrlRequest, widget.params, [File(widget.imagePath)])
          .callMultipartService(true, "post", ["profile_image"],[]);*/
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  void socialRegisterLoginApi() {
    try {
      debugPrint("SocialParams:${widget.params}");
      NetworkClass.fromNetworkClass(socialLoginRegisterUrl, this,
        socialLoginRegisterUrlRequest, widget.params,)
          .callRequestServiceHeader(true, "post",null);
      NetworkClass.multipartNetworkClassFiles(
              socialLoginRegisterUrl,
              this,
              socialLoginRegisterUrlRequest,
              widget.params,
              [File(widget.imagePath)])
          .callMultipartService(true, "post", ["profile_image"],[]);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }


  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case checkUserNameUrlRequest:
          var map = jsonDecode(response);
          debugPrint("CheckUserNameResponseError:$map");

          break;
        case verifyOtpUrlRequest:
          var data = jsonDecode(response);
          debugPrint("verifyOtpUrlRequest error::::$data");
                showSnackBar("Error", data["errors"]["msg"].toString().replaceAll("_", " "), Colors.red);


          /*  commonErrorDialogDialog(
              MediaQuery.of(context).size, data["errors"]["msg"].toString().replaceAll("_", " ").toCapitalized(),"",
                  () {
                Navigator.pop(context);
              });*/

          break;

        case registerUrlRequest:
          var map = jsonDecode(response);
          debugPrint("RegisterError: $response");

          break;
        case reqCreateStipeAccount:
          debugPrint("stripe accountResponse ===> ${jsonDecode(response)}");
        var data = jsonDecode(response);
          commonErrorDialogDialog(
              MediaQuery.of(context).size, data["errors"]["msg"].toString().replaceAll("_", " "),"",
                  () {
                Navigator.pop(context);
              });

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
        case sendOtpUrlRequest:
          var map = jsonDecode(response);
          expireTimeValue = "05:00";

          var data = jsonDecode(response);
          showSnackBar("New OTP", data["data"].toString().replaceAll("_", " "), Colors.green);
          startResendTime();
          break;

        case verifyOtpUrlRequest:
          debugPrint("VerifyResponse  success:::::::: $response");
          var map = jsonDecode(response);
          if (myTimer != null) {
            myTimer!.cancel();
          }
          if (map["code"] == 200) {
            if (widget.sociallogin) {
              socialRegisterLoginApi();
            } else {
              registerApi();
            }
          }

          break;
        case registerUrlRequest:
          debugPrint("RegisterSuccess: $response");
          var map = jsonDecode(response);

          if (map["code"] == 200) {
            rememberMe = true;
            sharedPreferences!.setBool(rememberKey, true);
            sharedPreferences!.setString(tokenKey, map["response"][tokenKey]);
            sharedPreferences!
                .setString(hopperIdKey, map["response"]["user"][hopperIdKey]);
            sharedPreferences!
                .setString(firstNameKey, map["response"]["user"][firstNameKey]);
            sharedPreferences!
                .setString(lastNameKey, map["response"]["user"][lastNameKey]);
            sharedPreferences!
                .setString(userNameKey, map["response"]["user"][userNameKey]);
            sharedPreferences!
                .setString(emailKey, map["response"]["user"][emailKey]);
            sharedPreferences!.setString(
                countryCodeKey, map["response"]["user"][countryCodeKey]);
            sharedPreferences!
                .setString(addressKey, map["response"]["user"][addressKey]);
            sharedPreferences!.setString(
                latitudeKey, map["response"]["user"][latitudeKey].toString());
            sharedPreferences!.setString(
                longitudeKey, map["response"]["user"][longitudeKey].toString());

            if(map["response"]["user"][avatarIdKey]!=null){
              sharedPreferences!
                  .setString(avatarIdKey, map["response"]["user"][avatarIdKey]);
            }
            sharedPreferences!.setBool(receiveTaskNotificationKey,
                map["response"]["user"][receiveTaskNotificationKey]);
            sharedPreferences!.setBool(
                isTermAcceptedKey, map["response"]["user"][isTermAcceptedKey]);

           Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => AddBankScreen(
                      editBank: false,
                      myBankList: [],
                      screenType:"",
                      myBankData: null,
                    )),
                (route) => false);


          }

          break;
        case socialLoginRegisterUrlRequest:
          debugPrint("SocialSuccess: $response");
          var map = jsonDecode(response);

          if (map["code"] == 200) {
            rememberMe = true;
            sharedPreferences!.setBool(rememberKey, true);
            sharedPreferences!.setString(tokenKey, map[tokenKey]);
            sharedPreferences!
                .setString(hopperIdKey, map["user"][hopperIdKey]);
            sharedPreferences!
                .setString(firstNameKey, map["user"][firstNameKey]);
            sharedPreferences!
                .setString(lastNameKey, map["user"][lastNameKey]);
            sharedPreferences!
                .setString(userNameKey, map["user"][userNameKey]);
            sharedPreferences!
                .setString(emailKey, map["user"][emailKey]);
            sharedPreferences!.setString(
                countryCodeKey, map["user"][countryCodeKey]);
            sharedPreferences!
                .setString(addressKey, map["user"][addressKey]);
            sharedPreferences!.setString(
                latitudeKey, map["user"][latitudeKey].toString());
            sharedPreferences!.setString(
                longitudeKey, map["user"][longitudeKey].toString());
            sharedPreferences!
                .setString(avatarIdKey, map["user"][avatarIdKey]);
            sharedPreferences!.setBool(receiveTaskNotificationKey,
                map["user"][receiveTaskNotificationKey]);
            sharedPreferences!.setBool(
                isTermAcceptedKey, map["user"][isTermAcceptedKey]);

            if(map["user"][profileImageKey]!=null){
              sharedPreferences!.setString(
                  profileImageKey, map["user"][profileImageKey]);
            }
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => AddBankScreen(
                      editBank: false,
                      myBankList: const [],
                      screenType:"",
                      myBankData: null,
                    )),
                    (route) => false);
          }

          break;

      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }
}





