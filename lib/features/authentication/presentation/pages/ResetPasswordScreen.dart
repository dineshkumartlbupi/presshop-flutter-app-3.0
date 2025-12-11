import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/widgets/common_text_field.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'package:presshop/core/di/injection_container.dart';

// ignore: must_be_immutable
class ResetPasswordScreen extends StatefulWidget {
  String emailAddressValue = "";

  ResetPasswordScreen({super.key, required this.emailAddressValue});

  @override
  State<StatefulWidget> createState() => ResetPasswordScreenState();
}

class ResetPasswordScreenState extends State<ResetPasswordScreen> {
  var formKey = GlobalKey<FormState>();

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  String passwordStrengthValue = "";

  bool hidePassword = true,
      hideConfirmPassword = true,
      showUppercase = false,
      showLowercase = false,
      showNumber = false,
      showSpecialcase = false,
      showMincase = false;

  @override
  void initState() {
    super.initState();
    setPasswordListener();
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
           if (state is ResetPasswordSuccess) {
             Navigator.pop(context); // Pop ResetPasswordScreen
             Navigator.pop(context); // Pop ForgotPasswordScreen (to return to login)
             showSnackBar(
                "Password Updated!",
                "Your password has been changed successfully!",
                colorOnlineGreen);
           } else if (state is AuthError) {
             showSnackBar("Error", state.message, Colors.red);
           }
        },
        child: Scaffold(
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
                ),
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
                  Text(
                      "Reset your password below to regain access to your account.",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: size.width * numD036,
                          fontFamily: 'AirbnbCereal_W_Lt')),
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
                      } else if (!showNumber) {
                        return '';
                      } else if (!showSpecialcase) {
                        return '';
                      } else if (!showLowercase) {
                        return '';
                      } else if (!showUppercase) {
                        return '';
                      } else if (!showMincase) {
                        return '';
                      }

                      return null; // Password is valid
                    },
                    onChanged: (text) {
                      if (text.toString().length < 8) {
                        showMincase = false;
                      } else {
                        showMincase = true;
                      }

                      if (!RegExp(r'[A-Z]').hasMatch(text.toString())) {
                        showUppercase = false;
                      } else {
                        showUppercase = true;
                      }

                      if (!RegExp(r'[a-z]').hasMatch(text.toString())) {
                        showLowercase = false;
                      } else {
                        showLowercase = true;
                      }

                      if (!RegExp(r'[0-9]').hasMatch(text.toString())) {
                        showNumber = false;
                      } else {
                        showNumber = true;
                      }

                      if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                          .hasMatch(text.toString())) {
                        showSpecialcase = false;
                      } else {
                        showSpecialcase = true;
                      }
                      setState(() {});
                      return null;
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
                      SizedBox(
                        height: size.width * 0.01,
                      ),
                      Text(
                        "Minimum password requirement",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: size.width * 0.035,
                        ),
                      ),
                      SizedBox(
                        height: size.width * 0.02,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                !showLowercase
                                    ? "${iconsPath}cross.png"
                                    : "${iconsPath}check.png",
                                width: 15,
                                height: 15,
                              ),
                              Text(
                                "Contains at least 01 lowercase character",
                                style: TextStyle(
                                    color:
                                        !showLowercase ? Colors.red : Colors.green,
                                    fontSize: size.width * 0.03,
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                          SizedBox(
                            height: size.width * 0.01,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                !showSpecialcase
                                    ? "${iconsPath}cross.png"
                                    : "${iconsPath}check.png",
                                width: 15,
                                height: 15,
                              ),
                              Text(
                                "Contains at least 01 special character",
                                style: TextStyle(
                                    color: !showSpecialcase
                                        ? Colors.red
                                        : Colors.green,
                                    fontSize: size.width * 0.03,
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: size.width * 0.01,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                !showUppercase
                                    ? "${iconsPath}cross.png"
                                    : "${iconsPath}check.png",
                                width: 15,
                                height: 15,
                              ),
                              Text(
                                "Contains at least 01 uppercase character",
                                style: TextStyle(
                                    color:
                                        !showUppercase ? Colors.red : Colors.green,
                                    fontSize: size.width * 0.03,
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                          SizedBox(
                            height: size.width * 0.01,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                !showMincase
                                    ? "${iconsPath}cross.png"
                                    : "${iconsPath}check.png",
                                width: 15,
                                height: 15,
                              ),
                              Text(
                                "Must be at least 08 characters",
                                style: TextStyle(
                                    color: !showMincase ? Colors.red : Colors.green,
                                    fontSize: size.width * 0.03,
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: size.width * 0.01,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            !showNumber
                                ? "${iconsPath}cross.png"
                                : "${iconsPath}check.png",
                            width: 15,
                            height: 15,
                          ),
                          Text(
                            "Contains at least 01 number",
                            style: TextStyle(
                                color: !showNumber ? Colors.red : Colors.green,
                                fontSize: size.width * 0.03,
                                fontWeight: FontWeight.w500),
                          )
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
                      } /* else if (value.length < 8) {
                        return passwordErrorText;
                      }*/
                      else if (passwordController.text.trim() != value) {
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
                  Container(
                    width: size.width,
                    height: size.width * numD14,
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
                             context.read<AuthBloc>().add(ResetPasswordSubmitted(
                               email: widget.emailAddressValue,
                               password: passwordController.text.trim(),
                             ));
                          } else if (passwordController.text.isEmpty) {
                            showSnackBar(
                                'Error', "Please enter new password", Colors.red);
                          } else if (confirmPasswordController.text.isEmpty) {
                            showSnackBar(
                                'Error', "Please confirm new password", Colors.red);
                          }
                        });
                      },
                    ),
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
                          // Or Navigate to login if needed, typically pop to prev stack is fine
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
        ),
      ),
    );
  }

  void setPasswordListener() {
    passwordController.addListener(() {
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
}
