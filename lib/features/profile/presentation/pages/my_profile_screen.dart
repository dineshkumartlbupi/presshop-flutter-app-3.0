import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:geocoding/geocoding.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:presshop/core/analytics/analytics_constants.dart';
import 'package:presshop/core/analytics/analytics_mixin.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/utils/extensions.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:presshop/core/widgets/common_text_field.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/widgets/common/avatar_bottom_sheet.dart';

import 'package:presshop/core/di/injection_container.dart';

import 'package:presshop/features/profile/constants/profile_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:presshop/main.dart';
import 'package:go_router/go_router.dart';

// ignore: must_be_immutable
class MyProfile extends StatefulWidget {
  MyProfile(
      {super.key, required this.editProfileScreen, required this.screenType});
  bool editProfileScreen;
  String screenType;

  @override
  State<StatefulWidget> createState() {
    return MyProfileState();
  }
}

class MyProfileState extends State<MyProfile> with AnalyticsPageMixin {
  Size size = Size.zero;

  var formKey = GlobalKey<FormState>();
  var scrollController = ScrollController();
  String? studentBeansResponseUrlGlobal = "";

  TextEditingController userNameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailAddressController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController postCodeController = TextEditingController();
  TextEditingController apartmentAndHouseNameController =
      TextEditingController();
  TextEditingController cityNameController = TextEditingController();
  TextEditingController countryNameController = TextEditingController();

  // Profile address controllers
  TextEditingController profileAddressController = TextEditingController();
  TextEditingController profileCityController = TextEditingController();
  TextEditingController profileCountryController = TextEditingController();
  TextEditingController profilePostCodeController = TextEditingController();

  List<AvatarData> avatarList = [];
  MyProfileData? myProfileData;
  // Completer<String?>? _studentBeansCompleter;

