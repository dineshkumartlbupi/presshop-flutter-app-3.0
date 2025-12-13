
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/features/account_settings/presentation/pages/account_settings.dart';
import 'package:presshop/features/authentication/presentation/pages/LoginScreen.dart';
import 'package:presshop/features/authentication/presentation/pages/TermCheckScreen.dart';
import 'package:presshop/features/authentication/presentation/pages/UploadDocumnetsScreen.dart';
import 'package:presshop/features/bank/presentation/pages/my_banks_page.dart';
import 'package:presshop/features/chat/presentation/pages/ChatCopy.dart';
import 'package:presshop/features/leaderboard/presentation/pages/leaderboard_page.dart';
import 'package:presshop/features/account_settings/presentation/pages/change_password_screen.dart';
import 'package:presshop/features/account_settings/presentation/pages/contact_us_screen.dart';
import 'package:presshop/features/profile/presentation/pages/DigitalIdScreen.dart';
import 'package:presshop/features/account_settings/presentation/pages/faq_screen.dart';
import 'package:presshop/features/content/presentation/pages/my_content_page.dart';
import 'package:presshop/features/content/presentation/pages/my_draft_screen.dart';
import 'package:presshop/features/profile/presentation/pages/my_profile_screen.dart';
import 'package:presshop/features/task/presentation/pages/my_task_screen.dart';
import 'package:presshop/features/notification/presentation/pages/MyNotifications.dart';
import 'package:presshop/features/earning/presentation/pages/MyEarningScreen.dart';
import 'package:presshop/features/publish/presentation/pages/TutorialsScreen.dart';
import 'package:presshop/features/rating/presentation/pages/RatingReviewScreen.dart';
import 'package:presshop/features/referral/presentation/pages/refer_screen.dart';

import 'package:presshop/main.dart';
import 'package:presshop/core/analytics/analytics_constants.dart';
import 'package:presshop/core/analytics/analytics_mixin.dart';
import 'package:presshop/features/chatbot/presentation/pages/chatBotScreen.dart';
import 'package:presshop/features/menu/presentation/bloc/menu_bloc.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return MenuScreenState();
  }
}

class MenuScreenState extends State<MenuScreen> with AnalyticsPageMixin {
  // Analytics Mixin Requirements
  @override
  String get pageName => PageNames.menu;

  @override
  Map<String, Object>? get pageParameters => {
        'notification_count': _notificationCount.toString(),
        'alert_count': _alertCount.toString(),
      };

  List<MenuData> menuList = [];
  int _notificationCount = 0;
  int _alertCount = 0;
  String? selectedCurrency = "GBP";

