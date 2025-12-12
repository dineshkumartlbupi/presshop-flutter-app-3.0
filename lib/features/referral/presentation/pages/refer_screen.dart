import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import 'package:presshop/core/analytics/analytics_constants.dart';
import 'package:presshop/core/analytics/analytics_mixin.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/features/dashboard/presentation/pages/Dashboard.dart';

class ReferScreen extends StatefulWidget {
  const ReferScreen({super.key});

  @override
  State<ReferScreen> createState() => _ReferScreenState();
}

class _ReferScreenState extends State<ReferScreen> with AnalyticsPageMixin {
  @override
  String get pageName => PageNames.referScreen;

  @override
  Map<String, Object>? get pageParameters => {
        'referral_code': 'your_referral_code',
      };

  @override
  void initState() {
    super.initState();

    // Print referral code when entering this page
    var refCode = sharedPreferences!.getString(referralCode) ?? "";
    print("Referral Code on ReferScreen: $refCode");
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var refrralCode = sharedPreferences!.getString(referralCode) ?? "";
    print("this this this tis");
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(
          "Refer a Hopper",
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
            padding: EdgeInsets.all(size.width * numD04),
            child: (Column(
              children: [
                Center(
                  child: Text(
                    "Hoppers unite — let’s grow the army",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD048,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(
                  height: size.width * numD06,
                ),
                RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(children: [
                      TextSpan(
                        text:
                            "Invite your friends, colleagues and family members to join ",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD03,
                            color: Colors.black,
                            lineHeight: 2,
                            fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: "PressHop",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD03,
                            color: Colors.black,
                            lineHeight: 2,
                            fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            " and get 5% of everything they earn — every month, for as long as they’re active. It's simple. Click the names below and send an invitation link instantly.\n\n",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD03,
                            color: Colors.black,
                            lineHeight: 2,
                            fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text:
                            "Everyone you invite will be linked to you with a unique code — so both you and we can track your Hopper Army’s sales and your monthly earnings with ease!",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD03,
                            color: Colors.black,
                            lineHeight: 2,
                            fontWeight: FontWeight.normal),
                      ),
                    ])),
                SizedBox(
                  height: size.height * numD04,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: size.width * numD03, right: size.width * numD03),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Column(
                          children: [
                            Text("Your Friends Earn",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD04,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(size.width * numD06),
                              child: Image.asset(
                                "${iconsPath}amount_100.png",
                                height: size.width * numD40,
                                width: size.width * numD40,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text("You Earn",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD04,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(size.width * numD06),
                              child: Image.asset(
                                "${iconsPath}amount_5.png",
                                height: size.width * numD40,
                                width: size.width * numD40,
                              ),
                            )
                          ],
                        )
                      ]),
                ),
                SizedBox(
                  height: size.height * numD03,
                ),
                Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: colorGrey6),
                        color: Colors.grey[300],
                        borderRadius:
                            BorderRadius.circular(size.width * numD03)),
                    padding: EdgeInsets.only(
                        left: size.width * numD05,
                        right: size.width * numD05,
                        top: size.width * numD035,
                        bottom: size.width * numD035),
                    margin: EdgeInsets.only(
                        left: size.width * numD03, right: size.width * numD03),
                    child: Row(
                      children: [
                        Text(sharedPreferences!.getString(referralCode) ?? "",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD044,
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                        Spacer(),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: refrralCode));
                            showToast("Referral code copied to clipboard");
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.copy,
                                color: colorGrey6,
                                size: size.width * numD05,
                              ),
                              Text("Tap to copy",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: colorGrey6,
                                      fontWeight: FontWeight.w400)),
                            ],
                          ),
                        )
                      ],
                    )),
                SizedBox(
                  height: size.height * numD05,
                ),
                SizedBox(
                  height: size.width * numD14,
                  width: size.width * numD70,
                  child: commonElevatedButton(
                    "Invite Your Friends",
                    size,
                    commonTextStyle(
                        size: size,
                        fontSize: size.width * numD035,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),
                    commonButtonStyle(size, colorThemePink),
                    () {
                      var shareText =
                          '${sharedPreferences!.getString(firstNameKey)!.toTitleCase()} $referInviteText ${sharedPreferences!.getString(referralCode)}';
                      Share.share(shareText);
                    },
                  ),
                ),
                SizedBox(
                  height: size.width * numD05,
                ),
                RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                        text: "You have ",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD03,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                        children: [
                          TextSpan(
                            text:
                                "${sharedPreferences!.getString(totalHopperArmy)} ",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD03,
                                color: Colors.black,
                                fontWeight: FontWeight.w800),
                          ),
                          TextSpan(
                            text: "Hoppers in your Army.",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD03,
                                color: Colors.black,
                                fontWeight: FontWeight.w400),
                          )
                        ])),
                RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    text: "Click here to",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD03,
                        color: Colors.black,
                        fontWeight: FontWeight.w400),
                    children: [
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => MyEarningScreen(
                                      openDashboard: false,
                                      initialTapPosition: 1,
                                    )));
                          },
                        text: " Track your earnings",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD03,
                            color: colorThemePink,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )
              ],
            )),
          ),
        ),
      ),
    );
  }
}