  String selectedCountryCode = "",
      userImagePath = "",
      latitude = "",
      longitude = "";
  bool userNameAutoFocus = false,
      userNameAlreadyExists = false,
      emailAlreadyExists = false,
      phoneAlreadyExists = false,
      showAddressError = false,
      showApartmentNumberError = false,
      showPostalCodeError = false,
      isLoading = false,
      isSilentLoading = false;
  FocusNode apartmentFocusNode = FocusNode();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    userNameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    emailAddressController.dispose();
    addressController.dispose();
    postCodeController.dispose();
    apartmentAndHouseNameController.dispose();
    cityNameController.dispose();
    countryNameController.dispose();
    profileAddressController.dispose();
    profileCityController.dispose();
    profileCountryController.dispose();
    profilePostCodeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    debugPrint("class:::: $runtimeType");
    super.initState();
    // Enforce editable state by default
    widget.editProfileScreen = true;
    debugPrint("editStatus::::::: ${widget.editProfileScreen}");
    _loadCachedData();
    setUserNameListener();
    setPhoneListener();
    setEmailListener();
    myProfileApi(showLoader: false);
    if (widget.editProfileScreen) {
      getAvatarsApi(showLoader: false);
    }
  }

  void _loadCachedData() {
    userNameController.text =
        sharedPreferences?.getString(SharedPreferencesKeys.userNameKey) ??
            "Hopper";
    firstNameController.text =
        sharedPreferences?.getString(SharedPreferencesKeys.firstNameKey) ??
            "Hopper";
    lastNameController.text =
        sharedPreferences?.getString(SharedPreferencesKeys.lastNameKey) ?? "";
    emailAddressController.text =
        sharedPreferences?.getString(SharedPreferencesKeys.emailKey) ?? "";
    phoneNumberController.text =
        sharedPreferences?.getString(SharedPreferencesKeys.phoneKey) ?? "";
    addressController.text =
        sharedPreferences?.getString(SharedPreferencesKeys.addressKey) ?? "";
    postCodeController.text =
        sharedPreferences?.getString(SharedPreferencesKeys.postCodeKey) ?? "";
    selectedCountryCode =
        sharedPreferences?.getString(SharedPreferencesKeys.countryCodeKey) ??
            "+44";
    cityNameController.text =
        sharedPreferences?.getString(SharedPreferencesKeys.cityKey) ?? "";
    countryNameController.text =
        sharedPreferences?.getString(SharedPreferencesKeys.countryKey) ?? "";
    apartmentAndHouseNameController.text =
        sharedPreferences?.getString(SharedPreferencesKeys.apartmentKey) ?? "";

    // Partially initialize myProfileData for the top card
    String cachedAvatar =
        sharedPreferences?.getString(SharedPreferencesKeys.avatarKey) ?? "";
    String cachedUsername =
        sharedPreferences?.getString(SharedPreferencesKeys.userNameKey) ?? "";
    String cachedIncome =
        sharedPreferences?.getString(SharedPreferencesKeys.totalIncomeKey) ??
            "0";
    String cachedAddress =
        sharedPreferences?.getString(SharedPreferencesKeys.addressKey) ?? "";

    myProfileData = MyProfileData();
    myProfileData!.userName =
        cachedUsername.isNotEmpty ? cachedUsername : "Hopper";
    myProfileData!.totalIncome = cachedIncome;
    myProfileData!.address = cachedAddress;

    if (cachedAvatar.isNotEmpty) {
      myProfileData!.avatarImage = cachedAvatar;
      myProfileData!.avatarImage = fixS3Url(myProfileData!.avatarImage);
    }
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

    final RegExp restrictPattern = RegExp(
      r"@(gmail\.com|yahoo\.com|hotmail\.com|outlook\.com)$",
      caseSensitive: true,
    );

    final RegExp restrictPatter2 = RegExp(r'@(gmail|yahoo|hotmail|outlook)\.');
    final RegExp restrictPatter3 =
        RegExp('gmail|yahoo|hotmail|outlook', caseSensitive: false);

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
    if (restrictPattern.hasMatch(value.trim()) ||
        restrictPatter2.hasMatch(value.trim()) ||
        restrictPatter3.hasMatch(value.trim())) {
      return "Domain names are not allowed for security reasons.";
    }
    if (userNameAlreadyExists) {
      return "This username is already taken. Please choose another one.";
    }

    return null;
  }

  int _getMaxPhoneLength() {
    return phoneNumberMaxLengthByCountry[selectedCountryCode] ?? 15;
  }

  String? checkSignupPhoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredText;
    }

    String digitsOnly = value.trim().replaceAll(RegExp(r'\D+'), '');

    // Default fallback
    int minLength = 7;
    int maxLength = 15;

    // Try to get country-specific length
    final countryData = phoneNumberLengthByCountryCode[selectedCountryCode];
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
      return AppStrings.phoneExistsErrorText;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    debugPrint("Building MyProfileScreen with size: $size");
    return Scaffold(
      appBar: CommonBrandedAppBar(
        title: widget.screenType,
        size: size,
      ),
      // appBar: CommonAppBar(
      //   elevation: 0,
      //   hideLeading: false,
      //   title: Text(
      //     widget.screenType,
      //     style: TextStyle(
      //         color: Colors.black,
      //         fontWeight: FontWeight.bold,
      //         fontSize: size.width * AppDimensions.appBarHeadingFontSize),
      //   ),
      //   centerTitle: false,
      //   titleSpacing: 0,
      //   size: size,
      //   showActions: true,
      //   leadingFxn: () {
      //     /*  if (widget.editProfileScreen) {
      //         widget.editProfileScreen = false;
      //       }*/
      //     context.pop();
      //   },
      //   actionWidget: [
      //     InkWell(
      //       onTap: () {
      //         context.goNamed(
      //           AppRoutes.dashboardName,
      //           extra: {'initialPosition': 2},
      //         );
      //       },
      //       child: Image.asset(
      //         "${commonImagePath}rabbitLogo.png",
      //         height: size.width * AppDimensions.numD07,
      //         width: size.width * AppDimensions.numD07,
      //       ),
      //     ),
      //     SizedBox(
      //       width: size.width * AppDimensions.numD04,
      //     )
      //   ],
      // ),

      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SafeArea(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Form(
                  key: formKey,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * AppDimensions.numD04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        topProfileWidget(),
                        SizedBox(
                          height: size.width * AppDimensions.numD06,
                        ),
                        _buildUserNameField(),
                        SizedBox(height: size.width * AppDimensions.numD06),
                        _buildFirstNameField(),
                        SizedBox(height: size.width * AppDimensions.numD06),
                        _buildLastNameField(),
                        SizedBox(height: size.width * AppDimensions.numD06),
                        _buildPhoneField(),
                        SizedBox(height: size.width * AppDimensions.numD06),
                        _buildEmailField(),
                        SizedBox(height: size.width * AppDimensions.numD06),
                        _buildAddressSection(),
                        SizedBox(height: size.width * AppDimensions.numD06),
                        _buildCityCountryFields(),
                        SizedBox(height: size.width * AppDimensions.numD09),
                        SizedBox(
                          width: double.infinity,
                          height: size.width * AppDimensions.numD14,
                          child: commonElevatedButton(
                              widget.editProfileScreen
                                  ? AppStrings.saveText.toTitleCase()
                                  : AppStrings.editProfileText.toTitleCase(),
                              size,
                              commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                              commonButtonStyle(
                                  size, AppColorTheme.colorThemePink), () {
                            if (!widget.editProfileScreen) {
                              widget.editProfileScreen =
                                  !widget.editProfileScreen;
                              scrollController.animateTo(
                                  scrollController.position.minScrollExtent,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut);
                              userNameAutoFocus = true;
                            } else {
                              scrollController.animateTo(
                                  scrollController.position.minScrollExtent,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut);
                              if (formKey.currentState!.validate()) {
                                editProfileApi();
                              }
                            }
                            setState(() {});
                          }),
                        ),
                        SizedBox(
                          height: size.width * AppDimensions.numD04,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.white.withOpacity(0.5),
              child: Center(
                child: showAnimatedLoader(size),
              ),
            ),
        ],
      ),
    );
    // );
  }

  Widget topProfileWidget() {
    return Container(
      height: size.width * AppDimensions.numD35,
      decoration: BoxDecoration(
          color: Colors.black,
          borderRadius:
              BorderRadius.circular(size.width * AppDimensions.numD04)),
      child: Row(
        children: [
          Stack(
            fit: StackFit.loose,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft:
                          Radius.circular(size.width * AppDimensions.numD04),
                      bottomLeft:
                          Radius.circular(size.width * AppDimensions.numD04)),
                  child: CachedNetworkImage(
                    imageUrl:
                        myProfileData != null ? myProfileData!.avatarImage : "",
                    placeholder: (context, url) => Center(
                      child: Padding(
                        padding:
                            EdgeInsets.all(size.width * AppDimensions.numD04),
                        child: Image.asset(
                          "${commonImagePath}rabbitLogo.png",
                          fit: BoxFit.contain,
                          width: size.width * AppDimensions.numD35,
                          height: size.width * AppDimensions.numD35,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Padding(
                      padding:
                          EdgeInsets.all(size.width * AppDimensions.numD04),
                      child: Image.asset(
                        "${commonImagePath}rabbitLogo.png",
                        fit: BoxFit.contain,
                        width: size.width * AppDimensions.numD35,
                        height: size.width * AppDimensions.numD35,
                      ),
                    ),
                    fit: BoxFit.cover,
                    width: size.width * AppDimensions.numD37,
                    height: size.width * AppDimensions.numD35,
                  )),
              if (isSilentLoading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(
                              size.width * AppDimensions.numD04),
                          bottomLeft: Radius.circular(
                              size.width * AppDimensions.numD04)),
                    ),
                    child: Center(
                      child: Lottie.asset(
                        "assets/lottieFiles/loader_new.json",
                        height: size.width * 0.15,
                        width: size.width * 0.15,
                      ),
                    ),
                  ),
                ),
              widget.editProfileScreen
                  ? Positioned(
                      bottom: size.width * AppDimensions.numD01,
                      right: size.width * AppDimensions.numD01,
                      child: InkWell(
                        onTap: () {
                          avatarBottomSheet(size);
                        },
                        child: Container(
                          padding: EdgeInsets.all(size.width * 0.005),
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: Container(
                              padding: EdgeInsets.all(size.width * 0.005),
                              decoration: const BoxDecoration(
                                  color: AppColorTheme.colorThemePink,
                                  shape: BoxShape.circle),
                              child: Icon(
                                Icons.edit_outlined,
                                color: Colors.white,
                                size: size.width * AppDimensions.numD04,
                              )),
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
          SizedBox(
            width: size.width * AppDimensions.numD04,
          ),
          Expanded(
              child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: size.width * AppDimensions.numD02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      myProfileData != null
                          ? myProfileData!.userName.toCapitalized()
                          : "",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD04,
                          color: AppColorTheme.colorThemePink,
                          fontWeight: FontWeight.w500)),
                  SizedBox(
                    height: size.width * AppDimensions.numD01,
                  ),
                  Text(
                      "${AppStrings.joinedText} - ${myProfileData != null ? myProfileData!.joinedDate : ""}",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD035,
                          color: Colors.white,
                          fontWeight: FontWeight.normal)),
                  SizedBox(
                    height: size.width * AppDimensions.numD005,
                  ),
                  Text(
                      "${AppStrings.earningsText} - $currencySymbol${myProfileData != null ? formatDouble(double.parse(myProfileData!.totalIncome)) : "0"}",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD035,
                          color: Colors.white,
                          fontWeight: FontWeight.normal)),
                  SizedBox(
                    height: size.width * AppDimensions.numD005,
                  ),
                  Text(_getCurrentAddress(),
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD035,
                          color: Colors.white,
                          fontWeight: FontWeight.normal))
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }

  String _getCurrentAddress() {
    if (myProfileData == null) return '';

    List<String> addressLines = [];
    if (myProfileData!.address.isNotEmpty) {
      addressLines.add("Current Address: ${myProfileData!.address}");
    }
    List<String> userAddressParts = [];
    if (myProfileData!.profileAddress.isNotEmpty) {
      userAddressParts.add(myProfileData!.profileAddress);
    }
    if (myProfileData!.profileCity.isNotEmpty) {
      userAddressParts.add(myProfileData!.profileCity);
    }
    if (myProfileData!.profileCountry.isNotEmpty) {
      userAddressParts.add(myProfileData!.profileCountry);
    }
    if (myProfileData!.profilePostCode.isNotEmpty) {
      userAddressParts.add(myProfileData!.profilePostCode);
    }

    if (userAddressParts.isNotEmpty) {
      addressLines.add("User Address: ${userAddressParts.join(', ')}");
    }

    return addressLines.join('\n');
  }

  void setProfileData() {
    if (myProfileData != null) {
      firstNameController.text = myProfileData!.firstName;
      lastNameController.text = myProfileData!.lastName;
      userNameController.text = myProfileData!.userName;
      selectedCountryCode = myProfileData!.countryCode;
      addressController.text = myProfileData!.address;
      phoneNumberController.text = myProfileData!.phoneNumber;
      emailAddressController.text = myProfileData!.email;
      postCodeController.text = myProfileData!.postCode;
      apartmentAndHouseNameController.text = myProfileData!.apartment;
      cityNameController.text = myProfileData!.cityName;
      countryNameController.text = myProfileData!.countryName;

      // Set profile address fields
      profileAddressController.text = myProfileData!.profileAddress;
      profileCityController.text = myProfileData!.profileCity;
      profileCountryController.text = myProfileData!.profileCountry;
      profilePostCodeController.text = myProfileData!.profilePostCode;
    }
  }

  String? firstNameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredText;
    }

    String username = userNameController.text.trim().toLowerCase();

    if (username.isEmpty || username.length < 4) {
      return null;
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

    List<String> usernameSubstrings = generateSubstrings(username);
    String firstNameLower = value.trim().toLowerCase();

    for (var substring in usernameSubstrings) {
      if (firstNameLower.contains(substring)) {
        return "First name cannot contain any sequence from your username.";
      }
    }

    return null;
  }

  String? lastNameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredText;
    }

    String username = userNameController.text.trim().toLowerCase();

    if (username.isEmpty || username.length < 4) {
      return null;
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

    List<String> usernameSubstrings = generateSubstrings(username);
    String lastNameLower = value.trim().toLowerCase();

    for (var substring in usernameSubstrings) {
      if (lastNameLower.contains(substring)) {
        return "Last name cannot contain any sequence from your username.";
      }
    }

    return null;
  }

  String? _onUserNameChanged(String? value) {
    if (widget.editProfileScreen) {
      if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        debugPrint("UserName:${userNameController.text}");
        if (userNameController.text.trim().isNotEmpty &&
            firstNameController.text.trim().isNotEmpty &&
            lastNameController.text.trim().isNotEmpty &&
            userNameController.text.trim().length >= 4 &&
            !userNameController.text
                .trim()
                .toLowerCase()
                .contains(firstNameController.text.trim().toLowerCase()) &&
            !userNameController.text
                .trim()
                .toLowerCase()
                .contains(lastNameController.text.trim().toLowerCase())) {
          debugPrint("notsuccess");
          checkUserNameApi();
        } else {
          userNameAlreadyExists = false;
        }
        setState(() {});
      });
    }
    return null;
  }

  void setUserNameListener() {
    userNameController.addListener(() {
      if (widget.editProfileScreen) {
        if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 500), () {
          debugPrint("UserName:${userNameController.text}");
          if (userNameController.text.trim().isNotEmpty &&
              firstNameController.text.trim().isNotEmpty &&
              lastNameController.text.trim().isNotEmpty &&
              userNameController.text.trim().length >= 4 &&
              !userNameController.text
                  .trim()
                  .toLowerCase()
                  .contains(firstNameController.text.trim().toLowerCase()) &&
              !userNameController.text
                  .trim()
                  .toLowerCase()
                  .contains(lastNameController.text.trim().toLowerCase())) {
            debugPrint("notsuccess");
            checkUserNameApi();
          } else {
            userNameAlreadyExists = false;
          }
          setState(() {});
        });
      }
    });
  }

  void setEmailListener() {
    emailAddressController.addListener(() {
      if (widget.editProfileScreen) {
        if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 500), () {
          debugPrint("Email:${emailAddressController.text}");
          if (emailAddressController.text.trim().isNotEmpty &&
              emailExpression.hasMatch(emailAddressController.text.trim()) &&
              emailAddressController.text.trim() != myProfileData?.email) {
            checkEmailApi();
          } else {
            emailAlreadyExists = false;
          }
          setState(() {});
        });
      }
    });
  }

  void setPhoneListener() {
    phoneNumberController.addListener(() {
      if (widget.editProfileScreen) {
        if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 500), () {
          debugPrint("Phone:${phoneNumberController.text}");
          if (phoneNumberController.text.trim().isNotEmpty &&
              phoneNumberController.text.trim().length > 7 &&
              phoneNumberController.text.trim() != myProfileData?.phoneNumber) {
            checkPhoneApi();
          } else {
            phoneAlreadyExists = false;
          }
          setState(() {});
        });
      }
    });
  }

  /// Avatar Images
  void avatarBottomSheet(Size size) {
    AvatarBottomSheet.show(
      context: context,
      size: size,
      avatarList: avatarList,
      onAvatarSelected: (avatar) {
        myProfileData!.avatarImage = avatar.avatar;
        myProfileData!.avatarId = avatar.id;
        setState(() {});
      },
    );
  }

  Widget _buildUserNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${AppStrings.userText.toTitleCase()} ${AppStrings.nameText}",
            style: commonTextStyle(
                size: size,
                fontSize: size.width * AppDimensions.numD032,
                color: Colors.black,
                fontWeight: FontWeight.normal)),
        SizedBox(height: size.width * AppDimensions.numD02),
        CommonTextField(
          size: size,
          maxLines: 1,
          textInputFormatters: null,
          borderColor: AppColorTheme.colorTextFieldBorder,
          controller: userNameController,
          hintText:
              "${AppStrings.enterText.toTitleCase()} ${AppStrings.userText} ${AppStrings.nameText}",
          prefixIcon: Container(
            margin: EdgeInsets.only(left: size.width * AppDimensions.numD015),
            child: Image.asset("${iconsPath}ic_user.png"),
          ),
          prefixIconHeight: size.width * AppDimensions.numD04,
          hidePassword: false,
          keyboardType: TextInputType.text,
          validator: null,
          enableValidations: false,
          filled: true,
          filledColor: AppColorTheme.colorLightGrey,
          autofocus: userNameAutoFocus,
          readOnly: true,
          onChanged: _onUserNameChanged,
          suffixIconIconHeight: size.width * AppDimensions.numD04,
          suffixIcon: null,
        ),
      ],
    );
  }

  Widget _buildFirstNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${AppStrings.firstText.toTitleCase()} ${AppStrings.nameText}",
            style: commonTextStyle(
                size: size,
                fontSize: size.width * AppDimensions.numD032,
                color: Colors.black,
                fontWeight: FontWeight.normal)),
        SizedBox(height: size.width * AppDimensions.numD02),
        CommonTextField(
          size: size,
          maxLines: 1,
          textInputFormatters: null,
          borderColor: AppColorTheme.colorTextFieldBorder,
          controller: firstNameController,
          hintText:
              "${AppStrings.enterText.toTitleCase()} ${AppStrings.firstText} ${AppStrings.nameText}",
          prefixIcon: Container(
            margin: EdgeInsets.only(left: size.width * AppDimensions.numD015),
            child: Image.asset("${iconsPath}ic_user.png"),
          ),
          prefixIconHeight: size.width * AppDimensions.numD04,
          suffixIconIconHeight: 0,
          suffixIcon: null,
          hidePassword: false,
          keyboardType: TextInputType.text,
          validator: firstNameValidator,
          enableValidations: true,
          filled: true,
          filledColor: widget.editProfileScreen
              ? Colors.white
              : AppColorTheme.colorLightGrey,
          readOnly: widget.editProfileScreen ? false : true,
        ),
      ],
    );
  }

  Widget _buildLastNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${AppStrings.lastText.toTitleCase()} ${AppStrings.nameText}",
            style: commonTextStyle(
                size: size,
                fontSize: size.width * AppDimensions.numD032,
                color: Colors.black,
                fontWeight: FontWeight.normal)),
        SizedBox(height: size.width * AppDimensions.numD02),
        CommonTextField(
          size: size,
          maxLines: 1,
          textInputFormatters: null,
          borderColor: AppColorTheme.colorTextFieldBorder,
          controller: lastNameController,
          hintText:
              "${AppStrings.enterText.toTitleCase()} ${AppStrings.lastText} ${AppStrings.nameText}",
          prefixIcon: Container(
            margin: EdgeInsets.only(left: size.width * AppDimensions.numD015),
            child: Image.asset("${iconsPath}ic_user.png"),
          ),
          prefixIconHeight: size.width * AppDimensions.numD04,
          suffixIconIconHeight: 0,
          suffixIcon: null,
          hidePassword: false,
          keyboardType: TextInputType.text,
          validator: lastNameValidator,
          enableValidations: true,
          filled: true,
          filledColor: widget.editProfileScreen
              ? Colors.white
              : AppColorTheme.colorLightGrey,
          readOnly: widget.editProfileScreen ? false : true,
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${AppStrings.phoneText.toTitleCase()} ${AppStrings.numberText}",
            style: commonTextStyle(
                size: size,
                fontSize: size.width * AppDimensions.numD032,
                color: Colors.black,
                fontWeight: FontWeight.normal)),
        SizedBox(height: size.width * AppDimensions.numD02),
        CommonTextField(
          size: size,
          maxLines: 1,
          borderColor: AppColorTheme.colorTextFieldBorder,
          controller: phoneNumberController,
          hintText: AppStrings.phoneHintText,
          textInputFormatters: [
            FilteringTextInputFormatter.allow(RegExp("[0-9]")),
            LengthLimitingTextInputFormatter(_getMaxPhoneLength()),
          ],
          prefixIcon: InkWell(
            onTap: widget.editProfileScreen ? openCountryCodePicker : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.call_outlined),
                SizedBox(width: size.width * AppDimensions.numD01),
                Text(
                  selectedCountryCode,
                  style: commonTextStyle(
                      size: size,
                      fontSize: size.width * AppDimensions.numD035,
                      color: Colors.black,
                      fontWeight: FontWeight.normal),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: size.width * AppDimensions.numD07,
                )
              ],
            ),
          ),
          prefixIconHeight: size.width * AppDimensions.numD06,
          suffixIconIconHeight: size.width * AppDimensions.numD085,
          suffixIcon: phoneNumberController.text.trim().length >= 7
              ? phoneAlreadyExists
                  ? const Icon(Icons.highlight_remove, color: Colors.red)
                  : const Icon(Icons.check_circle, color: Colors.green)
              : null,
          hidePassword: false,
          keyboardType: const TextInputType.numberWithOptions(
              decimal: false, signed: true),
          validator: checkSignupPhoneValidator,
          enableValidations: true,
          filled: true,
          filledColor: widget.editProfileScreen
              ? Colors.white
              : AppColorTheme.colorLightGrey,
          autofocus: false,
          readOnly: widget.editProfileScreen ? false : true,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.emailAddressText,
            style: commonTextStyle(
                size: size,
                fontSize: size.width * AppDimensions.numD032,
                color: Colors.black,
                fontWeight: FontWeight.normal)),
        SizedBox(height: size.width * AppDimensions.numD02),
        CommonTextField(
          size: size,
          maxLines: 1,
          textInputFormatters: null,
          borderColor: AppColorTheme.colorTextFieldBorder,
          controller: emailAddressController,
          hintText:
              "${AppStrings.enterText.toTitleCase()} ${AppStrings.emailAddressText}",
          prefixIcon: Container(
            margin: EdgeInsets.only(left: size.width * AppDimensions.numD015),
            child: Image.asset("${iconsPath}ic_email.png"),
          ),
          prefixIconHeight: size.width * AppDimensions.numD038,
          suffixIconIconHeight: 0,
          suffixIcon: null,
          hidePassword: false,
          keyboardType: TextInputType.emailAddress,
          validator: null,
          enableValidations: false,
          filled: true,
          filledColor: AppColorTheme.colorLightGrey,
          autofocus: false,
          readOnly: true,
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: size.width * AppDimensions.numD06),
        _buildApartmentField(),
        SizedBox(height: size.width * AppDimensions.numD06),
        _buildPostCodeField(),
        SizedBox(height: size.width * AppDimensions.numD06),
        _buildAddressField(),
        SizedBox(height: size.width * AppDimensions.numD06),
        _buildCurrentAddressField(),
      ],
    );
  }

  Widget _buildCurrentAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Current location",
            style: commonTextStyle(
                size: size,
                fontSize: size.width * AppDimensions.numD032,
                color: Colors.black,
                fontWeight: FontWeight.normal)),
        SizedBox(height: size.width * AppDimensions.numD02),
        CommonTextField(
          size: size,
          maxLines: 1,
          textInputFormatters: null,
          borderColor: AppColorTheme.colorTextFieldBorder,
          controller: addressController,
          hintText: "Current Address",
          prefixIcon: Container(
            margin: EdgeInsets.only(left: size.width * AppDimensions.numD015),
            child: Image.asset("${iconsPath}ic_location.png"),
          ),
          prefixIconHeight: size.width * AppDimensions.numD04,
          suffixIconIconHeight: 0,
          suffixIcon: null,
          hidePassword: false,
          keyboardType: TextInputType.text,
          validator: null,
          enableValidations: false,
          filled: true,
          filledColor: AppColorTheme.colorLightGrey,
          readOnly: true,
        ),
      ],
    );
  }

  Widget _buildApartmentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.apartmentNoHintText,
            style: commonTextStyle(
                size: size,
                fontSize: size.width * AppDimensions.numD032,
                color: Colors.black,
                fontWeight: FontWeight.normal)),
        SizedBox(height: size.width * AppDimensions.numD02),
        CommonTextField(
          size: size,
          maxLines: 1,
          textInputFormatters: null,
          borderColor: AppColorTheme.colorTextFieldBorder,
          controller: apartmentAndHouseNameController,
          hintText:
              "${AppStrings.enterText.toTitleCase()} ${AppStrings.apartmentNoHintText}",
          prefixIcon: Container(
            margin: EdgeInsets.only(left: size.width * AppDimensions.numD015),
            child: Image.asset("${iconsPath}ic_location.png"),
          ),
          prefixIconHeight: size.width * AppDimensions.numD04,
          suffixIconIconHeight: 0,
          suffixIcon: null,
          hidePassword: false,
          keyboardType: TextInputType.text,
          validator: checkRequiredValidator,
          enableValidations: true,
          filled: true,
          filledColor: widget.editProfileScreen
              ? Colors.white
              : AppColorTheme.colorLightGrey,
          readOnly: widget.editProfileScreen ? false : true,
        ),
      ],
    );
  }

  Widget _buildPostCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.postalCodeText,
            style: commonTextStyle(
                size: size,
                fontSize: size.width * AppDimensions.numD032,
                color: Colors.black,
                fontWeight: FontWeight.normal)),
        SizedBox(height: size.width * AppDimensions.numD02),
        widget.editProfileScreen
            ? SizedBox(
                height: size.width * AppDimensions.numD12,
                child: GooglePlaceAutoCompleteTextField(
                  textEditingController: profilePostCodeController,
                  googleAPIKey: Platform.isIOS
                      ? ApiConstantsNew.config.appleMapApiKey
                      : ApiConstantsNew.config.googleMapApiKey,
                  isCrossBtnShown: false,
                  boxDecoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(size.width * 0.03),
                      border: Border.all(
                          color: AppColorTheme.colorTextFieldBorder, width: 1)),
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: size.width * AppDimensions.numD032,
                      fontFamily: 'AirbnbCereal_W_Md'),
                  inputDecoration: InputDecoration(
                    border: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.symmetric(
                        vertical: size.width * AppDimensions.numD038),
                    hintText:
                        "${AppStrings.enterText.toTitleCase()} ${AppStrings.postalCodeText.toLowerCase()}",
                    hintStyle: TextStyle(
                        color: AppColorTheme.colorHint,
                        fontSize: size.width * AppDimensions.numD035,
                        fontFamily: 'AirbnbCereal_W_Md'),
                    prefixIcon: Container(
                      margin: EdgeInsets.only(
                          right: size.width * AppDimensions.numD02, left: 12),
                      child: Image.asset("${iconsPath}ic_location.png"),
                    ),
                    suffixIcon: InkWell(
                      onTap: () => profilePostCodeController.clear(),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(Icons.close,
                            color: Colors.black,
                            size: size.width * AppDimensions.numD058),
                      ),
                    ),
                    prefixIconConstraints: BoxConstraints(
                        maxHeight: size.width * AppDimensions.numD045),
                    suffixIconConstraints: BoxConstraints(
                        maxHeight: size.width * AppDimensions.numD07),
                    prefixIconColor: AppColorTheme.colorTextFieldIcon,
                  ),
                  debounceTime: 200,
                  countries: const ["uk", "in"],
                  isLatLngRequired: true,
                  getPlaceDetailWithLatLng: (prediction) {
                    latitude = prediction.lat.toString();
                    longitude = prediction.lng.toString();
                    getCurrentLocationFxn(
                            prediction.lat ?? "", prediction.lng ?? "")
                        .then((value) {
                      if (value.isNotEmpty) {
                        profileCityController.text = value.first.locality ?? '';
                        profileCountryController.text =
                            value.first.country ?? '';
                      }
                    });
                    showAddressError = false;
                    setState(() {});
                  },
                  itemClick: (prediction) {
                    profileAddressController.text =
                        prediction.description ?? "";
                    latitude = prediction.lat ?? "";
                    longitude = prediction.lng ?? "";
                    String postalCode =
                        prediction.structuredFormatting?.mainText ?? '';
                    profilePostCodeController.text = postalCode;
                    profileAddressController.selection =
                        TextSelection.fromPosition(TextPosition(
                            offset: prediction.description != null
                                ? prediction.description!.length
                                : 0));
                  },
                ),
              )
            : CommonTextField(
                size: size,
                maxLines: 1,
                textInputFormatters: null,
                borderColor: AppColorTheme.colorTextFieldBorder,
                controller: profilePostCodeController,
                hintText:
                    "${AppStrings.enterText.toTitleCase()} ${AppStrings.postalCodeText}",
                prefixIcon: Image.asset("${iconsPath}ic_location.png"),
                prefixIconHeight: size.width * AppDimensions.numD045,
                suffixIconIconHeight: 0,
                suffixIcon: null,
                hidePassword: false,
                keyboardType: TextInputType.text,
                enableValidations: false,
                validator: null,
                filled: true,
                filledColor: AppColorTheme.colorLightGrey,
                readOnly: true,
              ),
      ],
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.addressText,
            style: commonTextStyle(
                size: size,
                fontSize: size.width * AppDimensions.numD032,
                color: Colors.black,
                fontWeight: FontWeight.normal)),
        SizedBox(height: size.width * AppDimensions.numD02),
        widget.editProfileScreen
            ? SizedBox(
                height: size.width * AppDimensions.numD12,
                child: GooglePlaceAutoCompleteTextField(
                  textEditingController: profileAddressController,
                  googleAPIKey: Platform.isIOS
                      ? ApiConstantsNew.config.appleMapApiKey
                      : ApiConstantsNew.config.googleMapApiKey,
                  isCrossBtnShown: false,
                  boxDecoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(size.width * 0.03),
                      border: Border.all(
                          color: AppColorTheme.colorTextFieldBorder, width: 1)),
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: size.width * AppDimensions.numD032,
                      fontFamily: 'AirbnbCereal_W_Md'),
                  inputDecoration: InputDecoration(
                    border: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.symmetric(
                        vertical: size.width * AppDimensions.numD038),
                    hintText:
                        "${AppStrings.enterText.toTitleCase()} ${AppStrings.addressText.toLowerCase()}",
                    hintStyle: TextStyle(
                        color: AppColorTheme.colorHint,
                        fontSize: size.width * AppDimensions.numD035,
                        fontFamily: 'AirbnbCereal_W_Md'),
                    prefixIcon: Container(
                      margin: EdgeInsets.only(
                          right: size.width * AppDimensions.numD02, left: 12),
                      child: Image.asset("${iconsPath}ic_location.png"),
                    ),
                    suffixIcon: InkWell(
                      onTap: () => addressController.clear(),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(Icons.close,
                            color: Colors.black,
                            size: size.width * AppDimensions.numD058),
                      ),
                    ),
                    prefixIconConstraints: BoxConstraints(
                        maxHeight: size.width * AppDimensions.numD045),
                    suffixIconConstraints: BoxConstraints(
                        maxHeight: size.width * AppDimensions.numD07),
                    prefixIconColor: AppColorTheme.colorTextFieldIcon,
                  ),
                  debounceTime: 200,
                  countries: const ["uk", "in"],
                  isLatLngRequired: true,
                  getPlaceDetailWithLatLng: (prediction) {
                    latitude = prediction.lat.toString();
                    longitude = prediction.lng.toString();
                    getCurrentLocationFxn(
                            prediction.lat ?? "", prediction.lng ?? "")
                        .then((value) {
                      if (value.isNotEmpty) {
                        profileCityController.text = value.first.locality ?? '';
                        profileCountryController.text =
                            value.first.country ?? '';
                      }
                    });
                    showAddressError = false;
                    setState(() {});
                  },
                  itemClick: (prediction) {
                    profileAddressController.text =
                        prediction.description ?? "";
                    latitude = prediction.lat ?? "";
                    longitude = prediction.lng ?? "";
                    profileAddressController.selection =
                        TextSelection.fromPosition(TextPosition(
                            offset: prediction.description != null
                                ? prediction.description!.length
                                : 0));
                  },
                ),
              )
            : CommonTextField(
                size: size,
                maxLines: 1,
                textInputFormatters: null,
                borderColor: AppColorTheme.colorTextFieldBorder,
                controller: profileAddressController,
                hintText:
                    "${AppStrings.enterText.toTitleCase()} ${AppStrings.addressText}",
                prefixIcon: Image.asset("${iconsPath}ic_location.png"),
                prefixIconHeight: size.width * AppDimensions.numD045,
                suffixIconIconHeight: 0,
                suffixIcon: null,
                hidePassword: false,
                keyboardType: TextInputType.text,
                enableValidations: false,
                validator: null,
                filled: true,
                filledColor: AppColorTheme.colorLightGrey,
                readOnly: true,
              ),
      ],
    );
  }

  Widget _buildCityCountryFields() {
    return Column(
      children: [
        _buildCityField(),
        SizedBox(height: size.width * AppDimensions.numD06),
        _buildCountryField(),
      ],
    );
  }

  Widget _buildCityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.cityText.toTitleCase(),
            style: commonTextStyle(
                size: size,
                fontSize: size.width * AppDimensions.numD032,
                color: Colors.black,
                fontWeight: FontWeight.normal)),
        SizedBox(height: size.width * AppDimensions.numD02),
        CommonTextField(
          size: size,
          maxLines: 1,
          textInputFormatters: null,
          borderColor: AppColorTheme.colorTextFieldBorder,
          controller: profileCityController,
          hintText:
              "${AppStrings.enterText.toTitleCase()} ${AppStrings.cityText}",
          prefixIcon: Container(
            margin: EdgeInsets.only(left: size.width * AppDimensions.numD015),
            child: Image.asset("${iconsPath}ic_location.png"),
          ),
          prefixIconHeight: size.width * AppDimensions.numD04,
          suffixIconIconHeight: 0,
          suffixIcon: null,
          hidePassword: false,
          keyboardType: TextInputType.text,
          validator: checkRequiredValidator,
          enableValidations: true,
          filled: true,
          filledColor: widget.editProfileScreen
              ? Colors.white
              : AppColorTheme.colorLightGrey,
          readOnly: widget.editProfileScreen ? false : true,
        ),
      ],
    );
  }

  Widget _buildCountryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.countryText.toTitleCase(),
            style: commonTextStyle(
                size: size,
                fontSize: size.width * AppDimensions.numD032,
                color: Colors.black,
                fontWeight: FontWeight.normal)),
        SizedBox(height: size.width * AppDimensions.numD02),
        CommonTextField(
          size: size,
          maxLines: 1,
          textInputFormatters: null,
          borderColor: AppColorTheme.colorTextFieldBorder,
          controller: profileCountryController,
          hintText:
              "${AppStrings.enterText.toTitleCase()} ${AppStrings.countryText}",
          prefixIcon: Container(
            margin: EdgeInsets.only(left: size.width * AppDimensions.numD015),
            child: Image.asset("${iconsPath}ic_location.png"),
          ),
          prefixIconHeight: size.width * AppDimensions.numD04,
          suffixIconIconHeight: 0,
          suffixIcon: null,
          hidePassword: false,
          keyboardType: TextInputType.text,
          validator: checkRequiredValidator,
          enableValidations: true,
          filled: true,
          filledColor: widget.editProfileScreen
              ? Colors.white
              : AppColorTheme.colorLightGrey,
          readOnly: widget.editProfileScreen ? false : true,
        ),
      ],
    );
  }

  Future<List<Placemark>> getCurrentLocationFxn(
      String latitude, longitude) async {
    try {
      double lat = double.parse(latitude);
      double long = double.parse(longitude);
      List<Placemark> placeMarkList = await placemarkFromCoordinates(lat, long);
      debugPrint("PlaceHolder: ${placeMarkList.first}");

      latitude = lat.toString();
      longitude = long.toString();
      debugPrint("lat:::::$lat");
      debugPrint("long:::::$long");
      return placeMarkList;
    } on Exception catch (e) {
      debugPrint("PEx: $e");
      showSnackBar("Exception", e.toString(), Colors.red);
    }
    return [];
  }

  void openCountryCodePicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      // optional. Shows phone code before the country name.
      onSelect: (country) {
        debugPrint('Select country: ${country.displayName}');
        debugPrint('Select country: ${country.countryCode}');
        debugPrint('Select country: ${country.hashCode}');
        debugPrint('Select country: ${country.displayNameNoCountryCode}');
        debugPrint('Select country: ${country.phoneCode}');

        selectedCountryCode = country.phoneCode;
        setState(() {});
      },
    );
  }

  String? checkSignupEmailValidator(String? value) {
    //<-- add String? as a return type
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
  Future<void> checkUserNameApi() async {
    try {
      final response = await sl<ApiClient>().get(
        "${ApiConstantsNew.auth.checkUserName}${userNameController.text.trim().toLowerCase()}",
        showLoader: false,
      );
      if (response.statusCode == 200) {
        var map = response.data;
        if (map is String) map = jsonDecode(map);
        debugPrint("CheckUserNameResponse:$map");
        if (map['data'] != null &&
            map['data'] is Map &&
            map['data']['exists'] != null) {
          userNameAlreadyExists = map['data']['exists'];
        } else {
          userNameAlreadyExists = map["userNameExist"] ?? false;
        }
        setState(() {});
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> checkEmailApi() async {
    try {
      final response = await sl<ApiClient>().get(
        "${ApiConstantsNew.auth.checkEmail}${emailAddressController.text.trim()}",
        showLoader: false,
      );
      if (response.statusCode == 200) {
        var map = response.data;
        if (map is String) map = jsonDecode(map);
        debugPrint("CheckEmailResponse:$map");
        if (map['data'] != null &&
            map['data'] is Map &&
            map['data']['exists'] != null) {
          emailAlreadyExists = map['data']['exists'];
        } else {
          emailAlreadyExists = map["emailExist"] ?? false;
        }
        setState(() {});
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> checkPhoneApi() async {
    try {
      final response = await sl<ApiClient>().get(
        "${ApiConstantsNew.auth.checkPhone}${phoneNumberController.text.trim()}",
        showLoader: false,
      );
      if (response.statusCode == 200) {
        var map = response.data;
        if (map is String) map = jsonDecode(map);
        debugPrint("CheckPhoneResponse:$map");
        if (map['data'] != null &&
            map['data'] is Map &&
            map['data']['exists'] != null) {
          phoneAlreadyExists = map['data']['exists'];
        } else {
          phoneAlreadyExists = map["phoneExist"] ?? false;
        }
        setState(() {});
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> getAvatarsApi({bool showLoader = true}) async {
    if (showLoader) {
      setState(() {
        isLoading = true;
      });
    } else {
      setState(() {
        isSilentLoading = true;
      });
    }
    try {
      final response = await sl<ApiClient>()
          .get(ApiConstantsNew.profile.getAvatars, showLoader: false);
      if (response.statusCode == 200) {
        var map = response.data;
        if (map is String) map = jsonDecode(map);
        var list = map["data"] as List;
        avatarList = list.map((e) => AvatarData.fromJson(e)).toList();
        debugPrint("AvatarList: ${avatarList.length}");
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error fetching avatars: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          isSilentLoading = false;
        });
      }
    }
  }

  Future<void> myProfileApi({bool showLoader = true}) async {
    String userId =
        sharedPreferences!.getString(SharedPreferencesKeys.hopperIdKey) ?? "";
    print("🔴 DEBUG: Fetching Profile for userId: '$userId'");
    if (showLoader) {
      setState(() {
        isLoading = true;
      });
    } else {
      setState(() {
        isSilentLoading = true;
      });
    }
    try {
      final response = await sl<ApiClient>().get(
        ApiConstantsNew.profile.myProfile,
        queryParameters: {"userId": userId},
        showLoader: false,
      );
      // print("myProfileUrl: $myProfileUrl");

      if (response.statusCode == 200) {
        var map = response.data;
        if (map is String) map = jsonDecode(map);
        debugPrint("MyProfileSuccess:$map");

        if (map["code"] == 200 || map["success"] == true) {
          var userData = map["userData"] ?? map["data"];
          if (userData is Map &&
              userData.containsKey('data') &&
              userData['data'] is Map) {
            userData = userData['data'];
          }
          myProfileData = MyProfileData.fromJson(userData);

          void updateKey(String key, dynamic value) {
            if (value != null && value.toString().isNotEmpty) {
              sharedPreferences?.setString(key, value.toString());
            }
          }

          updateKey(
              SharedPreferencesKeys.firstNameKey,
              userData[SharedPreferencesKeys.firstNameKey] ??
                  userData['firstName']);
          updateKey(
              SharedPreferencesKeys.lastNameKey,
              userData[SharedPreferencesKeys.lastNameKey] ??
                  userData['lastName']);
          updateKey(
              SharedPreferencesKeys.userNameKey,
              userData[SharedPreferencesKeys.userNameKey] ??
                  userData['userName'] ??
                  userData['user_name']);
          updateKey(SharedPreferencesKeys.emailKey,
              userData[SharedPreferencesKeys.emailKey]);
          updateKey(
              SharedPreferencesKeys.countryCodeKey,
              userData[SharedPreferencesKeys.countryCodeKey] ??
                  userData['countryCode']);
          updateKey(
              SharedPreferencesKeys.phoneKey,
              userData[SharedPreferencesKeys.phoneKey] ??
                  userData['mobile_number']);
          updateKey(SharedPreferencesKeys.addressKey,
              userData[SharedPreferencesKeys.addressKey]);
          updateKey(SharedPreferencesKeys.cityKey,
              userData[SharedPreferencesKeys.cityKey] ?? userData['city']);
          updateKey(
              SharedPreferencesKeys.countryKey,
              userData[SharedPreferencesKeys.countryKey] ??
                  userData['country']);
          updateKey(
              SharedPreferencesKeys.apartmentKey,
              userData[SharedPreferencesKeys.apartmentKey] ??
                  userData['appartment']);
          updateKey(
              SharedPreferencesKeys.postCodeKey,
              userData[SharedPreferencesKeys.postCodeKey] ??
                  userData['postCode']);

          if (userData[SharedPreferencesKeys.latitudeKey] != null) {
            updateKey(SharedPreferencesKeys.latitudeKey,
                userData[SharedPreferencesKeys.latitudeKey]);
          }
          if (userData[SharedPreferencesKeys.longitudeKey] != null) {
            updateKey(SharedPreferencesKeys.longitudeKey,
                userData[SharedPreferencesKeys.longitudeKey]);
          }
          if (userData[SharedPreferencesKeys.avatarIdKey] != null) {
            updateKey(SharedPreferencesKeys.avatarIdKey,
                userData[SharedPreferencesKeys.avatarIdKey]);
          }
          if (userData["totalEarnings"] != null) {
            updateKey(SharedPreferencesKeys.totalIncomeKey,
                userData["totalEarnings"]);
          }

          // Save Profile Image (for Digital ID)
          String? profileImg = userData["profile_image"]?.toString() ??
              userData["profileImage"]?.toString();
          if (profileImg != null && profileImg.isNotEmpty) {
            sharedPreferences!.setString(
                SharedPreferencesKeys.profileImageKey, fixS3Url(profileImg));
          }

          // Save Avatar (for Profile Card)
          String? av;
          if (userData['avatarData'] is Map) {
            av = userData['avatarData']['avatar']?.toString();
          } else {
            av = userData['avatar']?.toString();
          }

          if (av != null && av.isNotEmpty) {
            sharedPreferences!
                .setString(SharedPreferencesKeys.avatarKey, fixS3Url(av));
          }

          final src1 = userData["source"];
          print("source ===> $src1");

          final sourceDataIsOpened = src1?["is_opened"] ?? false;
          final sourceDataType = src1?["type"] ?? "";
          final sourceDataHeading = src1?["heading"] ?? "";
          final sourceDataDescription = src1?["description"] ?? "";
          final isClick = src1?["is_clicked"] ?? false;

          if ((sourceDataType ?? '').toLowerCase() == 'studentbeans' &&
              (sourceDataIsOpened == false) &&
              isClick == false) {
            final size = MediaQuery.of(navigatorKey.currentState!.context).size;
            _showForceUpdateDialog(
                size, sourceDataHeading, sourceDataDescription);
          }

          setProfileData();
        } else {
          debugPrint("MyProfileError: ${map["message"]}");
        }
      }
    } catch (e) {
      debugPrint("$e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          isSilentLoading = false;
        });
      }
    }
  }

  Future<void> editProfileApi() async {
    setState(() {
      isLoading = true;
    });
    try {
      Map<String, String> params = {
        SharedPreferencesKeys.firstNameKey: firstNameController.text.trim(),
        SharedPreferencesKeys.lastNameKey: lastNameController.text.trim(),
        SharedPreferencesKeys.userNameKey:
            userNameController.text.trim().toLowerCase(),
        SharedPreferencesKeys.emailKey: emailAddressController.text.trim(),
        SharedPreferencesKeys.countryCodeKey: selectedCountryCode.trim(),
        SharedPreferencesKeys.phoneKey: phoneNumberController.text.trim(),
        SharedPreferencesKeys.addressKey: addressController.text.trim(),
        SharedPreferencesKeys.latitudeKey:
            latitude.isNotEmpty ? latitude : myProfileData!.latitude,
        SharedPreferencesKeys.longitudeKey:
            longitude.isNotEmpty ? longitude : myProfileData!.longitude,
        SharedPreferencesKeys.avatarIdKey: myProfileData!.avatarId,
        SharedPreferencesKeys.postCodeKey: postCodeController.text,
        SharedPreferencesKeys.cityKey: cityNameController.text.trim(),
        SharedPreferencesKeys.countryKey: countryNameController.text.trim(),
        SharedPreferencesKeys.apartmentKey:
            apartmentAndHouseNameController.text.trim(),

        // Add new profile address fields
        "profile_address": profileAddressController.text.trim(),
        "profile_city": profileCityController.text.trim(),
        "profile_country": profileCountryController.text.trim(),
        "profile_post_code": profilePostCodeController.text.trim(),

        SharedPreferencesKeys.roleKey: "hopper",
      };

      final response = await sl<ApiClient>().post(
        ApiConstantsNew.profile.editProfile,
        data: params,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var map = response.data;
        if (map is String) map = jsonDecode(map);

        if (map["code"] == 200 || map["success"] == true) {
          String message = map["message"] ?? "Request successful";
          showSnackBar("Success", message, Colors.green);

          widget.editProfileScreen = false;
          debugPrint("heloooo::::${myProfileData!.avatarId}");

          myProfileApi();
          sharedPreferences!.setString(
              SharedPreferencesKeys.avatarKey, myProfileData!.avatarImage);
        }
        setState(() {});
      }
    } catch (e) {
      debugPrint("$e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<String?> setIsClickForBeansActivation() async {
    try {
      final response = await sl<ApiClient>().post(
        ApiConstantsNew.profile.studentBeansActivation,
      );

      if (response.statusCode == 200) {
        var map = response.data;
        if (map is String) map = jsonDecode(map);
        var studentBeansResponseUrl = map["url"];
        return studentBeansResponseUrl;
      }
    } catch (e) {
      debugPrint("Error in StudentBeans Activation: $e");
    }
    return null;
  }

  @override
  // TODO: implement pageName
  String get pageName => PageNames.profile;

  void _showForceUpdateDialog(
      Size size, sourceDataHeading, sourceDataDescription) {
    showDialog(
        barrierDismissible: false,
        context: navigatorKey.currentState!.context,
        builder: (context) {
          return AlertDialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              contentPadding: EdgeInsets.zero,
              insetPadding: EdgeInsets.symmetric(
                  horizontal: size.width * AppDimensions.numD04),
              content: StatefulBuilder(
                builder: (context, setState) {
                  return Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            size.width * AppDimensions.numD045)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: size.width * AppDimensions.numD04),
                          child: Row(
                            children: [
                              Text(
                                sourceDataHeading ??
                                    "Brains, beans, and breaking news!",
                                // "Brains, beans, and breaking news!",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: size.width * AppDimensions.numD04,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              IconButton(
                                  onPressed: () {
                                    context.pop();
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.black,
                                    size: size.width * AppDimensions.numD06,
                                  ))
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * AppDimensions.numD04),
                          child: const Divider(
                            color: Colors.black,
                            thickness: 0.5,
                          ),
                        ),
                        SizedBox(
                          height: size.width * AppDimensions.numD02,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * AppDimensions.numD04),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 120, // fixed width
                                height: 120, // fixed height
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.black),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    "assets/rabbits/student_beans_rabbit2.png",
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: size.width * AppDimensions.numD04,
                              ),
                              Expanded(
                                child: Text(
                                  sourceDataDescription ??
                                      "Please confirm your student status to continue",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize:
                                          size.width * AppDimensions.numD035,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: size.width * AppDimensions.numD02,
                        ),
                        SizedBox(
                          height: size.width * AppDimensions.numD02,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * AppDimensions.numD04,
                              vertical: size.width * AppDimensions.numD04),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: size.width * AppDimensions.numD12,
                                  child: commonElevatedButton(
                                      "Confirm",
                                      size,
                                      commonButtonTextStyle(size),
                                      commonButtonStyle(
                                          size, AppColorTheme.colorThemePink),
                                      () async {
                                    try {
                                      final url =
                                          await setIsClickForBeansActivation();

                                      if (url == null || url.isEmpty) {
                                        debugPrint("URL is empty");
                                        return;
                                      }

                                      final uri = Uri.parse(url);
                                      final launched = await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );

                                      sharedPreferences!.setBool(
                                          SharedPreferencesKeys
                                              .sourceDataIsClickKey,
                                          true);
                                      sharedPreferences!.setBool(
                                          SharedPreferencesKeys
                                              .sourceDataIsOpenedKey,
                                          true);
                                      context.pop();

                                      if (!launched) {
                                        debugPrint(
                                            "Could not launch URL: $url");
                                      }
                                    } catch (e) {
                                      debugPrint("Error launching URL: $e");
                                    }
                                  }),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ));
        });
  }
}

class MyProfileData {
  MyProfileData.fromJson(json) {
    firstName =
        json[SharedPreferencesKeys.firstNameKey] ?? json['firstName'] ?? "";
    lastName =
        json[SharedPreferencesKeys.lastNameKey] ?? json['lastName'] ?? "";
    userName = json[SharedPreferencesKeys.userNameKey] ??
        json['username'] ??
        json['userName'] ??
        "";
    countryCode =
        json[SharedPreferencesKeys.countryCodeKey] ?? json['countryCode'] ?? "";
    phoneNumber = (json[SharedPreferencesKeys.phoneKey] ?? "").toString();
    debugPrint("MyPhone: $phoneNumber");

    cityName = json[SharedPreferencesKeys.cityKey] ?? json['city'] ?? '';
    countryName =
        json[SharedPreferencesKeys.countryKey] ?? json['country'] ?? '';
    apartment = json[SharedPreferencesKeys.apartmentKey] ?? '';
    email = json[SharedPreferencesKeys.emailKey] ?? "";
    address = json[SharedPreferencesKeys.addressKey] ?? "";
    postCode =
        json[SharedPreferencesKeys.postCodeKey] ?? json['postCode'] ?? "";

    // New profile address fields
    profileAddress = json['profile_address'] ?? "";
    profileCity = json['profile_city'] ?? "";
    profileCountry = json['profile_country'] ?? "";
    profilePostCode = json['profile_post_code'] ?? "";

    latitude = (json[SharedPreferencesKeys.latitudeKey] ?? "").toString();
    longitude = (json[SharedPreferencesKeys.longitudeKey] ?? "").toString();
    totalIncome = json[SharedPreferencesKeys.totalIncomeKey] != null
        ? json[SharedPreferencesKeys.totalIncomeKey].toString()
        : "0";
    String tempAvatar = "";
    if (json["avatarData"] is Map) {
      tempAvatar = json["avatarData"]["avatar"]?.toString() ?? "";
    } else if (json["avatarData"] is String &&
        json["avatarData"].toString().startsWith("http")) {
      tempAvatar = json["avatarData"];
    }

    if (tempAvatar.isEmpty) {
      tempAvatar = json["avatar"]?.toString() ??
          json["profile_image"]?.toString() ??
          json["profileImage"]?.toString() ??
          "";
    }

    avatarImage = fixS3Url(tempAvatar);
    avatarId = (json["avatarData"] is Map
            ? (json["avatarData"]["_id"]?.toString() ??
                json["avatarData"]["id"]?.toString() ??
                "")
            : json["avatarData"]?.toString()) ??
        json["avatar"]?.toString() ??
        "";
    joinedDate = json["createdAt"] != null
        ? changeDateFormat(
            "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'", json["createdAt"], "dd MMMM, yyyy")
        : "";
    validDegree = json["doc_to_become_pro"] != null
        ? json["doc_to_become_pro"]["govt_id_mediatype"].toString()
        : "";
    validMemberShip = json["doc_to_become_pro"] != null
        ? json["doc_to_become_pro"]["photography_mediatype"].toString()
        : "";
    validBritishPassport = json["doc_to_become_pro"] != null
        ? json["doc_to_become_pro"]["comp_incorporation_cert_mediatype"]
            .toString()
        : "";
  }
  MyProfileData();
  String firstName = "";
  String lastName = "";
  String userName = "";
  String countryCode = "";
  String phoneNumber = "";
  String email = "";
  String address = "";
  String postCode = "";

  String profileAddress = "";
  String profileCity = "";
  String profileCountry = "";
  String profilePostCode = "";

  String latitude = "";
  String longitude = "";
  String avatarImage = "";
  String avatarId = "";
  String joinedDate = "";
  String earnings = "0";
  String validDegree = "";
  String validMemberShip = "";
  String apartment = "";
  String cityName = "";
  String countryName = "";
  String validBritishPassport = "";
  String totalIncome = "";
}