  @override
  void initState() {
    addMenuData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MenuBloc>()..add(MenuLoadCounts()),
      child: BlocConsumer<MenuBloc, MenuState>(
        listener: (context, state) {
          if (state.status == MenuStatus.success) {
            setState(() {
              _notificationCount = state.notificationCount;
              _alertCount = state.alertCount;
            });
          }
          if (state.logoutStatus == MenuLogoutStatus.success) {
            _handleLogoutSuccess();
          } else if (state.logoutStatus == MenuLogoutStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? "Logout failed")),
            );
          }
        },
        builder: (context, state) {
          return _buildContent(context, state);
        },
      ),
    );
  }

  void _handleLogoutSuccess() async {
    rememberMe = false;
    sharedPreferences!.clear();
    // Assuming googleSignIn is globally available from main.dart
    try {
      if(await googleSignIn.isSignedIn()){
          googleSignIn.signOut();
      }
    } catch (e) {
      debugPrint("Error signing out google: $e");
    }
    
    if(!mounted) return;
    
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false);
        
    await FirebaseAnalytics.instance.logEvent(
      name: 'device_token_removed',
      parameters: {
        'message': 'Device token removed successfully',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Widget _buildContent(BuildContext context, MenuState state) {
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
                        if (menuList[index].name == "Choose currency") {
                          _showCurrencyBottomSheet(context);
                          return;
                        }
                        if (index == (menuList.length - 1)) {
                          logoutDialog(size, context);
                        } else {
                          debugPrint(
                              "value of navigation ===> ${menuList[index].name}");

                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) =>
                                      menuList[index].classWidget))
                              .then((value) => {
                                // Refresh counts when coming back
                                context.read<MenuBloc>().add(MenuLoadCounts())
                              });
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
                                                state.notificationCount.toString(),
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
                                      menuList[index].name == "Alerts" ||
                                              menuList[index].name ==
                                                  "Choose currency"
                                          ? ImageIcon(
                                              AssetImage(menuList[index].icon),
                                              size: size.width * numD072,
                                              color: Colors.black,
                                            )
                                          : ImageIcon(
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
                                                        "${state.alertCount}",
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
                            menuList[index].name ==
                                    "$contactText PressHop" // (client asked to lower case)
                                ? Row(
                                    children: [
                                      Text(
                                        "Contact Press" /*"Contact PRESS"*/, //client demand lowercase
                                        style: TextStyle(
                                            fontSize: size.width * numD035,
                                            color: Colors.black,
                                            fontFamily: "AirbnbCereal",
                                            fontWeight: FontWeight.normal),
                                      ),
                                      Text(
                                        "Hop",
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
    menuList.add(MenuData(
        name: digitalIdText,
        icon: "${iconsPath}ic_id.png",
        classWidget: const DigitalIdScreen()));
    menuList.add(MenuData(
        name: myProfileText,
        icon: "${iconsPath}ic_my_profile.png",
        classWidget: MyProfile(
          editProfileScreen: true,
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
        name: "Chat",
        icon: "${iconsPath}ic_chat.png",
        classWidget: ChatBotScreen()));

    menuList.add(MenuData(
        name: "$contactText PressHop", //client asked to lower case
        icon: "${iconsPath}ic_contact_us.png",
        classWidget: const ContactUsScreen()));

    menuList.add(MenuData(
        name: leaderboardText,
        icon: "${iconsPath}ic_ranking.png",
        classWidget: const LeaderboardPage()));

    menuList.add(MenuData(
        name: paymentMethodText,
        icon: "${iconsPath}ic_payment_method.png",
        classWidget: const MyBanksPage()));

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
        classWidget: const MyContentPage(
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
          openDashboard: false, initialTapPosition:0,
        )));

    menuList.add(MenuData(
        name: notificationText,
        icon: "${iconsPath}ic_feed.png",
        classWidget: MyNotificationScreen(count: _notificationCount))); 
        // Note: count here is just initial, screen should also be reactive or fetch on its own.
        // MyNotificationScreen was refactored previously to fetch its own data (it accepts count but does it use it? 
        // Previously edited MyNotifications.dart uses GetNotifications.
        // So passing count might be redundant or just for display before load.
        
    menuList.add(MenuData(
        name: "$ratingText & ${reviewText.toLowerCase()}",
        icon: "${iconsPath}ic_rating_review.png",
        classWidget: const RatingReviewScreen()));
    menuList.add(MenuData(
        name: "Refer a Hopper",
        icon: "${iconsPath}gift.png",
        classWidget: const ReferScreen()));
    menuList.add(MenuData(
        name: uploadDocsHeadingText,
        icon: "${iconsPath}ic_upload_documents.png",
        classWidget: const UploadDocumentsScreen(
          menuScreen: true,
          hideLeading: false,
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
        name: accountSettingText,
        icon: "${iconsPath}ic_my_profile.png",
        classWidget: const AccountSetting()));
    menuList.add(MenuData(
        name: logoutText,
        icon: "${iconsPath}ic_logout.png",
        classWidget: const LoginScreen()));
  }

  void logoutDialog(Size size, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) { 
          // Use dialogContext or just context inside builder
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
                                      "assets/rabbits/logout_rabbit.png",
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
                                  Navigator.pop(context); // Close dialog
                                  // Call logout on BLoC
                                  context.read<MenuBloc>().add(MenuLogoutRequested());
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
                      _buildCurrencyRow("GBP", currencySymbol, setState),
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
