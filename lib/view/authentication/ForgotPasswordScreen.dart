import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonTextField.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/networkOperations/NetworkClass.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:presshop/view/authentication/ResetPassword.dart';
import '../../utils/CommonAppBar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<StatefulWidget> createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    implements NetworkResponse {
  var formKey = GlobalKey<FormState>();

  TextEditingController emailAddressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CommonAppBar(
        elevation: 0,
        title: Text(
          "",
          style:commonBigTitleTextStyle(size, Colors.black),
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
                      fontWeight:FontWeight.w600,
                      fontFamily:'AirbnbCereal',
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
                        fontFamily:'AirbnbCereal',
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
                  prefixIcon: const ImageIcon(
                    AssetImage(
                      "${iconsPath}ic_email.png",
                    ),
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
                    forgotPasswordApi();
                  }
                }),
              ),

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

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case forgotPasswordUrlRequest:
          debugPrint("ForgotPasswordError: $response");
          var map = jsonDecode(response);
          debugPrint("LoginError:$map");
          showSnackBar("Error", map["errors"]["msg"].toString().replaceAll("_", " ").toCapitalized(), Colors.red);
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
        case forgotPasswordUrlRequest:
          var map = jsonDecode(response);
          debugPrint("ForgotPasswordResponse: $response");

          if (map["code"] == 200) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ResetPasswordScreen(
                      emailAddressValue: emailAddressController.text,
                    )));
          }
          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }
}
