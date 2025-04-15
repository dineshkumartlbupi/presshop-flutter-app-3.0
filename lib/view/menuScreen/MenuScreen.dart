import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:presshop/view/authentication/LoginScreen.dart';
import 'package:presshop/view/authentication/TermCheckScreen.dart';
import 'package:presshop/view/authentication/UploadDocumnetsScreen.dart';
import 'package:presshop/view/bankScreens/MyBanksScreen.dart';
import 'package:presshop/view/menuScreen/ChangePassword.dart';
import 'package:presshop/view/menuScreen/ContactUsScreen.dart';
import 'package:presshop/view/menuScreen/DigitalIdScreen.dart';
import 'package:presshop/view/menuScreen/FAQScreen.dart';
import 'package:presshop/view/menuScreen/MyContentScreen.dart';
import 'package:presshop/view/menuScreen/MyDraftScreen.dart';
import 'package:presshop/view/menuScreen/MyProfile.dart';
import 'package:presshop/view/menuScreen/MyTaskScreen.dart';
import 'package:presshop/view/menuScreen/Notification/MyNotifications.dart';
import 'package:presshop/view/menuScreen/feedScreen/FeedScreen.dart';
import 'package:presshop/view/myEarning/MyEarningScreen.dart';
import 'package:presshop/view/publishContentScreen/TutorialsScreen.dart';
import 'package:presshop/view/ratingReviewsScreen/RatingReviewScreen.dart';

import '../../main.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../chatBotScreen/chatBotScreen.dart';
import 'alertScreen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return MenuScreenState();
  }
}

