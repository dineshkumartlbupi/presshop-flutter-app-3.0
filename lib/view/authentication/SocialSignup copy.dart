import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/utils/networkOperations/NetworkClass.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:presshop/view/authentication/TermCheckScreen.dart';
import 'package:presshop/view/authentication/WelcomeScreen.dart';

import '../../main.dart';
import '../../utils/AnalyticsConstants.dart';
import '../../utils/AnalyticsMixin.dart';
import '../../utils/CommonSharedPrefrence.dart';
import '../../utils/CommonTextField.dart';
import '../../utils/CommonWigdets.dart';
import '../dashboard/Dashboard.dart';
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
    with SingleTickerProviderStateMixin, AnalyticsPageMixin
    implements NetworkResponse {
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

  bool _isLoggedIn = false;
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

    WidgetsBinding.instance.addPostFrameCallback((_) => getAvatarsApi());
  }

  @override
  void dispose() {
    controller.dispose();
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
                            FilteringTextInputFormatter.allow(RegExp("[0-9]"))
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
                                  "Accept our T\&Cs and Privacy Policy",
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
                                    "Please accept our T\&Cs and Privacy Policy",
                                    Colors.red);
                              } else if (selectedAvatar.isEmpty) {
                                showSnackBar("Avatar",
                                    "Please select an Avatar", Colors.red);
                              } else {
                                socialRegisterLoginApi();
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

  void socialRegisterLoginApi() {
    print("social45454 register api called");
    try {
      Map<String, String> params = {};
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

      NetworkClass.fromNetworkClass(
        socialLoginRegisterUrl,
        this,
        socialLoginRegisterUrlRequest,
        params,
      ).callRequestServiceHeader(false, "post", null);

      NetworkClass.multipartNetworkClassFiles(socialLoginRegisterUrl, this,
              socialLoginRegisterUrlRequest, params, [File(userImagePath)])
          .callMultipartService(true, "post", ["profile_image"], []);
    } on Exception catch (e) {
      debugPrint("from social234567 signup $e");
    }
  }

  // void socialRegisterLoginApi() async {
  //   print("🟢 socialRegisterLoginApi called");

  //   try {
  //     Map<String, String> params = {
  //       emailKey: widget.email.trim().toLowerCase(),
  //       isTermAcceptedKey: termConditionsChecked.toString(),
  //       firstNameKey: widget.name,
  //       receiveTaskNotificationKey: isSelectCheck.toString(),
  //       phoneKey: phoneController.text.trim(),
  //       roleKey: "Hopper",
  //       avatarIdKey: selectedAvatarId,
  //       userNameKey: userNameController.text.trim().toLowerCase(),
  //       "social_id": widget.socialId,
  //       "social_type": widget.socialType.toLowerCase(),
  //     };

  //     if (isRefferalCodeValid) {
  //       params[referredCodeKey] = referralCodeController.text.trim();
  //     }

  //     if (userImagePath.isNotEmpty) {
  //       print("🟡 Uploading with image...");
  //       await NetworkClass.multipartNetworkClassFiles(
  //         socialLoginRegisterUrl,
  //         this,
  //         socialLoginRegisterUrlRequest,
  //         params,
  //         [File(userImagePath)],
  //       ).callMultipartService(
  //         true,
  //         "post",
  //         ["profile_image"],
  //         ["profile_image"],
  //       );
  //     } else {
  //       print("🟣 Uploading without image...");
  //       await NetworkClass.fromNetworkClass(
  //         socialLoginRegisterUrl,
  //         this,
  //         socialLoginRegisterUrlRequest,
  //         params,
  //       ).callRequestServiceHeader(
  //         false,
  //         "post",
  //         null,
  //       );
  //     }
  //   } catch (e, st) {
  //     debugPrint("❌ socialRegisterLoginApi Exception: $e\n$st");
  //   }
  // }

  void verifyReferredCode() {
    try {
      Map<String, String> params = {
        "referredCode": referralCodeController.text.trim(),
      };
      NetworkClass.fromNetworkClass(
              verifyReferredCodeUrl, this, verifyReferredCodeUrlRequest, params)
          .callRequestServiceHeader(false, "post", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  void checkPhoneApi() {
    try {
      NetworkClass("$checkPhoneUrl${phoneController.text.trim()}", this,
              checkPhoneUrlRequest)
          .callRequestServiceHeader(false, "get", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
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
                      child: StaggeredGrid.count(
                        crossAxisCount: 6,
                        mainAxisSpacing: 3.0,
                        crossAxisSpacing: 4.0,
                        axisDirection: AxisDirection.down,
                        children: avatarList.map<Widget>((item) {
                          return InkWell(
                            onTap: () {
                              int pos = avatarList
                                  .indexWhere((element) => element.selected);

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
                                  errorBuilder: (BuildContext context,
                                      Object exception,
                                      StackTrace? stackTrace) {
                                    return Image.asset(
                                      "${commonImagePath}rabbitLogo.png",
                                      fit: BoxFit.contain,
                                      width: size.width * numD20,
                                      height: size.width * numD20,
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
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
  }

  String? checkSignupPhoneValidator(String? value) {
    if (value!.isEmpty) {
      return requiredText;
    } else if (value.length < 10) {
      return phoneErrorText;
    } else if (phoneAlreadyExists) {
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
    try {
      NetworkClass(
              "$checkUserNameUrl${userNameController.text.trim().toLowerCase()}",
              this,
              checkUserNameUrlRequest)
          .callRequestServiceHeader(false, "get", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  void checkEmailApi() {
    try {
      NetworkClass("$checkEmailUrl${widget.email}", this, checkEmailUrlRequest)
          .callRequestServiceHeader(false, "get", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  void getAvatarsApi() {
    try {
      NetworkClass(getAvatarsUrl, this, getAvatarsUrlRequest)
          .callRequestServiceHeader(false, "get", null);
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
        case socialLoginRegisterUrlRequest:
          var map = jsonDecode(response);
          debugPrint("SocialLoginRegisterResponseError:$map");
          showSnackBar("Error", "Something went wrong", Colors.red);
          break;
        case verifyReferredCodeUrlRequest:
          var map = jsonDecode(response);
          debugPrint("VerifyReferredCodeResponse:$map");
          isRefferalCodeValid = false;
          setState(() {});
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
        case checkUserNameUrlRequest:
          var map = jsonDecode(response);
          debugPrint("CheckUserNameResponse success:::::$map");
          userNameAlreadyExists = map["userNameExist"];
          setState(() {});
          break;
        case checkPhoneUrlRequest:
          var map = jsonDecode(response);
          debugPrint("CheckPhoneResponse:$map");
          phoneAlreadyExists = map["phoneExist"];
          setState(() {});
          break;

        case verifyReferredCodeUrlRequest:
          var map = jsonDecode(response);
          debugPrint("VerifyReferredCodeResponse:$map");
          isRefferalCodeValid = true;
          setState(() {});
          break;
        case socialLoginRegisterUrlRequest:
          debugPrint("SocialSuccess: $response");
          var map = jsonDecode(response);

          if (map["code"] == 200) {
            rememberMe = true;
            sharedPreferences!.setBool(rememberKey, true);
            sharedPreferences!.setString(tokenKey, map[tokenKey]);

            // rajesh
            // sharedPreferences!.setString(refreshtokenKey, map[refreshtokenKey]);

            sharedPreferences!.setString(hopperIdKey, map["user"][hopperIdKey]);
            sharedPreferences!
                .setString(firstNameKey, map["user"][firstNameKey]);
            sharedPreferences!.setString(lastNameKey, map["user"][lastNameKey]);
            sharedPreferences!.setString(userNameKey, map["user"][userNameKey]);
            sharedPreferences!.setString(phoneKey, map["user"][phoneKey]);
            sharedPreferences!
                .setString(referralCode, map["user"][referralCode]);
            sharedPreferences!.setString(totalHopperArmy,
                map['user'][currencySymbolKey]['symbol'].toString());
            sharedPreferences!
                .setString(countryCodeKey, map["user"][countryCodeKey]);
            sharedPreferences!.setString(addressKey, map["user"][addressKey]);
            sharedPreferences!
                .setString(latitudeKey, map["user"][latitudeKey].toString());
            sharedPreferences!
                .setString(longitudeKey, map["user"][longitudeKey].toString());
            sharedPreferences!.setString(avatarIdKey, map["user"][avatarIdKey]);

            print(" location44434 ${map["user"][receiveTaskNotificationKey]}");

            // sharedPreferences!.setBool(receiveTaskNotificationKey,
            //     map["user"][receiveTaskNotificationKey]);

// rajesh
            //  map["user"][recieve_task_notification]

            sharedPreferences!
                .setBool(isTermAcceptedKey, map["user"][isTermAcceptedKey]);

            if (map["user"][profileImageKey] != null) {
              sharedPreferences!
                  .setString(profileImageKey, map["user"][profileImageKey]);
            }
            currencySymbol =
                sharedPreferences!.getString(currencySymbolKey) ?? "£";
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => WelcomeScreen(
                          hideLeading: false,
                          screenType: '',
                          isSocialLogin: true,
                        )),
                (route) => false);
          }

          break;

        case checkEmailUrlRequest:
          var map = jsonDecode(response);
          debugPrint("CheckEmailResponse:$map");
          emailAlreadyExists = map["emailExist"];
          setState(() {});
          break;
        case getAvatarsUrlRequest:
          var map = jsonDecode(response);

          avatarBaseUrl = map["base_url"];
          var list = map["response"] as List;
          avatarList = list.map((e) => AvatarsData.fromJson(e)).toList();
          debugPrint("AvatarList: ${avatarList.length}");
          setState(() {});
          break;
        case sendOtpUrlRequest:
          break;

        case socialExistUrlRequest:
          var map = jsonDecode(response);
          debugPrint("SocialExistResponse: $response");

          if (map["code"] == 200) {
            if (map["token"] != null) {
              debugPrint("inside this::::::");
              //  rememberMe = true;
              //   sharedPreferences!.setBool(rememberKey, true);
              sharedPreferences!.setString(tokenKey, map[tokenKey]);
              sharedPreferences!
                  .setString(refreshtokenKey, map[refreshtokenKey]);

              sharedPreferences!
                  .setString(hopperIdKey, map["user"][hopperIdKey]);
              sharedPreferences!
                  .setString(firstNameKey, map["user"][firstNameKey]);
              sharedPreferences!
                  .setString(lastNameKey, map["user"][lastNameKey]);
              sharedPreferences!
                  .setString(userNameKey, map["user"][userNameKey]);
              sharedPreferences!.setString(emailKey, map["user"][emailKey]);
              sharedPreferences!.setString(phoneKey, map["user"][phoneKey]);
              sharedPreferences!.setString(
                  totalHopperArmy, map['user'][totalHopperArmy].toString());
              sharedPreferences!
                  .setString(countryCodeKey, map["user"][countryCodeKey]);
              sharedPreferences!.setString(addressKey, map["user"][addressKey]);
              sharedPreferences!
                  .setString(latitudeKey, map["user"][latitudeKey].toString());
              sharedPreferences!.setString(
                  longitudeKey, map["user"][longitudeKey].toString());
              if (map["user"][avatarIdKey] != null) {
                sharedPreferences!.setString(
                    avatarIdKey, map["user"][avatarIdKey]["_id"].toString());
                sharedPreferences!
                    .setString(avatarKey, map["user"][avatarIdKey][avatarKey]);
              }

              sharedPreferences!.setBool(receiveTaskNotificationKey,
                  map["user"][receiveTaskNotificationKey]);
              sharedPreferences!
                  .setBool(isTermAcceptedKey, map["user"][isTermAcceptedKey]);

              if (map["user"][profileImageKey] != null) {
                sharedPreferences!
                    .setString(profileImageKey, map["user"][profileImageKey]);
              }

              if (map["user"]["doc_to_become_pro"] != null) {
                debugPrint("InsideDoc");
                if (map["user"]["doc_to_become_pro"]["govt_id"] != null) {
                  debugPrint("InsideGov");
                  sharedPreferences!.setString(
                      file1Key, map["user"]["doc_to_become_pro"]["govt_id"]);
                  sharedPreferences!.setBool(skipDocumentsKey, true);
                }
                if (map["user"]["doc_to_become_pro"]
                        ["comp_incorporation_cert"] !=
                    null) {
                  sharedPreferences!.setString(
                      file2Key,
                      map["user"]["doc_to_become_pro"]
                          ["comp_incorporation_cert"]);
                  sharedPreferences!.setBool(skipDocumentsKey, true);
                }

                if (map["user"]["doc_to_become_pro"]["photography_licence"] !=
                    null) {
                  sharedPreferences!.setString(file3Key,
                      map["user"]["doc_to_become_pro"]["photography_licence"]);
                  sharedPreferences!.setBool(skipDocumentsKey, true);
                }
              }

              if (map["user"]["bank_detail"] != null) {
                var bankList = map["user"]["bank_detail"] as List;
                debugPrint("bankList:::::${bankList.length}");
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
                                builder: (context) =>
                                    const UploadDocumentsScreen(
                                      menuScreen: false,
                                      hideLeading: true,
                                    )),
                            (route) => false);
                      });
                }
              }
            } else {
              scrollController.animateTo(
                // scrollController.position.maxScrollExtent,
                scrollController.position.minScrollExtent,
                duration: const Duration(seconds: 2),
                curve: Curves.fastOutSlowIn,
              );
            }
          }
          break;
      }
    } on Exception catch (e) {
      print("exceptionsdfsdf in social signup on response");
      debugPrint("$e");
    }
  }

  @override
  // TODO: implement pageName
  String get pageName => PageNames.socialSignup;
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
