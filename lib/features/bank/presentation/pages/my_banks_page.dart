import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/core/utils/shared_preferences.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
// import 'package:presshop/core/widgets/common_web_view.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/features/bank/presentation/bloc/bank_bloc.dart';
import 'package:presshop/features/bank/presentation/bloc/bank_event.dart';
import 'package:presshop/features/bank/presentation/bloc/bank_state.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/core_export.dart';
import 'package:go_router/go_router.dart';
import 'package:presshop/core/router/router_constants.dart';

class MyBanksPage extends StatelessWidget {
  const MyBanksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<BankBloc>()..add(FetchBanksEvent()),
      child: const MyBanksView(),
    );
  }
}

class MyBanksView extends StatefulWidget {
  const MyBanksView({super.key});

  @override
  State<MyBanksView> createState() => _MyBanksViewState();
}

class _MyBanksViewState extends State<MyBanksView> {
  String stripeBankPageTitle = "Add bank";

  void _generateAddBankApi(BuildContext context) {
    context.read<BankBloc>().add(GetStripeUrlEvent());
  }

  // ignore: unused_element
  void _deleteBankDialog(BuildContext context, String id, String stripeBankId) {
    if (stripeBankId.isEmpty) return;

    var size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.symmetric(
              horizontal: size.width * AppDimensions.numD04),
          content: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(size.width * AppDimensions.numD045),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: size.width * AppDimensions.numD02),
                Padding(
                  padding:
                      EdgeInsets.only(left: size.width * AppDimensions.numD04),
                  child: Row(
                    children: [
                      Text(
                        "Delete bank?",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: size.width * AppDimensions.numD05,
                          fontFamily: "AirbnbCereal",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => dialogContext.pop(),
                        icon: Image.asset(
                          "${iconsPath}cross.png",
                          width: size.width * AppDimensions.numD065,
                          height: size.width * AppDimensions.numD065,
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
                const Divider(color: Colors.black, thickness: 0.5),
                SizedBox(height: size.width * AppDimensions.numD02),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * AppDimensions.numD035),
                  child: Text(
                    "Are you sure you wish to delete this bank account?",
                    style: TextStyle(
                      fontSize: size.width * AppDimensions.numD038,
                      color: Colors.black,
                      fontFamily: "AirbnbCereal",
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: size.width * AppDimensions.numD05),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: size.width * AppDimensions.numD035),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: size.width * AppDimensions.numD13,
                          child: commonElevatedButton(
                            "Cancel",
                            size,
                            commonButtonTextStyle(size),
                            commonButtonStyle(size, Colors.black),
                            () => dialogContext.pop(),
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * AppDimensions.numD04),
                      Expanded(
                        child: SizedBox(
                          height: size.width * AppDimensions.numD13,
                          child: commonElevatedButton(
                            "Delete",
                            size,
                            commonButtonTextStyle(size),
                            commonButtonStyle(
                                size, AppColorTheme.colorThemePink),
                            () {
                              dialogContext.pop();
                              context.read<BankBloc>().add(
                                    DeleteBankEvent(
                                      id: id,
                                      stripeBankId: stripeBankId,
                                    ),
                                  );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.width * AppDimensions.numD05),
              ],
            ),
          ),
        );
      },
    );
  }

