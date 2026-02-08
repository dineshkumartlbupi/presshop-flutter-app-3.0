import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';

import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_widgets.dart';
import 'package:presshop/features/authentication/presentation/bloc/term_bloc.dart';
import 'package:presshop/features/authentication/presentation/bloc/term_event.dart';
import 'package:presshop/features/authentication/presentation/bloc/term_state.dart';
import 'package:presshop/features/authentication/data/repositories/term_repository.dart';
import 'package:presshop/core/di/injection_container.dart'; // For sl
import 'package:go_router/go_router.dart';
import 'package:presshop/core/router/router_constants.dart';

// ignore: must_be_immutable
class TermCheckScreen extends StatefulWidget {
  TermCheckScreen({super.key, required this.type});
  String type = "";

  @override
  State<TermCheckScreen> createState() => _TermCheckScreenState();
}

class _TermCheckScreenState extends State<TermCheckScreen> {
  bool check1Value = false,
      check2Value = false,
      check3Value = false,
      check4Value = false,
      isSelectUpArrow = false;

  String updatedDate = "";
  var scrollController = ScrollController();
  List<String> htmlDataList = [];

  void scrollToBottom() {
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
  }

  @override
  void initState() {
    super.initState();
    debugPrint("class==> $runtimeType::::${widget.type}");
    debugPrint("rememberMe:::::::::::$rememberMe");
  }

