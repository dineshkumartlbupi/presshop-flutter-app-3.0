import 'dart:convert';
import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:location/location.dart' as lc;
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonSharedPrefrence.dart';
import 'package:presshop/utils/CommonTextField.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';

import '../../main.dart';
import '../../utils/CommonAppBar.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../authentication/SignUpScreen.dart';
import '../dashboard/Dashboard.dart';

class MyProfile extends StatefulWidget {
  bool editProfileScreen;
  String screenType;

  MyProfile({super.key, required this.editProfileScreen, required this.screenType});

  @override
  State<StatefulWidget> createState() {
    return MyProfileState();
  }
}

class MyProfileState extends State<MyProfile> implements NetworkResponse {
  late Size size;

  var formKey = GlobalKey<FormState>();
  var scrollController = ScrollController();

  TextEditingController userNameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailAddressController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController postCodeController = TextEditingController();
  TextEditingController apartmentAndHouseNameController = TextEditingController();
  TextEditingController cityNameController = TextEditingController();
  TextEditingController countryNameController = TextEditingController();

  List<AvatarsData> avatarList = [];
  MyProfileData? myProfileData;
  String selectedCountryCode = "", userImagePath = "", latitude = "", longitude = "";
  bool userNameAutoFocus = false, userNameAlreadyExists = false, emailAlreadyExists = false, phoneAlreadyExists = false, showAddressError = false, showApartmentNumberError = false, showPostalCodeError = false, isLoading = false;
  lc.LocationData? locationData;
  lc.Location location = lc.Location();
  FocusNode apartmentFocusNode = FocusNode();

