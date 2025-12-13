import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/utils/extensions.dart';
import 'package:presshop/core/widgets/common_text_field.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/core/widgets/common_web_view.dart';
import 'package:presshop/core/api/network_response.dart';
import 'ForgotPasswordScreen.dart';
import 'SocialSignUpScreen.dart';
import 'SignUpScreen.dart';
import 'package:presshop/features/dashboard/presentation/pages/Dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:presshop/main.dart';
import 'package:presshop/core/analytics/analytics_constants.dart';
import 'package:presshop/core/analytics/analytics_mixin.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:presshop/core/api/network_class.dart';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/di/injection_container.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../bloc/signup_bloc.dart';
import '../bloc/signup_event.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> with AnalyticsPageMixin {
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
  late FirebaseAuth _firebaseAuth;

  bool _isLoggedIn = false;
  String socialEmail = "";
  String socialId = "";
  String socialName = "";
  String socialProfileImage = "";
  String socialType = "";
  String deviceId = "";
  String isAppInstall = "";
  late String rawNonce;
  late String nonce;

  /// Returns the sha256 hash of [input] in hex notation.
  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  void initState() {
    _firebaseAuth = FirebaseAuth.instance;
    rawNonce = generateNonce();
    nonce = sha256ofString(rawNonce);
    getDeviceInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            commonErrorDialogDialog(
                MediaQuery.of(context).size, state.message, "", () {
              Navigator.pop(context);
            });
          } else if (state is AuthAuthenticated) {
            _handleLoginSuccess(state.user.source!);
          } else if (state is AuthSocialSignUpRequired) {
            Navigator.of(navigatorKey.currentState!.context).push(
              MaterialPageRoute(
                builder: (context) => SocialSignUp(
                  socialLogin: true,
                  socialId: state.socialId,
                  name: state.name,
                  email: state.email,
                  phoneNumber: "",
                  socialType: state.socialType,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                SafeArea(
                  child: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * numD08),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: size.width * numD25,
                            ),
                            Text(
                              greeting(),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: "AirbnbCereal",
                                  fontWeight: FontWeight.w600,
                                  fontSize: size.width * numD07),
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
                                          text:
                                              "Ready to dive in? Sign up or Log in to start making headlines with Press",
                                          style: TextStyle(
                                              fontSize: size.width * numD035,
                                              color: Colors.black,
                                              fontFamily: "AirbnbCereal",
                                              fontWeight: FontWeight.w400,
                                              height: 1.5),
                                          children: [
                                            TextSpan(
                                              text: "Hop",
                                              style: TextStyle(
                                                  fontSize:
                                                      size.width * numD035,
                                                  color: Colors.black,
                                                  fontFamily: "AirbnbCereal",
                                                  fontWeight: FontWeight.w400,
                                                  height: 1.5),
                                            ),
                                            TextSpan(
                                              text: " !",
                                              style: TextStyle(
                                                  fontSize:
                                                      size.width * numD038,
                                                  color: Colors.black,
                                                  fontFamily: "AirbnbCereal",
                                                  fontWeight: FontWeight.w400,
                                                  height: 1.5),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Text(loginSubTitleText,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: size.width * numD035))),

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
                              prefixIcon: ImageIcon(
                                AssetImage(
                                  "${iconsPath}ic_user.png",
                                ),
                                size: size.width * numD04,
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
                              prefixIcon: ImageIcon(
                                AssetImage(
                                  "${iconsPath}ic_key.png",
                                ),
                                size: size.width * numD04,
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
                                  color: !hidePassword
                                      ? colorTextFieldIcon
                                      : colorHint,
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
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const ForgotPasswordScreen()));
                                    },
                                    child: Text(
                                      "$forgotPasswordText?",
                                      style: TextStyle(
                                          color: colorThemePink,
                                          fontSize: size.width * numD035,
                                          fontWeight: FontWeight.w500),
                                    ))),

                            SizedBox(
                              height: size.width * numD07,
                            ),

                            /// SignIn Button
                            SizedBox(
                              width: size.width,
                              height: size.width * (isIpad ? numD1 : numD14),
                              child: commonElevatedButton(
                                  signInText,
                                  size,
                                  commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700),
                                  commonButtonStyle(size, colorThemePink),
                                  () async {
                                if (formKey.currentState!.validate()) {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  context.read<AuthBloc>().add(LoginRequested(
                                        username: loginController.text.trim(),
                                        password:
                                            passwordController.text.trim(),
                                      ));
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
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: size.width * numD04),
                              ),
                            ),

                            SizedBox(
                              height: Platform.isIOS ? size.width * numD036 : 0,
                            ),
                            Platform.isIOS
                                ? Container(
                                    width: size.width,
                                    height:
                                        size.width * (isIpad ? numD1 : numD14),
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(
                                            size.width * numD04),
                                        border: Border.all(
                                            color: colorGoogleButtonBorder)),
                                    child: InkWell(
                                      splashColor: Colors.grey.shade300,
                                      onTap: () async {
                                        await appleLogin(context);
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize:
                                                      size.width * numD036,
                                                  fontWeight: FontWeight.w500),
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

                            /// Google SignIn
                            InkWell(
                              splashColor: Colors.grey.shade300,
                              borderRadius:
                                  BorderRadius.circular(size.width * numD04),
                              onTap: () async {
                                googleSignIn.signOut();
                                googleLogin(context);
                              },
                              child: Container(
                                width: size.width,
                                height: size.width * (isIpad ? numD1 : numD14),
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD04),
                                    border: Border.all(
                                        color: colorGoogleButtonBorder)),
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
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: size.width * numD036,
                                          fontWeight: FontWeight.w500),
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
                                  TextSpan(
                                      text: donotHaveAccountText,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: size.width * numD035,
                                          fontWeight: FontWeight.normal)),
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
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MultiBlocProvider(
                                                        providers: [
                                                          BlocProvider(create: (context) => sl<SignUpBloc>()..add(FetchAvatarsEvent())),
                                                          BlocProvider(create: (context) => sl<AuthBloc>()),
                                                        ],
                                                        child: SignUpScreen(
                                                          socialLogin: false,
                                                          socialId: "",
                                                          name: "",
                                                          email: "",
                                                          phoneNumber: '',
                                                        ),
                                                      )));
                                        },
                                        child: Text(clickHereToJoinText,
                                            style: TextStyle(
                                                color: colorThemePink,
                                                fontSize: size.width * numD035,
                                                fontWeight: FontWeight.w500)),
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
                if (state is AuthLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
              ],
            ),
          );
        },
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
    sharedPreferences?.setString(deviceIdKey, deviceId);
  }

  Future<void> googleLogin(BuildContext context) async {
    googleSignIn.signIn().then((userData) {
      if (userData == null) {
        debugPrint("Google Sign-In cancelled by user");
        return;
      }
      _isLoggedIn = true;
      _userObj = userData;

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

      socialType = "google";
      context.read<AuthBloc>().add(SocialLoginRequested(
            socialType: "google",
            socialId: socialId,
            email: socialEmail,
            name: socialName,
            photoUrl: socialProfileImage,
          ));
      debugPrint("userObj ::${_userObj.toString()}");
      debugPrint("social email ::${_userObj.email.toString()}");
      debugPrint("social displayName ::${_userObj.displayName.toString()}");
      debugPrint("social photoUrl ::${_userObj.photoUrl.toString()}");
    }).catchError((e) {
      debugPrint("error encountered ::: ${e.toString()}");
    });
  }

  Future<void> appleLogin(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthProvider = OAuthProvider("apple.com");
      final appleAuthCredential = oauthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
        rawNonce: rawNonce,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(appleAuthCredential);

      debugPrint("✅ Apple sign-in success: ${userCredential.user?.uid}");
      debugPrint("AppleCredential Email: ${appleCredential.email}");
      debugPrint("Firebase User Email: ${userCredential.user?.email}");

      // STEP 1 — Get best available email
      String? emailFromApple = appleCredential.email;
      String? emailFromFirebase = userCredential.user?.email;
      String? finalEmail = emailFromApple?.isNotEmpty == true
          ? emailFromApple
          : (emailFromFirebase?.isNotEmpty == true ? emailFromFirebase : null);

      // STEP 2 — Fallback email if missing
      if (finalEmail == null || finalEmail.isEmpty) {
        final fallbackEmail =
            "${appleCredential.userIdentifier ?? userCredential.user?.uid ?? 'user'}@privaterelay.appleid.com";
        finalEmail = fallbackEmail;
        debugPrint("⚠️ Using fallback email: $finalEmail");
      }

      // STEP 3 — Get best available name
      String? nameFromApple = (appleCredential.givenName != null ||
              appleCredential.familyName != null)
          ? "${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}"
              .trim()
          : null;

      String? finalName;
      if (nameFromApple != null && nameFromApple.isNotEmpty) {
        finalName = nameFromApple;
      } else if (userCredential.user?.displayName != null &&
          userCredential.user!.displayName!.isNotEmpty) {
        finalName = userCredential.user!.displayName!;
      } else if (finalEmail.isNotEmpty) {
        finalName = finalEmail.split('@')[0];
      } else {
        finalName = "User";
      }

      // STEP 4 — Save fallback data locally
      await prefs.setString('apple_email', finalEmail);
      await prefs.setString('apple_name', finalName ?? "User");
      await prefs.setString('apple_id',
          userCredential.user?.uid ?? appleCredential.userIdentifier ?? "");

      // STEP 5 — Set social values
      final socialId =
          userCredential.user?.uid ?? appleCredential.userIdentifier ?? "";
      const socialType = "apple";
      final socialEmail = finalEmail;
      final socialName = finalName;

      debugPrint("socialEmail: $socialEmail");
      debugPrint("socialName: $socialName");
      debugPrint("socialId: $socialId");

      // STEP 6 — Call BLoC
      context.read<AuthBloc>().add(SocialLoginRequested(
            socialType: socialType,
            socialId: socialId,
            email: socialEmail,
            name: socialName ?? "",
            photoUrl: "",
          ));
    } on SignInWithAppleAuthorizationException catch (e) {
      print("Error code");
      print(e.code);
      if (e.code == AuthorizationErrorCode.canceled) {
        debugPrint("Apple Sign-In was cancelled by user");
        return;
      } else {
        debugPrint("Apple Sign-In failed: ${e.code} - ${e.message}");
        showSnackBar(
          "Sign in with Apple failed",
          "Please try again or use another method.",
          Colors.red,
        );
      }
    } catch (e) {
      debugPrint("❌ Apple Sign-In Error: $e");

      // Attempt local fallback if available
      final prefs = await SharedPreferences.getInstance();
      var savedEmail = prefs.getString('apple_email');
      var savedName = prefs.getString('apple_name');
      var savedId = prefs.getString('apple_id');

      if (savedEmail != null && savedEmail.isNotEmpty) {
        debugPrint("⚙️ Using locally saved Apple data");
        context.read<AuthBloc>().add(SocialLoginRequested(
              socialType: "apple",
              socialId: savedId ?? "",
              email: savedEmail,
              name: savedName ?? "User",
              photoUrl: "",
            ));
      } else {
        showSnackBar(
          "Apple Sign-In Failed",
          "We couldn’t complete your sign-in. Please try again.",
          Colors.red,
        );
      }
    }
  }

  void _handleLoginSuccess(Map<String, dynamic> source) {
      if (source.containsKey('bank_detail_missing') && source['bank_detail_missing'] == true) {
          // Handle logic if needed, or simply navigate
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => Dashboard(
                      initialPosition: 2,
                    )),
            (route) => false);
      } else {
         Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => Dashboard(
                      initialPosition: 0, 
                    )),
            (route) => false);
      }
  }

  @override
  // TODO: implement pageName
  String get pageName => PageNames.login;
}
