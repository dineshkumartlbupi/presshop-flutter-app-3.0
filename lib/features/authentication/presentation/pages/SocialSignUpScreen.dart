import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';

import 'TermCheckScreen.dart';
import 'package:presshop/features/authentication/presentation/pages/WelcomeScreen.dart';

import 'package:presshop/main.dart';
import 'package:presshop/core/analytics/analytics_constants.dart';
import 'package:presshop/core/analytics/analytics_mixin.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:presshop/core/widgets/common_text_field.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/features/authentication/presentation/bloc/signup_bloc.dart';
import 'package:presshop/features/authentication/presentation/bloc/signup_event.dart';
import 'package:presshop/features/authentication/presentation/bloc/signup_state.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/features/authentication/domain/entities/user.dart';
import 'package:presshop/features/dashboard/presentation/pages/Dashboard.dart';
import 'UploadDocumnetsScreen.dart';

class SocialSignUp extends StatefulWidget {
  bool socialLogin = false;
  String socialId = "";
  String name = "";
  String email = "";
  String phoneNumber = "";
  String socialType = "";

  SocialSignUp(
      {super.key,
      required this.socialLogin,
      required this.socialId,
      required this.email,
      required this.name,
      required this.socialType,
      required this.phoneNumber});

  @override
  State<SocialSignUp> createState() => _SocialSignUpState();
}