  @override
  void initState() {
    debugPrint("class:::: $runtimeType");
    super.initState();
    debugPrint("editStatus::::::: ${widget.editProfileScreen}");
    setUserNameListener();
    setPhoneListener();
    setEmailListener();
    Future.delayed(Duration.zero, () {
      myProfileApi();
    });
    if (widget.editProfileScreen) {
      getAvatarsApi();
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return /*WillPopScope(
      onWillPop: () async {
        if (widget.editProfileScreen) {
          widget.editProfileScreen = false;
        }
        return true;
      },
      child:*/
        Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(
          widget.screenType,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: size.width * appBarHeadingFontSize),
        ),
        centerTitle: false,
        titleSpacing: 0,
        size: size,
        showActions: true,
        leadingFxn: () {
          /*  if (widget.editProfileScreen) {
              widget.editProfileScreen = false;
            }*/
          Navigator.pop(context);
        },
        actionWidget: [
          InkWell(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Dashboard(initialPosition: 2)), (route) => false);
            },
            child: Image.asset(
              "${commonImagePath}rabbitLogo.png",
              height: size.width * numD07,
              width: size.width * numD07,
            ),
          ),
          SizedBox(
            width: size.width * numD02,
          ),
        ],
      ),
      body: !isLoading
          ? showLoader()
          : GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SafeArea(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Form(
                    key: formKey,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: size.width * numD06),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          topProfileWidget(),
                          SizedBox(
                            height: size.width * numD06,
                          ),
                          Text("${userText.toTitleCase()} $nameText", style: commonTextStyle(size: size, fontSize: size.width * numD032, color: Colors.black, fontWeight: FontWeight.normal)),
                          SizedBox(
                            height: size.width * numD02,
                          ),
                          CommonTextField(
                            size: size,
                            maxLines: 1,
                            textInputFormatters: null,
                            borderColor: colorTextFieldBorder,
                            controller: userNameController,
                            hintText: "${enterText.toTitleCase()} $userText $nameText",
                            prefixIcon: Container(
                              margin: EdgeInsets.only(left: size.width * numD015),
                              child: Image.asset(
                                "${iconsPath}ic_user.png",
                              ),
                            ),
                            prefixIconHeight: size.width * numD04,
                            hidePassword: false,
                            keyboardType: TextInputType.text,
                            validator: null /*userNameValidator*/,
                            enableValidations: false,
                            filled: true,
                            filledColor: widget.editProfileScreen ? colorLightGrey : colorLightGrey,
                            autofocus: userNameAutoFocus,
                            readOnly: true,
                            suffixIconIconHeight: size.width * numD04,
                            suffixIcon: /*widget.editProfileScreen &&
                                userNameController.text.trim().isNotEmpty &&
                                userNameController.text.trim().length >= 4
                            ? userNameAlreadyExists
                                ? const Icon(
                                    Icons.highlight_remove,
                                    color: Colors.red,
                                  )
                                : const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                            :*/
                                null,
                          ),
                          SizedBox(
                            height: size.width * numD06,
                          ),
                          Text("${firstText.toTitleCase()} $nameText", style: commonTextStyle(size: size, fontSize: size.width * numD032, color: Colors.black, fontWeight: FontWeight.normal)),
                          SizedBox(
                            height: size.width * numD02,
                          ),
                          CommonTextField(
                            size: size,
                            maxLines: 1,
                            textInputFormatters: null,
                            borderColor: colorTextFieldBorder,
                            controller: firstNameController,
                            hintText: "${enterText.toTitleCase()} $firstText $nameText",
                            prefixIcon: Container(
                              margin: EdgeInsets.only(left: size.width * numD015),
                              child: Image.asset(
                                "${iconsPath}ic_user.png",
                              ),
                            ),
                            prefixIconHeight: size.width * numD04,
                            suffixIconIconHeight: 0,
                            suffixIcon: null,
                            hidePassword: false,
                            keyboardType: TextInputType.text,
                            validator: checkRequiredValidator,
                            enableValidations: true,
                            filled: true,
                            filledColor: widget.editProfileScreen ? Colors.white : colorLightGrey,
                            autofocus: false,
                            readOnly: widget.editProfileScreen ? false : true,
                          ),
                          SizedBox(
                            height: size.width * numD06,
                          ),
                          Text("${lastText.toTitleCase()} $nameText", style: commonTextStyle(size: size, fontSize: size.width * numD032, color: Colors.black, fontWeight: FontWeight.normal)),
                          SizedBox(
                            height: size.width * numD02,
                          ),
                          CommonTextField(
                            size: size,
                            maxLines: 1,
                            textInputFormatters: null,
                            borderColor: colorTextFieldBorder,
                            controller: lastNameController,
                            hintText: "${enterText.toTitleCase()} $lastText $nameText",
                            prefixIcon: Container(
                              margin: EdgeInsets.only(left: size.width * numD015),
                              child: Image.asset(
                                "${iconsPath}ic_user.png",
                              ),
                            ),
                            prefixIconHeight: size.width * numD04,
                            suffixIconIconHeight: 0,
                            suffixIcon: null,
                            hidePassword: false,
                            keyboardType: TextInputType.text,
                            validator: checkRequiredValidator,
                            enableValidations: true,
                            filled: true,
                            filledColor: widget.editProfileScreen ? Colors.white : colorLightGrey,
                            autofocus: false,
                            readOnly: widget.editProfileScreen ? false : true,
                          ),
                          SizedBox(
                            height: size.width * numD06,
                          ),
                          Text("${phoneText.toTitleCase()} $numberText", style: commonTextStyle(size: size, fontSize: size.width * numD032, color: Colors.black, fontWeight: FontWeight.normal)),
                          SizedBox(
                            height: size.width * numD02,
                          ),
                          CommonTextField(
                            size: size,
                            maxLines: 1,
                            textInputFormatters: null,
                            borderColor: colorTextFieldBorder,
                            controller: phoneNumberController,
                            hintText: "${enterText.toTitleCase()} $phoneText $numberText",
                            prefixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const ImageIcon(
                                  AssetImage(
                                    "${iconsPath}ic_phone.png",
                                  ),
                                ),
                                SizedBox(
                                  width: size.width * numD02,
                                ),
                                Text(
                                  selectedCountryCode,
                                  style: commonTextStyle(size: size, fontSize: size.width * numD032, color: Colors.black, fontWeight: FontWeight.normal),
                                ),
                                SizedBox(
                                  width: size.width * 0.01,
                                ),
                                Image.asset(
                                  "${iconsPath}ic_drop_down.png",
                                  width: size.width * 0.025,
                                ),
                                SizedBox(
                                  width: size.width * 0.01,
                                ),

                                /*  InkWell(
                            onTap: () {},
                            child: Row(
                              children: [
                                Text(
                                  selectedCountryCode,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal),
                                ),
                                SizedBox(
                                  height: size.width*numD06,
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Colors.black,
                                    size: size.width * numD07,
                                  ),
                                )
                              ],
                            ),
                          )*/
                              ],
                            ),
                            prefixIconHeight: size.width * numD045,
                            suffixIconIconHeight: 0,
                            suffixIcon: null,
                            hidePassword: false,
                            keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: true),
                            validator: null /*checkSignupPhoneValidator*/,
                            enableValidations: false,
                            filled: true,
                            filledColor: widget.editProfileScreen ? colorLightGrey : colorLightGrey,
                            autofocus: false,
                            readOnly: true,
                          ),
                          SizedBox(
                            height: size.width * numD06,
                          ),
                          Text(emailAddressText, style: commonTextStyle(size: size, fontSize: size.width * numD032, color: Colors.black, fontWeight: FontWeight.normal)),
                          SizedBox(
                            height: size.width * numD02,
                          ),
                          CommonTextField(
                            size: size,
                            maxLines: 1,
                            textInputFormatters: null,
                            borderColor: colorTextFieldBorder,
                            controller: emailAddressController,
                            hintText: "${enterText.toTitleCase()} $emailAddressText",
                            prefixIcon: Container(
                              margin: EdgeInsets.only(left: size.width * numD015),
                              child: Image.asset(
                                "${iconsPath}ic_email.png",
                              ),
                            ),
                            prefixIconHeight: size.width * numD038,
                            suffixIconIconHeight: 0,
                            suffixIcon: null,
                            hidePassword: false,
                            keyboardType: TextInputType.emailAddress,
                            validator: null /*checkSignupEmailValidator*/,
                            enableValidations: false,
                            filled: true,
                            filledColor: widget.editProfileScreen ? colorLightGrey : colorLightGrey,
                            autofocus: false,
                            readOnly: true,
                          ),
                          SizedBox(
                            height: size.width * numD06,
                          ),

                          /// Apartment Number and House Number
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(apartmentNoHintText, style: commonTextStyle(size: size, fontSize: size.width * numD032, color: Colors.black, fontWeight: FontWeight.normal)),
                              SizedBox(
                                height: size.width * numD02,
                              ),
                              /* CommonTextField(
                          size: size,
                          maxLines: 1,
                          textInputFormatters: null,
                          borderColor: colorTextFieldBorder,
                          controller: apartmentAndHouseNameController,
                          hintText: apartmentNoHintText,
                          prefixIcon:Container(
                            margin: EdgeInsets.only(left: size.width * numD015),
                            child: Image.asset(
                              "${iconsPath}ic_location.png",
                            ),
                          ),
                          prefixIconHeight: size.width * numD045,
                          suffixIconIconHeight: 0,
                          suffixIcon: null,
                          hidePassword: false,
                          keyboardType: TextInputType.text,
                          validator: checkRequiredValidator,
                          enableValidations: true,
                          filled: true,
                          filledColor: colorLightGrey,
                          autofocus: false,
                          readOnly: widget.editProfileScreen ? false : true,
                        ),*/
                              SizedBox(
                                height: size.width * numD12,
                                child: GooglePlaceAutoCompleteTextField(
                                  focusNode: apartmentFocusNode,
                                  textEditingController: apartmentAndHouseNameController,
                                  googleAPIKey: Platform.isIOS ? appleMapAPiKey : googleMapAPiKey,
                                  isCrossBtnShown: false,
                                  boxDecoration: BoxDecoration(color: widget.editProfileScreen ? Colors.white : colorLightGrey, borderRadius: BorderRadius.circular(size.width * 0.03), border: Border.all(color: colorTextFieldBorder, width: 1)),
                                  textStyle: TextStyle(color: Colors.black, fontSize: size.width * numD032, fontFamily: 'AirbnbCereal_W_Md'),
                                  inputDecoration: InputDecoration(
                                    border: InputBorder.none,
                                    filled: false,
                                    enabled: widget.editProfileScreen,
                                    contentPadding: EdgeInsets.symmetric(vertical: 2),
                                    hintText: apartmentNoHintText,
                                    hintStyle: TextStyle(color: colorHint, fontSize: size.width * numD035, fontFamily: 'AirbnbCereal_W_Md'),
                                    prefixIcon: Container(
                                      margin: EdgeInsets.only(right: size.width * numD02, left: 12),
                                      child: Image.asset(
                                        "${iconsPath}ic_location.png",
                                      ),
                                    ),
                                    suffixIcon: widget.editProfileScreen
                                        ? InkWell(
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () {
                                              apartmentAndHouseNameController.clear();
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: 8),
                                              child: Icon(
                                                Icons.close,
                                                color: Colors.black,
                                                size: size.width * numD058,
                                              ),
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                    prefixIconConstraints: BoxConstraints(maxHeight: size.width * numD045),
                                    suffixIconConstraints: BoxConstraints(
                                      maxHeight: size.width * numD07,
                                    ),
                                    prefixIconColor: colorTextFieldIcon,
                                  ),
                                  debounceTime: 200,
                                  countries: const ["uk", "in"],
                                  isLatLngRequired: true,
                                  getPlaceDetailWithLatLng: (Prediction prediction) {
                                    latitude = prediction.lat.toString();
                                    longitude = prediction.lng.toString();
                                    debugPrint("placeDetails :: ${prediction.lng}");
                                    debugPrint("placeDetails :: ${prediction.lat}");
                                    getCurrentLocationFxn(prediction.lat ?? "", prediction.lng ?? "").then((value) {
                                      if (value.isNotEmpty) {
                                        cityNameController.text = value.first.locality ?? '';
                                        countryNameController.text = value.first.country ?? '';
                                      }
                                    });
                                    showAddressError = false;
                                    setState(() {});
                                  },
                                  itemClick: (Prediction prediction) {
                                    addressController.text = prediction.description ?? "";
                                    latitude = prediction.lat ?? "";
                                    longitude = prediction.lng ?? "";

                                    String postalCode = prediction.structuredFormatting?.mainText ?? '';
                                    debugPrint("postalCode=======> $postalCode");
                                    postCodeController.text = postalCode;
                                    addressController.selection = TextSelection.fromPosition(TextPosition(offset: prediction.description != null ? prediction.description!.length : 0));
                                  },
                                ),
                              )
                            ],
                          ),
                          showApartmentNumberError && apartmentAndHouseNameController.text.trim().isEmpty
                              ? Padding(
                                  padding: EdgeInsets.symmetric(horizontal: size.width * numD04, vertical: size.width * numD01),
                                  child: Text(
                                    requiredText,
                                    style: commonTextStyle(size: size, fontSize: size.width * numD03, color: Colors.red.shade700, fontWeight: FontWeight.normal),
                                  ),
                                )
                              : Container(),
                          SizedBox(
                            height: size.width * numD06,
                          ),
                          Text(postalCodeText, style: commonTextStyle(size: size, fontSize: size.width * numD032, color: Colors.black, fontWeight: FontWeight.normal)),
                          SizedBox(
                            height: size.width * numD02,
                          ),
                          /* CommonTextField(
                      size: size,
                      maxLines: 1,
                      textInputFormatters: null,
                      borderColor: colorTextFieldBorder,
                      controller: addressController,
                      hintText: "${enterText.toTitleCase()} $addressText",
                      prefixIcon: const ImageIcon(
                        AssetImage(
                          "${iconsPath}ic_location.png",
                        ),
                      ),
                      prefixIconHeight: size.width * numD045,
                      suffixIconIconHeight: 0,
                      suffixIcon: null,
                      hidePassword: false,
                      keyboardType: TextInputType.text,
                      validator: checkRequiredValidator,
                      enableValidations: true,
                      filled: true,
                      filledColor: colorLightGrey,
                      autofocus: false,
                      readOnly: widget.editProfileScreen ? false : true,
                    ),
                    SizedBox(
                      height: size.width * numD06,
                    ),
                    Text(postalCodeText,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD032,
                            color: Colors.black,
                            fontWeight: FontWeight.normal)),
                    SizedBox(
                      height: size.width * numD02,
                    ),
                    CommonTextField(
                      size: size,
                      maxLines: 1,
                      textInputFormatters: null,
                      borderColor: colorTextFieldBorder,
                      controller: postCodeController,
                      hintText: "${enterText.toTitleCase()} $postalCodeText",
                      prefixIcon: const ImageIcon(
                        AssetImage(
                          "${iconsPath}ic_location.png",
                        ),
                      ),
                      prefixIconHeight: size.width * numD045,
                      suffixIconIconHeight: 0,
                      suffixIcon: null,
                      hidePassword: false,
                      keyboardType: TextInputType.text,
                      validator: checkRequiredValidator,
                      enableValidations: true,
                      filled: true,
                      filledColor: colorLightGrey,
                      autofocus: false,
                      readOnly: widget.editProfileScreen ? false : true,
                    ),*/

                          widget.editProfileScreen
                              ? SizedBox(
                                  height: size.width * numD12,
                                  child: GooglePlaceAutoCompleteTextField(
                                    textEditingController: postCodeController,
                                    //   googleAPIKey: "AIzaSyAzccAqyrfD-V43gI9eBXqLf0qpqlm0Gu0",
                                    googleAPIKey: Platform.isIOS ? appleMapAPiKey : googleMapAPiKey,
                                    isCrossBtnShown: false,
                                    boxDecoration: BoxDecoration(color: widget.editProfileScreen ? Colors.white : colorLightGrey, borderRadius: BorderRadius.circular(size.width * 0.03), border: Border.all(color: colorTextFieldBorder, width: 1)),
                                    textStyle: TextStyle(color: Colors.black, fontSize: size.width * numD032, fontFamily: 'AirbnbCereal_W_Md'),
                                    inputDecoration: InputDecoration(
                                      border: InputBorder.none,
                                      filled: false,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: size.width * numD038,
                                      ),
                                      hintText: "${enterText.toTitleCase()} ${postalCodeText.toLowerCase()}",
                                      hintStyle: TextStyle(color: colorHint, fontSize: size.width * numD035, fontFamily: 'AirbnbCereal_W_Md'),
                                      prefixIcon: Container(
                                        margin: EdgeInsets.only(right: size.width * numD02, left: 12),
                                        child: Image.asset(
                                          "${iconsPath}ic_location.png",
                                        ),
                                      ),
                                      suffixIcon: InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () {
                                          postCodeController.clear();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.black,
                                            size: size.width * numD058,
                                          ),
                                        ),
                                      ),
                                      prefixIconConstraints: BoxConstraints(maxHeight: size.width * numD045),
                                      suffixIconConstraints: BoxConstraints(
                                        maxHeight: size.width * numD07,
                                      ),
                                      prefixIconColor: colorTextFieldIcon,
                                    ),
                                    debounceTime: 200,
                                    countries: const ["uk", "in"],
                                    isLatLngRequired: true,

                                    getPlaceDetailWithLatLng: (Prediction prediction) {
                                      latitude = prediction.lat.toString();
                                      longitude = prediction.lng.toString();
                                      debugPrint("placeDetails :: ${prediction.lng}");
                                      debugPrint("placeDetails :: ${prediction.lat}");
                                      getCurrentLocationFxn(prediction.lat ?? "", prediction.lng ?? "").then((value) {
                                        if (value.isNotEmpty) {
                                          cityNameController.text = value.first.locality ?? '';
                                          countryNameController.text = value.first.country ?? '';
                                        }
                                      });
                                      showAddressError = false;
                                      setState(() {});
                                    },

                                    itemClick: (Prediction prediction) {
                                      addressController.text = prediction.description ?? "";
                                      latitude = prediction.lat ?? "";
                                      longitude = prediction.lng ?? "";

                                      String postalCode = prediction.structuredFormatting?.mainText ?? '';
                                      debugPrint("postalCode=======> $postalCode");
                                      postCodeController.text = postalCode;
                                      addressController.selection = TextSelection.fromPosition(TextPosition(offset: prediction.description != null ? prediction.description!.length : 0));
                                    },
                                  ),
                                )
                              : CommonTextField(
                                  size: size,
                                  maxLines: 1,
                                  textInputFormatters: null,
                                  borderColor: colorTextFieldBorder,
                                  controller: postCodeController,
                                  hintText: "${enterText.toTitleCase()} $postalCodeText",
                                  prefixIcon: Image.asset(
                                    "${iconsPath}ic_location.png",
                                  ),
                                  prefixIconHeight: size.width * numD045,
                                  suffixIconIconHeight: 0,
                                  suffixIcon: null,
                                  hidePassword: false,
                                  keyboardType: TextInputType.text,
                                  validator: checkRequiredValidator,
                                  enableValidations: true,
                                  filled: true,
                                  filledColor: widget.editProfileScreen ? Colors.white : colorLightGrey,
                                  autofocus: false,
                                  readOnly: true,
                                ),

                          showAddressError && addressController.text.trim().isEmpty
                              ? Padding(
                                  padding: EdgeInsets.symmetric(horizontal: size.width * numD04, vertical: size.width * numD01),
                                  child: Text(
                                    requiredText,
                                    style: commonTextStyle(size: size, fontSize: size.width * numD03, color: Colors.red.shade700, fontWeight: FontWeight.normal),
                                  ),
                                )
                              : Container(),
                          SizedBox(
                            height: size.width * numD06,
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(addressText, style: commonTextStyle(size: size, fontSize: size.width * numD032, color: Colors.black, fontWeight: FontWeight.normal)),
                              SizedBox(
                                height: size.width * numD02,
                              ),

                              ///Address
                              widget.editProfileScreen
                                  ? SizedBox(
                                      height: size.width * numD12,
                                      child: GooglePlaceAutoCompleteTextField(
                                        textEditingController: addressController,
                                        //googleAPIKey: "AIzaSyAzccAqyrfD-V43gI9eBXqLf0qpqlm0Gu0",
                                        googleAPIKey: Platform.isIOS ? appleMapAPiKey : googleMapAPiKey,
                                        isCrossBtnShown: false,
                                        boxDecoration: BoxDecoration(color: widget.editProfileScreen ? Colors.white : colorLightGrey, borderRadius: BorderRadius.circular(size.width * 0.03), border: Border.all(color: colorTextFieldBorder, width: 1)),
                                        textStyle: TextStyle(color: Colors.black, fontSize: size.width * numD032, fontFamily: 'AirbnbCereal_W_Md'),
                                        inputDecoration: InputDecoration(
                                          helperMaxLines: 5,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(vertical: size.width * numD038),
                                          filled: false,
                                          hintText: "${enterText.toTitleCase()} ${addressText.toLowerCase()}",
                                          hintStyle: TextStyle(color: colorHint, fontSize: size.width * numD035, fontFamily: 'AirbnbCereal_W_Md'),
                                          prefixIcon: Container(
                                            margin: EdgeInsets.only(right: size.width * numD02, left: 12),
                                            child: Image.asset(
                                              "${iconsPath}ic_location.png",
                                            ),
                                          ),
                                          suffixIcon: InkWell(
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            onTap: () {
                                              addressController.clear();
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: 8),
                                              child: Icon(
                                                Icons.close,
                                                color: Colors.black,
                                                size: size.width * numD058,
                                              ),
                                            ),
                                          ),
                                          prefixIconConstraints: BoxConstraints(maxHeight: size.width * numD045),
                                          suffixIconConstraints: BoxConstraints(
                                            maxHeight: size.width * numD07,
                                          ),
                                          prefixIconColor: colorTextFieldIcon,
                                        ),
                                        debounceTime: 600,
                                        // default 600 ms,
                                        countries: const ["uk", "in"],
                                        // optional by default null is set
                                        isLatLngRequired: true,
                                        // if you required coordinates from place detail
                                        getPlaceDetailWithLatLng: (Prediction prediction) {
                                          latitude = prediction.lat.toString();
                                          longitude = prediction.lng.toString();
                                          debugPrint("placeDetails :: ${prediction.lng}");
                                          debugPrint("placeDetails :: ${prediction.lat}");
                                          getCurrentLocationFxn(prediction.lat ?? "", prediction.lng ?? "").then((value) {
                                            if (value.isNotEmpty) {
                                              cityNameController.text = value.first.locality ?? '';
                                              countryNameController.text = value.first.country ?? '';
                                            }
                                          });
                                          showAddressError = false;
                                          setState(() {});
                                        },
                                        // this callback is called when isLatLngRequired is true

                                        itemClick: (Prediction prediction) {
                                          addressController.text = prediction.description ?? "";
                                          latitude = prediction.lat ?? "";
                                          longitude = prediction.lng ?? "";

                                          String postalCode = prediction?.structuredFormatting?.mainText ?? '';
                                          debugPrint("postalCode=======> $postalCode");

                                          //postCodeController.text = postalCode;
                                          addressController.selection = TextSelection.fromPosition(TextPosition(offset: prediction.description != null ? prediction.description!.length : 0));
                                        },
                                      ),
                                    )
                                  : CommonTextField(
                                      size: size,
                                      maxLines: 3,
                                      textInputFormatters: null,
                                      borderColor: colorTextFieldBorder,
                                      controller: addressController,
                                      hintText: "${enterText.toTitleCase()} $addressText",
                                      prefixIcon: Image.asset(
                                        "${iconsPath}ic_location.png",
                                      ),
                                      prefixIconHeight: size.width * numD045,
                                      suffixIconIconHeight: 0,
                                      suffixIcon: null,
                                      hidePassword: false,
                                      keyboardType: TextInputType.text,
                                      validator: checkRequiredValidator,
                                      enableValidations: true,
                                      filled: true,
                                      filledColor: widget.editProfileScreen ? Colors.white : colorLightGrey,
                                      autofocus: false,
                                      readOnly: widget.editProfileScreen ? false : true,
                                    ),
                            ],
                          ),

                          showPostalCodeError && postCodeController.text.trim().isEmpty && addressController.text.isNotEmpty
                              ? Padding(
                                  padding: EdgeInsets.symmetric(horizontal: size.width * numD04, vertical: size.width * numD01),
                                  child: Text(
                                    requiredText,
                                    style: commonTextStyle(size: size, fontSize: size.width * numD03, color: Colors.red.shade700, fontWeight: FontWeight.normal),
                                  ),
                                )
                              : Container(),

                          SizedBox(
                            height: size.width * numD06,
                          ),

                          /// City
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cityText, style: commonTextStyle(size: size, fontSize: size.width * numD032, color: Colors.black, fontWeight: FontWeight.normal)),
                              SizedBox(
                                height: size.width * numD02,
                              ),
                              CommonTextField(
                                size: size,
                                maxLines: 1,
                                textInputFormatters: null,
                                borderColor: colorTextFieldBorder,
                                controller: cityNameController,
                                hintText: cityText,
                                prefixIcon: Container(
                                  margin: EdgeInsets.only(left: size.width * numD01),
                                  child: Image.asset(
                                    "${iconsPath}ic_location.png",
                                  ),
                                ),
                                prefixIconHeight: size.width * numD045,
                                suffixIconIconHeight: 0,
                                suffixIcon: null,
                                hidePassword: false,
                                keyboardType: TextInputType.text,
                                validator: checkRequiredValidator,
                                enableValidations: true,
                                filled: true,
                                filledColor: widget.editProfileScreen ? Colors.white : colorLightGrey,
                                autofocus: false,
                                readOnly: widget.editProfileScreen ? false : true,
                              ),
                            ],
                          ),

                          SizedBox(height: size.width * numD06),

                          /// Country
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(countryText, style: commonTextStyle(size: size, fontSize: size.width * numD032, color: Colors.black, fontWeight: FontWeight.normal)),
                              SizedBox(
                                height: size.width * numD02,
                              ),
                              CommonTextField(
                                size: size,
                                maxLines: 1,
                                textInputFormatters: null,
                                borderColor: colorTextFieldBorder,
                                controller: countryNameController,
                                hintText: countryText,
                                prefixIcon: Container(
                                  margin: EdgeInsets.only(left: size.width * numD01),
                                  child: Image.asset(
                                    "${iconsPath}ic_location.png",
                                  ),
                                ),
                                prefixIconHeight: size.width * numD045,
                                suffixIconIconHeight: 0,
                                suffixIcon: null,
                                hidePassword: false,
                                keyboardType: TextInputType.text,
                                validator: checkRequiredValidator,
                                enableValidations: true,
                                filled: true,
                                filledColor: widget.editProfileScreen ? Colors.white : colorLightGrey,
                                autofocus: false,
                                readOnly: widget.editProfileScreen ? false : true,
                              ),
                            ],
                          ),

                          SizedBox(
                            height: size.width * numD09,
                          ),
                          widget.editProfileScreen
                              ? SizedBox(
                                  width: double.infinity,
                                  height: size.width * numD14,
                                  //  padding: EdgeInsets.symmetric(horizontal: size.width * numD08),
                                  child: commonElevatedButton(widget.editProfileScreen ? saveText.toTitleCase() : editProfileText.toTitleCase(), size, commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.white, fontWeight: FontWeight.w700), commonButtonStyle(size, colorThemePink), () {
                                    if (!widget.editProfileScreen) {
                                      widget.editProfileScreen = !widget.editProfileScreen;
                                      scrollController.animateTo(scrollController.position.minScrollExtent, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                                      userNameAutoFocus = true;
                                    } else {
                                      scrollController.animateTo(scrollController.position.minScrollExtent, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                                      if (formKey.currentState!.validate()) {
                                        editProfileApi();
                                      }
                                    }
                                    setState(() {});
                                  }),
                                )
                              : Container(),
                          SizedBox(
                            height: size.width * numD04,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
    // );
  }

  Widget topProfileWidget() {
    return Container(
      height: size.width * numD35,
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(size.width * numD04)),
      child: Row(
        children: [
          Stack(
            fit: StackFit.loose,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(size.width * numD04), bottomLeft: Radius.circular(size.width * numD04)),
                  child: Image.network(
                    myProfileData != null ? "$avatarImageUrl${myProfileData!.avatarImage}" : "",
                    errorBuilder: (context, exception, stacktrace) {
                      return Padding(
                        padding: EdgeInsets.all(size.width * numD04),
                        child: Image.asset(
                          "${commonImagePath}rabbitLogo.png",
                          fit: BoxFit.contain,
                          width: size.width * numD35,
                          height: size.width * numD35,
                        ),
                      );
                    },
                    fit: BoxFit.cover,
                    width: size.width * numD37,
                    height: size.width * numD35,
                  )),
              widget.editProfileScreen
                  ? Positioned(
                      bottom: size.width * numD01,
                      right: size.width * numD01,
                      child: InkWell(
                        onTap: () {
                          avatarBottomSheet(size);
                        },
                        child: Container(
                          padding: EdgeInsets.all(size.width * 0.005),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: Container(
                              padding: EdgeInsets.all(size.width * 0.005),
                              decoration: const BoxDecoration(color: colorThemePink, shape: BoxShape.circle),
                              child: Icon(
                                Icons.edit_outlined,
                                color: Colors.white,
                                size: size.width * numD04,
                              )),
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
          SizedBox(
            width: size.width * numD04,
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(myProfileData != null ? myProfileData!.userName.toCapitalized() : "", style: commonTextStyle(size: size, fontSize: size.width * numD04, color: colorThemePink, fontWeight: FontWeight.w500)),
              SizedBox(
                height: size.width * numD01,
              ),
              Text("$joinedText - ${myProfileData != null ? myProfileData!.joinedDate : ""}", style: commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.white, fontWeight: FontWeight.normal)),
              SizedBox(
                height: size.width * numD005,
              ),
              Text("$earningsText - ${euroUniqueCode}0", style: commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.white, fontWeight: FontWeight.normal)),
              SizedBox(
                height: size.width * numD005,
              ),
              Text(myProfileData != null ? myProfileData!.address : "", maxLines: 3, overflow: TextOverflow.ellipsis, style: commonTextStyle(size: size, fontSize: size.width * numD035, color: Colors.white, fontWeight: FontWeight.normal))
            ],
          ))
        ],
      ),
    );
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
    }
  }

  String? userNameValidator(String? value) {
    //<-- add String? as a return type
    if (value!.isEmpty) {
      return requiredText;
    } else if (firstNameController.text.trim().isEmpty) {
      return "First name must be filled.";
    } else if (lastNameController.text.trim().isEmpty) {
      return "Last name must be filled.";
    }
    if (value.toLowerCase().contains(firstNameController.text.toLowerCase()) || value.toLowerCase().contains(lastNameController.text.toLowerCase())) {
      return "First name or Last name are not allowed in user name.";
    } else if (value.length < 4) {
      return "Your user name must be at least 4 characters in length";
    } else if (userNameAlreadyExists) {
      return "This user name already occupied. Please try another one";
    }
    return null;
  }

  void setUserNameListener() {
    userNameController.addListener(() {
      if (widget.editProfileScreen) {
        debugPrint("UserName:${userNameController.text}");
        if (userNameController.text.trim().isNotEmpty && firstNameController.text.trim().isNotEmpty && lastNameController.text.trim().isNotEmpty && userNameController.text.trim().length >= 4 && !userNameController.text.trim().toLowerCase().contains(firstNameController.text.trim().toLowerCase()) && !userNameController.text.trim().toLowerCase().contains(lastNameController.text.trim().toLowerCase())) {
          debugPrint("notsuccess");
          checkUserNameApi();
        } else {
          userNameAlreadyExists = false;
        }
        setState(() {});
      }
    });
  }

  void setEmailListener() {
    emailAddressController.addListener(() {
      if (widget.editProfileScreen) {
        debugPrint("Emil:${emailAddressController.text}");
        if (emailAddressController.text.trim().isNotEmpty) {
          debugPrint("notsuccess");
          checkEmailApi();
        } else {
          emailAlreadyExists = false;
        }

        setState(() {});
      }
    });
  }

  void setPhoneListener() {
    phoneNumberController.addListener(() {
      if (widget.editProfileScreen) {
        debugPrint("Phone:${phoneNumberController.text}");
        if (phoneNumberController.text.trim().isNotEmpty && phoneNumberController.text.trim().length > 9) {
          debugPrint("notsuccess");
          checkPhoneApi();
        } else {
          phoneAlreadyExists = false;
        }

        setState(() {});
      }
    });
  }

  /// Avatar Images
  void avatarBottomSheet(Size size) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Ensures the bottom sheet is full height if needed
      builder: (context) {
        return StatefulBuilder(builder: (context, avatarState) {
          return Container(
            height: size.height * 0.6, // Set a fixed height
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and close button
                Padding(
                  padding: EdgeInsets.only(left: size.width * numD04),
                  child: Row(
                    children: [
                      Text(
                        chooseAvatarText,
                        style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD04,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.close,
                          color: Colors.black,
                          size: size.width * numD06,
                        ),
                      ),
                    ],
                  ),
                ),
                // Scrollable Avatar List
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
                              int pos = avatarList.indexWhere((element) => element.selected);
                              if (pos >= 0) {
                                avatarList[pos].selected = false;
                              }
                              myProfileData!.avatarImage = item.avatar;
                              myProfileData!.avatarId = item.id;
                              item.selected = true;
                              avatarState(() {});
                              setState(() {});
                              Navigator.pop(context);
                            },
                            child: Stack(
                              children: [
                                Image.network("$avatarImageUrl${item.avatar}"),
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
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  /// Get current Location
/*
  Future<String?> getCurrentLocationFxn(String latitude, longitude) async {
    try {
      double lat = double.parse(latitude);
      double long = double.parse(longitude);
      List<Placemark> placeMarkList = await placemarkFromCoordinates(lat, long);
      debugPrint("PlaceHolder: ${placeMarkList.first}");
      return placeMarkList.first.postalCode!;
    } on Exception catch (e) {
      debugPrint("PEx: $e");
      showSnackBar("Exception", e.toString(), Colors.red);
    }
    return null;
  }
*/

  Future<List<Placemark>> getCurrentLocationFxn(String latitude, longitude) async {
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
      onSelect: (Country country) {
        debugPrint('Select country: ${country.displayName}');
        debugPrint('Select country: ${country.countryCode}');
        debugPrint('Select country: ${country.hashCode}');
        debugPrint('Select country: ${country.displayNameNoCountryCode}');
        debugPrint('Select country: ${country.phoneCode}');

        myProfileData!.countryCode = country.phoneCode;
        setState(() {});
      },
    );
  }

  String? checkSignupPhoneValidator(String? value) {
    //<-- add String? as a return type
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
    //<-- add String? as a return type
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
      NetworkClass("$checkUserNameUrl${userNameController.text.trim().toLowerCase()}", this, checkUserNameUrlRequest).callRequestServiceHeader(false, "get", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  void checkEmailApi() {
    try {
      NetworkClass("$checkEmailUrl${emailAddressController.text.trim()}", this, checkEmailUrlRequest).callRequestServiceHeader(false, "get", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  void checkPhoneApi() {
    try {
      NetworkClass("$checkPhoneUrl${phoneNumberController.text.trim()}", this, checkPhoneUrlRequest).callRequestServiceHeader(false, "get", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  void getAvatarsApi() {
    try {
      NetworkClass(getAvatarsUrl, this, getAvatarsUrlRequest).callRequestServiceHeader(false, "get", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  void myProfileApi() {
    NetworkClass(myProfileUrl, this, myProfileUrlRequest).callRequestServiceHeader(false, "get", null);
  }

  void editProfileApi() {
    try {
      Map<String, String> params = {
        firstNameKey: firstNameController.text.trim(),
        lastNameKey: lastNameController.text.trim(),
        userNameKey: userNameController.text.trim().toLowerCase(),
        emailKey: emailAddressController.text.trim(),
        countryCodeKey: myProfileData!.countryCode,
        phoneKey: phoneNumberController.text.trim(),
        addressKey: addressController.text.trim(),
        latitudeKey: latitude.isNotEmpty ? latitude : myProfileData!.latitude,
        longitudeKey: longitude.isNotEmpty ? longitude : myProfileData!.longitude,
        avatarIdKey: myProfileData!.avatarId,
        postCodeKey: postCodeController.text,
        cityKey: cityNameController.text.trim(),
        countryKey: countryNameController.text.trim(),
        apartmentKey: apartmentAndHouseNameController.text.trim(),
        roleKey: "Hopper",
      };
      NetworkClass.fromNetworkClass(editProfileUrl, this, editProfileUrlRequest, params).callRequestServiceHeader(true, "patch", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case myProfileUrlRequest:
          var map = jsonDecode(response);
          debugPrint("MyProfileError:$map");
          break;

        case editProfileUrlRequest:
          var map = jsonDecode(response);
          debugPrint("EditProfileError:$map");
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
        case myProfileUrlRequest:
          var map = jsonDecode(response);
          debugPrint("MyProfileSuccess:$map");

          if (map["code"] == 200) {
            myProfileData = MyProfileData.fromJson(map["userData"]);
            sharedPreferences!.setString(firstNameKey, map["userData"][firstNameKey]);
            sharedPreferences!.setString(lastNameKey, map["userData"][lastNameKey]);
            sharedPreferences!.setString(emailKey, map["userData"][emailKey]);
            sharedPreferences!.setString(countryCodeKey, map["userData"][countryCodeKey]);
            sharedPreferences!.setString(phoneKey, map["userData"][phoneKey].toString());
            debugPrint("phoneNumber======> ${map["userData"][phoneKey]}");
            sharedPreferences!.setString(addressKey, map["userData"][addressKey]);
            if (map["userData"][postCodeKey] != null) {
              sharedPreferences!.setString(addressKey, map["userData"][postCodeKey]);
            }

            sharedPreferences!.setString(latitudeKey, map["userData"][latitudeKey].toString());
            sharedPreferences!.setString(longitudeKey, map["userData"][longitudeKey].toString());
            sharedPreferences!.setString(avatarIdKey, map["userData"][avatarIdKey].toString());
            if (map["userData"]['avatarData'] != null) {
              sharedPreferences!.setString(avatarKey, map["userData"]['avatarData'][avatarKey]);
            }
            isLoading = true;
            setProfileData();
            setState(() {});
          }
          break;

        case checkUserNameUrlRequest:
          var map = jsonDecode(response);
          debugPrint("CheckUserNameResponse:$map");
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

          var list = map["response"] as List;
          avatarList = list.map((e) => AvatarsData.fromJson(e)).toList();
          debugPrint("AvatarList: ${avatarList.length}");
          setState(() {});
          break;
        case editProfileUrlRequest:
          var map = jsonDecode(response);
          if (map["code"] == 200) {
            widget.editProfileScreen = true;
            /* showSnackBar("Profile Updated!",
                "Your profile has been updated successfully", colorOnlineGreen);*/
            debugPrint("heloooo::::${myProfileData!.avatarId}");

            myProfileApi();
            sharedPreferences!.setString(avatarKey, myProfileData!.avatarImage);
          }
          setState(() {});
          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }
}

class MyProfileData {
  String firstName = "";
  String lastName = "";
  String userName = "";
  String countryCode = "";
  String phoneNumber = "";
  String email = "";
  String address = "";
  String postCode = "";
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

  MyProfileData.fromJson(json) {
    firstName = json[firstNameKey];
    lastName = json[lastNameKey];
    userName = json[userNameKey];
    countryCode = json[countryCodeKey];
    phoneNumber = json[phoneKey].toString();
    debugPrint("MyPhone: $phoneNumber");

    cityName = json[cityKey] ?? '';
    countryName = json[countryKey] ?? '';
    apartment = json[apartmentKey] ?? '';
    email = json[emailKey];
    address = json[addressKey];
    postCode = json[postCodeKey] ?? "";
    latitude = json[latitudeKey].toString();
    longitude = json[longitudeKey].toString();
    avatarImage = json["avatarData"] != null ? json["avatarData"]["avatar"] : "";
    avatarId = json["avatarData"] != null ? json["avatarData"]["_id"] : "";
    joinedDate = changeDateFormat("yyyy-MM-dd'T'hh:mm:ss.SSS'Z'", json["createdAt"], "dd MMMM, yyyy");
    validDegree = json["doc_to_become_pro"] != null ? json["doc_to_become_pro"]["govt_id_mediatype"].toString() : "";
    validMemberShip = json["doc_to_become_pro"] != null ? json["doc_to_become_pro"]["photography_mediatype"].toString() : "";
    validBritishPassport = json["doc_to_become_pro"] != null ? json["doc_to_become_pro"]["comp_incorporation_cert_mediatype"].toString() : "";
  }
}
