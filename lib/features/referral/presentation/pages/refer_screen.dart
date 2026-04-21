import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:presshop/core/constants/string_constants.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/core_export.dart';
import 'package:share_plus/share_plus.dart';

import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/di/injection_container.dart' as di;

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

  // Dynamic data
  String _referralCode = "";
  int _totalHopperArmy = 0;
  bool _isLoadingProfile = true;
  String _referralCurrency = "£";

  // Representative amounts for referral visualization
  double _friendsEarnAmount = 100.0;
  double _youEarnAmount = 5.0;

  @override
  void initState() {
    super.initState();
    // Initialize with cached values first
    _referralCode =
        sharedPreferences!.getString(SharedPreferencesKeys.referralCode) ?? "";
    _totalHopperArmy = int.tryParse(sharedPreferences!
                .getString(SharedPreferencesKeys.totalHopperArmy) ??
            "0") ??
        0;

    _friendsEarnAmount = sharedPreferences!
            .getDouble(SharedPreferencesKeys.referralFriendEarningKey) ??
        10.0;
    _youEarnAmount = sharedPreferences!
            .getDouble(SharedPreferencesKeys.referralUserEarningKey) ??
        15.0;

    _referralCurrency = sharedPreferences!
            .getString(SharedPreferencesKeys.referralCurrencyKey) ??
        currencySymbol;

    // Then fetch fresh data from API
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final apiClient = di.sl<ApiClient>();
      final response = await apiClient.get(
        ApiConstantsNew.profile.myProfile,
        showLoader: false,
      );

      final data = response.data;
      final userData = data['data'] ?? data['userData'] ?? data;
      final profileData = userData is Map && userData.containsKey('data')
          ? userData['data']
          : userData;

      if (mounted) {
        setState(() {
          _referralCode = profileData['referral_code']?.toString() ??
              profileData['referralCode']?.toString() ??
              _referralCode;
          _totalHopperArmy = profileData['totalHopperArmy'] ?? _totalHopperArmy;
          _isLoadingProfile = false;
        });

        // Update SharedPreferences with fresh data
        sharedPreferences!
            .setString(SharedPreferencesKeys.referralCode, _referralCode);
        sharedPreferences!.setString(
            SharedPreferencesKeys.totalHopperArmy, _totalHopperArmy.toString());
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(
          "Refer a Hopper",
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
              context.goNamed(AppRoutes.dashboardName,
                  extra: {'initialPosition': 2});
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
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _isLoadingProfile = true;
            });
            await _fetchProfileData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(size.width * AppDimensions.numD04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Hoppers unite — let's grow the army",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD048,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD06,
                  ),
                  RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(children: [
                        TextSpan(
                          text:
                              "Invite your friends, colleagues and family members to join ",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD03,
                              color: Colors.black,
                              lineHeight: 2,
                              fontWeight: FontWeight.normal),
                        ),
                        TextSpan(
                          text: "PressHop®",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD03,
                              color: Colors.black,
                              lineHeight: 2,
                              fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              " and get 5% of everything they earn — every month, for as long as they're active. It's simple. Click the names below and send an invitation link instantly.\n\n",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD03,
                              color: Colors.black,
                              lineHeight: 2,
                              fontWeight: FontWeight.normal),
                        ),
                        TextSpan(
                          text:
                              "Everyone you invite will be linked to you with a unique code — so both you and we can track your Hopper Army's sales and your monthly earnings with ease!",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD03,
                              color: Colors.black,
                              lineHeight: 2,
                              fontWeight: FontWeight.normal),
                        ),
                      ])),
                  SizedBox(
                    height: size.height * AppDimensions.numD04,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: size.width * AppDimensions.numD03,
                        right: size.width * AppDimensions.numD03),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text("Your Friends Earn",
                                    textAlign: TextAlign.center,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD04,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                                // ClipRRect(
                                //   borderRadius: BorderRadius.circular(
                                //       size.width * AppDimensions.numD06),
                                //   child: Image.asset(
                                //     "${iconsPath}amount_100.png",
                                //     height: size.width * AppDimensions.numD40,
                                //     width: size.width * AppDimensions.numD40,
                                //   ),
                                // ),

                                SizedBox(
                                    height: size.width * AppDimensions.numD04),
                                _Referral3DCard(
                                  amount: _friendsEarnAmount,
                                  size: size,
                                  currency: _referralCurrency,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text("You Earn",
                                    textAlign: TextAlign.center,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD04,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                                // ClipRRect(
                                //   borderRadius: BorderRadius.circular(
                                //       size.width * AppDimensions.numD06),
                                //   child: Image.asset(
                                //     "${iconsPath}amount_5.png",
                                //     height: size.width * AppDimensions.numD40,
                                //     width: size.width * AppDimensions.numD40,
                                //   ),
                                // ),
                                SizedBox(
                                    height: size.width * AppDimensions.numD04),
                                _Referral3DCard(
                                  amount: _youEarnAmount,
                                  size: size,
                                  isYouEarn: true,
                                  currency: _referralCurrency,
                                ),
                              ],
                            ),
                          )
                        ]),
                  ),
                  SizedBox(
                    height: size.height * AppDimensions.numD03,
                  ),

                  /// Referral Code Box
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: AppColorTheme.colorGrey6),
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(
                              size.width * AppDimensions.numD03)),
                      padding: EdgeInsets.only(
                          left: size.width * AppDimensions.numD05,
                          right: size.width * AppDimensions.numD05,
                          top: size.width * AppDimensions.numD035,
                          bottom: size.width * AppDimensions.numD035),
                      margin: EdgeInsets.only(
                          left: size.width * AppDimensions.numD03,
                          right: size.width * AppDimensions.numD03),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text(_referralCode,
                                  overflow: TextOverflow.ellipsis,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize:
                                          size.width * AppDimensions.numD044,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold))),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(
                                  ClipboardData(text: _referralCode));
                              showToast("Referral code copied to clipboard");
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.copy,
                                  color: AppColorTheme.colorGrey6,
                                  size: size.width * AppDimensions.numD05,
                                ),
                                Text("Tap to copy",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD035,
                                        color: AppColorTheme.colorGrey6,
                                        fontWeight: FontWeight.w400)),
                              ],
                            ),
                          )
                        ],
                      )),
                  SizedBox(
                    height: size.height * AppDimensions.numD05,
                  ),

                  /// Invite Button
                  Center(
                    child: SizedBox(
                      height: size.width * AppDimensions.numD14,
                      width: size.width * AppDimensions.numD70,
                      child: Builder(builder: (buttonContext) {
                        return commonElevatedButton(
                          "Invite Your Friends",
                          size,
                          commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD035,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                          commonButtonStyle(size, AppColorTheme.colorThemePink),
                          () {
                            final firstName = sharedPreferences?.getString(
                                    SharedPreferencesKeys.firstNameKey) ??
                                "A hopper";
                            final namePart = firstName.isNotEmpty
                                ? firstName.toTitleCase()
                                : "A hopper";
                            var shareText =
                                '$namePart $referInviteText $_referralCode';
                            shareText = shareText.replaceAll(
                                r'$appUrl', 'https://presshop.app');

                            final box =
                                buttonContext.findRenderObject() as RenderBox?;
                            Share.share(
                              shareText,
                              subject: 'Join PressHop!',
                              sharePositionOrigin: box != null
                                  ? box.localToGlobal(Offset.zero) & box.size
                                  : null,
                            );
                          },
                        );
                      }),
                    ),
                  ),
                  SizedBox(
                    height: size.width * AppDimensions.numD05,
                  ),

                  /// Hopper Army Count
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "You have ",
                        style: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD03,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text: _isLoadingProfile
                                ? "..."
                                : "$_totalHopperArmy ",
                            style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD03,
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: _isLoadingProfile
                                ? ""
                                : (_totalHopperArmy == 1
                                    ? "Hopper in your Army."
                                    : "Hoppers in your Army."),
                            style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD03,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "Click here to",
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD03,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                        children: [
                          TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                context.pushNamed(
                                  AppRoutes.myEarningName,
                                  extra: {
                                    'openDashboard': false,
                                    'initialTapPosition': 1,
                                  },
                                );
                              },
                            text: " Track your earnings",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD03,
                                color: AppColorTheme.colorThemePink,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: size.width * AppDimensions.numD06),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Referral3DCard extends StatelessWidget {
  const _Referral3DCard({
    required this.amount,
    required this.size,
    this.isYouEarn = false,
    required this.currency,
  });
  final double amount;
  final Size size;
  final bool isYouEarn;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final amountText =
        amount % 1 == 0 ? amount.toInt().toString() : amount.toStringAsFixed(1);

    return Container(
      height: size.width * AppDimensions.numD40,
      width: size.width * AppDimensions.numD40,
      padding: EdgeInsets.all(size.width * AppDimensions.numD04),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size.width * AppDimensions.numD06),
        gradient: const RadialGradient(
          colors: [
            Color(0xFFFDEB71), // Lighter yellow
            Color(0xFFF8D800), // Vibrant yellow
          ],
          center: Alignment.center,
          radius: 0.8,
        ),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.1),
        //     blurRadius: 10,
        //     spreadRadius: 2,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Rays (Simulated with icons or custom painter if needed, but a simple gradient is often enough)
          Opacity(
            opacity: 0.1,
            child: Icon(
              Icons.wb_sunny_outlined,
              size: size.width * AppDimensions.numD30,
              color: Colors.white,
            ),
          ),

          // 3D Text Effect
          _build3DText(amountText),
        ],
      ),
    );
  }

  Widget _build3DText(String text) {
    const depth = 9;
    const shadowColor = Color(0xFFC0392B); // Dark red for extrusion
    const currencyColor = Color(0xFFE74C3C); // Vibrant red for £

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Extrusion Layers (Shadow Layers)
          for (int i = 1; i <= depth; i++)
            Transform.translate(
              offset: Offset(i.toDouble(), i.toDouble()),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    currency,
                    style: TextStyle(
                      fontSize: size.width * AppDimensions.numD14,
                      fontWeight: FontWeight.w900,
                      color: shadowColor,
                      fontFamily: "AirbnbCereal",
                    ),
                  ),
                  SizedBox(width: size.width * AppDimensions.numD01), // spacing
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: size.width * AppDimensions.numD18,
                      fontWeight: FontWeight.w900,
                      color: shadowColor,
                      fontFamily: "AirbnbCereal",
                    ),
                  ),
                ],
              ),
            ),

          // Main Foreground Layer
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                currency,
                style: TextStyle(
                  fontSize: size.width * AppDimensions.numD14,
                  fontWeight: FontWeight.w900,
                  color: currencyColor,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                  fontFamily: "AirbnbCereal",
                ),
              ),
              SizedBox(width: size.width * AppDimensions.numD01), // spacing
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, Color(0xFFE0E0E0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: size.width * AppDimensions.numD18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                    fontFamily: "AirbnbCereal",
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
