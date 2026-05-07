import 'dart:async';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import 'package:image_picker/image_picker.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/features/authentication/constants/auth_constants.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/widgets/common_text_field.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/features/authentication/presentation/bloc/signup_bloc.dart';
import 'package:presshop/features/authentication/presentation/bloc/signup_event.dart';
import 'package:presshop/features/authentication/presentation/bloc/signup_state.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/features/authentication/domain/entities/user.dart';
import 'package:presshop/core/widgets/common/avatar_bottom_sheet.dart';

// ignore: must_be_immutable
class SocialSignUp extends StatefulWidget {
  SocialSignUp(
      {super.key,
      required this.socialLogin,
      required this.socialId,
      required this.email,
      required this.name,
      required this.socialType,
      required this.phoneNumber});
  bool socialLogin = false;
  String socialId = "";
  String name = "";
  String email = "";
  String phoneNumber = "";
  String socialType = "";

  @override
  State<SocialSignUp> createState() => _SocialSignUpState();
}

class _SocialSignUpState extends State<SocialSignUp>
    with SingleTickerProviderStateMixin, AnalyticsPageMixin {
  @override
  String get pageName => PageNames.socialSignup;

  var formKey = GlobalKey<FormState>();
  var scrollController = ScrollController();

  late AnimationController controller;
  Timer? _phoneDebounce;
  Timer? _userDebounce;
  Timer? _referralDebounce;

  String userNameApiError = "";
  String phoneApiError = "";
  String referralCodeApiError = "";

  final RegExp _restrictPattern = RegExp(
    r"@(gmail\.com|yahoo\.com|hotmail\.com|outlook\.com)$",
    caseSensitive: true,
  );
  final RegExp _restrictPatter2 = RegExp(r'@(gmail|yahoo|hotmail|outlook)\.');
  final RegExp _restrictPatter3 =
      RegExp('gmail|yahoo|hotmail|outlook', caseSensitive: false);

  void _onUserNameChanged(String? value) {
    if (value == null || value.trim().isEmpty) return;

    _userDebounce?.cancel();

    _userDebounce = Timer(const Duration(milliseconds: 800), () {
      if (value.trim().length >= 4) {
        checkUserNameApi();
      }
    });
  }

  void _onPhoneChanged(String? value) {
    if (value == null || value.trim().isEmpty) {
      phoneAlreadyExists = false;
      setState(() {});
      return;
    }

    _phoneDebounce?.cancel();

    _phoneDebounce = Timer(const Duration(milliseconds: 600), () {
      if (value.trim().length >= 7) {
        checkPhoneApi();
      }
    });
  }

  ///TextEditingController
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController avatarController = TextEditingController();
  TextEditingController referralCodeController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  final ValueNotifier<bool> _avatarsNotifier = ValueNotifier(false);

  String userImagePath = "",
      avatarBaseUrl = "",
      selectedAvatar = "",
      selectedCountryCodePicker = "+44",
      selectedAvatarId = "";

  bool hidePassword = true,
      hideConfirmPassword = true,
      enableNotifications = false,
      showImageError = false,
      userNameAlreadyExists = false,
      emailAlreadyExists = false,
      phoneAlreadyExists = false,
      showAvatarError = false,
      isRefferalCodeValid = false,
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
  List<AvatarData> avatarList = [];
  // final bool _isLoggedIn = false;
  String socialEmail = "";
  String socialId = "";
  String socialName = "";
  String socialProfileImage = "";
  String socialType = "";
  late SignUpBloc _signUpBloc;

  @override
  void initState() {
    controller = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);
    super.initState();
    if (widget.socialLogin) {
      emailController.text = widget.email;
      // Removed auto-fill of username with name/email as requested.
      userNameController.text = "";
      phoneController.text = widget.phoneNumber;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (phoneController.text.isNotEmpty) {
        checkPhoneApi();
      }
    });
  }

  @override
  void dispose() {
    _userDebounce?.cancel();
    _phoneDebounce?.cancel();
    _referralDebounce?.cancel();
    controller.dispose();
    userNameController.dispose();
    emailController.dispose();
    avatarController.dispose();
    referralCodeController.dispose();
    phoneController.dispose();
    _avatarsNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    // final Animation<double> offsetAnimation = Tween(begin: 0.0, end: 24.0)
    //     .chain(CurveTween(curve: Curves.elasticIn))
    //     .animate(controller)
    //   ..addStatusListener((status) {
    //     if (status == AnimationStatus.completed) {
    //       controller.reverse();
    //     }
    //   });

    _signUpBloc = context.read<SignUpBloc>();
    return BlocConsumer<SignUpBloc, SignUpState>(
        listener: (context, state) {
          if (state is SignUpError) {
            _avatarsNotifier.value = false;
            debugPrint("❌ SocialSignUp Error: ${state.message}");
            commonErrorDialogDialog(
                MediaQuery.of(context).size, state.message, "", () {
              context.pop();
            });
          } else if (state is SignUpSuccess) {
            debugPrint("✅ SocialSignUp Success: ${state.user}");
            _handleLoginSuccess(state.user);
          } else if (state is AvatarsLoading) {
            _avatarsNotifier.value = true;
          } else if (state is AvatarsLoaded) {
            if (state.avatars.isNotEmpty) {}
            avatarList = state.avatars
                .map((e) =>
                    AvatarData.fromJson({'_id': e.id, 'avatar': e.avatar}))
                .toList();

            _avatarsNotifier.value = false;
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
          return Scaffold(
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
            body: Stack(
              children: [
                SafeArea(
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
                              "Almost there!",
                              style:
                                  commonBigTitleTextStyle(size, Theme.of(context).colorScheme.onSurface),
                            ),
                            SizedBox(
                              height: size.width * AppDimensions.numD01,
                            ),
                            Text(
                              "Hi ${widget.name}, please complete your profile to continue.",
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: size.width * AppDimensions.numD035,
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
                                  selectedAvatar.isEmpty
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                avatarBottomSheet(size);
                                              },
                                              child: Container(
                                                height: size.width *
                                                    AppDimensions.numD30,
                                                width: size.width *
                                                    AppDimensions.numD35,
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context).cardColor,
                                                    border: Border.all(
                                                        color: AppColorTheme
                                                            .colorTextFieldBorder),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            size.width *
                                                                AppDimensions
                                                                    .numD04)),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      "${iconsPath}ic_user.png",
                                                      width: size.width *
                                                          AppDimensions.numD11,
                                                      color: Theme.of(context).iconTheme.color,
                                                    ),
                                                    SizedBox(
                                                      height: size.width *
                                                          AppDimensions.numD01,
                                                    ),
                                                    Text(
                                                      AppStrings
                                                          .chooseYourAvatarText,
                                                      style: commonTextStyle(
                                                          size: size,
                                                          fontSize: size.width *
                                                              AppDimensions
                                                                  .numD03,
                                                          color: Theme.of(context).hintColor,
                                                          fontWeight: FontWeight
                                                              .normal),
                                                      textAlign:
                                                          TextAlign.center,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Align(
                                          alignment: Alignment.centerLeft,
                                          child: Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(size
                                                            .width *
                                                        AppDimensions.numD04),
                                                child: Image.network(
                                                  selectedAvatar,
                                                  height: size.width *
                                                      AppDimensions.numD30,
                                                  width: size.width *
                                                      AppDimensions.numD35,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Positioned(
                                                right: 0,
                                                top: 0,
                                                child: InkWell(
                                                  onTap: () {
                                                    selectedAvatar = "";
                                                    if (selectedAvatar
                                                        .isNotEmpty) {
                                                      int pos = avatarList
                                                          .indexWhere((element) =>
                                                              element.avatar ==
                                                              selectedAvatar);

                                                      if (pos >= 0) {
                                                        avatarList[pos]
                                                            .selected = false;
                                                      }
                                                    }
                                                    showAvatarError = true;

                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(size
                                                            .width *
                                                        AppDimensions.numD01),
                                                    decoration:
                                                        const BoxDecoration(
                                                            color: Colors.white,
                                                            shape: BoxShape
                                                                .circle),
                                                    child: Icon(Icons.cancel,
                                                        color: Theme.of(context)
                                                     .colorScheme
                                                     .onSurface,
                                                        size: size.width *
                                                            AppDimensions
                                                                .numD035),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
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
                                      color: Theme.of(context).hintColor,
                                      fontSize:
                                          size.width * AppDimensions.numD025,
                                    ),
                                    textAlign: TextAlign.justify,
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
                                    prefixIcon:
                                        const Icon(Icons.person_outline_sharp),
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
                                        color: Theme.of(context).hintColor,
                                        fontSize:
                                            size.width * AppDimensions.numD025),
                                  ),

                                  // SizedBox(
                                  //   height: size.height * AppDimensions.numD02,
                                  // ),

                                  // CommonTextField(
                                  //   size: size,
                                  //   maxLines: 1,
                                  //   borderColor:
                                  //       AppColorTheme.colorTextFieldBorder,
                                  //   controller: emailController,
                                  //   hintText: AppStrings.emailHintText,
                                  //   textInputFormatters: null,
                                  //   prefixIcon:
                                  //       const Icon(Icons.email_outlined),
                                  //   prefixIconHeight:
                                  //       size.width * AppDimensions.numD06,
                                  //   suffixIconIconHeight:
                                  //       size.width * AppDimensions.numD085,
                                  //   suffixIcon: null,
                                  //   hidePassword: false,
                                  //   keyboardType: TextInputType.emailAddress,
                                  //   validator: null,
                                  //   enableValidations: false,
                                  //   filled: true,
                                  //   filledColor: Colors.grey.shade100,
                                  //   readOnly: true,
                                  //   autofocus: false,
                                  // ),

                                  SizedBox(
                                    height: size.height * AppDimensions.numD02,
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
                                      LengthLimitingTextInputFormatter(AuthConstants
                                                  .phoneNumberMaxLengthByCountry[
                                              selectedCountryCodePicker] ??
                                          15),
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
                                                AppDimensions.numD01,
                                          ),
                                          Text(
                                            selectedCountryCodePicker,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD035,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                fontWeight: FontWeight.normal),
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
                                            decimal: false, signed: true),
                                    validator: checkSignupPhoneValidator,
                                    enableValidations: true,
                                    filled: false,
                                    filledColor: Colors.transparent,
                                    autofocus: false,
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
                                    validator: null,
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
                                        color: Theme.of(context).hintColor,
                                        fontSize:
                                            size.width * AppDimensions.numD025),
                                  ),
                                  SizedBox(
                                    height: size.width * AppDimensions.numD04,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                      rememberMe = false;

                                      context.pushNamed(AppRoutes.termCheckName,
                                          extra: {
                                            'type': "legal"
                                          }).then((value) {
                                        if (value != null && value is bool) {
                                          debugPrint("value::::$value");
                                          termConditionsChecked = value;
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
                                                        AppDimensions.numD008),
                                                child: Image.asset(
                                                  "${iconsPath}ic_checkbox_filled.png",
                                                  height: size.width *
                                                      AppDimensions.numD06,
                                                ),
                                              )
                                            : Container(
                                                margin: EdgeInsets.only(
                                                    top: size.width *
                                                        AppDimensions.numD008),
                                                child: Image.asset(
                                                    "${iconsPath}ic_checkbox_empty.png",
                                                    height: size.width *
                                                        AppDimensions.numD06),
                                              ),
                                        SizedBox(
                                          width:
                                              size.width * AppDimensions.numD02,
                                        ),
                                        Expanded(
                                          child: Text(
                                            "Accept our T&Cs and Privacy Policy",
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width *
                                                    AppDimensions.numD035,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                fontWeight: FontWeight.normal,
                                              ),
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
                                        horizontal:
                                            size.width * AppDimensions.numD04),
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
                                        commonButtonStyle(
                                            size, AppColorTheme.colorThemePink),
                                        () {
                                      if (formKey.currentState!.validate()) {
                                        if (!isSelectCheck) {
                                          // showSnackBar(
                                          //     "Error",
                                          //     AppStrings.enableNotificationText,
                                          //     Colors.red);
                                        } else if (!termConditionsChecked) {
                                          // showSnackBar(
                                          //     "Privacy Policy",
                                          //     "Please accept our T&Cs and Privacy Policy",
                                          //     Colors.red);
                                        } else if (selectedAvatar.isEmpty) {
                                          // showSnackBar(
                                          //     "Avatar",
                                          //     "Please select an Avatar",
                                          //     Colors.red);
                                        } else {
                                          Map<String, dynamic> params = {};
                                          params[SharedPreferencesKeys
                                                  .emailKey] =
                                              widget.email.trim().toLowerCase();
                                          params[SharedPreferencesKeys
                                                  .isTermAcceptedKey] =
                                              termConditionsChecked.toString();
                                          params[SharedPreferencesKeys
                                              .firstNameKey] = widget.name;
                                          params[SharedPreferencesKeys
                                                  .receiveTaskNotificationKey] =
                                              isSelectCheck.toString();
                                          params[SharedPreferencesKeys
                                                  .phoneKey] =
                                              phoneController.text.trim();
                                          params[SharedPreferencesKeys
                                              .roleKey] = "Hopper";
                                          params[SharedPreferencesKeys
                                              .avatarIdKey] = selectedAvatarId;
                                          if (isRefferalCodeValid) {
                                            params[SharedPreferencesKeys
                                                    .referredCodeKey] =
                                                referralCodeController.text
                                                    .trim();
                                          }
                                          params[SharedPreferencesKeys
                                                  .userNameKey] =
                                              userNameController.text
                                                  .trim()
                                                  .toLowerCase();
                                          params["social_id"] = widget.socialId;
                                          params["social_type"] =
                                              widget.socialType.toLowerCase();
                                          params["_imagePath"] = userImagePath;

                                          context.read<SignUpBloc>().add(
                                              SocialSignUpSubmitted(
                                                  data: params));
                                        }
                                      }
                                      setState(() {});
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (state is SignUpLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: showAnimatedLoader(size),
                    ),
                  ),
              ],
            ),
          );
        },
      );
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

  void openCountryCodePicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        textStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        searchTextStyle:
            TextStyle(color: Theme.of(context).colorScheme.onSurface),
        bottomSheetHeight: 500,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        inputDecoration: InputDecoration(
          labelText: 'Search',
          hintStyle: TextStyle(color: Theme.of(context).hintColor),
          prefixIcon:
              Icon(Icons.search, color: Theme.of(context).iconTheme.color),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            ),
          ),
        ),
      ),
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

  void verifyReferredCode() {
    context
        .read<SignUpBloc>()
        .add(VerifyReferralCodeEvent(referralCodeController.text.trim()));
  }

  void checkPhoneApi() {
    _signUpBloc.add(CheckPhoneEvent(
        selectedCountryCodePicker + phoneController.text.trim()));
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

    List<String> nameParts = widget.name.trim().split(' ');
    String firstName = nameParts[0].toLowerCase();
    String lastName = nameParts.length > 1
        ? nameParts.sublist(1).join(" ").toLowerCase()
        : "";

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
      return const Icon(
        Icons.highlight_remove,
        color: Colors.red,
      );
    }

    if (lastName.isNotEmpty &&
        containsAnySubstring(username, lastNameSubstrings)) {
      return const Icon(
        Icons.highlight_remove,
        color: Colors.red,
      );
    }

    // NEW: Check if username contains email sequence
    String emailLocalPart = widget.email.split('@')[0].toLowerCase();
    List<String> emailSubstrings = generateSubstrings(emailLocalPart);
    if (containsAnySubstring(username, emailSubstrings)) {
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

  void setUserNameListener() {
    userNameController.addListener(() {
      debugPrint("UserName:${userNameController.text}");
      if (userNameController.text.trim().isNotEmpty &&
          widget.name.trim().isNotEmpty &&
          userNameController.text.trim().length >= 4 &&
          !userNameController.text.toLowerCase().contains(widget.name)) {
        debugPrint("not-success");
      } else {
        userNameAlreadyExists = false;
      }
      setState(() {});
    });
  }

  String? userNameValidator(String? value) {
    if (value!.isEmpty) {
      return AppStrings.requiredText;
    }

    List<String> nameParts = widget.name.trim().split(' ');
    String firstName = nameParts[0].toLowerCase();
    String lastName = nameParts.length > 1
        ? nameParts.sublist(1).join(" ").toLowerCase()
        : "";

    String username = value.trim().toLowerCase();

    if (firstName.isEmpty) {
      return "First name must be filled.";
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

    if (lastName.isNotEmpty &&
        containsAnySubstring(username, lastNameSubstrings)) {
      return "Your username cannot contain any sequence from your last name.";
    }

    // NEW: Check if username contains email sequence
    String emailLocalPart = widget.email.split('@')[0].toLowerCase();
    List<String> emailSubstrings = generateSubstrings(emailLocalPart);
    if (containsAnySubstring(username, emailSubstrings)) {
      return "Your username cannot contain any sequence from your email address.";
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

  // String? checkSignupPhoneValidator(String? value) {
  //   if (value!.isEmpty) {
  //     return AppStrings.requiredText;
  //   } else if (value.length < 10) {
  //     return AppStrings.phoneErrorText;
  //   } else if (phoneAlreadyExists) {
  //     return AppStrings.phoneExistsErrorText;
  //   }
  //   return null;
  // }

  String? checkSignupPhoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredText;
    }

    String digitsOnly = value.trim().replaceAll(RegExp(r'\D+'), '');

    // Default fallback
    int minLength = 7;
    int maxLength = 15;

    // Try to get country-specific length
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
    context
        .read<SignUpBloc>()
        .add(CheckUserNameEvent(userNameController.text.trim().toLowerCase()));
  }

  void checkEmailApi() {
    context.read<SignUpBloc>().add(CheckEmailEvent(widget.email));
  }

  void getAvatarsApi() {
    context.read<SignUpBloc>().add(FetchAvatarsEvent());
  }

  void _handleLoginSuccess(User user) {
    // Navigation is enough as AuthRepository handles caching
    context.goNamed(AppRoutes.dashboardName);
  }
}