  // void _selectDefault(BuildContext context, String stripeBankId, bool isDefault) {
  //   context.read<BankBloc>().add(
  //         SetDefaultBankEvent(
  //           stripeBankId: stripeBankId,
  //           isDefault: isDefault,
  //         ),
  //       );
  // }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(
          AppStrings.paymentMethods,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: size.width * AppDimensions.appBarHeadingFontSize,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        size: size,
        showActions: true,
        leadingFxn: () => context.pop(),
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
          SizedBox(width: size.width * AppDimensions.numD04),
        ],
      ),
      body: BlocConsumer<BankBloc, BankState>(
        listener: (context, state) {
          if (state is BankError) {
            showToast(state.message);
          } else if (state is StripeUrlLoaded) {
            context.pushNamed(
              AppRoutes.commonWebViewName,
              extra: {
                'webUrl': state.url,
                'title': stripeBankPageTitle,
                'accountId': "",
                'type': "",
              },
            ).then((value) {
              if (value == true) {
                context.read<BankBloc>().add(FetchBanksEvent());
              }
            });
          }
        },
        builder: (context, state) {
          debugPrint("MyBanksPage: Current State: $state");
          if (state is BanksLoaded) {
            final banks = state.banks;
            return banks.isNotEmpty
                ? _upliftAccountsPaymentDesign(context, size, banks)
                : _upliftNoAccountsPaymentDesign(context, size);
          } else if (state is BankLoading || state is BankInitial) {
            return Center(
              child: showAnimatedLoader(size),
            );
          } else if (state is BankError) {
            return Center(child: Text(state.message));
          } else {
            // Support showing loader for other transient states if no data
            return Center(child: showAnimatedLoader(size));
          }
        },
      ),
    );
  }

  Widget _upliftAccountsPaymentDesign(
      BuildContext context, Size size, List banks) {
    final firstBank = banks.first;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(size.width * AppDimensions.numD05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hi hopper32 ${sharedPreferences!.getString(SharedPreferencesKeys.userNameKey) ?? ''}",
              style: TextStyle(
                color: Colors.black,
                fontSize: size.width * AppDimensions.numD06,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * AppDimensions.numD04),
            Center(
              child: Image.asset("${iconsPath}payment_page_icon_2.png"),
            ),
            SizedBox(height: size.width * AppDimensions.numD02),
            Container(
              decoration: BoxDecoration(
                color: const Color(
                    0xFFF3F4F6), // Very light grey background matching image
                borderRadius:
                    BorderRadius.circular(size.width * AppDimensions.numD03),
                border: Border.all(
                    color: Colors.grey.shade600,
                    width: 0.8), // Distinct thin border
              ),
              padding: EdgeInsets.all(size.width * AppDimensions.numD045),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ready to get paid?",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: size.width * AppDimensions.numD032,
                      fontFamily: "AirbnbCereal",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: size.width * AppDimensions.numD02),
                  // Display the first bank detail
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                          size.width * AppDimensions.numD03),
                      border:
                          Border.all(color: Colors.grey.shade300, width: 0.8),
                    ),
                    padding: EdgeInsets.all(size.width * AppDimensions.numD03),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  size.width * AppDimensions.numD02),
                              child: Image.network(
                                firstBank.bankImage,
                                height: size.width * AppDimensions.numD11,
                                width: size.width * AppDimensions.numD11,
                                fit: BoxFit.contain,
                                errorBuilder: (c, s, o) {
                                  return Container(
                                    height: size.width * AppDimensions.numD11,
                                    width: size.width * AppDimensions.numD11,
                                    decoration: BoxDecoration(
                                      color: AppColorTheme.colorLightGrey,
                                      borderRadius: BorderRadius.circular(
                                          size.width * AppDimensions.numD02),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: size.width * AppDimensions.numD02),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: size.width * 0.25, // Limit width
                                      child: Text(
                                        firstBank.bankName,
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: size.width *
                                              AppDimensions.numD028,
                                          fontFamily: "AirbnbCereal",
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        width:
                                            size.width * AppDimensions.numD01),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey[100],
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        firstBank.currency.toUpperCase(),
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: size.width *
                                              AppDimensions.numD028,
                                          fontFamily: "AirbnbCereal",
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                    height: size.width * AppDimensions.numD015),
                                Text(
                                  "********${firstBank.accountNumber}",
                                  style: commonTextStyle(
                                    size: size,
                                    fontSize:
                                        size.width * AppDimensions.numD025,
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Status indicators
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (firstBank.isDefault)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      size.width * AppDimensions.numD028,
                                  vertical: size.width * AppDimensions.numD01,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColorTheme.colorThemePink,
                                  borderRadius: BorderRadius.circular(
                                      size.width * AppDimensions.numD03),
                                ),
                                child: Text(
                                  "Default",
                                  style: commonTextStyle(
                                    size: size,
                                    fontSize:
                                        size.width * AppDimensions.numD028,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            Container(
                              margin: EdgeInsets.only(top: size.width * 0.014),
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * AppDimensions.numD028,
                                vertical: size.width * 0.008,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD03),
                              ),
                              child: Text(
                                "Verified",
                                style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD028,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: size.width * AppDimensions.numD02),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "This is your connected bank account on Stripe — where your payments will be sent.\n\n",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: size.width * AppDimensions.numD032,
                            fontFamily: "AirbnbCereal",
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        TextSpan(
                          text:
                              "Need to update your details or switch to a different account? Simply click below to log into Stripe and make any changes you need.",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: size.width * AppDimensions.numD032,
                            fontFamily: "AirbnbCereal",
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * AppDimensions.numD06),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: SizedBox(
                    height: size.width * AppDimensions.numD13,
                    child: commonElevatedButton(
                      "Update Your Details",
                      size,
                      commonButtonTextStyle(size),
                      commonButtonStyle(size, Colors.black),
                      () {
                        stripeBankPageTitle = "Update Your Details";
                        _generateAddBankApi(context);
                      },
                    ),
                  ),
                ),
                SizedBox(width: size.width * AppDimensions.numD06),
                Expanded(
                  child: SizedBox(
                    height: size.width * AppDimensions.numD13,
                    child: commonElevatedButton(
                      "Change Bank Account",
                      size,
                      commonButtonTextStyle(size),
                      commonButtonStyle(size, AppColorTheme.colorThemePink),
                      () {
                        stripeBankPageTitle = "Add bank";
                        _generateAddBankApi(context);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _upliftNoAccountsPaymentDesign(BuildContext context, Size size) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(size.width * AppDimensions.numD05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hi ${sharedPreferences!.getString(SharedPreferencesKeys.userNameKey) ?? ''}",
              style: TextStyle(
                color: Colors.black,
                fontSize: size.width * AppDimensions.numD06,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * AppDimensions.numD04),
            Center(
              child: Image.asset("${iconsPath}payment_page_icon.png"),
            ),
            SizedBox(height: size.width * AppDimensions.numD02),
            Container(
              decoration: BoxDecoration(
                color: Color(
                    0xFFF3F4F6), // Very light grey background matching image
                borderRadius:
                    BorderRadius.circular(size.width * AppDimensions.numD03),
                border: Border.all(
                    color: Colors.grey.shade600,
                    width: 0.8), // Distinct thin border
              ),
              padding: EdgeInsets.all(size.width * AppDimensions.numD045),
              child: RichText(
                text: TextSpan(
                  text: "Ready to get paid?\n\n",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize:
                        size.width * AppDimensions.numD032, // Matched body size
                    fontFamily: "AirbnbCereal",
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text:
                          "Set up your Stripe account now to receive payments within 2-7 days when your content is purchased.\n\n",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: size.width * AppDimensions.numD032,
                        fontFamily: "AirbnbCereal",
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    TextSpan(
                      text:
                          "Just tap the CTA below to get started - it takes less than a minute.",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: size.width * AppDimensions.numD032,
                        fontFamily: "AirbnbCereal",
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: size.height * AppDimensions.numD06),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: SizedBox(
                    height: size.width * AppDimensions.numD13,
                    child: commonElevatedButton(
                      "Camera",
                      size,
                      commonButtonTextStyle(size),
                      commonButtonStyle(size, Colors.black),
                      () {
                        context.goNamed(
                          AppRoutes.dashboardName,
                          extra: {'initialPosition': 2},
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: size.width * AppDimensions.numD06),
                Expanded(
                  child: SizedBox(
                    height: size.width * AppDimensions.numD13,
                    child: commonElevatedButton(
                      "Add bank",
                      size,
                      commonButtonTextStyle(size),
                      commonButtonStyle(size, AppColorTheme.colorThemePink),
                      () {
                        stripeBankPageTitle = "Add bank";
                        _generateAddBankApi(context);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