  void _scrollDown() {
    scrollController.animateTo(
      !isSelectUpArrow
          ? scrollController.position.maxScrollExtent
          : scrollController.position.minScrollExtent,
      duration: const Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => TermsBloc(sl<TermsRepository>())
        ..add(FetchTermsEvent(type: widget.type)),
      child: BlocConsumer<TermsBloc, TermsState>(
        listener: (context, state) {
          if (state is TermsLoaded) {
            htmlDataList.clear();
            htmlDataList.add(state.htmlContent);
            // You might want to parse the date if available in the model/state
            // updatedDate = ...
          } else if (state is TermsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            floatingActionButton: AnimatedSize(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80.0),
                child: InkWell(
                  onTap: () {
                    _scrollDown();
                    setState(() {
                      isSelectUpArrow = !isSelectUpArrow;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding:
                        EdgeInsets.only(top: 6, bottom: 6, left: 15, right: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                                opacity: animation, child: child);
                          },
                          child: Text(
                            'Scroll ${!isSelectUpArrow ? "Down" : "Up"}',
                            key: ValueKey<bool>(isSelectUpArrow),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF4F4F4F),
                              fontSize: size.width * AppDimensions.numD04,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        AnimatedRotation(
                          turns: isSelectUpArrow ? 0.5 : 0,
                          duration: Duration(milliseconds: 300),
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_down_sharp,
                              color: Colors.white,
                              size: size.width * AppDimensions.numD085,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            appBar: CommonAppBar(
              elevation: 0,
              hideLeading: false,
              title: Text(
                  widget.type == "privacy_policy"
                      ? AppStrings.privacyPolicyText
                      : "${AppStrings.legalText} ${AppStrings.tcText}",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize:
                          size.width * AppDimensions.appBarHeadingFontSize)),
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
                  width: size.width * AppDimensions.numD02,
                ),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: size.width * AppDimensions.numD02,
                ),
                htmlDataList.isNotEmpty
                    ? Flexible(
                        child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            !rememberMe
                                ? Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            size.width * AppDimensions.numD04),
                                    child: Text(
                                      "PLEASE READ THESE LICENCE TERMS CAREFULLY. BY CLICKING ON THE ${"ACCEPT"} BUTTON BELOW YOU AGREE TO THESE TERMS WHICH WILL BIND YOU. IF YOU DO NOT AGREE TO THESE TERMS, CLICK ON THE REJECT BUTTON BELOW.",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: size.width *
                                              AppDimensions.numD035,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                : Container(),
                            /*   SizedBox(
                              height: size.width * AppDimensions.numD06,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * AppDimensions.numD06),
                              child: Text(
                                "Updated on : $updatedDate",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * AppDimensions.numD035,
                                    color: AppColorTheme.colorHint,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),*/
                            ListView.separated(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        size.width * AppDimensions.numD02),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Html(
                                    data: htmlDataList[index],
                                    style: {
                                      "span": Style(
                                        color: AppColorTheme.colorTextFieldIcon,
                                        fontSize: FontSize(
                                            size.width * AppDimensions.numD01),
                                      ),
                                      "h1": Style(
                                          color: AppColorTheme.colorGreyNew,
                                          fontSize: FontSize(size.width *
                                              AppDimensions.numD02),
                                          padding: HtmlPaddings.symmetric(
                                              vertical: size.width *
                                                  AppDimensions.numD01)),
                                      "h2": Style(
                                          color: Colors.black,
                                          fontSize: FontSize(size.width *
                                              AppDimensions.numD04),
                                          padding: HtmlPaddings.symmetric(
                                              vertical: size.width *
                                                  AppDimensions.numD01)),
                                      "h3": Style(
                                          color: Colors.black,
                                          fontSize: FontSize(size.width *
                                              AppDimensions.numD035),
                                          padding: HtmlPaddings.symmetric(
                                              vertical: size.width *
                                                  AppDimensions.numD01)),
                                      "h4": Style(
                                          color: Colors.black,
                                          fontSize: FontSize(size.width *
                                              AppDimensions.numD035),
                                          padding: HtmlPaddings.symmetric(
                                              vertical: size.width *
                                                  AppDimensions.numD01)),
                                      "td": Style(
                                          color: AppColorTheme.colorGreyNew,
                                          fontSize: FontSize(size.width *
                                              AppDimensions.numD02),
                                          padding: HtmlPaddings.symmetric(
                                              vertical: size.width *
                                                  AppDimensions.numD01)),
                                      "th": Style(
                                          color: AppColorTheme.colorGreyNew,
                                          fontSize: FontSize(size.width *
                                              AppDimensions.numD02),
                                          fontWeight: FontWeight.w600,
                                          padding: HtmlPaddings.zero),
                                      "div": Style(
                                        backgroundColor:
                                            AppColorTheme.colorLightGrey,
                                      )
                                    },
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return const SizedBox(
                                    height: 0,
                                  );
                                },
                                itemCount: htmlDataList.length),
                            !rememberMe ? checkBoxWidget(size) : Container(),
                            !rememberMe
                                ? Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            size.width * AppDimensions.numD06),
                                    child: buttonWidget(size),
                                  )
                                : Container(),
                          ],
                        ),
                      ))
                    : Container()
              ],
            ),
          );
        },
      ),
    );
  }

  Widget termCheckWidget(Size size) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: size.width * AppDimensions.numD15),
      child: const Column(
        children: [
          Text(
            AppStrings.legalDescText,
            style: TextStyle(fontWeight: FontWeight.w300),
          )
        ],
      ),
    );
  }

  //termAndCondition
  Widget termsAndConditions(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          AppStrings.legalDummyText,
          style: commonTextStyle(
              size: size,
              fontSize: size.width * AppDimensions.numD02,
              color: AppColorTheme.colorHint,
              fontWeight: FontWeight.w400),
        ),
        SizedBox(
          height: size.width * AppDimensions.numD02,
        ),
        Text(
          AppStrings.termsAndConditionText,
          style: commonTextStyle(
              size: size,
              fontSize: size.width * AppDimensions.numD04,
              color: Colors.black,
              fontWeight: FontWeight.w400),
        ),
        SizedBox(
          height: size.width * AppDimensions.numD02,
        ),
        Container(
          decoration: const BoxDecoration(color: AppColorTheme.colorLightGrey),
          padding: EdgeInsets.all(size.width * AppDimensions.numD04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "What & Why",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * AppDimensions.numD05,
                    color: AppColorTheme.colorTextFieldIcon,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: size.width * AppDimensions.numD01,
              ),
              Text(
                AppStrings.dummyTermText,
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * AppDimensions.numD035,
                    color: AppColorTheme.colorGreyNew,
                    fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: size.width * AppDimensions.numD06,
              ),
              Text(
                AppStrings.userConductDummyText,
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * AppDimensions.numD05,
                    color: AppColorTheme.colorTextFieldIcon,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: size.width * AppDimensions.numD01,
              ),
              Text(
                AppStrings.dummyPrivacyText,
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * AppDimensions.numD035,
                    color: AppColorTheme.colorGreyNew,
                    fontWeight: FontWeight.w400),
              )
            ],
          ),
        )
      ],
    );
  }

  //copyRight
  Widget copyRightWidget(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: size.width * AppDimensions.numD06,
        ),
        Text(
          AppStrings.copyRightText,
          style: commonTextStyle(
              size: size,
              fontSize: size.width * AppDimensions.numD04,
              color: Colors.black,
              fontWeight: FontWeight.w400),
        ),
        SizedBox(
          height: size.width * AppDimensions.numD02,
        ),
        Container(
          decoration: const BoxDecoration(color: AppColorTheme.colorLightGrey),
          padding: EdgeInsets.all(size.width * AppDimensions.numD04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "What & Why",
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * AppDimensions.numD05,
                    color: AppColorTheme.colorTextFieldIcon,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: size.width * AppDimensions.numD01,
              ),
              Text(
                AppStrings.dummyTermText,
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * AppDimensions.numD035,
                    color: AppColorTheme.colorGreyNew,
                    fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: size.width * AppDimensions.numD06,
              ),
              Text(
                AppStrings.userConductDummyText,
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * AppDimensions.numD05,
                    color: AppColorTheme.colorTextFieldIcon,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: size.width * AppDimensions.numD01,
              ),
              Text(
                AppStrings.dummyPrivacyText,
                style: commonTextStyle(
                    size: size,
                    fontSize: size.width * AppDimensions.numD035,
                    color: AppColorTheme.colorGreyNew,
                    fontWeight: FontWeight.w400),
              )
            ],
          ),
        )
      ],
    );
  }

  //Privacy
  Widget privacyWidget(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: size.width * AppDimensions.numD06,
        ),
        Padding(
          padding: EdgeInsets.only(
              left: size.width * AppDimensions.numD05,
              bottom: size.width * AppDimensions.numD05,
              right: size.width * AppDimensions.numD05),
          child: Text(
            AppStrings.privacyPolicyText,
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: size.width * AppDimensions.numD05),
          ),
        ),
        SizedBox(
          height: size.width * AppDimensions.numD02,
        ),
        ListView.separated(
            padding: EdgeInsets.symmetric(
                horizontal: size.width * AppDimensions.numD04),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Html(
                data: htmlDataList[index],
                style: {
                  "span": Style(
                    color: AppColorTheme.colorTextFieldIcon,
                    fontSize: FontSize(size.width * AppDimensions.numD01),
                  ),
                  "h1": Style(
                      color: AppColorTheme.colorGreyNew,
                      fontSize: FontSize(size.width * AppDimensions.numD02),
                      padding: HtmlPaddings.symmetric(
                          vertical: size.width * AppDimensions.numD01)),
                  "h2": Style(
                      color: Colors.black,
                      fontSize: FontSize(size.width * AppDimensions.numD04),
                      padding: HtmlPaddings.symmetric(
                          vertical: size.width * AppDimensions.numD01)),
                  "h3": Style(
                      color: Colors.black,
                      fontSize: FontSize(size.width * AppDimensions.numD035),
                      padding: HtmlPaddings.symmetric(
                          vertical: size.width * AppDimensions.numD01)),
                  "h4": Style(
                      color: Colors.black,
                      fontSize: FontSize(size.width * AppDimensions.numD035),
                      padding: HtmlPaddings.symmetric(
                          vertical: size.width * AppDimensions.numD01)),
                  "td": Style(
                      color: AppColorTheme.colorGreyNew,
                      fontSize: FontSize(size.width * AppDimensions.numD02),
                      padding: HtmlPaddings.symmetric(
                          vertical: size.width * AppDimensions.numD01)),
                  "th": Style(
                      color: AppColorTheme.colorGreyNew,
                      fontSize: FontSize(size.width * AppDimensions.numD02),
                      fontWeight: FontWeight.w600,
                      padding: HtmlPaddings.zero),
                  "div": Style(
                    backgroundColor: AppColorTheme.colorLightGrey,
                  )
                },
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(
                height: 0,
              );
            },
            itemCount: htmlDataList.length),
      ],
    );
  }

  //please confirm
  Widget checkBoxWidget(Size size) {
    return Container(
      decoration: const BoxDecoration(color: AppColorTheme.colorLightGrey),
      padding: EdgeInsets.all(size.width * AppDimensions.numD04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              check1Value = !check1Value;
              setState(() {});
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                check1Value
                    ? Container(
                        margin: EdgeInsets.only(
                            top: size.width * AppDimensions.numD008),
                        child: Image.asset(
                          "${iconsPath}ic_checkbox_filled.png",
                          height: size.width * AppDimensions.numD05,
                        ),
                      )
                    : Container(
                        margin: EdgeInsets.only(
                            top: size.width * AppDimensions.numD008),
                        child: Image.asset("${iconsPath}ic_checkbox_empty.png",
                            height: size.width * AppDimensions.numD05),
                      ),
                SizedBox(
                  width: size.width * AppDimensions.numD02,
                ),
                Expanded(
                  child: RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                      text: "I have read and agree to Press",
                      style: TextStyle(
                          fontSize: size.width * AppDimensions.numD038,
                          color: Colors.black,
                          fontFamily: "AirbnbCereal",
                          fontWeight: FontWeight.w400,
                          height: 1.5),
                      children: [
                        TextSpan(
                          text: "Hop's",
                          style: TextStyle(
                              fontSize: size.width * AppDimensions.numD038,
                              color: Colors.black,
                              fontFamily: "AirbnbCereal",
                              fontWeight: FontWeight.w400,
                              height: 1.5),
                        ),
                        TextSpan(
                          text:
                              "  terms & conditions as set out in the user agreement.",
                          style: TextStyle(
                              fontSize: size.width * AppDimensions.numD038,
                              color: Colors.black,
                              fontFamily: "AirbnbCereal",
                              fontWeight: FontWeight.w400,
                              height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: size.width * AppDimensions.numD03,
          ),
          InkWell(
            onTap: () {
              check2Value = !check2Value;
              setState(() {});
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                check2Value
                    ? Container(
                        margin: EdgeInsets.only(
                            top: size.width * AppDimensions.numD008),
                        child: Image.asset(
                          "${iconsPath}ic_checkbox_filled.png",
                          height: size.width * AppDimensions.numD05,
                        ),
                      )
                    : Container(
                        margin: EdgeInsets.only(
                            top: size.width * AppDimensions.numD008),
                        child: Image.asset("${iconsPath}ic_checkbox_empty.png",
                            height: size.width * AppDimensions.numD05),
                      ),
                SizedBox(
                  width: size.width * AppDimensions.numD02,
                ),
                Expanded(
                  child: RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                      text: "I have read and agree to Press",
                      style: TextStyle(
                          fontSize: size.width * AppDimensions.numD038,
                          color: Colors.black,
                          fontFamily: "AirbnbCereal",
                          fontWeight: FontWeight.w400,
                          height: 1.5),
                      children: [
                        TextSpan(
                          text: "Hop's",
                          style: TextStyle(
                              fontSize: size.width * AppDimensions.numD038,
                              color: Colors.black,
                              fontFamily: "AirbnbCereal",
                              fontWeight: FontWeight.w400,
                              height: 1.5),
                        ),
                        TextSpan(
                          text: " privacy policy.",
                          style: TextStyle(
                              fontSize: size.width * AppDimensions.numD038,
                              color: Colors.black,
                              fontFamily: "AirbnbCereal",
                              fontWeight: FontWeight.w400,
                              height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: size.width * AppDimensions.numD03,
          ),
          InkWell(
            onTap: () {
              check3Value = !check3Value;
              setState(() {});
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                check3Value
                    ? Container(
                        margin: EdgeInsets.only(
                            top: size.width * AppDimensions.numD008),
                        child: Image.asset(
                          "${iconsPath}ic_checkbox_filled.png",
                          height: size.width * AppDimensions.numD05,
                        ),
                      )
                    : Container(
                        margin: EdgeInsets.only(
                            top: size.width * AppDimensions.numD008),
                        child: Image.asset("${iconsPath}ic_checkbox_empty.png",
                            height: size.width * AppDimensions.numD05),
                      ),
                SizedBox(
                  width: size.width * AppDimensions.numD02,
                ),
                Expanded(
                  child: RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                      text: "By uploading content on the Press",
                      style: TextStyle(
                          fontSize: size.width * AppDimensions.numD038,
                          color: Colors.black,
                          fontFamily: "AirbnbCereal",
                          fontWeight: FontWeight.w400,
                          height: 1.5),
                      children: [
                        TextSpan(
                          text: "Hop",
                          style: TextStyle(
                              fontSize: size.width * AppDimensions.numD038,
                              color: Colors.black,
                              fontFamily: "AirbnbCereal",
                              fontWeight: FontWeight.w400,
                              height: 1.5),
                        ),
                        TextSpan(
                          text:
                              " app and platform, you are warranting that you own all proprietary rights, or are the authorised representative of the applicable copyright owner(s) of such content, including copyright.",
                          style: TextStyle(
                              fontSize: size.width * AppDimensions.numD038,
                              color: Colors.black,
                              fontFamily: "AirbnbCereal",
                              fontWeight: FontWeight.w400,
                              height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: size.width * AppDimensions.numD03,
          ),
          InkWell(
            onTap: () {
              check4Value = !check4Value;
              setState(() {});
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                check4Value
                    ? Container(
                        margin: EdgeInsets.only(
                            top: size.width * AppDimensions.numD008),
                        child: Image.asset(
                          "${iconsPath}ic_checkbox_filled.png",
                          height: size.width * AppDimensions.numD05,
                        ),
                      )
                    : Container(
                        margin: EdgeInsets.only(
                            top: size.width * AppDimensions.numD008),
                        child: Image.asset("${iconsPath}ic_checkbox_empty.png",
                            height: size.width * AppDimensions.numD05),
                      ),
                SizedBox(
                  width: size.width * AppDimensions.numD02,
                ),
                Expanded(
                  child: RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                      text: "By using the Press",
                      style: TextStyle(
                          fontSize: size.width * AppDimensions.numD038,
                          color: Colors.black,
                          fontFamily: "AirbnbCereal",
                          fontWeight: FontWeight.w400,
                          height: 1.5),
                      children: [
                        TextSpan(
                          text: "Hop",
                          style: TextStyle(
                              fontSize: size.width * AppDimensions.numD038,
                              color: Colors.black,
                              fontFamily: "AirbnbCereal",
                              fontWeight: FontWeight.w400,
                              height: 1.5),
                        ),
                        TextSpan(
                          text:
                              " app and platform, you warrant that you are 18 years of age or older, and have the legal authority to enter into these Terms.",
                          style: TextStyle(
                              fontSize: size.width * AppDimensions.numD038,
                              color: Colors.black,
                              fontFamily: "AirbnbCereal",
                              fontWeight: FontWeight.w400,
                              height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buttonWidget(Size size) {
    return Container(
      padding: EdgeInsets.only(
          top: size.width * AppDimensions.numD05,
          bottom: size.width * AppDimensions.numD05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
              child: SizedBox(
            height: size.width * AppDimensions.numD15,
            child: commonElevatedButton(
                AppStrings.declineText.toTitleCase(),
                size,
                commonButtonTextStyle(size),
                commonButtonStyle(size, Colors.black), () {
              declinedDialog("", size, () {});
            }),
          )),
          SizedBox(
            width: size.width * AppDimensions.numD04,
          ),
          Expanded(
              child: SizedBox(
            height: size.width * AppDimensions.numD15,
            child: commonElevatedButton(
                AppStrings.acceptText,
                size,
                commonButtonTextStyle(size),
                commonButtonStyle(size, AppColorTheme.colorThemePink), () {
              if (check1Value && check2Value && check3Value && check4Value) {
                context.pop(true);
              } else {
                showSnackBar(
                    "Error",
                    "Please select all the boxes to confirm your acceptance of our Terms & Conditions.",
                    Colors.red);
              }
            }),
          )),
        ],
      ),
    );
  }

  void declinedDialog(String message, Size size, VoidCallback pressed) {
    showDialog(
        context: context,
        builder: (dialogContext) {
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
                                "${AppStrings.tcText} ${AppStrings.declinedText}?",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: size.width * AppDimensions.numD05,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              IconButton(
                                  onPressed: () {
                                    dialogContext.pop();
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
                          child: Text(
                            AppStrings.tcDeclinedNoteText,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: size.width * AppDimensions.numD04,
                                fontWeight: FontWeight.w400),
                          ),
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
                                    AppStrings.declineText.toTitleCase(),
                                    size,
                                    commonButtonTextStyle(size),
                                    commonButtonStyle(size, Colors.black), () {
                                  dialogContext.pop();
                                  this.context.pop(false);
                                }),
                              )),
                              SizedBox(
                                width: size.width * AppDimensions.numD04,
                              ),
                              Expanded(
                                  child: SizedBox(
                                height: size.width * AppDimensions.numD12,
                                child: commonElevatedButton(
                                    "${AppStrings.acceptText} ${AppStrings.tcText}",
                                    size,
                                    commonButtonTextStyle(size),
                                    commonButtonStyle(
                                        size, AppColorTheme.colorThemePink),
                                    () {
                                  dialogContext.pop();
                                  this.context.pop(true);
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
}
