import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_text_field.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/core/router/router_constants.dart';

import '../bloc/account_settings_bloc.dart';
import '../bloc/account_settings_event.dart';
import '../bloc/account_settings_state.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return ContactUsScreenState();
  }
}

class ContactUsScreenState extends State<ContactUsScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailAddressController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  String adminEmail = "";
  final contactUsKey = GlobalKey<FormState>();

  bool isRequiredVisible = false;

  @override
  void initState() {
    debugPrint("class ==> $runtimeType");
    initialData();
    super.initState();
  }

  void onTextChanged() {
    setState(() {
      isRequiredVisible = messageController.text.isEmpty;
    });
  }

  void initialData() {
    String firstName =
        sharedPreferences!.getString(SharedPreferencesKeys.firstNameKey) ?? "";
    String lastName =
        sharedPreferences!.getString(SharedPreferencesKeys.lastNameKey) ?? "";
    nameController.text = "$firstName $lastName".trim();

    phoneNumberController.text =
        sharedPreferences!.getString(SharedPreferencesKeys.phoneKey) ?? "";
    emailAddressController.text =
        sharedPreferences!.getString(SharedPreferencesKeys.emailKey) ?? "";
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) =>
          sl<AccountSettingsBloc>()..add(const GetAdminContactInfoEvent()),
      child: BlocListener<AccountSettingsBloc, AccountSettingsState>(
        listener: (context, state) {
          if (state is AdminContactInfoLoaded) {
            setState(() {
              adminEmail = state.adminContactInfo.email;
            });
          } else if (state is AccountSettingsError) {
       
            debugPrint("Failed to load admin contact info: ${state.message}");
          }
        },
        child: Scaffold(
          appBar: CommonAppBar(
            elevation: 0,
            hideLeading: false,
            title: Text(
              "${AppStrings.contactText} ${AppStrings.usText.toTitleCase()}",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: size.width * AppDimensions.appBarHeadingFontSize,
                  fontWeight: FontWeight.w700),
            ),
            centerTitle: false,
            titleSpacing: 0,
            size: size,
            showActions: true,
            leadingFxn: () {
              context.pop();
            },
            actionWidget: [
              InkWell(
                onTap: () {
                  context.goNamed(
                    AppRoutes.dashboardName,
                    extra: {'initialPosition': 2},
                  );
                },
                child: Image.asset(
                  "${commonImagePath}rabbitLogo.png",
                  height: size.width * AppDimensions.numD07,
                  width: size.width * AppDimensions.numD07,
                ),
              ),
              SizedBox(
                width: size.width * AppDimensions.numD04,
              )
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal:AppDimensions.commonPaddingSize(size)),
                child: Form(
                  key: contactUsKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: size.width,
                        height: size.width * AppDimensions.numD35,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              left: 0,
                              child: Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 5),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            size.width * AppDimensions.numD15),
                                        child: Image.asset(
                                          "${dummyImagePath}image1.png",
                                          height:
                                              size.width * AppDimensions.numD20,
                                          width:
                                              size.width * AppDimensions.numD20,
                                          fit: BoxFit.cover,
                                        )),
                                  ),
                                  Positioned(
                                    bottom: 2,
                                    right: 10,
                                    child: Container(
                                      padding:
                                          EdgeInsets.all(size.width * 0.005),
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                      child: Icon(
                                        Icons.circle,
                                        color: AppColorTheme.colorOnlineGreen,
                                        size: size.width * AppDimensions.numD03,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Positioned(
                              left: size.width * AppDimensions.numD18,
                              child: Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 5),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            size.width * AppDimensions.numD15),
                                        child: Image.asset(
                                          "${dummyImagePath}image2.png",
                                          height:
                                              size.width * AppDimensions.numD20,
                                          width:
                                              size.width * AppDimensions.numD20,
                                          fit: BoxFit.cover,
                                        )),
                                  ),
                                  Positioned(
                                    bottom: 2,
                                    right: 10,
                                    child: Container(
                                      padding:
                                          EdgeInsets.all(size.width * 0.005),
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                      child: Icon(
                                        Icons.circle,
                                        color: AppColorTheme.colorOnlineGreen,
                                        size: size.width * AppDimensions.numD03,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Positioned(
                              left: size.width * AppDimensions.numD36,
                              child: Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 5),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            size.width * AppDimensions.numD15),
                                        child: Image.asset(
                                          "${dummyImagePath}image3.png",
                                          height:
                                              size.width * AppDimensions.numD20,
                                          width:
                                              size.width * AppDimensions.numD20,
                                          fit: BoxFit.cover,
                                        )),
                                  ),
                                  Positioned(
                                    bottom: 2,
                                    right: 10,
                                    child: Container(
                                      padding:
                                          EdgeInsets.all(size.width * 0.005),
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                      child: Icon(
                                        Icons.circle,
                                        color: AppColorTheme.colorOnlineGreen,
                                        size: size.width * AppDimensions.numD03,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Positioned(
                              left: size.width * AppDimensions.numD55,
                              child: Stack(
                                children: [
                                  Container(
                                    height: size.width * AppDimensions.numD20,
                                    width: size.width * AppDimensions.numD20,
                                    padding: EdgeInsets.all(
                                        size.width * AppDimensions.numD04),
                                    margin: const EdgeInsets.only(bottom: 5),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey.shade200,
                                              spreadRadius: 2,
                                              blurRadius: 2)
                                        ]),
                                    child:
                                        Image.asset("${iconsPath}ic_dots.png"),
                                  ),
                                  Positioned(
                                    bottom: 2,
                                    right: 10,
                                    child: Container(
                                      padding:
                                          EdgeInsets.all(size.width * 0.005),
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                      child: Icon(
                                        Icons.circle,
                                        color: AppColorTheme.colorOnlineGreen,
                                        size: size.width * AppDimensions.numD03,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "We’d love to hear from you!",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD05,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD01,
                      ),
                      RichText(
                          text: TextSpan(children: [
                        TextSpan(
                          text:
                              "Our helpful teams are available 24x7 to assist, and answer your questions. All communication with us, will remain discreet and secure",
                          style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD034,
                            color: Colors.black,
                            fontWeight:
                                FontWeight.w300, // Set fontWeight to normal
                          ),
                        )
                      ])),
                      SizedBox(
                        height: size.width * AppDimensions.numD03,
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'Please fill out the form to start an instant chat with one of our experienced team members. You can also send us an email. Meanwhile, please check our ',
                              style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD033,
                                color: Colors.black,
                                fontWeight:
                                    FontWeight.w300, // Set fontWeight to normal
                              ),
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: InkWell(
                                onTap: () {
                                  context.pushNamed(
                                    AppRoutes.faqName,
                                    extra: {
                                      'priceTipsSelected': false,
                                      'type': 'faq',
                                      'index': 0,
                                    },
                                  );
                                },
                                child: Text(
                                  "${AppStrings.faqText}, ",
                                  style: commonTextStyle(
                                    size: size,
                                    fontSize:
                                        size.width * AppDimensions.numD033,
                                    color: AppColorTheme.colorThemePink,
                                    fontWeight: FontWeight
                                        .w500, // Set fontWeight to the desired value
                                  ),
                                ),
                              ),
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: InkWell(
                                onTap: () {
                                  context.pushNamed(
                                    AppRoutes.faqName,
                                    extra: {
                                      'priceTipsSelected': true,
                                      'type': '',
                                      'index': 0,
                                    },
                                  );
                                },
                                child: Text(
                                  "${AppStrings.priceTipsText.toLowerCase()} ",
                                  style: commonTextStyle(
                                    size: size,
                                    fontSize:
                                        size.width * AppDimensions.numD033,
                                    color: AppColorTheme.colorThemePink,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            TextSpan(
                              text: "${AppStrings.andText} ",
                              style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD032,
                                color: Colors.black,
                                fontWeight:
                                    FontWeight.w300, // Set fontWeight to normal
                              ),
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: InkWell(
                                onTap: () {
                                  context.pushNamed(AppRoutes.tutorialsName);
                                },
                                child: Text(
                                  "${AppStrings.tutorialsText.toLowerCase()} ",
                                  style: commonTextStyle(
                                    size: size,
                                    fontSize:
                                        size.width * AppDimensions.numD033,
                                    color: AppColorTheme.colorThemePink,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            TextSpan(
                              text: "for answers to common queries.",
                              style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD032,
                                color: Colors.black,
                                fontWeight:
                                    FontWeight.w300, // Set fontWeight to normal
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD06,
                      ),
                      Text(AppStrings.nameText.toTitleCase(),
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD033,
                              color: Colors.black,
                              fontWeight: FontWeight.normal)),
                      SizedBox(
                        height: size.width * AppDimensions.numD02,
                      ),
                      CommonTextField(
                        size: size,
                        maxLines: 1,
                        textInputFormatters: null,
                        borderColor: AppColorTheme.colorTextFieldBorder,
                        controller: nameController,
                        hintText: "Enter name",
                        prefixIcon: null,
                        prefixIconHeight: size.width * AppDimensions.numD06,
                        suffixIconIconHeight: 0,
                        suffixIcon: null,
                        hidePassword: false,
                        keyboardType: TextInputType.text,
                        validator: checkRequiredValidator,
                        enableValidations: true,
                        autofocus: false,
                        filled: false,
                        filledColor: AppColorTheme.colorLightGrey,
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD06,
                      ),
                      Text(AppStrings.emailAddressText,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.normal)),
                      SizedBox(
                        height: size.width * AppDimensions.numD02,
                      ),
                      CommonTextField(
                        size: size,
                        maxLines: 1,
                        textInputFormatters: null,
                        borderColor: AppColorTheme.colorTextFieldBorder,
                        controller: emailAddressController,
                        hintText: AppStrings.emailAddressHintText,
                        prefixIcon: null,
                        prefixIconHeight: size.width * AppDimensions.numD06,
                        suffixIconIconHeight: 0,
                        suffixIcon: null,
                        hidePassword: false,
                        autofocus: false,
                        keyboardType: TextInputType.emailAddress,
                        validator: checkEmailValidator,
                        enableValidations: true,
                        filled: false,
                        filledColor: AppColorTheme.colorLightGrey,
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD06,
                      ),
                      Text(
                          "${AppStrings.phoneText.toTitleCase()} ${AppStrings.numberText}",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.normal)),
                      SizedBox(
                        height: size.width * AppDimensions.numD02,
                      ),
                      CommonTextField(
                        controller: phoneNumberController,
                        size: size,
                        textInputFormatters: null,
                        borderColor: AppColorTheme.colorTextFieldBorder,
                        hintText: AppStrings.phoneHintText,
                        prefixIcon: null,
                        prefixIconHeight: size.width * AppDimensions.numD06,
                        suffixIconIconHeight: 0,
                        suffixIcon: null,
                        hidePassword: false,
                        autofocus: false,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: false, signed: true),
                        validator: checkRequiredValidator,
                        enableValidations: true,
                        filled: false,
                        filledColor: AppColorTheme.colorLightGrey,
                        maxLines: 5,
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD06,
                      ),
                      Text(AppStrings.messageText.toTitleCase(),
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.normal)),
                      SizedBox(
                        height: size.width * AppDimensions.numD02,
                      ),
                      TextFormField(
                        maxLines: 5,
                        controller: messageController,
                        cursorColor: AppColorTheme.colorTextFieldIcon,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: size.width * AppDimensions.numD032,
                          fontFamily: 'AirbnbCereal_W_Md',
                        ),
                        onChanged: (v) {
                          onTextChanged();
                        },
                        decoration: InputDecoration(
                          counterText: "",
                          fillColor: Colors.white,
                          hintText:
                              "${AppStrings.enterText.toTitleCase()} ${AppStrings.messageText}",
                          hintStyle: TextStyle(
                            color: AppColorTheme.colorHint,
                            fontSize: size.width * AppDimensions.numD035,
                            fontFamily: 'AirbnbCereal_W_Md',
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1,
                                color: AppColorTheme.colorTextFieldBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1,
                                color: AppColorTheme.colorTextFieldBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1,
                                color: AppColorTheme.colorTextFieldBorder),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1,
                                color: AppColorTheme.colorTextFieldBorder),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1,
                                color: AppColorTheme.colorTextFieldBorder),
                          ),
                          prefixIconColor: AppColorTheme.colorTextFieldIcon,
                        ),
                      ),
                      SizedBox(height: size.width * AppDimensions.numD017),
                      messageController.text.isEmpty
                          ? const Text(
                              "Required",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w400),
                            )
                          : Container(),
                      SizedBox(
                        height: size.width * AppDimensions.numD15,
                      ),
                      Container(
                        width: size.width,
                        height: size.width * AppDimensions.numD14,
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * AppDimensions.numD08),
                        child: commonElevatedButton(
                            AppStrings.chatText,
                            size,
                            commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD035,
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                            commonButtonStyle(
                                size, AppColorTheme.colorThemePink), () {
                          if (messageController.text.isNotEmpty) {
                            context.pushNamed(
                              AppRoutes.chatName,
                              extra: {
                                'hideLeading': false,
                                'message': messageController.text.trim(),
                              },
                            );
                          }
                          setState(() {});
                        }),
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD04,
                      ),
                      Container(
                        width: size.width,
                        height: size.width * AppDimensions.numD14,
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * AppDimensions.numD08),
                        child: commonElevatedButton(
                            AppStrings.emailUsText,
                            size,
                            commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD035,
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                            commonButtonStyle(size, Colors.black), () async {
                          if (adminEmail.isEmpty) {
                            showSnackBar(
                                'Error',
                                'Contact email not available, please try again later.',
                                Colors.red);
                            return;
                          }
                          final Uri emailURL = Uri(
                            scheme: 'mailto',
                            path: adminEmail,
                            query:
                                'subject=Please contact me &body=${messageController.text.trim()}',
                          );

                          if (await canLaunchUrl(emailURL)) {
                            launchUrl(emailURL);
                          } else {
                            // Fallback or show error
                            debugPrint("Could not launch email");
                          }
                          setState(() {});
                        }),
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD04,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          AppStrings.orText,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD04,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Follow us to start a conversation",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD03,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                      SizedBox(
                        height: size.width * AppDimensions.numD08,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () async {
                              Uri twitterUrl = Uri.parse(
                                  'https://twitter.com/Presshopuk'); // Replace with the desired Twitter URL
                              if (await canLaunchUrl(twitterUrl)) {
                                await launchUrl(twitterUrl);
                              }
                            },
                            child: Container(
                              height: size.width * AppDimensions.numD1,
                              width: size.width * AppDimensions.numD11,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(
                                      size.width * AppDimensions.numD02)),
                              padding: EdgeInsets.all(
                                  size.width * AppDimensions.numD02),
                              child: Image.asset("${iconsPath}ic_twitter.png"),
                            ),
                          ),
                          SizedBox(
                            width: size.width * AppDimensions.numD04,
                          ),
                          InkWell(
                            onTap: () async {
                              Uri linkedUrl = Uri.parse(
                                  'https://www.linkedin.com/company/presshop/');
                              if (await canLaunchUrl(linkedUrl)) {
                                await launchUrl(linkedUrl);
                              }
                            },
                            child: Container(
                              height: size.width * AppDimensions.numD1,
                              width: size.width * AppDimensions.numD11,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(
                                      size.width * AppDimensions.numD02)),
                              padding: EdgeInsets.all(
                                  size.width * AppDimensions.numD02),
                              child: Image.asset("${iconsPath}ic_linkdin.png"),
                            ),
                          ),
                          SizedBox(
                            width: size.width * AppDimensions.numD04,
                          ),
                          InkWell(
                            onTap: () async {
                              Uri instagramUrl = Uri.parse(
                                  'https://www.instagram.com/presshopuk/'); // Replace with the desired Twitter URL
                              if (await canLaunchUrl(instagramUrl)) {
                                await launchUrl(instagramUrl);
                              }
                            },
                            child: Container(
                              height: size.width * AppDimensions.numD1,
                              width: size.width * AppDimensions.numD11,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(
                                      size.width * AppDimensions.numD02)),
                              padding: EdgeInsets.all(
                                  size.width * AppDimensions.numD02),
                              child:
                                  Image.asset("${iconsPath}ic_instagram.png"),
                            ),
                          ),
                          SizedBox(width: size.width * AppDimensions.numD04),
                          InkWell(
                            onTap: () async {
                              Uri facebookUrl = Uri.parse(
                                  'https://www.facebook.com/presshopuk/'); // Replace with the desired Twitter URL
                              if (await canLaunchUrl(facebookUrl)) {
                                await launchUrl(facebookUrl);
                              }
                            },
                            child: Container(
                              height: size.width * AppDimensions.numD1,
                              width: size.width * AppDimensions.numD11,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(
                                      size.width * AppDimensions.numD02)),
                              padding: EdgeInsets.all(
                                  size.width * AppDimensions.numD02),
                              child: Image.asset("${iconsPath}ic_facebook.png"),
                            ),
                          )
                        ],
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
      ),
    );
  }
}
