import 'dart:async';
import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/router/router_constants.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/features/authentication/constants/auth_constants.dart';
import '../bloc/signup_bloc.dart';
import '../bloc/signup_event.dart';
import '../bloc/signup_state.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/analytics/analytics_constants.dart';
import 'package:presshop/core/analytics/analytics_mixin.dart';
import 'package:presshop/core/widgets/common_text_field.dart';
import 'package:presshop/core/widgets/common_widgets.dart';

import 'package:presshop/core/widgets/common/avatar_bottom_sheet.dart';
import 'package:presshop/features/authentication/presentation/widgets/password_requirements_list.dart';
import 'package:presshop/features/authentication/presentation/widgets/avatar_selection_box.dart';

// ignore: must_be_immutable
class SignUpScreen extends StatefulWidget {
  SignUpScreen(
      {super.key,
      required this.socialLogin,
      required this.socialId,
      required this.email,
      required this.name,
      required this.phoneNumber});
  bool socialLogin = false;
  String socialId = "";
  String name = "";
  String email = "";
  String phoneNumber = "";

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with AnalyticsPageMixin {
  // Analytics Mixin Requirements
  @override
  String get pageName => PageNames.signup;
  Timer? _phoneDebounce;
  Timer? _emailDebounce;
  Timer? _userDebounce;
  Timer? _referralDebounce;

  String? _onUserNameChanged(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    _userDebounce?.cancel();

    _userDebounce = Timer(const Duration(milliseconds: 800), () {
      if (value.trim().length >= 4) {
        checkUserNameApi();
      }
    });
    return null;
  }

  void _onPhoneChanged(String? value) {
    if (value == null || value.trim().isEmpty) return;

    _phoneDebounce?.cancel();

    _phoneDebounce = Timer(const Duration(milliseconds: 600), () {
      if (value.trim().length >= 7) {
        checkPhoneApi();
      }
    });
  }

  @override
  Map<String, Object>? get pageParameters => {
        'social_login': widget.socialLogin.toString(),
        'has_email': widget.email.isNotEmpty.toString(),
      };

  var formKey = GlobalKey<FormState>();
  var scrollController = ScrollController();

  Timer? debounce;
  final ImagePicker _picker = ImagePicker();
  final RegExp _restrictPattern = RegExp(
    r"@(gmail\.com|yahoo\.com|hotmail\.com|outlook\.com)$",
    caseSensitive: true,
  );
  final RegExp _restrictPatter2 = RegExp(r'@(gmail|yahoo|hotmail|outlook)\.');
  final RegExp _restrictPatter3 =
      RegExp('gmail|yahoo|hotmail|outlook', caseSensitive: false);

  ///TextEditingController
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController referralCodeController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController selectDobController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController avatarController = TextEditingController();
  TextEditingController apartmentAndHouseNameController =
      TextEditingController();
  TextEditingController cityNameController = TextEditingController();
  TextEditingController countryNameController = TextEditingController();

  String passwordStrengthValue = "",
      userImagePath = "",
      avatarBaseUrl = "",
      selectedAvatar = "",
      selectedAvatarId = "",
      latitude = "",
      longitude = "",
      selectedDates = "Select date of birth",
      selectedDates1 = "Select date of birth",
      selectedCountryCodePicker = "+44";

  bool hidePassword = true,
      hideConfirmPassword = true,
      enableNotifications = false,
      showImageError = false,
      userNameAlreadyExists = false,
      isRefferalCodeValid = false,
      emailAlreadyExists = false,
      phoneAlreadyExists = false,
      showAvatarError = false,
      showReferralCodeError = false,
      showAddressError = false,
      showApartmentNumberError = false,
      showDateError = false,
      showPostalCodeError = false,
      termConditionsChecked = false,
      showTermConditionError = false,
      showLowercase = false,
      showSpecialcase = false,
      showUppercase = false,
      showMincase = false,
      showNumber = false,
      isSelectCheck = true;
  bool validUserName = false;
  String userNameApiError = "";
  String phoneApiError = "";
  String referralCodeApiError = "";

  List<AvatarData> avatarList = [];

  late GoogleSignInAccount _userObj;
  String socialEmail = "";
  String socialId = "";
  String socialName = "";
  String socialProfileImage = "";
  String socialType = "";
  final ValueNotifier<bool> _avatarsNotifier = ValueNotifier(false);
  late SignUpBloc _signUpBloc;

  @override
  void initState() {
    super.initState();

    if (widget.socialLogin) {
      List<String> nameParts = widget.name.split(' ');
      firstNameController.text = nameParts[0];
      lastNameController.text = nameParts.length > 1 ? nameParts[1] : '';
      emailController.text = widget.email;
      phoneController.text = widget.phoneNumber;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => getAvatarsApi());
    setPasswordListener();
  }

  @override
  void dispose() {
    _emailDebounce?.cancel();
    _phoneDebounce?.cancel();
    _userDebounce?.cancel();
    _referralDebounce?.cancel();
    _avatarsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    _signUpBloc = context.read<SignUpBloc>();

    return BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go(AppRoutes.dashboardPath, extra: {'initialPosition': 2});
          } else if (state is AuthSocialSignUpRequired) {
            setState(() {
              widget.socialLogin = true;
              widget.socialId = state.socialId;
              widget.name = state.name;
              widget.email = state.email;

              List<String> nameParts = state.name.split(' ');
              if (nameParts.isNotEmpty) firstNameController.text = nameParts[0];
              if (nameParts.length > 1) {
                lastNameController.text = nameParts.sublist(1).join(" ");
              }
              emailController.text = state.email;
            });
          } else if (state is AuthError) {
            commonErrorDialogDialog(
                MediaQuery.of(context).size, state.message, "", () {
              context.pop();
            });
          }
        },
        child: BlocConsumer<SignUpBloc, SignUpState>(
          listener: (context, state) {
            if (state is SignUpError) {
              commonErrorDialogDialog(
                  MediaQuery.of(context).size, state.message, "", () {
                context.pop();
              });
            } else if (state is SignUpOtpSent) {
              context.pushNamed(AppRoutes.verifyAccountName, extra: {
                'sociallogin': widget.socialLogin,
                'imagePath': userImagePath,
                'params': Map<String, String>.from(state.data),
                'countryCode': selectedCountryCodePicker,
                'mobileNumberValue': phoneController.text.trim(),
                'emailAddressValue': emailController.text.trim(),
              });
            } else if (state is SignUpSuccess) {
              context
                  .go(AppRoutes.dashboardPath, extra: {'initialPosition': 2});
            } else if (state is AvatarsLoaded) {
              avatarList = state.avatars
                  .map((e) =>
                      AvatarData.fromJson({'_id': e.id, 'avatar': e.avatar}))
                  .toList();

              _avatarsNotifier.value = !_avatarsNotifier.value;
            } else if (state is UserNameCheckResult) {
              userNameAlreadyExists = !state.isAvailable;
              userNameApiError = state.errorMessage;
              setState(() {});
            } else if (state is EmailCheckResult) {
              emailAlreadyExists = !state.isAvailable;
              setState(() {});
            } else if (state is PhoneCheckResult) {
              phoneAlreadyExists = !state.isAvailable;
              phoneApiError = state.errorMessage;
              setState(() {});
            } else if (state is ReferralCodeVerified) {
              isRefferalCodeValid = true;
              showReferralCodeError = false;
              referralCodeApiError = "";
              setState(() {});
            } else if (state is ReferralCodeVerificationFailed) {
              isRefferalCodeValid = false;
              showReferralCodeError = true;
              referralCodeApiError = state.message;
              setState(() {});
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                Scaffold(
                  appBar: CommonAppBar(
                    elevation: 0,
                    hideLeading: false,
                    title: const Text(""),
                    centerTitle: false,
                    titleSpacing: 0,
                    size: size,
                    showActions: false,
                    actionWidget: null,
                    leadingFxn: () {
                      context.pop();
                    },
                    leadingLeftSPace: size.width * AppDimensions.numD04,
                  ),
                  body: SafeArea(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * AppDimensions.numD08),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.signUpText,
                                style:
                                    commonBigTitleTextStyle(size, Colors.black),
                              ),
                              SizedBox(
                                height: size.width * AppDimensions.numD01,
                              ),
                              Text(
                                AppStrings.signUpSubTitleText,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        size.width * AppDimensions.numD035,
                                    fontFamily: 'AirbnbCereal'),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  right: size.width * AppDimensions.numD01,
                                  top: size.width * AppDimensions.numD04,
                                  bottom: size.width * AppDimensions.numD04,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: size.width * AppDimensions.numD04,
                                    ),
                                    AvatarSelectionBox(
                                      size: size,
                                      selectedAvatar: selectedAvatar,
                                      onTap: () => avatarBottomSheet(size),
                                      onClear: () {
                                        selectedAvatar = "";
                                        selectedAvatarId = "";
                                        showAvatarError = true;
                                        for (var element in avatarList) {
                                          element.selected = false;
                                        }
                                        setState(() {});
                                      },
                                    ),
                                    selectedAvatar.isEmpty
                                        ? Align(
                                            alignment: Alignment.topLeft,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: size.width *
                                                      AppDimensions.numD01),
                                              child: Text(
                                                AppStrings.requiredText,
                                                style: commonTextStyle(
                                                    size: size,
                                                    fontSize: size.width *
                                                        AppDimensions.numD03,
                                                    color: Colors.red.shade700,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    SizedBox(
                                      height: size.width * AppDimensions.numD02,
                                    ),
                                    Text(
                                      AppStrings.chooseAvatarNoteText,
                                      style: TextStyle(
                                        color: AppColorTheme.colorHint,
                                        fontSize:
                                            size.width * AppDimensions.numD025,
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                    SizedBox(
                                      height: size.width * AppDimensions.numD06,
                                    ),
                                    CommonTextField(
                                      controller: firstNameController,
                                      size: size,
                                      borderColor:
                                          AppColorTheme.colorTextFieldBorder,
                                      maxLines: 1,
                                      enableValidations: true,
                                      hintText: AppStrings.firstNameHintText,
                                      textInputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp("[a-z A-Z]"))
                                      ],
                                      prefixIcon: const Icon(
                                          Icons.person_outline_sharp),
                                      prefixIconHeight:
                                          size.width * AppDimensions.numD06,
                                      suffixIconIconHeight: 0,
                                      suffixIcon: null,
                                      hidePassword: false,
                                      keyboardType: TextInputType.text,
                                      validator: checkRequiredValidator,
                                      filled: false,
                                      filledColor: Colors.transparent,
                                      autofocus: false,
                                    ),
                                    SizedBox(
                                      height: size.width * AppDimensions.numD06,
                                    ),
                                    CommonTextField(
                                      size: size,
                                      maxLines: 1,
                                      borderColor:
                                          AppColorTheme.colorTextFieldBorder,
                                      controller: lastNameController,
                                      hintText: AppStrings.lastNameHintText,
                                      textInputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp("[a-z A-Z]"))
                                      ],
                                      prefixIcon: const Icon(
                                          Icons.person_outline_sharp),
                                      prefixIconHeight:
                                          size.width * AppDimensions.numD06,
                                      suffixIconIconHeight: 0,
                                      suffixIcon: null,
                                      // Capitalize first letter
                                      hidePassword: false,
                                      keyboardType: TextInputType.name,
                                      validator: checkRequiredValidator,
                                      enableValidations: true,
                                      filled: false,
                                      filledColor: Colors.transparent,
                                      autofocus: false,
                                    ),
                                    SizedBox(
                                      height: size.width * AppDimensions.numD06,
                                    ),
                                    CommonTextField(
                                      size: size,
                                      maxLines: 1,
                                      borderColor:
                                          AppColorTheme.colorTextFieldBorder,
                                      controller: userNameController,
                                      hintText: AppStrings.userNameHintText,
                                      errorMaxLines: 2,
                                      textInputFormatters: [
                                        FilteringTextInputFormatter.deny(
                                            RegExp(r'[ \\]')),
                                      ],
                                      suffixIcon: getUsernameSuffixIcon(),
                                      prefixIcon: const Icon(
                                          Icons.person_outline_sharp),
                                      prefixIconHeight:
                                          size.width * AppDimensions.numD06,
                                      suffixIconIconHeight:
                                          size.width * AppDimensions.numD085,
                                      hidePassword: false,
                                      keyboardType: TextInputType.text,
                                      enableValidations: true,
                                      validator: userNameValidator,
                                      filled: false,
                                      filledColor: Colors.transparent,
                                      autofocus: false,
                                      onChanged: (v) {
                                        _onUserNameChanged(v);
                                        setState(() {});
                                        return null;
                                      },
                                    ),
                                    SizedBox(
                                      height: size.width * AppDimensions.numD01,
                                    ),
                                    Text(
                                      AppStrings.userNameNoteText,
                                      style: TextStyle(
                                          color: AppColorTheme.colorHint,
                                          fontSize: size.width *
                                              AppDimensions.numD025),
                                    ),
                                    SizedBox(
                                      height: size.width * AppDimensions.numD04,
                                    ),
                                    CommonTextField(
                                      size: size,
                                      maxLines: 1,
                                      borderColor:
                                          AppColorTheme.colorTextFieldBorder,
                                      controller: phoneController,
                                      hintText: AppStrings.phoneHintText,
                                      textInputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp("[0-9]")),
                                        LengthLimitingTextInputFormatter(
                                            _getMaxPhoneLength()),
                                      ],
                                      prefixIcon: InkWell(
                                        onTap: () {
                                          openCountryCodePicker();
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.call_outlined),
                                            SizedBox(
                                                width: size.width *
                                                    AppDimensions.numD01),
                                            Text(
                                              selectedCountryCodePicker,
                                              style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD035,
                                                color: Colors.black,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                            Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              size: size.width *
                                                  AppDimensions.numD07,
                                            )
                                          ],
                                        ),
                                      ),
                                      prefixIconHeight:
                                          size.width * AppDimensions.numD06,
                                      suffixIconIconHeight:
                                          size.width * AppDimensions.numD085,
                                      suffixIcon: getPhoneSuffixIcon(),
                                      hidePassword: false,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: false,
                                        signed: true,
                                      ),
                                      validator: checkSignupPhoneValidator,
                                      enableValidations: true,
                                      filled: false,
                                      filledColor: Colors.transparent,
                                      autofocus: false,

                                      ///  DEBOUNCED HERE
                                      onChanged: (val) {
                                        _onPhoneChanged(val);
                                        setState(() {});
                                        return null;
                                      },
                                    ),
                                    SizedBox(
                                      height: size.width * AppDimensions.numD06,
                                    ),
                                    CommonTextField(
                                      size: size,
                                      maxLines: 1,
                                      borderColor:
                                          AppColorTheme.colorTextFieldBorder,
                                      controller: emailController,
                                      hintText: AppStrings.emailHintText,
                                      textInputFormatters: null,
                                      prefixIcon:
                                          const Icon(Icons.email_outlined),
                                      prefixIconHeight:
                                          size.width * AppDimensions.numD06,
                                      suffixIconIconHeight:
                                          size.width * AppDimensions.numD085,
                                      suffixIcon: getEmailSuffixIcon(),
                                      hidePassword: false,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: checkSignupEmailValidator,
                                      enableValidations: true,
                                      filled: false,
                                      filledColor: Colors.transparent,
                                      autofocus: false,
                                      onChanged: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          emailAlreadyExists = false;
                                          setState(() {});
                                          return null;
                                        }

                                        // cancel previous timer
                                        _emailDebounce?.cancel();

                                        setState(() {});

                                        _emailDebounce = Timer(
                                            const Duration(milliseconds: 500),
                                            () {
                                          final email = val.trim();

                                          // call API only if email is valid
                                          if (emailExpression.hasMatch(email)) {
                                            checkEmailApi();
                                          }
                                        });

                                        return null;
                                      },
                                    ),
                                    SizedBox(
                                      height: size.width * AppDimensions.numD06,
                                    ),
                                    CommonTextField(
                                      size: size,
                                      maxLines: 1,
                                      borderColor:
                                          AppColorTheme.colorTextFieldBorder,
                                      controller: referralCodeController,
                                      hintText: AppStrings.referralCodeHintText,
                                      errorMaxLines: 2,
                                      textInputFormatters: [
                                        FilteringTextInputFormatter.deny(
                                            RegExp(r'[ \\]')),
                                      ],
                                      suffixIcon: getReferralCodeSuffixIcon(),
                                      prefixIcon:
                                          const Icon(Icons.campaign_outlined),
                                      prefixIconHeight:
                                          size.width * AppDimensions.numD06,
                                      suffixIconIconHeight:
                                          size.width * AppDimensions.numD085,
                                      hidePassword: false,
                                      keyboardType: TextInputType.text,
                                      enableValidations: false,
                                      validator: null,
                                      filled: false,
                                      filledColor: Colors.transparent,
                                      autofocus: false,
                                      onChanged: (v) {
                                        showReferralCodeError = false;
                                        referralCodeApiError = "";
                                        isRefferalCodeValid = false;

                                        _referralDebounce?.cancel();

                                        if (v != null && v.trim().length >= 5) {
                                          _referralDebounce = Timer(
                                              const Duration(milliseconds: 600),
                                              () {
                                            verifyReferredCode();
                                          });
                                        }
                                        setState(() {});
                                        return null;
                                      },
                                    ),
                                    SizedBox(
                                      height: size.width * AppDimensions.numD01,
                                    ),
                                    if (showReferralCodeError &&
                                        referralCodeApiError.isNotEmpty)
                                      Padding(
                                        padding: EdgeInsets.only(
                                            bottom: size.width *
                                                AppDimensions.numD01),
                                        child: Text(
                                          referralCodeApiError,
                                          style: commonTextStyle(
                                              size: size,
                                              fontSize: size.width *
                                                  AppDimensions.numD03,
                                              color: Colors.red.shade700,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                    Text(
                                      AppStrings.referralcodeNoteText,
                                      style: TextStyle(
                                          color: AppColorTheme.colorHint,
                                          fontSize: size.width *
                                              AppDimensions.numD025),
                                    ),
                                    SizedBox(
                                      height: size.width * AppDimensions.numD04,
                                    ),
                                    !widget.socialLogin
                                        ? CommonTextField(
                                            size: size,
                                            maxLines: 1,
                                            borderColor: AppColorTheme
                                                .colorTextFieldBorder,
                                            controller: passwordController,
                                            hintText:
                                                AppStrings.enterPasswordHint,
                                            textInputFormatters: null,
                                            prefixIcon:
                                                const Icon(Icons.lock_outline),
                                            prefixIconHeight: size.width *
                                                AppDimensions.numD08,
                                            suffixIconIconHeight: size.width *
                                                AppDimensions.numD06,
                                            suffixIcon: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    hidePassword =
                                                        !hidePassword;
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
                                                        ? AppColorTheme
                                                            .colorTextFieldIcon
                                                        : AppColorTheme
                                                            .colorHint,
                                                  ),
                                                ),
                                                if (passwordController
                                                    .text.isNotEmpty) ...[
                                                  const SizedBox(width: 8),
                                                  getPasswordSuffixIcon() ??
                                                      const SizedBox.shrink(),
                                                ]
                                              ],
                                            ),
                                            hidePassword: hidePassword,
                                            keyboardType: TextInputType.text,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.trim().isEmpty) {
                                                return 'Required';
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
                                          )
                                        : const SizedBox.shrink(),
                                    !widget.socialLogin
                                        ? PasswordRequirementsList(
                                            showLowercase: showLowercase,
                                            showUppercase: showUppercase,
                                            showNumber: showNumber,
                                            showSpecial: showSpecialcase,
                                            showMinLength: showMincase,
                                            size: size,
                                          )
                                        : const SizedBox.shrink(),
                                    SizedBox(
                                      height: !widget.socialLogin
                                          ? passwordStrengthValue.isNotEmpty
                                              ? size.width *
                                                  AppDimensions.numD02
                                              : 0
                                          : 0,
                                    ),
                                    passwordStrengthValue.trim().isNotEmpty &&
                                            !widget.socialLogin
                                        ? Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                AppStrings.passwordStrengthText,
                                                style: TextStyle(
                                                    color:
                                                        AppColorTheme.colorHint,
                                                    fontSize: size.width *
                                                        AppDimensions.numD03),
                                              ),
                                              Text(
                                                passwordStrengthValue,
                                                style: TextStyle(
                                                    color: AppColorTheme
                                                        .colorThemePink,
                                                    fontSize: size.width *
                                                        AppDimensions.numD03),
                                              ),
                                            ],
                                          )
                                        : Container(),
                                    SizedBox(
                                      height: !widget.socialLogin
                                          ? size.width * AppDimensions.numD04
                                          : 0,
                                    ),
                                    !widget.socialLogin
                                        ? CommonTextField(
                                            size: size,
                                            maxLines: 1,
                                            borderColor: AppColorTheme
                                                .colorTextFieldBorder,
                                            controller:
                                                confirmPasswordController,
                                            hintText:
                                                AppStrings.confirmPwdHintText,
                                            textInputFormatters: null,
                                            prefixIcon:
                                                const Icon(Icons.lock_outline),
                                            prefixIconHeight: size.width *
                                                AppDimensions.numD08,
                                            suffixIconIconHeight: size.width *
                                                AppDimensions.numD08,
                                            suffixIcon: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    hideConfirmPassword =
                                                        !hideConfirmPassword;
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
                                                        ? AppColorTheme
                                                            .colorTextFieldIcon
                                                        : AppColorTheme
                                                            .colorHint,
                                                  ),
                                                ),
                                                if (confirmPasswordController
                                                    .text.isNotEmpty) ...[
                                                  const SizedBox(width: 8),
                                                  getConfirmPasswordSuffixIcon() ??
                                                      const SizedBox.shrink(),
                                                ]
                                              ],
                                            ),
                                            hidePassword: hideConfirmPassword,
                                            keyboardType: TextInputType.text,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return AppStrings.requiredText;
                                              }
                                              /*else if (value.length < 8) {
                                    return AppStrings.passwordErrorText;
                                  } */
                                              else if (passwordController
                                                      .text !=
                                                  value) {
                                                return AppStrings
                                                    .confirmPasswordErrorText;
                                              }
                                              return null;
                                            },
                                            enableValidations: true,
                                            filled: false,
                                            filledColor: Colors.transparent,
                                            autofocus: false,
                                          )
                                        : Container(),
                                    SizedBox(
                                      height: size.width * AppDimensions.numD04,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                        rememberMe = false;

                                        context.pushNamed(
                                            AppRoutes.termCheckName,
                                            extra: {
                                              'type': "legal"
                                            }).then((value) {
                                          if (value != null) {
                                            debugPrint("value::::$value");
                                            termConditionsChecked =
                                                value as bool;
                                            setState(() {});
                                            //  termConditionsChecked = !termConditionsChecked;
                                          }
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          termConditionsChecked
                                              ? Container(
                                                  margin: EdgeInsets.only(
                                                      top: size.width *
                                                          AppDimensions
                                                              .numD008),
                                                  child: Image.asset(
                                                    "${iconsPath}ic_checkbox_filled.png",
                                                    height: size.width *
                                                        AppDimensions.numD06,
                                                  ),
                                                )
                                              : Container(
                                                  margin: EdgeInsets.only(
                                                      top: size.width *
                                                          AppDimensions
                                                              .numD008),
                                                  child: Image.asset(
                                                      "${iconsPath}ic_checkbox_empty.png",
                                                      height: size.width *
                                                          AppDimensions.numD06),
                                                ),
                                          SizedBox(
                                            width: size.width *
                                                AppDimensions.numD02,
                                          ),
                                          Expanded(
                                            child: Text(
                                              "Accept our T&Cs and Privacy Policy",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: "AirbnbCereal",
                                                  fontSize: size.width *
                                                      AppDimensions.numD035),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.width * AppDimensions.numD06,
                                    ),
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: size.width *
                                              AppDimensions.numD04),
                                      width: size.width,
                                      height: size.width * AppDimensions.numD13,
                                      child: commonElevatedButton(
                                          AppStrings.nextText,
                                          size,
                                          commonTextStyle(
                                              size: size,
                                              fontSize: size.width *
                                                  AppDimensions.numD035,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700),
                                          commonButtonStyle(size,
                                              AppColorTheme.colorThemePink),
                                          () {
                                        if (formKey.currentState!.validate()) {
                                          if (!isSelectCheck) {
                                            showSnackBar(
                                                "Error",
                                                AppStrings
                                                    .enableNotificationText,
                                                Colors.red);
                                          } else if (!termConditionsChecked) {
                                            showSnackBar(
                                                "Privacy Policy",
                                                "Please accept our T&Cs and Privacy Policy",
                                                Colors.red);
                                          } else if (selectedAvatar.isEmpty) {
                                            showSnackBar(
                                                "Avatar",
                                                "Please select an Avatar",
                                                Colors.red);
                                          } else {
                                            sendOtpApi();
                                          }
                                        }
                                        setState(() {});
                                      }),
                                    ),
                                    !widget.socialLogin
                                        ? Align(
                                            alignment: Alignment.center,
                                            child: TextButton(
                                                onPressed: () {
                                                  context.pop();
                                                },
                                                child: RichText(
                                                  text: TextSpan(children: [
                                                    TextSpan(
                                                        text: AppStrings
                                                            .alreadyHaveAccountText,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontFamily:
                                                                "AirbnbCereal",
                                                            fontSize: size
                                                                    .width *
                                                                AppDimensions
                                                                    .numD035)),
                                                    WidgetSpan(
                                                        alignment:
                                                            PlaceholderAlignment
                                                                .middle,
                                                        child: SizedBox(
                                                          width: size.width *
                                                              0.005,
                                                        )),
                                                    TextSpan(
                                                        text: AppStrings
                                                            .signInText,
                                                        style: TextStyle(
                                                            color: AppColorTheme
                                                                .colorThemePink,
                                                            fontFamily:
                                                                "AirbnbCereal",
                                                            fontSize: size
                                                                    .width *
                                                                AppDimensions
                                                                    .numD035,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700)),
                                                  ]),
                                                )))
                                        : Container(),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (state is SignUpLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: showAnimatedLoader(size),
                    ),
                  ),
              ],
            );
          },
        ));
  }

  Future<void> googleLogin() async {
    googleSignIn.signIn().then((userData) {
      // _isLoggedIn = true;
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
      debugPrint(e.toString());
    });
  }

  void startVibration() async {
    // final Iterable<Duration> pauses = [
    //   const Duration(milliseconds: 50),
    //   const Duration(milliseconds: 50),
    // ];
  }

  Icon? getUsernameSuffixIcon() {
    String username = userNameController.text.trim().toLowerCase();
    if (username.isEmpty) {
      return null;
    }
    if (username.length < 4) {
      return const Icon(
        Icons.highlight_remove,
        color: Colors.red,
      );
    }
    if (userNameAlreadyExists) {
      return const Icon(
        Icons.highlight_remove,
        color: Colors.red,
      );
    }

    if (_restrictPattern.hasMatch(username) ||
        _restrictPatter2.hasMatch(username) ||
        _restrictPatter3.hasMatch(username)) {
      return const Icon(
        Icons.highlight_remove,
        color: Colors.red,
      );
    }

    String firstName = firstNameController.text.trim().toLowerCase();
    String lastName = lastNameController.text.trim().toLowerCase();
    List<String> generateSubstrings(String text) {
      List<String> substrings = [];
      for (int i = 0; i < text.length; i++) {
        for (int j = i + 4; j <= text.length; j++) {
          substrings.add(text.substring(i, j));
        }
      }
      debugPrint("substrings::::$substrings");
      return substrings;
    }

    List<String> firstNameSubstrings = generateSubstrings(firstName);
    List<String> lastNameSubstrings = generateSubstrings(lastName);

    bool containsAnySubstring(String username, List<String> substrings) {
      for (var substring in substrings) {
        if (username.contains(substring)) {
          return true;
        }
      }
      return false;
    }

    if (containsAnySubstring(username, firstNameSubstrings)) {
      return const Icon(
        Icons.highlight_remove,
        color: Colors.red,
      );
    }

    if (containsAnySubstring(username, lastNameSubstrings)) {
      return const Icon(
        Icons.highlight_remove,
        color: Colors.red,
      );
    }

    return const Icon(
      Icons.check_circle,
      color: Colors.green,
    );
    // return null;
  }

  Icon? getReferralCodeSuffixIcon() {
    String referralCode = referralCodeController.text.trim().toLowerCase();
    if (referralCode.isEmpty) {
      return null;
    }
    if (showReferralCodeError) {
      return const Icon(
        Icons.highlight_remove,
        color: Colors.red,
      );
    }
    if (isRefferalCodeValid) {
      return const Icon(
        Icons.check_circle,
        color: Colors.green,
      );
    }
    return null;
  }

  Icon? getEmailSuffixIcon() {
    String email = emailController.text.trim();
    if (email.isEmpty) {
      return null;
    }
    if (!emailExpression.hasMatch(email) || emailAlreadyExists) {
      return const Icon(
        Icons.highlight_remove,
        color: Colors.red,
      );
    }
    return const Icon(
      Icons.check_circle,
      color: Colors.green,
    );
  }

  Icon? getPhoneSuffixIcon() {
    String phone = phoneController.text.trim();
    if (phone.isEmpty) {
      return null;
    }
    if (checkSignupPhoneValidator(phone) != null) {
      return const Icon(
        Icons.highlight_remove,
        color: Colors.red,
      );
    }
    return const Icon(
      Icons.check_circle,
      color: Colors.green,
    );
  }

  Icon? getPasswordSuffixIcon() {
    String password = passwordController.text;
    if (password.isEmpty) {
      return null;
    }
    if (showLowercase &&
        showUppercase &&
        showNumber &&
        showSpecialcase &&
        showMincase) {
      return const Icon(
        Icons.check_circle,
        color: Colors.green,
      );
    } else {
      return const Icon(
        Icons.highlight_remove,
        color: Colors.red,
      );
    }
  }

  Icon? getConfirmPasswordSuffixIcon() {
    String confirmPassword = confirmPasswordController.text;
    if (confirmPassword.isEmpty) {
      return null;
    }
    if (confirmPassword == passwordController.text) {
      return const Icon(
        Icons.check_circle,
        color: Colors.green,
      );
    } else {
      return const Icon(
        Icons.highlight_remove,
        color: Colors.red,
      );
    }
  }

  void setUserNameListener() {
    userNameController.addListener(() {
      debugPrint("UserName:${userNameController.text}");
      if (userNameController.text.trim().isNotEmpty &&
          firstNameController.text.trim().isNotEmpty &&
          lastNameController.text.trim().isNotEmpty &&
          userNameController.text.trim().length >= 4 &&
          !userNameController.text
              .toLowerCase()
              .contains(firstNameController.text) &&
          !userNameController.text
              .trim()
              .toLowerCase()
              .contains(lastNameController.text.trim().toLowerCase())) {
        debugPrint("not-success");
      } else {
        userNameAlreadyExists = false;
      }
      setState(() {});
    });
  }

  void setEmailListener() {
    emailController.addListener(() {
      debugPrint("Emil:${emailController.text}");
      if (emailController.text.trim().isNotEmpty) {
        debugPrint("notsuccess");
        checkEmailApi();
      } else {
        emailAlreadyExists = false;
      }

      setState(() {});
    });
  }

  void setPasswordListener() {
    passwordController.addListener(() {
      final text = passwordController.text;

      // Update strength indicators
      bool minLength = text.length >= 8;
      bool hasUppercase = RegExp(r'[A-Z]').hasMatch(text);
      bool hasLowercase = RegExp(r'[a-z]').hasMatch(text);
      bool hasNumber = RegExp(r'[0-9]').hasMatch(text);
      bool hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(text);

      String strength = "";
      // Utilizing the existing passwordExpression checking
      if (text.isNotEmpty &&
          minLength &&
          !passwordExpression.hasMatch(text.trim())) {
        strength = AppStrings.weakText;
      } else if (text.isNotEmpty &&
          minLength &&
          passwordExpression.hasMatch(text.trim())) {
        strength = AppStrings.strongText;
      } else {
        strength = "";
      }

      if (showMincase != minLength ||
          showUppercase != hasUppercase ||
          showLowercase != hasLowercase ||
          showNumber != hasNumber ||
          showSpecialcase != hasSpecial ||
          passwordStrengthValue != strength) {
        setState(() {
          showMincase = minLength;
          showUppercase = hasUppercase;
          showLowercase = hasLowercase;
          showNumber = hasNumber;
          showSpecialcase = hasSpecial;
          passwordStrengthValue = strength;
        });
      }
    });
  }

  /// Get current Location
  Future<List<Placemark>> getCurrentLocationFxn(
      String latitude, longitude) async {
    try {
      double lat = double.parse(latitude);
      double long = double.parse(longitude);
      List<Placemark> placeMarkList = await placemarkFromCoordinates(lat, long);
      debugPrint("PlaceHolder: ${placeMarkList.first}");
      return placeMarkList;
    } on Exception catch (e) {
      debugPrint("PEx: $e");
      showSnackBar("Exception", e.toString(), Colors.red);
    }
    return [];
  }

  void setSocialPreData() {
    if (widget.email.isNotEmpty) {}

    if (widget.name.isNotEmpty) {
      var nameArray = widget.name.split(" ");
      if (nameArray.length > 1) {
        firstNameController.text = nameArray.first;
        lastNameController.text = nameArray[1];
      }
    }
  }

  Future openGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      return;
    }

    avatarController.text = File(image.path).uri.pathSegments.last;

    setState(() {});
  }

  String? userNameValidator(String? value) {
    if (value!.isEmpty) {
      return AppStrings.requiredText;
    }
    String firstName = firstNameController.text.trim().toLowerCase();
    String lastName = lastNameController.text.trim().toLowerCase();
    String username = value.trim().toLowerCase();

    if (firstName.isEmpty) {
      return "First name must be filled.";
    }
    if (lastName.isEmpty) {
      return "Last name must be filled.";
    }
    List<String> generateSubstrings(String text) {
      List<String> substrings = [];
      for (int i = 0; i < text.length; i++) {
        for (int j = i + 4; j <= text.length; j++) {
          substrings.add(text.substring(i, j));
        }
      }
      return substrings;
    }

    List<String> firstNameSubstrings = generateSubstrings(firstName);
    List<String> lastNameSubstrings = generateSubstrings(lastName);

    bool containsAnySubstring(String username, List<String> substrings) {
      for (var substring in substrings) {
        if (username.contains(substring)) {
          return true;
        }
      }
      return false;
    }

    if (containsAnySubstring(username, firstNameSubstrings)) {
      return "Your username cannot contain any sequence from your first name.";
    }

    if (containsAnySubstring(username, lastNameSubstrings)) {
      return "Your username cannot contain any sequence from your last name.";
    }
    if (value.length < 4) {
      return "Your username must be at least 4 characters in length.";
    }
    if (_restrictPattern.hasMatch(value.trim()) ||
        _restrictPatter2.hasMatch(value.trim()) ||
        _restrictPatter3.hasMatch(value.trim())) {
      return "Domain names are not allowed for security reasons.";
    }
    if (userNameAlreadyExists) {
      return userNameApiError.isNotEmpty
          ? userNameApiError
          : "This username is already taken. Please choose another one.";
    }

    return null;
  }

  void avatarBottomSheet(Size size) {
    AvatarBottomSheet.show(
      context: context,
      size: size,
      avatarList: avatarList,
      onAvatarSelected: (avatar) {
        selectedAvatar = avatar.avatar;
        selectedAvatarId = avatar.id;
        showAvatarError = false;
        setState(() {});
      },
      notifier: _avatarsNotifier,
    );
  }

  void selectedDate1(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime date13YearsAgo =
        DateTime(currentDate.year - 13, currentDate.month, currentDate.day);

    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: date13YearsAgo,
        firstDate: DateTime(1970),
        lastDate: date13YearsAgo);
    DateFormat formats = DateFormat("yyyy-MM-dd");
    DateFormat formats1 = DateFormat("dd/MM/yyyy");
    debugPrint("Selected Date  ${formats.format(picked!)}");
    selectedDates = formats.format(picked);
    selectedDates1 = formats1.format(picked);
    showDateError = false;
    setState(() {});
  }

  Future<String?> selectedDate11() async {
    final DateTime? pickedDate = await showDatePicker(
      context: navigatorKey.currentContext!,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900, 01, 01),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light()
                  .copyWith(primary: AppColorTheme.colorThemePink)),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      DateFormat formats = DateFormat("dd/MM/yyyy");
      DateFormat formats1 = DateFormat("dd/MM/yyyy");
      debugPrint("Selected Date  ${formats.format(pickedDate)}");
      selectedDates1 = formats.format(pickedDate);
      selectedDates = formats1.format(pickedDate);
      showDateError = false;
      setState(() {});
    } else {
      return null;
    }
    return null;
  }

  Future<String?> selectedDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: navigatorKey.currentContext!,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900, 01, 01),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light()
                .copyWith(primary: AppColorTheme.colorThemePink),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      DateTime eighteenYearsAgo =
          DateTime.now().subtract(const Duration(days: 365 * 18));

      if (pickedDate.isAfter(eighteenYearsAgo)) {
        debugPrint("You must be at least 18 years old.");
        showSnackBar("For safety reasons",
            "You need to be at least 18 years old to use the app.", Colors.red);
        showDateError = true;
        setState(() {});
        return null;
      } else {
        DateFormat formats = DateFormat("dd/MM/yyyy");
        selectedDates1 = formats.format(pickedDate);
        selectedDates = formats.format(pickedDate);
        selectDobController.text = selectedDates;
        showDateError = false;
        debugPrint("Selected Date: ${formats.format(pickedDate)}");
        setState(() {});
      }
    } else {
      return null;
    }
    return null;
  }

  void openCountryCodePicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (country) {
        debugPrint('Select country: ${country.displayName}');
        debugPrint('Select country: ${country.countryCode}');
        debugPrint('Select country: ${country.hashCode}');
        debugPrint('Select country: ${country.displayNameNoCountryCode}');
        debugPrint('Select country: ${country.phoneCode}');
        selectedCountryCodePicker = "+${country.phoneCode}";
        setState(() {});
      },
    );
  }

  int _getMaxPhoneLength() {
    return AuthConstants
            .phoneNumberMaxLengthByCountry[selectedCountryCodePicker] ??
        15;
  }

  String? checkSignupPhoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredText;
    }

    String digitsOnly = value.trim().replaceAll(RegExp(r'\D+'), '');

    int minLength = 7;
    int maxLength = 15;

    final countryData =
        AuthConstants.phoneNumberLengthByCountryCode[selectedCountryCodePicker];
    if (countryData != null) {
      minLength = countryData['min']!;
      maxLength = countryData['max']!;
    }

    if (digitsOnly.length < minLength) {
      return "Too short for selected country";
    }
    if (digitsOnly.length > maxLength) {
      return "Too long for selected country";
    }

    if (phoneAlreadyExists) {
      print("This phone number already exists");
      print(phoneAlreadyExists);
      return phoneApiError.isNotEmpty
          ? phoneApiError
          : AppStrings.phoneExistsErrorText;
    }

    return null;
  }

  String? checkSignupEmailValidator(String? value) {
    if (value!.isEmpty) {
      return AppStrings.requiredText;
    } else if (!emailExpression.hasMatch(value)) {
      return AppStrings.emailErrorText;
    } else if (emailAlreadyExists) {
      return AppStrings.emailExistsErrorText;
    }
    return null;
  }

  ///ApisSection------------
  void checkUserNameApi() {
    _signUpBloc.add(CheckUserNameEvent(userNameController.text.trim()));
  }

  void checkEmailApi() {
    _signUpBloc.add(CheckEmailEvent(emailController.text.trim()));
  }

  void checkPhoneApi() {
    _signUpBloc.add(CheckPhoneEvent(
        selectedCountryCodePicker + phoneController.text.trim()));
  }

  void getAvatarsApi() {
    _signUpBloc.add(FetchAvatarsEvent());
  }

  void verifyReferredCode() {
    _signUpBloc
        .add(VerifyReferralCodeEvent(referralCodeController.text.trim()));
  }

  void sendOtpApi() {
    Map<String, dynamic> params = {};
    params[SharedPreferencesKeys.firstNameKey] =
        firstNameController.text.trim();
    params[SharedPreferencesKeys.lastNameKey] = lastNameController.text.trim();
    params[SharedPreferencesKeys.emailKey] = emailController.text.trim();
    if (isRefferalCodeValid) {
      params[SharedPreferencesKeys.referredCodeKey] =
          referralCodeController.text.trim();
    }
    params[SharedPreferencesKeys.countryCodeKey] = selectedCountryCodePicker;
    params[SharedPreferencesKeys.phoneKey] = phoneController.text.trim();
    params[SharedPreferencesKeys.addressKey] = addressController.text.trim();
    params[SharedPreferencesKeys.postCodeKey] =
        postalCodeController.text.trim();
    params[SharedPreferencesKeys.latitudeKey] = latitude;
    params[SharedPreferencesKeys.longitudeKey] = longitude;
    params[SharedPreferencesKeys.isTermAcceptedKey] =
        termConditionsChecked.toString();
    params[SharedPreferencesKeys.dobKey] = selectedDates.toString();
    params[SharedPreferencesKeys.receiveTaskNotificationKey] =
        isSelectCheck.toString();
    params[SharedPreferencesKeys.roleKey] = "Hopper";
    params[SharedPreferencesKeys.avatarIdKey] = selectedAvatarId;
    params[SharedPreferencesKeys.userNameKey] =
        userNameController.text.trim().toLowerCase();
    params[SharedPreferencesKeys.countryKey] =
        countryNameController.text.trim();
    params[SharedPreferencesKeys.cityKey] = cityNameController.text.trim();
    params["password"] = passwordController.text.trim();

    _signUpBloc.add(SignUpSubmitted(data: params));
  }
}