class _SocialSignUpState extends State<SocialSignUp>
    with SingleTickerProviderStateMixin, AnalyticsPageMixin {
  var formKey = GlobalKey<FormState>();
  var scrollController = ScrollController();

  late AnimationController controller;
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
  TextEditingController userNameController = TextEditingController();
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

  List<AvatarsData> avatarList = [];

  final bool _isLoggedIn = false;
  String socialEmail = "";
  String socialId = "";
  String socialName = "";
  String socialProfileImage = "";
  String socialType = "";

  @override
  void initState() {
    controller = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);
    super.initState();

    if (widget.socialLogin) {
      List<String> nameParts = widget.name.split(' ');
    }

    // WidgetsBinding.instance.addPostFrameCallback((_) => getAvatarsApi());
  }

  @override
  void dispose() {
    controller.dispose();
    _avatarsNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final Animation<double> offsetAnimation = Tween(begin: 0.0, end: 24.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        }
      });

    return BlocProvider(
      create: (context) => sl<SignUpBloc>()..add(FetchAvatarsEvent()),
      child: BlocConsumer<SignUpBloc, SignUpState>(
        listener: (context, state) {
           if (state is SignUpError) {
             commonErrorDialogDialog(
                MediaQuery.of(context).size, state.message, "", () {
              Navigator.pop(context);
            });
           } else if (state is SignUpSuccess) {
              _handleLoginSuccess(state.user);
           } else if (state is AvatarsLoaded) {
             avatarList = state.avatars.map((e) => AvatarsData.fromJson({'_id': e.id, 'avatar': e.avatar})).toList();
             _avatarsNotifier.value = !_avatarsNotifier.value;
           } else if (state is UserNameCheckResult) {
             userNameAlreadyExists = !state.isAvailable;
             setState((){});
           } else if (state is PhoneCheckResult) {
             phoneAlreadyExists = !state.isAvailable;
             setState((){});
           } else if (state is ReferralCodeVerified) {
             isRefferalCodeValid = true;
             setState((){});
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
          Navigator.pop(context);
        },
        leadingLeftSPace: size.width * numD04,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * numD08),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Almost there!",
                    style: commonBigTitleTextStyle(size, Colors.black),
                  ),
                  SizedBox(
                    height: size.width * numD01,
                  ),
                  Text(
                    "Hi ${widget.name}, please complete your profile to continue.",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: size.width * numD035,
                        fontFamily: 'AirbnbCereal'),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: size.width * numD01,
                      top: size.width * numD04,
                      bottom: size.width * numD04,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: size.width * numD04,
                        ),
                        selectedAvatar.isEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      avatarBottomSheet(size);
                                    },
                                    child: Container(
                                      height: size.width * numD30,
                                      width: size.width * numD35,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: colorTextFieldBorder),
                                          borderRadius: BorderRadius.circular(
                                              size.width * numD04)),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            "${iconsPath}ic_user.png",
                                            width: size.width * numD11,
                                          ),
                                          SizedBox(
                                            height: size.width * numD01,
                                          ),
                                          Text(
                                            chooseYourAvatarText,
                                            style: commonTextStyle(
                                                size: size,
                                                fontSize: size.width * numD03,
                                                color: colorHint,
                                                fontWeight: FontWeight.normal),
                                            textAlign: TextAlign.center,
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
                                      borderRadius: BorderRadius.circular(
                                          size.width * numD04),
                                      child: Image.network(
                                        "$avatarBaseUrl/$selectedAvatar",
                                        height: size.width * numD30,
                                        width: size.width * numD35,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: InkWell(
                                        onTap: () {
                                          selectedAvatar = "";
                                          if (selectedAvatar.isNotEmpty) {
                                            int pos = avatarList.indexWhere(
                                                (element) =>
                                                    element.avatar ==
                                                    selectedAvatar);

                                            if (pos >= 0) {
                                              avatarList[pos].selected = false;
                                            }
                                          }
                                          showAvatarError = true;

                                          setState(() {});
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(
                                              size.width * numD01),
                                          decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle),
                                          child: Icon(Icons.cancel,
                                              color: Colors.black,
                                              size: size.width * numD035),
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
                                      vertical: size.width * numD01),
                                  child: Text(
                                    requiredText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD03,
                                        color: Colors.red.shade700,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ),
                              )
                            : Container(),
                        SizedBox(
                          height: size.width * numD02,
                        ),
                        Text(
                          chooseAvatarNoteText,
                          style: TextStyle(
                            color: colorHint,
                            fontSize: size.width * numD025,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        SizedBox(
                          height: size.width * numD06,
                        ),
                        CommonTextField(
                          size: size,
                          maxLines: 1,
                          borderColor: colorTextFieldBorder,
                          controller: userNameController,
                          hintText: userNameHintText,
                          errorMaxLines: 2,
                          textInputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'[ \\]')),
                          ],
                          suffixIcon: getUsernameSuffixIcon(),
                          prefixIcon: const Icon(Icons.person_outline_sharp),
                          prefixIconHeight: size.width * numD06,
                          suffixIconIconHeight: size.width * numD085,
                          hidePassword: false,
                          keyboardType: TextInputType.text,
                          enableValidations: true,
                          validator: userNameValidator,
                          filled: false,
                          filledColor: Colors.transparent,
                          autofocus: false,
                          onChanged: (v) {
                            if (v!.trim().length >= 4) {
                              checkUserNameApi();
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: size.width * numD01,
                        ),
                        Text(
                          userNameNoteText,
                          style: TextStyle(
                              color: colorHint, fontSize: size.width * numD025),
                        ),
                        SizedBox(
                          height: size.height * numD02,
                        ),
                        CommonTextField(
                          size: size,
                          maxLines: 1,
                          borderColor: colorTextFieldBorder,
                          controller: phoneController,
                          hintText: phoneHintText,
                          textInputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp("[0-9]")),
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
                                  width: size.width * numD01,
                                ),
                                Text(
                                  selectedCountryCodePicker,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: size.width * numD07,
                                )
                              ],
                            ),
                          ),
                          prefixIconHeight: size.width * numD06,
                          suffixIconIconHeight: size.width * numD085,
                          suffixIcon: phoneController.text.trim().length >= 7
                              ? phoneAlreadyExists
                                  ? const Icon(
                                      Icons.highlight_remove,
                                      color: Colors.red,
                                    )
                                  : const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    )
                              : null,
                          hidePassword: false,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: false, signed: true),
                          validator: checkSignupPhoneValidator,
                          enableValidations: true,
                          filled: false,
                          filledColor: Colors.transparent,
                          autofocus: false,
                          onChanged: (val) {
                            checkPhoneApi();
                            return null;
                          },
                        ),
                        SizedBox(
                          height: size.width * numD06,
                        ),
                        CommonTextField(
                          size: size,
                          maxLines: 1,
                          borderColor: colorTextFieldBorder,
                          controller: referralCodeController,
                          hintText: referralCodeHintText,
                          errorMaxLines: 2,
                          textInputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'[ \\]')),
                          ],
                          suffixIcon: getReferralCodeSuffixIcon(),
                          prefixIcon: const Icon(Icons.campaign_outlined),
                          prefixIconHeight: size.width * numD06,
                          suffixIconIconHeight: size.width * numD085,
                          hidePassword: false,
                          keyboardType: TextInputType.text,
                          enableValidations: false,
                          filled: false,
                          filledColor: Colors.transparent,
                          autofocus: false,
                          onChanged: (v) {
                            if (v!.trim().length >= 5) {
                              verifyReferredCode();
                            } else if (v.trim().isEmpty) {
                              isRefferalCodeValid = false;
                              setState(() {});
                            }
                            return null;
                          },
                          validator: null,
                        ),
                        SizedBox(
                          height: size.width * numD01,
                        ),
                        Text(
                          referralcodeNoteText,
                          style: TextStyle(
                              color: colorHint, fontSize: size.width * numD025),
                        ),
                        SizedBox(
                          height: size.width * numD04,
                        ),
                        InkWell(
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            rememberMe = false;

                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) => TermCheckScreen(
                                          type: 'legal',
                                        )))
                                .then((value) {
                              if (value != null) {
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
                                          top: size.width * numD008),
                                      child: Image.asset(
                                        "${iconsPath}ic_checkbox_filled.png",
                                        height: size.width * numD06,
                                      ),
                                    )
                                  : Container(
                                      margin: EdgeInsets.only(
                                          top: size.width * numD008),
                                      child: Image.asset(
                                          "${iconsPath}ic_checkbox_empty.png",
                                          height: size.width * numD06),
                                    ),
                              SizedBox(
                                width: size.width * numD02,
                              ),
                              Expanded(
                                child: Text(
                                  "Accept our T&Cs and Privacy Policy",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: "AirbnbCereal",
                                      fontSize: size.width * numD035),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: size.width * numD06,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: size.width * numD04),
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
                              commonButtonStyle(size, colorThemePink), () {
                            if (formKey.currentState!.validate()) {
                              if (!isSelectCheck) {
                                showSnackBar("Error", enableNotificationText,
                                    Colors.red);
                              } else if (!termConditionsChecked) {
                                showSnackBar(
                                    "Privacy Policy",
                                    "Please accept our T&Cs and Privacy Policy",
                                    Colors.red);
                              } else if (selectedAvatar.isEmpty) {
                                showSnackBar("Avatar",
                                    "Please select an Avatar", Colors.red);
                              } else {
                                Map<String, dynamic> params = {};
                                params[emailKey] = widget.email.trim().toLowerCase();
                                params[isTermAcceptedKey] = termConditionsChecked.toString();
                                params[firstNameKey] = widget.name;
                                params[receiveTaskNotificationKey] = isSelectCheck.toString();
                                params[phoneKey] = phoneController.text.trim();
                                params[roleKey] = "Hopper";
                                params[avatarIdKey] = selectedAvatarId;
                                if (isRefferalCodeValid) {
                                  params[referredCodeKey] = referralCodeController.text.trim();
                                }
                                params[userNameKey] = userNameController.text.trim().toLowerCase();
                                params["social_id"] = widget.socialId;
                                params["social_type"] = widget.socialType.toLowerCase();
                                params["_imagePath"] = userImagePath;

                                context.read<SignUpBloc>().add(SocialSignUpSubmitted(data: params));
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
    );
        },
      ),
    );  

  }

  Icon? getReferralCodeSuffixIcon() {
    String referralCode = referralCodeController.text.trim().toLowerCase();
    if (referralCode.isEmpty) {
      return null;
    }
    if (referralCode.length < 4 || !isRefferalCodeValid) {
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
      onSelect: (Country country) {
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
    context.read<SignUpBloc>().add(VerifyReferralCodeEvent(referralCodeController.text.trim()));
  }

  void checkPhoneApi() {
    context.read<SignUpBloc>().add(CheckPhoneEvent(phoneController.text.trim()));
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

    if (userNameValidator(userNameController.text) != null) {
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
      return requiredText;
    }

    String firstName = widget.name.trim().toLowerCase();
    String username = value.trim().toLowerCase();

    print("firstName = $firstName");

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

    if (value.length < 4) {
      return "Your username must be at least 4 characters in length.";
    }
    if (_restrictPattern.hasMatch(value.trim()) ||
        _restrictPatter2.hasMatch(value.trim()) ||
        _restrictPatter3.hasMatch(value.trim())) {
      return "Domain names are not allowed for security reasons.";
    }
    if (userNameAlreadyExists) {
      isRefferalCodeValid = false;
      return "This username is already taken. Please choose another one.";
    }

    return null;
  }

  void avatarBottomSheet(Size size) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return ValueListenableBuilder<bool>(
              valueListenable: _avatarsNotifier,
              builder: (context, value, child) {
                return StatefulBuilder(builder: (context, avatarState) {
                  return Container(
                    height: size.height * 0.6,
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: size.width * numD04),
                          child: Row(
                            children: [
                              Text(
                                chooseAvatarText,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD05,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700),
                              ),
                              const Spacer(),
                              IconButton(
                                  splashRadius: size.width * numD06,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.black,
                                    size: size.width * numD06,
                                  ))
                            ],
                          ),
                        ),
                        Expanded(
                            child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: avatarList.isEmpty
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                    ),
                                  )
                                : StaggeredGrid.count(
                                    crossAxisCount: 6,
                                    mainAxisSpacing: 3.0,
                                    crossAxisSpacing: 4.0,
                                    axisDirection: AxisDirection.down,
                                    children: avatarList.map<Widget>((item) {
                                      return InkWell(
                                        onTap: () {
                                          int pos = avatarList.indexWhere(
                                              (element) => element.selected);

                                          if (pos >= 0) {
                                            avatarList[pos].selected = false;
                                          }
                                          selectedAvatar = item.avatar;
                                          selectedAvatarId = item.id;
                                          item.selected = true;
                                          showAvatarError = false;
                                          avatarState(() {});
                                          setState(() {});
                                          Navigator.pop(context);
                                        },
                                        child: Stack(
                                          children: [
                                            Image.network(
                                              "$avatarBaseUrl/${item.avatar}",
                                              errorBuilder:
                                                  (BuildContext context,
                                                      Object exception,
                                                      StackTrace? stackTrace) {
                                                return Image.asset(
                                                  "${commonImagePath}rabbitLogo.png",
                                                  fit: BoxFit.contain,
                                                  width: size.width * numD20,
                                                  height: size.width * numD20,
                                                );
                                              },
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.black,
                                                    strokeWidth: 2,
                                                  ),
                                                );
                                              },
                                            ),
                                            if (item.selected)
                                              Align(
                                                alignment: Alignment.topRight,
                                                child: Icon(
                                                  Icons.check,
                                                  color: Colors.black,
                                                  size: size.width * numD06,
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ),
                        ))
                      ],
                    ),
                  );
                });
              });
        });
  }

  // String? checkSignupPhoneValidator(String? value) {
  //   if (value!.isEmpty) {
  //     return requiredText;
  //   } else if (value.length < 10) {
  //     return phoneErrorText;
  //   } else if (phoneAlreadyExists) {
  //     return phoneExistsErrorText;
  //   }
  //   return null;
  // }

  String? checkSignupPhoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return requiredText;
    }

    String digitsOnly = value.trim().replaceAll(RegExp(r'\D+'), '');

    // Default fallback
    int minLength = 7;
    int maxLength = 15;

    // Try to get country-specific length
    final countryData =
        phoneNumberLengthByCountryCode[selectedCountryCodePicker];
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
      return phoneExistsErrorText;
    }

    return null;
  }

  String? checkSignupEmailValidator(String? value) {
    if (value!.isEmpty) {
      return requiredText;
    } else if (!emailExpression.hasMatch(value)) {
      return emailErrorText;
    } else if (emailAlreadyExists) {
      return emailExistsErrorText;
    }
    return null;
  }

  ///ApisSection------------
  void checkUserNameApi() {
    context.read<SignUpBloc>().add(CheckUserNameEvent(userNameController.text.trim().toLowerCase()));
  }

  void checkEmailApi() {
    context.read<SignUpBloc>().add(CheckEmailEvent(widget.email));
  }

  void getAvatarsApi() {
    context.read<SignUpBloc>().add(FetchAvatarsEvent());
  }

  // Add this map at the top of your state class
  static final Map<String, int> phoneNumberMaxLengthByCountry = {
    // Format: '+CountryCode': maxDigits
    '+1': 10, // USA, Canada
    '+44': 10, // UK
    '+91': 10, // India
    '+33': 9, // France
    '+49': 11, // Germany
    '+39': 10, // Italy
    '+34': 9, // Spain
    '+81': 11, // Japan
    '+86': 11, // China
    '+61': 9, // Australia
    '+55': 11, // Brazil
    '+52': 10, // Mexico
    '+7': 10, // Russia
    '+27': 9, // South Africa
    '+82': 10, // South Korea
    '+90': 10, // Turkey
    '+234': 10, // Nigeria
    '+20': 10, // Egypt
    '+92': 10, // Pakistan
    '+880': 10, // Bangladesh
    '+62': 12, // Indonesia
    '+63': 10, // Philippines
    '+84': 10, // Vietnam
    '+66': 9, // Thailand
    // Add more countries as needed
  };

  int _getMaxPhoneLength() {
    return phoneNumberMaxLengthByCountry[selectedCountryCodePicker] ?? 15;
  }

  static final Map<String, Map<String, int>> phoneNumberLengthByCountryCode = {
    '+1': {'min': 10, 'max': 10}, // USA, Canada
    '+44': {'min': 10, 'max': 10}, // UK
    '+91': {'min': 10, 'max': 10}, // India
    '+33': {'min': 9, 'max': 9}, // France
    '+49': {'min': 10, 'max': 11}, // Germany
    '+39': {'min': 9, 'max': 10}, // Italy
    '+34': {'min': 9, 'max': 9}, // Spain
    '+81': {'min': 10, 'max': 11}, // Japan
    '+86': {'min': 11, 'max': 11}, // China
    '+61': {'min': 9, 'max': 9}, // Australia
    '+55': {'min': 10, 'max': 11}, // Brazil
    '+52': {'min': 10, 'max': 10}, // Mexico
    '+7': {'min': 10, 'max': 10}, // Russia, Kazakhstan
    '+27': {'min': 9, 'max': 9}, // South Africa
    '+82': {'min': 9, 'max': 10}, // South Korea
    '+90': {'min': 10, 'max': 10}, // Turkey
    '+234': {'min': 10, 'max': 10}, // Nigeria
    '+20': {'min': 10, 'max': 10}, // Egypt
    '+92': {'min': 10, 'max': 10}, // Pakistan
    '+880': {'min': 10, 'max': 10}, // Bangladesh
    '+62': {'min': 9, 'max': 12}, // Indonesia
    '+63': {'min': 10, 'max': 10}, // Philippines
    '+84': {'min': 9, 'max': 10}, // Vietnam
    '+66': {'min': 9, 'max': 9}, // Thailand
    // Add more if needed
  };

  void _handleLoginSuccess(User user) {
    if (user.token != null) {
      sharedPreferences!.setString(tokenKey, user.token!);
    }
    if (user.refreshToken != null) {
      sharedPreferences!.setString(refreshtokenKey, user.refreshToken!);
    }
    sharedPreferences!.setString(hopperIdKey, user.id);
    sharedPreferences!.setString(firstNameKey, user.firstName);
    sharedPreferences!.setString(lastNameKey, user.lastName);
    sharedPreferences!.setString(emailKey, user.email);
    
    if(user.userName != null) sharedPreferences!.setString(userNameKey, user.userName!);
    if(user.phone != null) sharedPreferences!.setString(phoneKey, user.phone!);
    if(user.countryCode != null) sharedPreferences!.setString(countryCodeKey, user.countryCode!);
    if(user.address != null) sharedPreferences!.setString(addressKey, user.address!);
    if(user.latitude != null) sharedPreferences!.setString(latitudeKey, user.latitude!);
    if(user.longitude != null) sharedPreferences!.setString(longitudeKey, user.longitude!);
    if(user.avatarId != null) sharedPreferences!.setString(avatarIdKey, user.avatarId!);
    if(user.receiveTaskNotification != null) sharedPreferences!.setBool(receiveTaskNotificationKey, user.receiveTaskNotification!);
    if(user.isTermAccepted != null) sharedPreferences!.setBool(isTermAcceptedKey, user.isTermAccepted!);
    if(user.profileImage != null) sharedPreferences!.setString(profileImageKey, user.profileImage!);
    if(user.referralCode != null) sharedPreferences!.setString(referralCode, user.referralCode!);
    if(user.currencySymbol != null) {
        sharedPreferences!.setString(currencySymbolKey, user.currencySymbol!);
    }
    if(user.totalHopperArmy != null) sharedPreferences!.setString(totalHopperArmy, user.totalHopperArmy!);

    if (user.source != null) {
        var src = user.source!;
        sharedPreferences!.setBool(sourceDataIsOpenedKey, src["is_opened"] ?? false);
        sharedPreferences!.setString(sourceDataTypeKey, src["type"] ?? "");
        sharedPreferences!.setString(sourceDataUrlKey, src["url"] ?? "");
        sharedPreferences!.setString(sourceDataHeadingKey, src["heading"] ?? "");
        sharedPreferences!.setString(sourceDataDescriptionKey, src["description"] ?? "");
        sharedPreferences!.setBool(sourceDataIsClickKey, src["is_clicked"] ?? false);
    }

     Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => WelcomeScreen(
                  hideLeading: false,
                  screenType: '',
                  isSocialLogin: true,
                )),
        (route) => false);
  }
  
  @override
  // TODO: implement pageName
  String get pageName => throw UnimplementedError();
  
}



class AvatarsData {
  String id = "";
  String avatar = "";
  bool selected = false;

  AvatarsData.fromJson(json) {
    id = json["_id"] ?? "";
    avatar = json["avatar"] ?? "";
  }
}
