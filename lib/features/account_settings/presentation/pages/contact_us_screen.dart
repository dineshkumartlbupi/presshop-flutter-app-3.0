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
import 'package:presshop/features/dashboard/presentation/pages/Dashboard.dart';
import 'faq_screen.dart';
import '../../../../features/publish/presentation/pages/TutorialsScreen.dart';

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

  initialData() {
    nameController.text =
        "${sharedPreferences!.get(firstNameKey).toString()} ${sharedPreferences!.get(lastNameKey).toString()}";
    phoneNumberController.text = sharedPreferences!.get(phoneKey).toString();
    emailAddressController.text = sharedPreferences!.get(emailKey).toString();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => sl<AccountSettingsBloc>()..add(const GetAdminContactInfoEvent()),
      child: BlocListener<AccountSettingsBloc, AccountSettingsState>(
        listener: (context, state) {
          if (state is AdminContactInfoLoaded) {
            setState(() {
              adminEmail = state.adminContactInfo.email;
            });
          } else if (state is AccountSettingsError) {
            // Optional: Show error or just fail silently since it's just prefetching email
            debugPrint("Failed to load admin contact info: ${state.message}");
          }
        },
        child: Scaffold(
          appBar: CommonAppBar(
            elevation: 0,
            hideLeading: false,
            title: Text(
              "$contactText ${usText.toTitleCase()}",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: size.width * appBarHeadingFontSize,
                  fontWeight: FontWeight.w700),
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Dashboard(initialPosition: 2)));
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
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * numD06),
                child: Form(
                  key: contactUsKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: size.width,
                        height: size.width * numD35,
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
                                            size.width * numD15),
                                        child: Image.asset(
                                          "${dummyImagePath}image1.png",
                                          height: size.width * numD20,
                                          width: size.width * numD20,
                                          fit: BoxFit.cover,
                                        )),
                                  ),
                                  Positioned(
                                    bottom: 2,
                                    right: 10,
                                    child: Container(
                                      padding: EdgeInsets.all(size.width * 0.005),
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                      child: Icon(
                                        Icons.circle,
                                        color: colorOnlineGreen,
                                        size: size.width * numD03,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Positioned(
                              left: size.width * numD18,
                              child: Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 5),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            size.width * numD15),
                                        child: Image.asset(
                                          "${dummyImagePath}image2.png",
                                          height: size.width * numD20,
                                          width: size.width * numD20,
                                          fit: BoxFit.cover,
                                        )),
                                  ),
                                  Positioned(
                                    bottom: 2,
                                    right: 10,
                                    child: Container(
                                      padding: EdgeInsets.all(size.width * 0.005),
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                      child: Icon(
                                        Icons.circle,
                                        color: colorOnlineGreen,
                                        size: size.width * numD03,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Positioned(
                              left: size.width * numD36,
                              child: Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 5),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            size.width * numD15),
                                        child: Image.asset(
                                          "${dummyImagePath}image3.png",
                                          height: size.width * numD20,
                                          width: size.width * numD20,
                                          fit: BoxFit.cover,
                                        )),
                                  ),
                                  Positioned(
                                    bottom: 2,
                                    right: 10,
                                    child: Container(
                                      padding: EdgeInsets.all(size.width * 0.005),
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                      child: Icon(
                                        Icons.circle,
                                        color: colorOnlineGreen,
                                        size: size.width * numD03,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Positioned(
                              left: size.width * numD55,
                              child: Stack(
                                children: [
                                  Container(
                                    height: size.width * numD20,
                                    width: size.width * numD20,
                                    padding: EdgeInsets.all(size.width * numD04),
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
                                    child: Image.asset("${iconsPath}ic_dots.png"),
                                  ),
                                  Positioned(
                                    bottom: 2,
                                    right: 10,
                                    child: Container(
                                      padding: EdgeInsets.all(size.width * 0.005),
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white),
                                      child: Icon(
                                        Icons.circle,
                                        color: colorOnlineGreen,
                                        size: size.width * numD03,
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
                            fontSize: size.width * numD05,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: size.width * numD01,
                      ),
                      RichText(
                          text: TextSpan(children: [
                        TextSpan(
                          text:
                              "Our helpful teams are available 24x7 to assist, and answer your questions. All communication with us, will remain discreet and secure",
                          style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD034,
                            color: Colors.black,
                            fontWeight: FontWeight.w300, // Set fontWeight to normal
                          ),
                        )
                      ])),
                      SizedBox(
                        height: size.width * numD03,
                      ),
    
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'Please fill out the form to start an instant chat with one of our experienced team members. You can also send us an email. Meanwhile, please check our ',
                              style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD033,
                                color: Colors.black,
                                fontWeight:
                                    FontWeight.w300, // Set fontWeight to normal
                              ),
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => FAQScreen(
                                      priceTipsSelected: false,
                                      type: 'faq',
                                      index: 0,
                                    ),
                                  ));
                                },
                                child: Text(
                                  "$faqText, ",
                                  style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD033,
                                    color: colorThemePink,
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
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => FAQScreen(
                                      priceTipsSelected: true,
                                      type: '',
                                      index: 0,
                                    ),
                                  ));
                                },
                                child: Text(
                                  "${priceTipsText.toLowerCase()} ",
                                  style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD033,
                                    color: colorThemePink,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            TextSpan(
                              text: "$andText ",
                              style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD032,
                                color: Colors.black,
                                fontWeight:
                                    FontWeight.w300, // Set fontWeight to normal
                              ),
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const TutorialsScreen(),
                                  ));
                                },
                                child: Text(
                                  "${tutorialsText.toLowerCase()} ",
                                  style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD033,
                                    color: colorThemePink,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            TextSpan(
                              text: "for answers to common queries.",
                              style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD032,
                                color: Colors.black,
                                fontWeight:
                                    FontWeight.w300, // Set fontWeight to normal
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: size.width * numD06,
                      ),
                      Text(nameText.toTitleCase(),
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD033,
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
                        controller: nameController,
                        hintText: "Enter name",
                        prefixIcon: null,
                        prefixIconHeight: size.width * numD06,
                        suffixIconIconHeight: 0,
                        suffixIcon: null,
                        hidePassword: false,
                        keyboardType: TextInputType.text,
                        validator: checkRequiredValidator,
                        enableValidations: true,
                        autofocus: false,
                        filled: false,
                        filledColor: colorLightGrey,
                      ),
                      SizedBox(
                        height: size.width * numD06,
                      ),
                      Text(emailAddressText,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
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
                        controller: emailAddressController,
                        hintText: emailAddressHintText,
                        prefixIcon: null,
                        prefixIconHeight: size.width * numD06,
                        suffixIconIconHeight: 0,
                        suffixIcon: null,
                        hidePassword: false,
                        autofocus: false,
                        keyboardType: TextInputType.emailAddress,
                        validator: checkEmailValidator,
                        enableValidations: true,
                        filled: false,
                        filledColor: colorLightGrey,
                      ),
                      SizedBox(
                        height: size.width * numD06,
                      ),
                      Text("${phoneText.toTitleCase()} $numberText",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.normal)),
                      SizedBox(
                        height: size.width * numD02,
                      ),
                      CommonTextField(
                        controller: phoneNumberController,
                        size: size,
                        textInputFormatters: null,
                        borderColor: colorTextFieldBorder,
                        hintText: phoneHintText,
                        prefixIcon: null,
                        prefixIconHeight: size.width * numD06,
                        suffixIconIconHeight: 0,
                        suffixIcon: null,
                        hidePassword: false,
                        autofocus: false,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: false, signed: true),
                        validator: checkRequiredValidator,
                        enableValidations: true,
                        filled: false,
                        filledColor: colorLightGrey,
                        maxLines: 5,
                      ),
                      SizedBox(
                        height: size.width * numD06,
                      ),
                      Text(messageText.toTitleCase(),
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.normal)),
                      SizedBox(
                        height: size.width * numD02,
                      ),
                      TextFormField(
                        maxLines: 5,
                        controller: messageController,
                        cursorColor: colorTextFieldIcon,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: size.width * numD032,
                          fontFamily: 'AirbnbCereal_W_Md',
                        ),
                        onChanged: (v) {
                          onTextChanged();
                        },
                        decoration: InputDecoration(
                          counterText: "",
                          fillColor: Colors.white,
                          hintText: "${enterText.toTitleCase()} $messageText",
                          hintStyle: TextStyle(
                            color: colorHint,
                            fontSize: size.width * numD035,
                            fontFamily: 'AirbnbCereal_W_Md',
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1, color: colorTextFieldBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1, color: colorTextFieldBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1, color: colorTextFieldBorder),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1, color: colorTextFieldBorder),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(size.width * 0.03),
                            borderSide: const BorderSide(
                                width: 1, color: colorTextFieldBorder),
                          ),
                          prefixIconColor: colorTextFieldIcon,
                        ),
                      ),
                      SizedBox(height: size.width * numD017),
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
                        height: size.width * numD15,
                      ),
                      Container(
                        width: size.width,
                        height: size.width * numD14,
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * numD08),
                        child: commonElevatedButton(
                            chatText,
                            size,
                            commonTextStyle(
                                size: size,
                                fontSize: size.width * numD035,
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                            commonButtonStyle(size, colorThemePink), () {
                          if (messageController.text.isNotEmpty) {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Dashboard(initialPosition: 3)),
                                (route) => false);
                          }
                          setState(() {});
                        }),
                      ),
                      SizedBox(
                        height: size.width * numD04,
                      ),
                      Container(
                        width: size.width,
                        height: size.width * numD14,
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * numD08),
                        child: commonElevatedButton(
                            emailUsText,
                            size,
                            commonTextStyle(
                                size: size,
                                fontSize: size.width * numD035,
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                            commonButtonStyle(size, Colors.black), () async {
                          if (adminEmail.isEmpty) {
                            showSnackBar('Error', 'Contact email not available, please try again later.', Colors.red);
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
                        height: size.width * numD04,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          orText,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD035,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                      SizedBox(
                        height: size.width * numD04,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Follow us to start a conversation",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD03,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                      SizedBox(
                        height: size.width * numD08,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () async {
                              Uri twitterUrl = Uri.parse(
                                  'https://twitter.com/Presshopuk'); // Replace with the desired Twitter URL
                              if (await canLaunchUrl(twitterUrl)) await launchUrl(twitterUrl);
                            },
                            child: Container(
                              height: size.width * numD1,
                              width: size.width * numD11,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius:
                                      BorderRadius.circular(size.width * numD02)),
                              padding: EdgeInsets.all(size.width * numD02),
                              child: Image.asset("${iconsPath}ic_twitter.png"),
                            ),
                          ),
                          SizedBox(
                            width: size.width * numD04,
                          ),
                          InkWell(
                            onTap: () async {
                              Uri linkedUrl = Uri.parse(
                                  'https://www.linkedin.com/company/presshop/');
                              if (await canLaunchUrl(linkedUrl)) await launchUrl(linkedUrl);
                            },
                            child: Container(
                              height: size.width * numD1,
                              width: size.width * numD11,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius:
                                      BorderRadius.circular(size.width * numD02)),
                              padding: EdgeInsets.all(size.width * numD02),
                              child: Image.asset("${iconsPath}ic_linkdin.png"),
                            ),
                          ),
                          SizedBox(
                            width: size.width * numD04,
                          ),
                          InkWell(
                            onTap: () async {
                              Uri instagramUrl = Uri.parse(
                                  'https://www.instagram.com/presshopuk/'); // Replace with the desired Twitter URL
                              if (await canLaunchUrl(instagramUrl)) await launchUrl(instagramUrl);
                            },
                            child: Container(
                              height: size.width * numD1,
                              width: size.width * numD11,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius:
                                      BorderRadius.circular(size.width * numD02)),
                              padding: EdgeInsets.all(size.width * numD02),
                              child: Image.asset("${iconsPath}ic_instagram.png"),
                            ),
                          ),
                          SizedBox(width: size.width * numD04),
                          InkWell(
                            onTap: () async {
                              Uri facebookUrl = Uri.parse(
                                  'https://www.facebook.com/presshopuk/'); // Replace with the desired Twitter URL
                              if (await canLaunchUrl(facebookUrl)) await launchUrl(facebookUrl);
                            },
                            child: Container(
                              height: size.width * numD1,
                              width: size.width * numD11,
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius:
                                      BorderRadius.circular(size.width * numD02)),
                              padding: EdgeInsets.all(size.width * numD02),
                              child: Image.asset("${iconsPath}ic_facebook.png"),
                            ),
                          )
                        ],
                      ),
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
      ),
    );
  }
}