class MenuScreenState extends State<MenuScreen> implements NetworkResponse {
  List<MenuData> menuList = [];
  int notificationCount = 0;
  String? selectedCurrency="GBP";

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => callNotificationList());
    addMenuData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: size.width * numD08,
            ),
            Text(
              menuText,
              style: commonTextStyle(
                  size: size,
                  fontSize: size.width * numD07,
                  color: Colors.black,
                  fontWeight: FontWeight.w600),
            ),
            Flexible(
              child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * numD06,
                      vertical: size.width * numD06),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        if(menuList[index].name=="Choose currency"){
                          _showCurrencyBottomSheet(context);
                          return;
                        }
                        if (index == (menuList.length - 1)) {
                          logoutDialog(size);
                        } else {
                          debugPrint(
                              "value of navigation ===> ${menuList[index].name}");

                          /* if (index == 5) {
                            Fluttertoast.showToast(
                              msg: "Launching soon",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: lightGrey,
                              textColor: Colors.black,
                              fontSize: 16.0,
                            );
                          } else {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) =>
                                        menuList[index].classWidget))
                                .then((value) => {callNotificationList()});
                          }*/

                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) =>
                                      menuList[index].classWidget))
                              .then((value) => {callNotificationList()});
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: menuList[index].name == notificationText
                                ? size.width * numD01
                                : size.width * numD02),
                        child: Row(
                          children: [
                            menuList[index].name == notificationText
                                ? SizedBox(
                                    width: size.width * numD075,
                                    height: size.width * numD075,
                                    child: Stack(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          height: size.width * numD06,
                                          width: size.width * numD06,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black,
                                                  width: 1.2),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      size.width * numD015)),
                                        ),
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(
                                                    size.width * 0.002),
                                                decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle),
                                                child: Icon(
                                                  Icons.circle,
                                                  color: colorThemePink,
                                                  size: size.width * numD04,
                                                ),
                                              ),
                                              Text(
                                                notificationCount.toString(),
                                                style: commonTextStyle(
                                                    size: size,
                                                    fontSize:
                                                        size.width * numD025,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w500),
                                                textAlign: TextAlign.center,
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                : Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      menuList[index].name == "Alerts"  || menuList[index].name == "Choose currency" ?  ImageIcon(
                                        AssetImage(menuList[index].icon),
                                        size: size.width * numD072,
                                        color: Colors.black,
                                      ): ImageIcon(
                                        AssetImage(menuList[index].icon),
                                        size: size.width * numD06,
                                        color: Colors.black,
                                      ),
                                      menuList[index].name == "Alerts"
                                          ? Container(
                                              margin: EdgeInsets.only(
                                                  top: size.width * numD004),
                                              child: CircleAvatar(
                                                  backgroundColor:
                                                      colorThemePink,
                                                  radius: size.width * numD016,
                                                  child: FittedBox(
                                                    child: Padding(
                                                      padding: EdgeInsets.all(
                                                          size.width * numD004),
                                                      child: Text(
                                                        "3",
                                                        style: commonTextStyle(
                                                            size: size,
                                                            fontSize:
                                                                size.width *
                                                                    numD019,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  )),
                                            )
                                          : Container(),
                                    ],
                                  ),
                            SizedBox(
                              width: menuList[index].name == notificationText
                                  ? size.width * numD015
                                  : size.width * numD03,
                            ),
                            menuList[index].name == "$contactText PressHop"  // (client asked to lower case)
                                ? Row(
                                    children: [
                                      Text("Contact Press"
                                        /*"Contact PRESS"*/, //client demand lowercase
                                        style: TextStyle(
                                            fontSize: size.width * numD035,
                                            color: Colors.black,
                                            fontFamily: "AirbnbCereal",
                                            fontWeight: FontWeight.normal),
                                      ),
                                      Text("Hop",
                                        // "HOP",  // client asked to lowercase
                                        style: TextStyle(
                                            fontSize: size.width * numD035,
                                            color: Colors.black,
                                            letterSpacing: 0,
                                            fontFamily: "AirbnbCereal",
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  )
                                : Text(
                                    menuList[index].name,
                                    style: TextStyle(
                                        fontSize: size.width * numD035,
                                        color: Colors.black,
                                        fontFamily: "AirbnbCereal",
                                        fontWeight: FontWeight.normal),
                                  ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.black,
                              size: size.width * numD04,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider(
                      thickness: 2,
                      color: colorLightGrey,
                    );
                  },
                  itemCount: menuList.length),
            ),
          ],
        ),
      ),
    );
  }

  void addMenuData() {
    // menuList.add(MenuData(
    //     name: "Chat Bot",
    //     icon: "${iconsPath}ic_logout.png",
    //     classWidget: const ChatBotScreen()));
    menuList.add(MenuData(
        name: digitalIdText,
        icon: "${iconsPath}ic_id.png",
        classWidget: const DigitalIdScreen()));
    menuList.add(MenuData(
        name: myProfileText,
        icon: "${iconsPath}ic_my_profile.png",
        classWidget: MyProfile(
          editProfileScreen: false,
          screenType: myProfileText,
        )));
    menuList.add(MenuData(
        name: editProfileText,
        icon: "${iconsPath}ic_edit_profile.png",
        classWidget: MyProfile(
          editProfileScreen: true,
          screenType: editProfileText,
        )));
    menuList.add(MenuData(
        name: myDraftText,
        icon: "${iconsPath}ic_my_draft.png",
        classWidget: MyDraftScreen(
          publishedContent: false,
          screenType: '',
        )));
    menuList.add(MenuData(
        name: myContentText,
        icon: "${iconsPath}ic_content.png",
        classWidget: MyContentScreen(
          hideLeading: false,
        )));
    menuList.add(MenuData(
        name: "My tasks",
        icon: "${iconsPath}ic_task.png",
        classWidget: MyTaskScreen(hideLeading: false)));
    menuList.add(MenuData(
        name: "My earnings",
        icon: "${iconsPath}ic_earning.png",
        classWidget: MyEarningScreen(
          openDashboard: false,
        )));
    menuList.add(MenuData(
        name: paymentMethodText,
        icon: "${iconsPath}ic_payment_method.png",
        classWidget: const MyBanksScreen()));
    menuList.add(MenuData(
        name: chooseCurrencyText,
        icon: "${iconsPath}choose_currency.png",
        classWidget: const MyBanksScreen()));
    menuList.add(MenuData(
        name: "Alerts",
        icon: "${iconsPath}ic_alert.png",
        classWidget: const AlertScreen()));
    menuList.add(MenuData(
        name: notificationText,
        icon: "${iconsPath}ic_feed.png",
        classWidget: MyNotificationScreen(count: notificationCount)));

    menuList.add(MenuData(
        name: feedText,
        icon: "${iconsPath}ic_feed.png",
        classWidget: FeedScreen()));

    menuList.add(MenuData(
        name: "$ratingText & ${reviewText.toLowerCase()}",
        icon: "${iconsPath}ic_rating_review.png",
        classWidget: const RatingReviewScreen()));
    menuList.add(MenuData(
        name: uploadDocsHeadingText,
        icon: "${iconsPath}ic_upload_documents.png",
        classWidget: const UploadDocumentsScreen(
          menuScreen: true,
          hideLeading: false,
        )));
    menuList.add(MenuData(
        name: "$legalText $tcText",
        icon: "${iconsPath}ic_legal.png",
        classWidget: TermCheckScreen(
          type: 'legal',
        )));
    menuList.add(MenuData(
        name: "Privacy policy",
        icon: "${iconsPath}ic_privacy.png",
        classWidget: TermCheckScreen(
          type: 'privacy_policy',
        )));

    menuList.add(MenuData(
        name: faqText,
        icon: "${iconsPath}ic_faq.png",
        classWidget: FAQScreen(
          priceTipsSelected: false,
          type: 'faq',
          index: 0,
        )));

    menuList.add(MenuData(
        name: "Price tips",
        icon: "${iconsPath}ic_price_tips.png",
        classWidget: FAQScreen(
          priceTipsSelected: true,
          type: 'price_tips',
          index: 0,
        )));
    menuList.add(MenuData(
        name: tutorialsText,
        icon: "${iconsPath}ic_tutorials.png",
        classWidget: const TutorialsScreen()));
    menuList.add(MenuData(
        name: changePasswordText,
        icon: "${iconsPath}ic_change_password.png",
        classWidget: const ChangePasswordScreen()));
    menuList.add(MenuData(
        name: "$contactText PressHop",   //client asked to lower case
        icon: "${iconsPath}ic_contact_us.png",
        classWidget: const ContactUsScreen()));
    menuList.add(MenuData(
        name: logoutText,
        icon: "${iconsPath}ic_logout.png",
        classWidget: const LoginScreen()));


  }

  void logoutDialog(Size size) {
    showDialog(
        context: navigatorKey.currentState!.context,
        builder: (BuildContext context) {
          return AlertDialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              contentPadding: EdgeInsets.zero,
              insetPadding:
                  EdgeInsets.symmetric(horizontal: size.width * numD04),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(size.width * numD045)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: size.width * numD04),
                          child: Row(
                            children: [
                              Text(
                                youWIllBeMissedText,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: size.width * numD05,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    //  https://developers.promaticstechnologies.com:5019/hopper/stripeStatus?status=0&id=64b0d3be5d37c40ad2370f18
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.black,
                                    size: size.width * numD06,
                                  ))
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * numD04),
                          child: const Divider(
                            color: Colors.black,
                            thickness: 0.5,
                          ),
                        ),
                        SizedBox(
                          height: size.width * numD02,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * numD04),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD04),
                                    border: Border.all(color: Colors.black)),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD04),
                                    child: Image.asset(
                                      "${commonImagePath}tea.png",
                                      height: size.width * numD30,
                                      width: size.width * numD35,
                                      fit: BoxFit.cover,
                                    )),
                              ),
                              SizedBox(
                                width: size.width * numD04,
                              ),
                              Expanded(
                                child: Text(
                                  logoutMessageText,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: size.width * numD035,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: size.width * numD02,
                        ),
                        SizedBox(
                          height: size.width * numD02,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * numD04,
                              vertical: size.width * numD04),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                  child: SizedBox(
                                height: size.width * numD12,
                                child: commonElevatedButton(
                                    logoutText,
                                    size,
                                    commonButtonTextStyle(size),
                                    commonButtonStyle(size, Colors.black), () {
                                  Navigator.pop(context);
                                  callRemoveDeviceApi();
                                }),
                              )),
                              SizedBox(
                                width: size.width * numD04,
                              ),
                              Expanded(
                                  child: SizedBox(
                                height: size.width * numD12,
                                child: commonElevatedButton(
                                    stayLoggedInText,
                                    size,
                                    commonButtonTextStyle(size),
                                    commonButtonStyle(size, colorThemePink),
                                    () async {
                                  Navigator.pop(context);
                                }),
                              )),
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

  void onBoardingDialog(Size size) {
    showDialog(
        context: navigatorKey.currentState!.context,
        builder: (BuildContext context) {
          return AlertDialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              contentPadding: EdgeInsets.zero,
              insetPadding:
                  EdgeInsets.symmetric(horizontal: size.width * numD04),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(size.width * numD045)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: size.width * numD04),
                          child: Row(
                            children: [
                              Text(
                                youWIllBeMissedText,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: size.width * numD05,
                                    fontWeight: FontWeight.bold),
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
                                  ))
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * numD04),
                          child: const Divider(
                            color: Colors.black,
                            thickness: 0.5,
                          ),
                        ),
                        SizedBox(
                          height: size.width * numD02,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * numD04),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD04),
                                    border: Border.all(color: Colors.black)),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD04),
                                    child: Image.asset(
                                      "${commonImagePath}tea.png",
                                      height: size.width * numD30,
                                      width: size.width * numD35,
                                      fit: BoxFit.cover,
                                    )),
                              ),
                              SizedBox(
                                width: size.width * numD04,
                              ),
                              Expanded(
                                child: Text(
                                  logoutMessageText,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: size.width * numD035,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: size.width * numD02,
                        ),
                        SizedBox(
                          height: size.width * numD02,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * numD04,
                              vertical: size.width * numD04),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                  child: SizedBox(
                                height: size.width * numD12,
                                child: commonElevatedButton(
                                    logoutText,
                                    size,
                                    commonButtonTextStyle(size),
                                    commonButtonStyle(size, Colors.black), () {
                                  Navigator.pop(context);
                                  callRemoveDeviceApi();
                                }),
                              )),
                              SizedBox(
                                width: size.width * numD04,
                              ),
                              Expanded(
                                  child: SizedBox(
                                height: size.width * numD12,
                                child: commonElevatedButton(
                                    stayLoggedInText,
                                    size,
                                    commonButtonTextStyle(size),
                                    commonButtonStyle(size, colorThemePink),
                                    () async {
                                  Navigator.pop(context);
                                }),
                              )),
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

  /// Api Section
  callNotificationList() {
    NetworkClass("$notificationListAPI?limit=10&offset=0", this,
            reqNotificationListAPI)
        .callRequestServiceHeader(false, 'get', null);
  }

  /// remove Device
  void callRemoveDeviceApi() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId = "";
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      debugPrint('Running on ${androidInfo.id}');
      deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      debugPrint('Running on ${iosInfo.identifierForVendor}');
      deviceId = iosInfo.identifierForVendor ?? "";
    }
    Map<String, String> map = {
      "device_id": deviceId,
    };
    NetworkClass.fromNetworkClass(removeDeviceUrl, this, removeDeviceReq, map)
        .callRequestServiceHeader(true, 'post', null);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case reqNotificationListAPI:
          debugPrint("Error response===> ${jsonDecode(response)}");
          break;

        /// Remove Device Api
        case removeDeviceReq:
          var data = jsonDecode(response);
          debugPrint("removeDeviceReq-Error: $data");
          if (data["errors"] != null) {
            SnackBar(
              content:
                  Text(data["errors"]["msg"].toString().replaceAll("_", " ")),
            );
          } else {
            SnackBar(
              content: Text(data["errors"].toString()),
            );
          }
          break;
      }
    } on Exception catch (e) {
      debugPrint('exception catch====> $e');
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case reqNotificationListAPI:
          debugPrint("success response===> ${jsonDecode(response)}");

          var data = jsonDecode(response);
          var dataList = data['readCount'];
          debugPrint("dataList:::: $dataList");
          notificationCount = data['unreadCount'] ?? 0;

          if (mounted) {
            setState(() {});
          }
          break;

        /// Remove Device Api
        case removeDeviceReq:
          var data = jsonDecode(response);
          debugPrint("removeDeviceReq-Success: $data");
          rememberMe = false;
          debugPrint("rememberMe: $rememberMe");
          sharedPreferences!.clear();
          googleSignIn.signOut();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false);
          break;
      }
    } on Exception catch (e) {
      debugPrint('exception catch====> $e');
    }
  }

  void _showCurrencyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Choose Currency",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Divider(),
                  Column(
                    children: [
                      _buildCurrencyRow("AUD", "\$", setState),
                      _buildCurrencyRow("INR", "₹", setState),
                      _buildCurrencyRow("GBP", "£", setState),
                      _buildCurrencyRow("USD", "\$", setState),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCurrencyRow(String currency, String symbol, Function setState) {
    bool isSelected = selectedCurrency == currency;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCurrency = currency;
        });
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        margin: EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          color: isSelected ? colorGreyChat : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          "$currency ($symbol)",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isSelected ? colorThemePink : Colors.black,
          ),
        ),
      ),
    );
  }

}

class MenuData {
  String icon = "";
  String name = "";
  Widget classWidget;

  MenuData({required this.name, required this.icon, required this.classWidget});
}
