import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/widgets/common_text_field.dart';

import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/features/dashboard/presentation/pages/Dashboard.dart';
import 'package:presshop/core/di/injection_container.dart';
import '../bloc/account_settings_bloc.dart';
import '../bloc/account_settings_event.dart';
import '../bloc/account_settings_state.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  var formKey = GlobalKey<FormState>();

  late Size size;
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();
  bool hideNewPassword = false,
      showLowercase = false,
      showSpecialcase = false,
      showUppercase = false,
      showMincase = false,
      showNumber = false;
  bool hideCurrentPassword = false;
  bool hideConfirmPassword = false;
  String passwordStrengthValue = "";

  @override
  void initState() {
    super.initState();
    setPasswordListener();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => sl<AccountSettingsBloc>(),
      child: BlocListener<AccountSettingsBloc, AccountSettingsState>(
        listener: (context, state) {
          if (state is AccountSettingsLoading) {
            // Show loading indicator if needed? Actually generic button loader is better or overlay.
            // Using a simple barrier or just relying on fast interaction.
            // For now, let's show a global loader or nothing if the button handles state.
            // Since we don't have a button loader ready, we can show a dialog or snackbar?
            // Usually we show an overlay.
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(child: CircularProgressIndicator()),
            );
          } else if (state is AccountSettingsError) {
             Navigator.pop(context); // Close loading dialog
             showSnackBar("Error", state.message, Colors.red);
          } else if (state is PasswordChangedSuccess) {
             Navigator.pop(context); // Close loading
             _newPasswordController.clear();
             _currentPasswordController.clear();
             _confirmNewPasswordController.clear();
             
             // Navigate back or to dashboard
             Navigator.pop(context);
             showSnackBar(
                "Password updated!",
                "Your password has been successfully changed!",
                colorOnlineGreen);
          }
        },
        child: Scaffold(
          appBar: CommonAppBar(
            elevation: 0,
            hideLeading: false,
            title: Text(
              changePasswordText,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: size.width * appBarHeadingFontSize),
            ),
            centerTitle: false,
            titleSpacing: 0,
            size: size,
            showActions: true,
            leadingFxn: () {
              Navigator.pop(context);
            },
            actionWidget: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => Dashboard(initialPosition: 2)),
                      (route) => false);
                },
                child: Image.asset(
                  "${commonImagePath}rabbitLogo.png",
                  height: size.width * numD07,
                  width: size.width * numD07,
                ),
              ),
              SizedBox(
                width: size.width * numD04,
              )
            ],
          ),
          body: SafeArea(
            child: Form(
              key: formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * numD05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: size.width * numD11, right: size.width * numD1),
                      child: Text(
                        changePasswordSubTitleText,
                        style: TextStyle(
                            color: Colors.black, fontSize: size.width * numD033),
                      ),
                    ),
                    SizedBox(
                      height: size.width * numD06,
                    ),
                    Expanded(
                        child: ListView(
                      children: [
                        /// Current Password
                        Text(
                          currentPasswordText,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                        SizedBox(
                          height: size.width * numD02,
                        ),
                        CommonTextField(
                          size: size,
                          controller: _currentPasswordController,
                          hintText: enterCurrentPasswordHintText,
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
                              hideCurrentPassword = !hideCurrentPassword;
                              setState(() {});
                            },
                            child: ImageIcon(
                              !hideCurrentPassword
                                  ? const AssetImage(
                                      "${iconsPath}ic_show_eye.png",
                                    )
                                  : const AssetImage(
                                      "${iconsPath}ic_block_eye.png",
                                    ),
                              color: !hideCurrentPassword
                                  ? colorTextFieldIcon
                                  : colorHint,
                            ),
                          ),
                          hidePassword: hideCurrentPassword,
                          keyboardType: TextInputType.text,
                          validator: checkPasswordValidator,
                          enableValidations: true,
                          filled: false,
                          filledColor: Colors.transparent,
                          maxLines: 1,
                          borderColor: colorTextFieldBorder,
                          autofocus: false,
                        ),
                        SizedBox(
                          height: size.width * numD06,
                        ),
    
                        /// New Password
                        Text(
                          newPasswordText,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                        SizedBox(
                          height: size.width * numD02,
                        ),
               
                        CommonTextField(
                          size: size,
                          maxLines: 1,
                          borderColor: colorTextFieldBorder,
                          controller: _newPasswordController,
                          hintText: enterNewPasswordHint,
                          textInputFormatters: null,
                          prefixIcon: const ImageIcon(
                            AssetImage(
                              "${iconsPath}ic_key.png",
                            ),
                          ),
                          prefixIconHeight: size.width * numD08,
                          suffixIconIconHeight: size.width * numD08,
                          onChanged: (text) {
                            if (text.toString().length < 8) {
                              showMincase = false;
                              setState(() {});
                            } else {
                              showMincase = true;
                              setState(() {});
                            }
    
                            if (!RegExp(r'[A-Z]').hasMatch(text.toString())) {
                              showUppercase = false;
                              setState(() {});
                            } else {
                              showUppercase = true;
                              setState(() {});
                            }
    
                            if (!RegExp(r'[a-z]').hasMatch(text.toString())) {
                              showLowercase = false;
                              setState(() {});
                            } else {
                              showLowercase = true;
                              setState(() {});
                            }
    
                            if (!RegExp(r'[0-9]').hasMatch(text.toString())) {
                              showNumber = false;
                              setState(() {});
                            } else {
                              showNumber = true;
                              setState(() {});
                            }
    
                            if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                                .hasMatch(text.toString())) {
                              showSpecialcase = false;
                              setState(() {});
                            } else {
                              showSpecialcase = true;
                              setState(() {});
                            }
                            return null;
                          },
                          suffixIcon: InkWell(
                            onTap: () {
                              hideNewPassword = !hideNewPassword;
                              setState(() {});
                            },
                            child: ImageIcon(
                              !hideNewPassword
                                  ? const AssetImage(
                                      "${iconsPath}ic_show_eye.png",
                                    )
                                  : const AssetImage(
                                      "${iconsPath}ic_block_eye.png",
                                    ),
                              color: !hideNewPassword
                                  ? colorTextFieldIcon
                                  : colorHint,
                            ),
                          ),
                          hidePassword: hideNewPassword,
                          keyboardType: TextInputType.text,
                          errorMaxLines: 2,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return requiredText;
                            } else if (_currentPasswordController.text ==
                                _newPasswordController.text) {
                              return "Please choose a new password. The old password cannot be reused.";
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
                          enableValidations: true,
                          filled: false,
                          filledColor: Colors.transparent,
                          autofocus: false,
                        ),
                        SizedBox(height: size.width * numD02),
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
                                          color: !showLowercase
                                              ? Colors.red
                                              : Colors.green,
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
                                          color: !showUppercase
                                              ? Colors.red
                                              : Colors.green,
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
                                          color: !showMincase
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
                                      color: !showNumber
                                          ? Colors.red
                                          : Colors.green,
                                      fontSize: size.width * 0.03,
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: size.width * numD06,
                        ),
    
                        /// Confirm New Password
                        Text(
                          confirmNewPasswordText,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                        SizedBox(
                          height: size.width * numD02,
                        ),
                        CommonTextField(
                          size: size,
                          maxLines: 1,
                          borderColor: colorTextFieldBorder,
                          controller: _confirmNewPasswordController,
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
                              color: !hideConfirmPassword
                                  ? colorTextFieldIcon
                                  : colorHint,
                            ),
                          ),
                          hidePassword: hideConfirmPassword,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return requiredText;
                            } else if (_newPasswordController.text.trim() !=
                                value) {
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
                          height: size.width * numD30,
                        ),
    
                        /// Button
                        Container(
                          width: size.width,
                          height: size.width * numD13,
                          margin: EdgeInsets.symmetric(
                              horizontal: size.width * numD04),
                          child: Builder(
                            builder: (context) {
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
                                  context.read<AccountSettingsBloc>().add(
                                    ChangePasswordEvent(
                                      oldPassword: _currentPasswordController.text.trim(),
                                      newPassword: _newPasswordController.text.trim(),
                                    ),
                                  );
                                }
                              });
                            }
                          ),
                        ),
    
                        SizedBox(
                          height: size.width * numD03,
                        ),
                      ],
                    )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void setPasswordListener() {
    _newPasswordController.addListener(() {
      var m = passwordExpression.hasMatch(_newPasswordController.text.trim());

      debugPrint("EmailExpression: $m");

      if (_newPasswordController.text.isNotEmpty &&
              _newPasswordController.text.length >=
                  8 /*&&
          !passwordExpression.hasMatch(_newPasswordController.text.trim())*/
          ) {
        passwordStrengthValue = weakText;
      } else if (_newPasswordController.text.isNotEmpty &&
          _newPasswordController.text.length >= 8 &&
          passwordExpression.hasMatch(_newPasswordController.text.trim())) {
        passwordStrengthValue = strongText;
      } else {
        passwordStrengthValue = "";
      }

      setState(() {});
    });
  }
}


