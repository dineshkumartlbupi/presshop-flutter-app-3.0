import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonTextField.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/commonWebView.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:presshop/view/authentication/ForgotPasswordScreen.dart';
import 'package:presshop/view/authentication/SignUpScreen.dart';
import 'package:presshop/view/dashboard/Dashboard.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../main.dart';
import '../../utils/CommonSharedPrefrence.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../bankScreens/AddBankScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> implements NetworkResponse {
  var formKey = GlobalKey<FormState>();
  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
  );
  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool hidePassword = true;

  late GoogleSignInAccount _userObj;
  bool _isLoggedIn = false;
  String socialEmail = "";
  String socialId = "";
  String socialName = "";
  String socialProfileImage = "";
  String socialType = "";
  String deviceId = "";
  String isAppInstall = "";

  @override
  void initState() {
    getDeviceInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * numD08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.width * numD25,
                  ),
                  Text(
                    greeting(),
                    style: TextStyle(color: Colors.black, fontFamily: "AirbnbCereal", fontWeight: FontWeight.w600, fontSize: size.width * numD07),
                  ),
                  SizedBox(
                    height: size.width * numD055,
                  ),
                  Container(
                      margin: const EdgeInsets.only(left: 1.8),
                      child: isAppInstall != "true"
                          ? RichText(
                              textAlign: TextAlign.start,
                              text: TextSpan(
                                text: "Ready to dive in? Sign up or Log in to start making headlines with PRESS",
                                style: TextStyle(fontSize: size.width * numD035, color: Colors.black, fontFamily: "AirbnbCereal", fontWeight: FontWeight.w400, height: 1.5),
                                children: [
                                  TextSpan(
                                    text: "HOP",
                                    style: TextStyle(fontSize: size.width * numD035, color: Colors.black, fontFamily: "AirbnbCereal", fontStyle: FontStyle.italic, fontWeight: FontWeight.w400, height: 1.5),
                                  ),
                                  TextSpan(
                                    text: " !",
                                    style: TextStyle(fontSize: size.width * numD038, color: Colors.black, fontFamily: "AirbnbCereal", fontWeight: FontWeight.w400, height: 1.5),
                                  ),
                                ],
                              ),
                            )
                          : Text(loginSubTitleText, style: TextStyle(color: Colors.black, fontSize: size.width * numD035))),

                  SizedBox(
                    height: size.width * numD08,
                  ),

                  /// User name controller
                  CommonTextField(
                    size: size,
                    borderColor: colorTextFieldBorder,
                    maxLines: 1,
                    controller: loginController,
                    hintText: loginUserHint,
                    textInputFormatters: null,
                    prefixIcon: const ImageIcon(
                      AssetImage(
                        "${iconsPath}ic_user.png",
                      ),
                    ),
                    prefixIconHeight: size.width * numD05,
                    suffixIconIconHeight: 0,
                    suffixIcon: null,
                    hidePassword: false,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return requiredText;
                      } else if (value.trim().length < 4) {
                        return validUserNameOrPhoneText;
                      }
                      return null;
                    },
                    enableValidations: true,
                    filled: false,
                    filledColor: Colors.transparent,
                    autofocus: false,
                  ),

                  SizedBox(
                    height: size.width * numD08,
                  ),

                  /// Password Controller
                  CommonTextField(
                    size: size,
                    maxLines: 1,
                    borderColor: colorTextFieldBorder,
                    controller: passwordController,
                    hintText: enterPasswordHint,
                    textInputFormatters: null,
                    prefixIcon: const ImageIcon(
                      AssetImage(
                        "${iconsPath}ic_key.png",
                      ),
                    ),
                    prefixIconHeight: size.width * numD07,
                    suffixIconIconHeight: size.width * numD065,
                    suffixIcon: InkWell(
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
                    hidePassword: hidePassword,
                    keyboardType: TextInputType.text,
                    validator: checkPasswordValidator,
                    enableValidations: true,
                    filled: false,
                    filledColor: Colors.transparent,
                    autofocus: false,
                  ),
                  SizedBox(
                    height: size.width * numD058,
                  ),

                  /// Forgot password
                  Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                          },
                          child: Text(
                            "$forgotPasswordText?",
                            style: TextStyle(color: colorThemePink, fontSize: size.width * numD035, fontWeight: FontWeight.w500),
                          ))),

                  SizedBox(
                    height: size.width * numD08,
                  ),

                  /// SignIn Button
                  SizedBox(
                    width: size.width,
                    height: size.width * numD13,
                    child: commonElevatedButton(signInText, size, commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.white, fontWeight: FontWeight.w700), commonButtonStyle(size, colorThemePink), () async {
                      if (formKey.currentState!.validate()) {
                        FocusScope.of(context).requestFocus(FocusNode());
                        callLoginApi();
                      }
                    }),
                  ),
                  SizedBox(
                    height: size.width * numD038,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      orText,
                      style: TextStyle(color: Colors.black, fontSize: size.width * numD04),
                    ),
                  ),

                  SizedBox(
                    height: Platform.isIOS ? size.width * numD036 : 0,
                  ),
                  Platform.isIOS
                      ? Container(
                          width: size.width,
                          height: size.width * numD13,
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(size.width * numD04), border: Border.all(color: colorGoogleButtonBorder)),
                          child: InkWell(
                            splashColor: Colors.grey.shade300,
                            onTap: () async {
                              final credential = await SignInWithApple.getAppleIDCredential(
                                scopes: [
                                  AppleIDAuthorizationScopes.email,
                                  AppleIDAuthorizationScopes.fullName,
                                ],
                              );

                              debugPrint("AppleCredentials: $credential");
                              if (credential != null) {
                                socialId = credential.userIdentifier ?? "";
                                socialEmail = credential.email ?? "";
                                socialName = credential.givenName ?? credential.familyName ?? "";
                                //socialPhoneNumber = '';

                                debugPrint("socialEmail: $socialEmail");
                                debugPrint("socialName: $socialName");
                                debugPrint("SocialId: $socialId");
                                socialExistsApi();
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "${iconsPath}appleLogo.png",
                                  height: size.width * numD045,
                                  width: size.width * numD045,
                                  color: Colors.white,
                                ),
                                SizedBox(width: size.width * numD01),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Sign in with Apple",
                                    style: TextStyle(color: Colors.white, fontSize: size.width * numD036, fontWeight: FontWeight.w500),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : Container(),
                  SizedBox(
                    height: size.width * numD05,
                  ),
                  /*   Platform.isIOS
                      ? Container(
                    width: size.width,
                    height: size.width * numD12,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(size.width * numD04),
                        border: Border.all(color: colorGoogleButtonBorder)),
                    child: InkWell(
                      splashColor: Colors.grey.shade300,
                      onTap: () async {
                        User? user = await Authentication.signInWithGoogle(
                            context: context);
                        if (user != null) {
                          final credential = await SignInWithApple
                              .getAppleIDCredential(
                            scopes: [
                              AppleIDAuthorizationScopes.email,
                              AppleIDAuthorizationScopes.fullName,
                            ],
                          );

                          debugPrint("AppleCredentials: $credential");
                          if (credential != null) {
                            // socialId = credential.userIdentifier ?? "";
                            socialId = credential.userIdentifier ?? "";
                            socialEmail = credential.email ?? "";
                            socialName = credential.givenName ??
                                credential.familyName ??
                                "";
                            //socialPhoneNumber = '';

                            debugPrint("socialEmail: $socialEmail");
                            debugPrint("socialName: $socialName");
                            debugPrint("SocialId: $socialId");
                            socialExistsApi();
                          }
                        } else {
                          debugPrint("Some Google Login Error");
                        }
                      },
                      child: Stack(
                        children: [
                          Positioned(
                              top: 0,
                              bottom: 0,
                              left: size.width * numD01,
                              child: Padding(
                                padding: EdgeInsets.all(size.width * numD025),
                                child: Image.asset(
                                  "assets/icons/appleLogo.png",
                                ),
                              )),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              continueGoogleText,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: size.width * numD035,
                                  fontWeight: FontWeight.w700),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                      : Container(),*/

                  /// Google SignIn
                  InkWell(
                    splashColor: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(size.width * numD04),
                    onTap: () async {
                      googleLogin();
                    },
                    child: Container(
                      width: size.width,
                      height: size.width * numD13,
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(size.width * numD04), border: Border.all(color: colorGoogleButtonBorder)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "${iconsPath}ic_google.png",
                            height: size.width * numD045,
                            width: size.width * numD045,
                          ),
                          SizedBox(width: size.width * numD01),
                          Text(
                            continueGoogleText,
                            style: TextStyle(color: Colors.black, fontSize: size.width * numD036, fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                  ),

                  SizedBox(
                    height: size.width * numD04,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(children: [
                        TextSpan(text: donotHaveAccountText, style: TextStyle(color: Colors.black, fontSize: size.width * numD035, fontWeight: FontWeight.normal)),
                        WidgetSpan(
                            child: SizedBox(
                          width: size.width * 0.005,
                        )),
                        WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => SignUpScreen(
                                          socialLogin: false,
                                          socialId: "",
                                          name: "",
                                          email: "",
                                          phoneNumber: '',
                                        )));
                              },
                              child: Text(clickHereToJoinText, style: TextStyle(color: colorThemePink, fontSize: size.width * numD035, fontWeight: FontWeight.w500)),
                            ))
                      ]),
                    ),
                  ),
                  SizedBox(
                    height: size.width * numD04,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      debugPrint('Running on ${androidInfo.model}');
      deviceId = androidInfo.id;
      debugPrint('deviceId::::::: $deviceId');
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      debugPrint('Running on ${iosInfo.utsname.machine}');
      deviceId = iosInfo.identifierForVendor!;
      debugPrint('deviceId::::::: $deviceId');
    }
    callAppInstallFirstTimeOrNotApi();
  }

  Future<void> googleLogin() async {
    googleSignIn.signIn().then((userData) {
      _isLoggedIn = true;
      _userObj = userData!;

      socialId = _userObj.id;
      socialType = "google";

      if (_userObj.email.isNotEmpty) {
        socialEmail = _userObj.email;
      }
      if (_userObj.displayName != null) {
        socialName = _userObj.displayName!;
      }
      if (_userObj.photoUrl != null) {
        socialProfileImage = _userObj.photoUrl!;
      } else {
        socialProfileImage = "";
      }
      /*callSocialLoginGoogleApi(
          "google", socialId, socialName, socialEmail, socialProfileImage);*/
      socialExistsApi();
      debugPrint("userObj ::${_userObj.toString()}");
      debugPrint("social email ::${_userObj.email.toString()}");
      debugPrint("social displayName ::${_userObj.displayName.toString()}");
      debugPrint("social photoUrl ::${_userObj.photoUrl.toString()}");
    }).catchError((e) {
      debugPrint("error encountered ::: ${e.toString()}");
    });
  }

  ///-------LoginApi-----------

  void callLoginApi() {
    try {
      Map<String, String> params = {"userNameOrPhone": loginController.text.trim(), "password": passwordController.text.trim()};

      debugPrint("LoginParams: $params");
      NetworkClass.fromNetworkClass(loginUrl, this, loginUrlRequest, params).callRequestServiceHeader(true, "post", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  void socialExistsApi() {
    try {
      Map<String, String> params = {"social_id": socialId, "social_type": Platform.isIOS ? "apple" : "google"};

      NetworkClass.fromNetworkClass(socialExistUrl, this, socialExistUrlRequest, params).callRequestServiceHeader(true, "post", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  callAppInstallFirstTimeOrNotApi() {
    NetworkClass(checkAppInstallFirstTimeIrNotUrl + deviceId, this, checkAppInstallFirstTimeIrNotReq).callRequestServiceHeader(false, "get", null);
  }

  void createStripeAccountApi() {
    Map<String, String> map = {
      "email": sharedPreferences!.getString(emailKey).toString(),
      "first_name": sharedPreferences!.getString(firstNameKey).toString(),
      "last_name": sharedPreferences!.getString(lastNameKey).toString(),
      "country": sharedPreferences!.getString(countryKey).toString(),
      "phone": sharedPreferences!.getString(phoneKey).toString(),
      "post_code": sharedPreferences!.getString(postCodeKey).toString(),
      "city": sharedPreferences!.getString(cityKey).toString(),
      "dob": sharedPreferences!.getString(dobKey).toString(),
    };
    debugPrint("stripe map:::::$map");
    NetworkClass.fromNetworkClass(createStripeAccount, this, reqCreateStipeAccount, map).callRequestServiceHeader(true, "post", null);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case loginUrlRequest:
          var map = jsonDecode(response);
          debugPrint("LoginError:$map");
          if (map["code"] == 409) {
            commonErrorDialogDialog(MediaQuery.of(context).size, map["errors"]["msg"].toString().replaceAll("_", " ").toTitleCase(), map["code"].toString(), () {
              Navigator.pop(context);
            });
          } else if (map["code"] == 422) {
            commonErrorDialogDialog(MediaQuery.of(context).size, map["errors"]["msg"].toString().replaceAll("_", " ").toTitleCase(), map["code"].toString(), () {
              Navigator.pop(context);
            });
          } else {
            commonErrorDialogDialog(MediaQuery.of(context).size, "Please enter valid username, phone number or password", map["code"].toString(), () {
              Navigator.pop(context);
            });
          }
          break;
        case reqCreateStipeAccount:
          debugPrint("reqCreateStipeAccount:::::: $response");
          var data = jsonDecode(response);
          commonErrorDialogDialog(MediaQuery.of(context).size, data["errors"]["msg"].toString().replaceAll("_", " ").toTitleCase(), "", () {
            Navigator.pop(context);
          });

          break;
        case checkAppInstallFirstTimeIrNotReq:
          debugPrint("checkAppInstallFirstTimeIrNotReq error:::::: $response");

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
        case loginUrlRequest:
          var map = jsonDecode(response);
          log("LoginResponse success:::::::$map");

          if (map["code"] == 200) {
            rememberMe = true;
            sharedPreferences!.setBool(rememberKey, true);
            sharedPreferences!.setString(tokenKey, map[tokenKey]);
            sharedPreferences!.setString(hopperIdKey, map["user"][hopperIdKey]);
            sharedPreferences!.setString(firstNameKey, map["user"][firstNameKey]);
            sharedPreferences!.setString(lastNameKey, map["user"][lastNameKey]);
            sharedPreferences!.setString(userNameKey, map["user"][userNameKey]);
            sharedPreferences!.setString(emailKey, map["user"][emailKey]);
            sharedPreferences!.setString(countryCodeKey, map["user"][countryCodeKey]);
            sharedPreferences!.setString(phoneKey, map["user"][phoneKey].toString());
            debugPrint("phoneNumber======> ${map["user"][phoneKey]}");
            sharedPreferences!.setString(addressKey, map["user"][addressKey]);
            if (map["user"][postCodeKey] != null) {
              sharedPreferences!.setString(addressKey, map["user"][postCodeKey]);
            }

            sharedPreferences!.setString(latitudeKey, map["user"][latitudeKey].toString());
            sharedPreferences!.setString(longitudeKey, map["user"][longitudeKey].toString());
            if (map["user"][avatarIdKey] != null) {
              sharedPreferences!.setString(avatarIdKey, map["user"][avatarIdKey]["_id"].toString());
              sharedPreferences!.setString(avatarKey, map["user"][avatarIdKey][avatarKey]);
            }

            sharedPreferences!.setBool(receiveTaskNotificationKey, map["user"][receiveTaskNotificationKey]);
            sharedPreferences!.setBool(isTermAcceptedKey, map["user"][isTermAcceptedKey]);

            if (map["user"][profileImageKey] != null) {
              sharedPreferences!.setString(profileImageKey, map["user"][profileImageKey]);
            }

            if (map["user"]["doc_to_become_pro"] != null) {
              debugPrint("InsideDocccc");
              if (map["user"]["doc_to_become_pro"]["govt_id"] != null) {
                debugPrint("InsideGov");

                sharedPreferences!.setString(file1Key, map["user"]["doc_to_become_pro"]["govt_id"]);
                sharedPreferences!.setBool(skipDocumentsKey, true);
              }
              if (map["user"]["doc_to_become_pro"]["comp_incorporation_cert"] != null) {
                sharedPreferences!.setString(file2Key, map["user"]["doc_to_become_pro"]["comp_incorporation_cert"]);
                sharedPreferences!.setBool(skipDocumentsKey, true);
              }

              if (map["user"]["doc_to_become_pro"]["photography_licence"] != null) {
                sharedPreferences!.setString(file3Key, map["user"]["doc_to_become_pro"]["photography_licence"]);
                sharedPreferences!.setBool(skipDocumentsKey, true);
              }
            }

            if (map["user"]["bank_detail"] != null) {
              var bankList = map["user"]["bank_detail"] as List;
              debugPrint("InsideGov ====> $bankList::::${map["user"]["stripe_status"].toString()}");
              if (map["user"]["stripe_status"].toString() == "0") {
                onBoardingCompleteDialog(
                    size: MediaQuery.of(context).size,
                    func: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => AddBankScreen(
                                    editBank: false,
                                    myBankList: [],
                                    screenType: "",
                                    myBankData: null,
                                  )),
                          (route) => false);
                    });
              } else {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => Dashboard(
                              initialPosition: 2,
                            )),
                    (route) => false);
              }
              /*  if (bankList.isEmpty) {
                onBoardingCompleteDialog(
                    size: MediaQuery.of(context).size,
                    func: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => AddBankScreen(
                                    showPageNumber: true,
                                    hideLeading: true,
                                    editBank: false,
                                    myBankList: [],
                                  )),
                          (route) => false);
                    });
              } else {
                if (sharedPreferences!.getBool(skipDocumentsKey) != null) {
                  bool skipDoc = sharedPreferences!.getBool(skipDocumentsKey)!;

                  if (skipDoc) {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) =>
                                Dashboard(initialPosition: 2)),
                        (route) => false);
                  } else {
                    onBoardingCompleteDialog(
                        size: MediaQuery.of(context).size,
                        func: () {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => UploadDocumentsScreen(
                                        menuScreen: false,
                                        hideLeading: true,
                                      )),
                              (route) => false);
                        });
                  }
                } else {
                  onBoardingCompleteDialog(
                      size: MediaQuery.of(context).size,
                      func: () {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => UploadDocumentsScreen(
                                      menuScreen: false,
                                      hideLeading: true,
                                    )),
                            (route) => false);
                      });
                }
              }*/
            }
          }
          break;

        case socialExistUrlRequest:
          var map = jsonDecode(response);
          debugPrint("SocialExistResponse: $response");

          if (map["code"] == 200) {
            if (map["token"] != null) {
              debugPrint("inside this::::::");
              //rememberMe = true;
              //sharedPreferences!.setBool(rememberKey, true);
              sharedPreferences!.setString(tokenKey, map[tokenKey]);
              sharedPreferences!.setString(hopperIdKey, map["user"][hopperIdKey]);
              sharedPreferences!.setString(firstNameKey, map["user"][firstNameKey]);
              sharedPreferences!.setString(lastNameKey, map["user"][lastNameKey]);
              sharedPreferences!.setString(userNameKey, map["user"][userNameKey]);
              sharedPreferences!.setString(emailKey, map["user"][emailKey]);
              sharedPreferences!.setString(countryCodeKey, map["user"][countryCodeKey]);
              sharedPreferences!.setString(phoneKey, map["user"][phoneKey].toString());
              debugPrint("phoneNumber======> ${map["user"][phoneKey]}");
              sharedPreferences!.setString(addressKey, map["user"][addressKey]);
              sharedPreferences!.setString(latitudeKey, map["user"][latitudeKey].toString());
              sharedPreferences!.setString(longitudeKey, map["user"][longitudeKey].toString());
              if (map["user"][avatarIdKey] != null) {
                sharedPreferences!.setString(avatarIdKey, map["user"][avatarIdKey]["_id"].toString());
                sharedPreferences!.setString(avatarKey, map["user"][avatarIdKey][avatarKey]);
              }

              sharedPreferences!.setBool(receiveTaskNotificationKey, map["user"][receiveTaskNotificationKey]);
              sharedPreferences!.setBool(isTermAcceptedKey, map["user"][isTermAcceptedKey]);

              if (map["user"][profileImageKey] != null) {
                sharedPreferences!.setString(profileImageKey, map["user"][profileImageKey]);
              }

              if (map["user"]["doc_to_become_pro"] != null) {
                debugPrint("InsideDoc");
                if (map["user"]["doc_to_become_pro"]["govt_id"] != null) {
                  debugPrint("InsideGov");

                  sharedPreferences!.setString(file1Key, map["user"]["doc_to_become_pro"]["govt_id"]);
                  sharedPreferences!.setBool(skipDocumentsKey, true);
                }
                if (map["user"]["doc_to_become_pro"]["comp_incorporation_cert"] != null) {
                  sharedPreferences!.setString(file2Key, map["user"]["doc_to_become_pro"]["comp_incorporation_cert"]);
                  sharedPreferences!.setBool(skipDocumentsKey, true);
                }

                if (map["user"]["doc_to_become_pro"]["photography_licence"] != null) {
                  sharedPreferences!.setString(file3Key, map["user"]["doc_to_become_pro"]["photography_licence"]);
                  sharedPreferences!.setBool(skipDocumentsKey, true);
                }
              }

              if (map["user"]["bank_detail"] != null) {
                var bankList = map["user"]["bank_detail"] as List;
                debugPrint("bankList:::::${bankList.length}");
                if (bankList.isEmpty) {
                  onBoardingCompleteDialog(
                      size: MediaQuery.of(context).size,
                      func: () {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => AddBankScreen(
                                      editBank: false,
                                      myBankList: const [],
                                      screenType: "",
                                      myBankData: null,
                                    )),
                            (route) => false);
                      });
                } else {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => Dashboard(
                                initialPosition: 2,
                              )),
                      (route) => false);
                }
                /*  else {
                  if (sharedPreferences!.getBool(skipDocumentsKey) != null) {
                    bool skipDoc =
                        sharedPreferences!.getBool(skipDocumentsKey)!;
                    if (skipDoc) {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) =>
                                  Dashboard(initialPosition: 2)),
                          (route) => false);
                    } else {
                      onBoardingCompleteDialog(
                          size: MediaQuery.of(context).size,
                          func: () {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => UploadDocumentsScreen(
                                          menuScreen: false,
                                          hideLeading: true,
                                        )),
                                (route) => false);
                          });
                    }
                  } else {
                    onBoardingCompleteDialog(
                        size: MediaQuery.of(context).size,
                        func: () {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => UploadDocumentsScreen(
                                        menuScreen: false,
                                        hideLeading: true,
                                      )),
                              (route) => false);
                        });
                  }
                }*/
              }
            } else {
              Navigator.of(navigatorKey.currentState!.context).push(MaterialPageRoute(
                  builder: (context) => SignUpScreen(
                        socialLogin: true,
                        socialId: socialId,
                        name: socialName,
                        email: socialEmail,
                        phoneNumber: "",
                      )));
            }
          }
          break;
        case reqCreateStipeAccount:
          debugPrint("reqCreateStipeAccount success::::::$response");
          var data = jsonDecode(response);

          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => CommonWebView(
                    webUrl: data['message']['url'] ?? "",
                    title: "PressHop",
                    accountId: data['account_id']['id'] ?? "",
                    type: "",
                  )));
          break;

        case checkAppInstallFirstTimeIrNotReq:
          debugPrint("checkAppInstallFirstTimeIrNotReq success:::::: $response");
          var data = jsonDecode(response);
          isAppInstall = data['data'].toString();
          debugPrint("isAppInstall:::::: $isAppInstall");
          setState(() {});

          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }
}

class Authentication {
  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    showLoaderDialog(context);
    FirebaseAuth auth = FirebaseAuth.instance;
    debugPrint('inside authentication====>');
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();
    debugPrint('inside authentication2====>');
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    debugPrint('inside authentication3====>');
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      debugPrint('inside authentication4====>');
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential = await auth.signInWithCredential(credential);

        user = userCredential.user;
        debugPrint("user===>$user");
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          showSnackBar("Error", "This account already exists with different credentials", Colors.red);
        } else if (e.code == 'invalid-credential') {
          showSnackBar("Invalid Credentials", "The credentials are invalid", Colors.red);
        }
      } catch (e) {
        debugPrint("$e");
      }
    }
    Navigator.pop(navigatorKey.currentContext!);
    return user;
  }

  static Future<void> signOutWithGoogle({required BuildContext context}) async {
    showLoaderDialog(context);
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    googleSignIn.isSignedIn().then((value) {
      if (value) {
        auth.signOut();
        googleSignIn.signOut();
      }
    });
    Navigator.pop(navigatorKey.currentContext!);
  }

  static Future<bool> signInAlready() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    return await googleSignIn.isSignedIn();
  }
}
