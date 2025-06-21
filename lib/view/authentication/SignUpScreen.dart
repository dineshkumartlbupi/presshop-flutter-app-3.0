import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/networkOperations/NetworkClass.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:presshop/view/authentication/TermCheckScreen.dart';
import 'package:presshop/view/authentication/VerifyAccountScreen.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../main.dart';
import '../../utils/CommonSharedPrefrence.dart';
import '../../utils/CommonTextField.dart';
import '../../utils/CommonWigdets.dart';
import '../dashboard/Dashboard.dart';
import 'UploadDocumnetsScreen.dart';

class SignUpScreen extends StatefulWidget {
  bool socialLogin = false;
  String socialId = "";
  String name = "";
  String email = "";
  String phoneNumber = "";

  SignUpScreen(
      {super.key,
      required this.socialLogin,
      required this.socialId,
      required this.email,
      required this.name,
      required this.phoneNumber});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin
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
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
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
      emailAlreadyExists = false,
      phoneAlreadyExists = false,
      showAvatarError = false,
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

  late GoogleSignInAccount _userObj;
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
      firstNameController.text = nameParts[0];
      lastNameController.text = nameParts.length > 1 ? nameParts[1] : '';
      emailController.text = widget.email;
      phoneController.text = widget.phoneNumber;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => getAvatarsApi());
    if (Platform.isIOS) {
    } else if (Platform.isAndroid) {}
    setPasswordListener();
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
                    signUpText,
                    style: commonBigTitleTextStyle(size, Colors.black),
                  ),
                  SizedBox(
                    height: size.width * numD01,
                  ),
                  Text(
                    signUpSubTitleText,
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
                          controller: firstNameController,
                          size: size,
                          borderColor: colorTextFieldBorder,
                          maxLines: 1,
                          enableValidations: true,
                          hintText: firstNameHintText,
                          textInputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp("[a-z A-Z]"))
                          ],
                          prefixIcon: const Icon(Icons.person_outline_sharp),
                          prefixIconHeight: size.width * numD06,
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
                          height: size.width * numD06,
                        ),
                        CommonTextField(
                          size: size,
                          maxLines: 1,
                          borderColor: colorTextFieldBorder,
                          controller: lastNameController,
                          hintText: lastNameHintText,
                          textInputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp("[a-z A-Z]"))
                          ],
                          prefixIcon: const Icon(Icons.person_outline_sharp),
                          prefixIconHeight: size.width * numD06,
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
                          height: size.width * numD04,
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
                          suffixIcon: phoneController.text.trim().length >= 10
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
                          controller: emailController,
                          hintText: emailHintText,
                          textInputFormatters: null,
                          prefixIcon: const Icon(Icons.email_outlined),
                          prefixIconHeight: size.width * numD06,
                          suffixIconIconHeight: 0,
                          suffixIcon: null,
                          hidePassword: false,
                          keyboardType: TextInputType.emailAddress,
                          validator: checkSignupEmailValidator,
                          enableValidations: true,
                          filled: false,
                          filledColor: Colors.transparent,
                          autofocus: false,
                          onChanged: (val) {
                            debounce =
                                Timer(const Duration(milliseconds: 300), () {
                              checkEmailApi();
                            });
                          },
                        ),
                        SizedBox(
                          height: size.width * numD06,
                        ),

                        CommonTextField(
                          size: size,
                          maxLines: 1,
                          borderColor: colorTextFieldBorder,
                          controller: selectDobController,
                          hintText: "Select date of birth",
                          textInputFormatters: null,
                          prefixIcon: const Icon(Icons.calendar_month_rounded),
                          prefixIconHeight: size.width * numD06,
                          suffixIconIconHeight: 0,
                          suffixIcon: null,
                          hidePassword: false,
                          keyboardType: TextInputType.text,
                          validator: null,
                          enableValidations: false,
                          filled: false,
                          filledColor: Colors.transparent,
                          autofocus: false,
                          readOnly: true,
                          callback: () {
                            selectedDate();
                          },
                        ),
                        SizedBox(
                          height: size.width * numD06,
                        ),

                        /// Apartment Number & House name
                        CommonTextField(
                          size: size,
                          maxLines: 1,
                          borderColor: colorTextFieldBorder,
                          controller: apartmentAndHouseNameController,
                          hintText: apartmentNoHintText,
                          textInputFormatters: null,
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          prefixIconHeight: size.width * numD045,
                          suffixIconIconHeight: 0,
                          suffixIcon: null,
                          hidePassword: false,
                          keyboardType: TextInputType.text,
                          enableValidations: true,
                          filled: false,
                          filledColor: Colors.transparent,
                          autofocus: false,
                          onChanged: (value) {
                            if (value!.isNotEmpty) {
                              showApartmentNumberError = false;
                            } else {
                              showApartmentNumberError = true;
                            }
                            setState(() {});
                          },
                          validator: null,
                        ),

                        SizedBox(
                          height: size.width * numD06,
                        ),

                        /// Post Code
                        SizedBox(
                          height: size.width * numD13,
                          child: GooglePlaceAutoCompleteTextField(
                            containerHorizontalPadding: 0,
                            textEditingController: postalCodeController,
                            googleAPIKey: Platform.isIOS
                                ? appleMapAPiKey
                                : googleMapAPiKey,
                            isCrossBtnShown: false,
                            boxDecoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(size.width * 0.03),
                                border: Border.all(
                                    color: colorTextFieldBorder, width: 1)),
                            textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: size.width * numD03,
                                fontFamily: 'AirbnbCereal'),
                            inputDecoration: InputDecoration(
                              border: InputBorder.none,
                              filled: false,
                              hintText:
                                  "${enterText.toTitleCase()} ${postalCodeText.toLowerCase()}",
                              hintStyle: TextStyle(
                                  color: colorHint,
                                  fontSize: size.width * numD035,
                                  fontFamily: 'AirbnbCereal'),
                              prefixIcon:
                                  const Icon(Icons.location_on_outlined),
                              suffixIcon: postalCodeController.text.isNotEmpty
                                  ? InkWell(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () {
                                        postalCodeController.clear();
                                        apartmentAndHouseNameController.clear();
                                        addressController.clear();
                                        cityNameController.clear();
                                        countryNameController.clear();
                                      },
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.black,
                                        size: size.width * numD058,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              prefixIconColor: colorTextFieldIcon,
                              prefixIconConstraints:
                                  BoxConstraints(minWidth: size.width * numD10),
                            ),
                            debounceTime: 200,
                            countries: const ["uk", "in"],
                            isLatLngRequired: true,
                            getPlaceDetailWithLatLng: (Prediction prediction) {
                              latitude = prediction.lat.toString();
                              longitude = prediction.lng.toString();
                              debugPrint("placeDetails${prediction.lng}");
                              debugPrint("placeDetails${prediction.lng}");
                              getCurrentLocationFxn(prediction.lat ?? "",
                                      prediction.lng ?? "")
                                  .then((value) {
                                debugPrint("pin code===> $value");
                                if (value.isNotEmpty) {
                                  cityNameController.text =
                                      value.first.locality ??
                                          value.first.subAdministrativeArea ??
                                          '';
                                  countryNameController.text =
                                      value.first.country ?? '';
                                  postalCodeController.text =
                                      value.first.postalCode ?? '';
                                }
                              });
                              showAddressError = false;
                              setState(() {});
                            },
                            itemClick: (Prediction prediction) {
                              addressController.text =
                                  prediction.description ?? "";
                              latitude = prediction.lat ?? "";
                              longitude = prediction.lng ?? "";

                              String postalCode =
                                  prediction.structuredFormatting?.mainText ??
                                      '';
                              debugPrint("postalCode=======> $postalCode");
                              //  postalCodeController.text = postalCode;
                              addressController.selection =
                                  TextSelection.fromPosition(TextPosition(
                                      offset: prediction.description != null
                                          ? prediction.description!.length
                                          : 0));
                            },
                          ),
                        ),
                        // pin code required
                        // postalCodeController.text.trim().isEmpty
                        //     ? Padding(
                        //         padding: EdgeInsets.symmetric(
                        //             vertical: size.width * numD01),
                        //         child: Text(
                        //           requiredText,
                        //           style: commonTextStyle(
                        //               size: size,
                        //               fontSize: size.width * numD03,
                        //               color: Colors.red.shade700,
                        //               fontWeight: FontWeight.normal),
                        //         ),
                        //       )
                        //     : Container(),

                        SizedBox(
                          height: postalCodeController.text.isNotEmpty
                              ? size.width * numD06
                              : 0,
                        ),
                        postalCodeController.text.isNotEmpty
                            ? CommonTextField(
                                size: size,
                                maxLines: 1,
                                borderColor: colorTextFieldBorder,
                                controller: addressController,
                                hintText:
                                    "${enterText.toTitleCase()} ${addressText.toLowerCase()}",
                                textInputFormatters: null,
                                prefixIcon:
                                    const Icon(Icons.location_on_outlined),
                                prefixIconHeight: size.width * numD06,
                                suffixIconIconHeight: 0,
                                suffixIcon: null,
                                hidePassword: false,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: false, signed: false),
                                enableValidations: true,
                                filled: false,
                                filledColor: Colors.transparent,
                                autofocus: false,
                                validator: null,
                              )
                            : Container(),
                        showPostalCodeError &&
                                postalCodeController.text.trim().isEmpty &&
                                addressController.text.isNotEmpty
                            ? Padding(
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
                              )
                            : Container(),
                        SizedBox(
                          height: postalCodeController.text.isNotEmpty
                              ? size.width * numD06
                              : 0,
                        ),

                        // /// City
                        // postalCodeController.text.isNotEmpty
                        //     ? CommonTextField(
                        //         size: size,
                        //         maxLines: 1,
                        //         borderColor: colorTextFieldBorder,
                        //         controller: cityNameController,
                        //         hintText: cityText,
                        //         textInputFormatters: null,
                        //         prefixIcon:
                        //             const Icon(Icons.location_on_outlined),
                        //         prefixIconHeight: size.width * numD06,
                        //         suffixIconIconHeight: 0,
                        //         suffixIcon: null,
                        //         hidePassword: false,
                        //         keyboardType: TextInputType.text,
                        //         enableValidations: true,
                        //         filled: false,
                        //         filledColor: Colors.transparent,
                        //         autofocus: false,
                        //         validator: null,
                        //       )
                        //     : Container(),
                        // SizedBox(
                        //   height: postalCodeController.text.isNotEmpty
                        //       ? size.width * numD06
                        //       : 0,
                        // ),

                        /// country Text
                        postalCodeController.text.isNotEmpty
                            ? CommonTextField(
                                size: size,
                                maxLines: 1,
                                borderColor: colorTextFieldBorder,
                                controller: countryNameController,
                                hintText: countryText,
                                textInputFormatters: null,
                                prefixIcon:
                                    const Icon(Icons.location_on_outlined),
                                prefixIconHeight: size.width * numD06,
                                suffixIconIconHeight: 0,
                                suffixIcon: null,
                                hidePassword: false,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: false, signed: false),
                                enableValidations: true,
                                filled: false,
                                filledColor: Colors.transparent,
                                autofocus: false,
                                validator: null,
                              )
                            : Container(),
                        SizedBox(
                          height: size.width * numD06,
                        ),
                        !widget.socialLogin
                            ? CommonTextField(
                                size: size,
                                maxLines: 1,
                                borderColor: colorTextFieldBorder,
                                controller: passwordController,
                                hintText: enterPasswordHint,
                                textInputFormatters: null,
                                prefixIcon: const Icon(Icons.lock_outline),
                                onChanged: (text) {
                                  if (text.toString().length < 8) {
                                    showMincase = false;
                                    setState(() {});
                                  } else {
                                    showMincase = true;
                                    setState(() {});
                                  }

                                  if (!RegExp(r'[A-Z]')
                                      .hasMatch(text.toString())) {
                                    showUppercase = false;
                                    setState(() {});
                                  } else {
                                    showUppercase = true;
                                    setState(() {});
                                  }

                                  if (!RegExp(r'[a-z]')
                                      .hasMatch(text.toString())) {
                                    showLowercase = false;
                                    setState(() {});
                                  } else {
                                    showLowercase = true;
                                    setState(() {});
                                  }

                                  if (!RegExp(r'[0-9]')
                                      .hasMatch(text.toString())) {
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
                                },
                                prefixIconHeight: size.width * numD08,
                                suffixIconIconHeight: size.width * numD06,
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
                                        color: !hidePassword
                                            ? colorTextFieldIcon
                                            : colorHint,
                                      ),
                                    ),
                                    SizedBox(
                                      width: passwordStrengthValue.isNotEmpty &&
                                              passwordStrengthValue ==
                                                  strongText
                                          ? size.width * numD02
                                          : 0,
                                    ),
                                    passwordStrengthValue.isNotEmpty &&
                                            passwordStrengthValue == strongText
                                        ? const ImageIcon(
                                            AssetImage(
                                              "${iconsPath}checked.png",
                                            ),
                                            color: Colors.green,
                                          )
                                        : Container(),
                                  ],
                                ),
                                hidePassword: hidePassword,
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
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
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: size.width * 0.03,
                                  ),
                                  Text(
                                    "Minimum password requirement",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: size.width * 0.045,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(
                                    height: size.width * 0.02,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                              )
                            : const SizedBox.shrink(),
                        SizedBox(
                          height: !widget.socialLogin
                              ? passwordStrengthValue.isNotEmpty
                                  ? size.width * numD02
                                  : 0
                              : 0,
                        ),
                        passwordStrengthValue.trim().isNotEmpty &&
                                !widget.socialLogin
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    passwordStrengthText,
                                    style: TextStyle(
                                        color: colorHint,
                                        fontSize: size.width * numD03),
                                  ),
                                  Text(
                                    passwordStrengthValue,
                                    style: TextStyle(
                                        color: colorThemePink,
                                        fontSize: size.width * numD03),
                                  ),
                                ],
                              )
                            : Container(),
                        SizedBox(
                          height: !widget.socialLogin ? size.width * numD04 : 0,
                        ),
                        !widget.socialLogin
                            ? CommonTextField(
                                size: size,
                                maxLines: 1,
                                borderColor: colorTextFieldBorder,
                                controller: confirmPasswordController,
                                hintText: confirmPwdHintText,
                                textInputFormatters: null,
                                prefixIcon: const Icon(Icons.lock_outline),
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
                                  if (value!.isEmpty) {
                                    return requiredText;
                                  }
                                  /*else if (value.length < 8) {
                                    return passwordErrorText;
                                  } */
                                  else if (passwordController.text != value) {
                                    return confirmPasswordErrorText;
                                  }
                                  return null;
                                },
                                enableValidations: true,
                                filled: false,
                                filledColor: Colors.transparent,
                                autofocus: false,
                              )
                            : Container(),
                        // SizedBox(
                        //   height: !widget.socialLogin ? size.width * numD04 : 0,
                        // ),

                        // InkWell(
                        //   onTap: () {
                        //     FocusScope.of(context).requestFocus(FocusNode());
                        //     isSelectCheck = !isSelectCheck;
                        //     setState(() {});
                        //   },
                        //   child: Row(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       isSelectCheck
                        //           ? Container(
                        //               margin: EdgeInsets.only(
                        //                   top: size.width * numD008),
                        //               child: Image.asset(
                        //                 "${iconsPath}ic_checkbox_filled.png",
                        //                 height: size.width * numD06,
                        //               ),
                        //             )
                        //           : Container(
                        //               margin: EdgeInsets.only(
                        //                   top: size.width * numD008),
                        //               child: Image.asset(
                        //                   "${iconsPath}ic_checkbox_empty.png",
                        //                   height: size.width * numD06),
                        //             ),
                        //       SizedBox(
                        //         width: size.width * numD02,
                        //       ),
                        //       Expanded(
                        //         child: Text(
                        //           enableNotificationText,
                        //           style: TextStyle(
                        //               color: Colors.black,
                        //               fontFamily: "AirbnbCereal",
                        //               fontSize: size.width * numD035),
                        //         ),
                        //       ),
                        //       SizedBox(
                        //         width: size.width * numD02,
                        //       ),
                        //     ],
                        //   ),
                        // ),
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
                                sendOtpApi();
                              }
                            }
                            setState(() {});
                          }),
                        ),

                        /// Or
                        // Align(
                        //   alignment: Alignment.center,
                        //   child: Padding(
                        //     padding: EdgeInsets.symmetric(
                        //         vertical: size.width * numD04),
                        //     child: Text(
                        //       orText,
                        //       style: TextStyle(
                        //           color: Colors.black,
                        //           fontFamily: "AirbnbCereal",
                        //           fontSize: size.width * numD04),
                        //     ),
                        //   ),
                        // ),

                        // Platform.isIOS
                        //     ? Container(
                        //         width: size.width,
                        //         height: size.width * numD13,
                        //         margin: EdgeInsets.symmetric(
                        //             horizontal: size.width * numD04),
                        //         alignment: Alignment.centerLeft,
                        //         decoration: BoxDecoration(
                        //             color: Colors.black,
                        //             borderRadius: BorderRadius.circular(
                        //                 size.width * numD04),
                        //             border: Border.all(
                        //                 color: colorGoogleButtonBorder)),
                        //         child: InkWell(
                        //           splashColor: Colors.grey.shade300,
                        //           onTap: () async {
                        //             final credential = await SignInWithApple
                        //                 .getAppleIDCredential(
                        //               scopes: [
                        //                 AppleIDAuthorizationScopes.email,
                        //                 AppleIDAuthorizationScopes.fullName,
                        //               ],
                        //             );

                        //             debugPrint("AppleCredentials: $credential");
                        //           },
                        //           child: Row(
                        //             mainAxisAlignment: MainAxisAlignment.center,
                        //             children: [
                        //               Image.asset(
                        //                 "${iconsPath}appleLogo.png",
                        //                 height: size.width * numD045,
                        //                 width: size.width * numD045,
                        //                 color: Colors.white,
                        //               ),
                        //               SizedBox(width: size.width * numD01),
                        //               Align(
                        //                 alignment: Alignment.center,
                        //                 child: Text(
                        //                   "Sign in with Apple",
                        //                   style: TextStyle(
                        //                       color: Colors.white,
                        //                       fontFamily: "AirbnbCereal",
                        //                       fontSize: size.width * numD036,
                        //                       fontWeight: FontWeight.w500),
                        //                 ),
                        //               )
                        //             ],
                        //           ),
                        //         ),
                        //       )
                        //     : Container(
                        //         width: size.width,
                        //         height: size.width * numD13,
                        //         margin: EdgeInsets.symmetric(
                        //             horizontal: size.width * numD04),
                        //         decoration: BoxDecoration(
                        //             borderRadius: BorderRadius.circular(
                        //                 size.width * numD04),
                        //             border: Border.all(
                        //                 color: colorGoogleButtonBorder)),
                        //         child: InkWell(
                        //           splashColor: Colors.grey.shade300,
                        //           borderRadius: BorderRadius.circular(
                        //               size.width * numD04),
                        //           onTap: () async {
                        //             googleLogin();
                        //           },
                        //           child: Row(
                        //             mainAxisAlignment: MainAxisAlignment.center,
                        //             children: [
                        //               Image.asset(
                        //                 "${iconsPath}ic_google.png",
                        //                 height: size.width * numD045,
                        //                 width: size.width * numD045,
                        //               ),
                        //               SizedBox(width: size.width * numD01),
                        //               Align(
                        //                 alignment: Alignment.center,
                        //                 child: Text(
                        //                   continueGoogleText,
                        //                   style: TextStyle(
                        //                       color: Colors.black,
                        //                       fontFamily: "AirbnbCereal",
                        //                       fontSize: size.width * numD036,
                        //                       fontWeight: FontWeight.w500),
                        //                 ),
                        //               )
                        //             ],
                        //           ),
                        //         ),
                        //       ),

                        !widget.socialLogin
                            ? Align(
                                alignment: Alignment.center,
                                child: TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                            text: alreadyHaveAccountText,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontFamily: "AirbnbCereal",
                                                fontSize:
                                                    size.width * numD035)),
                                        WidgetSpan(
                                            alignment:
                                                PlaceholderAlignment.middle,
                                            child: SizedBox(
                                              width: size.width * 0.005,
                                            )),
                                        TextSpan(
                                            text: signInText,
                                            style: TextStyle(
                                                color: colorThemePink,
                                                fontFamily: "AirbnbCereal",
                                                fontSize: size.width * numD035,
                                                fontWeight: FontWeight.w700)),
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
    );
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
      socialExistsApi();
      debugPrint("userObj ::${_userObj.toString()}");
      debugPrint("social email ::${_userObj.email.toString()}");
      debugPrint("social displayName ::${_userObj.displayName.toString()}");
      debugPrint("social photoUrl ::${_userObj.photoUrl.toString()}");
    }).catchError((e) {
      debugPrint(e.toString());
    });
  }

  void startVibration() async {
    final Iterable<Duration> pauses = [
      const Duration(milliseconds: 50),
      const Duration(milliseconds: 50),
    ];
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
    return null;
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

  void setPhoneListener() {
    phoneController.addListener(() {
      debugPrint("Phone:${phoneController.text}");
      if (phoneController.text.trim().isNotEmpty &&
          phoneController.text.trim().length > 9) {
        debugPrint("notsuccess");
        checkPhoneApi();
      } else {
        phoneAlreadyExists = false;
      }

      setState(() {});
    });
  }

  void setPasswordListener() {
    passwordController.addListener(() {
      var m = passwordExpression.hasMatch(passwordController.text.trim());

      debugPrint("EmailExpression: $m");

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
      return requiredText;
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
                                      "${dummyImagePath}news.png",
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

  void selectedDate1(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime date13YearsAgo =
        DateTime(currentDate.year - 13, currentDate.month, currentDate.day);

    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: date13YearsAgo,
        firstDate: DateTime(1970),
        lastDate: date13YearsAgo);
    if (picked != null) {
      DateFormat formats = DateFormat("yyyy-MM-dd");
      DateFormat formats1 = DateFormat("dd/MM/yyyy");
      debugPrint("Selected Date  ${formats.format(picked)}");
      selectedDates = formats.format(picked);
      selectedDates1 = formats1.format(picked);
      showDateError = false;
      setState(() {});
    }
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
              colorScheme:
                  const ColorScheme.light().copyWith(primary: colorThemePink)),
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
            colorScheme:
                const ColorScheme.light().copyWith(primary: colorThemePink),
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
      NetworkClass("$checkEmailUrl${emailController.text.trim()}", this,
              checkEmailUrlRequest)
          .callRequestServiceHeader(false, "get", null);
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

  void getAvatarsApi() {
    try {
      NetworkClass(getAvatarsUrl, this, getAvatarsUrlRequest)
          .callRequestServiceHeader(false, "get", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  void sendOtpApi() {
    try {
      Map<String, String> params = {
        "phone": selectedCountryCodePicker + phoneController.text.trim(),
        "email": emailController.text.trim()
      };
      NetworkClass.fromNetworkClass(sendOtpUrl, this, sendOtpUrlRequest, params)
          .callRequestServiceHeader(true, "post", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  void socialExistsApi() {
    try {
      Map<String, String> params = {
        "social_id": socialId,
        "social_type": Platform.isIOS ? "apple" : "google"
      };

      NetworkClass.fromNetworkClass(
              socialExistUrl, this, socialExistUrlRequest, params)
          .callRequestServiceHeader(true, "post", null);
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
          var map = jsonDecode(response);
          Map<String, String> params = {};
          params[firstNameKey] = firstNameController.text.trim();
          params[lastNameKey] = lastNameController.text.trim();
          params[emailKey] = emailController.text.trim();
          params[countryCodeKey] = selectedCountryCodePicker;
          params[phoneKey] = phoneController.text.trim();
          params[addressKey] = addressController.text.trim();
          params[postCodeKey] = postalCodeController.text.trim();
          params[latitudeKey] = latitude;
          params[longitudeKey] = longitude;
          params[isTermAcceptedKey] = termConditionsChecked.toString();
          params[dobKey] = selectedDates.toString();

          //params[receiveTaskNotificationKey] = enableNotifications.toString();
          params[receiveTaskNotificationKey] = isSelectCheck.toString();
          params[roleKey] = "Hopper";
          params[avatarIdKey] = selectedAvatarId;
          params[userNameKey] = userNameController.text.trim().toLowerCase();
          params[countryKey] = countryNameController.text.trim();
          params[cityKey] = cityNameController.text.trim();
          params[apartmentKey] = apartmentAndHouseNameController.text.trim();

          if (!widget.socialLogin) {
            params[passwordKey] = passwordController.text.trim();
          } else {
            params["social_id"] = widget.socialId;
            params["social_type"] = Platform.isIOS ? "apple" : "google";
          }

          sharedPreferences!
              .setString(firstNameKey, firstNameController.text.trim());
          sharedPreferences!
              .setString(lastNameKey, lastNameController.text.trim());
          sharedPreferences!.setString(
              userNameKey, userNameController.text.trim().toLowerCase());
          sharedPreferences!.setString(emailKey, emailController.text.trim());
          sharedPreferences!.setString(phoneKey, phoneController.text.trim());
          sharedPreferences!
              .setString(countryKey, countryNameController.text.trim());
          sharedPreferences!.setString(cityKey, cityNameController.text.trim());
          sharedPreferences!.setString(dobKey, selectedDates1.trim());
          sharedPreferences!
              .setString(postCodeKey, postalCodeController.text.trim());

          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => VerifyAccountScreen(
                    countryCode: selectedCountryCodePicker,
                    emailAddressValue: emailController.text.trim(),
                    mobileNumberValue: phoneController.text.trim(),
                    params: params,
                    imagePath: userImagePath,
                    sociallogin: widget.socialLogin,
                  )));

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
                  .setString(hopperIdKey, map["user"][hopperIdKey]);
              sharedPreferences!
                  .setString(firstNameKey, map["user"][firstNameKey]);
              sharedPreferences!
                  .setString(lastNameKey, map["user"][lastNameKey]);
              sharedPreferences!
                  .setString(userNameKey, map["user"][userNameKey]);
              sharedPreferences!.setString(emailKey, map["user"][emailKey]);
              sharedPreferences!.setString(phoneKey, map["user"][phoneKey]);
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
              firstNameController.text = socialName.split(" ").first;
              lastNameController.text = socialName.split(" ").last;
              emailController.text = socialEmail;
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
      debugPrint("$e");
    }
  }
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
