import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:presshop/core/widgets/common_widgets.dart';

// ignore: must_be_immutable
class ManageContentScreen extends StatefulWidget {
  ManageContentScreen({super.key, required this.taskStatus});
  String taskStatus = "";

  @override
  State<StatefulWidget> createState() {
    return ManageContentScreenState();
  }
}

class ManageContentScreenState extends State<ManageContentScreen> {
  @override
  void initState() {
    super.initState();
    print("WhereIam: ManageContentScreen");
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(
          AppStrings.manageContentText,
          style: TextStyle(
              color: Colors.black,
              fontSize: size.width * AppDimensions.headerFontSize),
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
                horizontal: size.width * AppDimensions.numD04),
            child: Column(
              children: [
                SizedBox(
                  height: size.width * AppDimensions.numD08,
                ),
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(size.width * AppDimensions.numD04),
                  child: Stack(
                    children: [
                      Image.asset(
                        "${dummyImagePath}dummy_content.png",
                        height: size.width * AppDimensions.numD50,
                        width: size.width,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        right: size.width * AppDimensions.numD02,
                        top: size.width * AppDimensions.numD02,
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * AppDimensions.numD01,
                                vertical: size.width * 0.002),
                            decoration: BoxDecoration(
                                color: AppColorTheme.colorLightGreen
                                    .withOpacity(0.8),
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD015)),
                            child: Icon(
                              Icons.videocam_outlined,
                              size: size.width * AppDimensions.numD06,
                              color: Colors.white,
                            )),
                      ),
                      Positioned(
                        right: size.width * AppDimensions.numD02,
                        bottom: size.width * AppDimensions.numD02,
                        child: Text(
                          "+2",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD04,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Image.asset(
                        "${commonImagePath}watermark.png",
                        height: size.width * AppDimensions.numD50,
                        width: size.width,
                        fit: BoxFit.cover,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * AppDimensions.numD02,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "In political crosshairs, U.S. Supreme Court weighs abortion have to do this in a manner",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * AppDimensions.numD045,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "${iconsPath}ic_exclusive.png",
                          height: size.width * AppDimensions.numD05,
                        ),
                        SizedBox(
                          width: size.width * AppDimensions.numD02,
                        ),
                        Text(
                          AppStrings.exclusiveText,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * AppDimensions.numD04,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: size.width * AppDimensions.numD04,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                "${iconsPath}ic_clock.png",
                                height: size.width * AppDimensions.numD05,
                                color: AppColorTheme.colorTextFieldIcon,
                              ),
                              SizedBox(
                                width: size.width * AppDimensions.numD02,
                              ),
                              Text(
                                "12:36, 10:12:2021",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize:
                                        size.width * AppDimensions.numD035,
                                    color: AppColorTheme.colorHint,
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                          SizedBox(
                            height: size.width * AppDimensions.numD02,
                          ),
                          Row(
                            children: [
                              Image.asset(
                                "${iconsPath}ic_location.png",
                                height: size.width * AppDimensions.numD06,
                                color: AppColorTheme.colorTextFieldIcon,
                              ),
                              SizedBox(
                                width: size.width * AppDimensions.numD02,
                              ),
                              Text(
                                "Grenfell Tower, London",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize:
                                        size.width * AppDimensions.numD035,
                                    color: AppColorTheme.colorHint,
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                          SizedBox(
                            height: size.width * AppDimensions.numD02,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * AppDimensions.numD06,
                          vertical: size.width * AppDimensions.numD01),
                      decoration: BoxDecoration(
                          color: AppColorTheme.colorThemePink,
                          borderRadius: BorderRadius.circular(
                              size.width * AppDimensions.numD03)),
                      child: Column(
                        children: [
                          Text(
                            AppStrings.priceQuotedText,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD035,
                                color: Colors.white,
                                fontWeight: FontWeight.normal),
                          ),
                          Text(
                            "${currencySymbol}350",
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD06,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: size.width * AppDimensions.numD04,
                ),
                const Divider(
                  color: AppColorTheme.colorTextFieldIcon,
                ),
                SizedBox(
                  height: size.width * AppDimensions.numD04,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          top: size.width * AppDimensions.numD04),
                      padding:
                          EdgeInsets.all(size.width * AppDimensions.numD03),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade300, spreadRadius: 2)
                          ]),
                      child: Image.asset(
                        "${commonImagePath}rabbitLogo.png",
                        height: size.width * AppDimensions.numD07,
                        width: size.width * AppDimensions.numD07,
                      ),
                    ),
                    SizedBox(
                      width: size.width * AppDimensions.numD04,
                    ),
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.only(
                          top: size.width * AppDimensions.numD06),
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * AppDimensions.numD05,
                          vertical: size.width * AppDimensions.numD02),
                      width: size.width,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(
                                  size.width * AppDimensions.numD04),
                              bottomLeft: Radius.circular(
                                  size.width * AppDimensions.numD04),
                              bottomRight: Radius.circular(
                                  size.width * AppDimensions.numD04))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: size.width * AppDimensions.numD04,
                          ),
                          Text(
                            "Congrats, you’ve received $currencySymbol 200 from Reuters Media ",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD035,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: size.width * AppDimensions.numD04,
                          ),
                          SizedBox(
                            height: size.width * AppDimensions.numD13,
                            width: size.width,
                            child: commonElevatedButton(
                                AppStrings.viewDetailsText,
                                size,
                                commonButtonTextStyle(size),
                                commonButtonStyle(
                                    size, AppColorTheme.colorThemePink),
                                () {}),
                          )
                        ],
                      ),
                    ))
                  ],
                ),
                SizedBox(
                  height: size.width * AppDimensions.numD07,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          top: size.width * AppDimensions.numD04),
                      padding:
                          EdgeInsets.all(size.width * AppDimensions.numD01),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade300, spreadRadius: 2)
                          ]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            size.width * AppDimensions.numD04),
                        child: Image.asset(
                          "${dummyImagePath}news.png",
                          height: size.width * AppDimensions.numD09,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: size.width * AppDimensions.numD04,
                    ),
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.only(
                          top: size.width * AppDimensions.numD06),
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * AppDimensions.numD05,
                          vertical: size.width * AppDimensions.numD02),
                      width: size.width,
                      decoration: BoxDecoration(
                          color: AppColorTheme.colorLightGrey,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(
                                  size.width * AppDimensions.numD04),
                              bottomLeft: Radius.circular(
                                  size.width * AppDimensions.numD04),
                              bottomRight: Radius.circular(
                                  size.width * AppDimensions.numD04))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: size.width * AppDimensions.numD04,
                          ),
                          Text(
                            "Do you have additional pictures related to the task?",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD035,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: size.width * AppDimensions.numD04,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: SizedBox(
                                height: size.width * AppDimensions.numD13,
                                width: size.width,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              size.width *
                                                  AppDimensions.numD04),
                                          side: const BorderSide(
                                              color: AppColorTheme.colorGrey1,
                                              width: 2))),
                                  child: Text(
                                    AppStrings.noText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD04,
                                        color: AppColorTheme.colorLightGreen,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              )),
                              SizedBox(
                                width: size.width * AppDimensions.numD04,
                              ),
                              Expanded(
                                  child: SizedBox(
                                height: size.width * AppDimensions.numD13,
                                width: size.width,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppColorTheme.colorThemePink,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            size.width * AppDimensions.numD04),
                                      )),
                                  child: Text(
                                    AppStrings.viewDetailsText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD04,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              )),
                            ],
                          )
                        ],
                      ),
                    ))
                  ],
                ),
                SizedBox(
                  height: size.width * AppDimensions.numD07,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          top: size.width * AppDimensions.numD04),
                      padding:
                          EdgeInsets.all(size.width * AppDimensions.numD03),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade300, spreadRadius: 2)
                          ]),
                      child: Image.asset(
                        "${commonImagePath}rabbitLogo.png",
                        height: size.width * AppDimensions.numD07,
                        width: size.width * AppDimensions.numD07,
                      ),
                    ),
                    SizedBox(
                      width: size.width * AppDimensions.numD04,
                    ),
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.only(
                          top: size.width * AppDimensions.numD06),
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * AppDimensions.numD05,
                          vertical: size.width * AppDimensions.numD02),
                      width: size.width,
                      decoration: BoxDecoration(
                          color: AppColorTheme.colorLightGrey,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(
                                  size.width * AppDimensions.numD04),
                              bottomLeft: Radius.circular(
                                  size.width * AppDimensions.numD04),
                              bottomRight: Radius.circular(
                                  size.width * AppDimensions.numD04))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: size.width * AppDimensions.numD04,
                          ),
                          Text(
                            "Send the content for approval",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD035,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: size.width * AppDimensions.numD04,
                          ),
                          SizedBox(
                            height: size.width * AppDimensions.numD13,
                            width: size.width,
                            child: commonElevatedButton(
                                AppStrings.uploadText,
                                size,
                                commonButtonTextStyle(size),
                                commonButtonStyle(
                                    size, AppColorTheme.colorThemePink),
                                () {}),
                          )
                        ],
                      ),
                    ))
                  ],
                ),
                SizedBox(
                  height: size.width * AppDimensions.numD07,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  size.width * AppDimensions.numD04),
                              child: Image.asset(
                                "${dummyImagePath}walk6.png",
                                height: size.height / 3,
                                width: size.width / 1.7,
                                fit: BoxFit.cover,
                              )),
                          Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(
                                    size.width * AppDimensions.numD04),
                              ),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      size.width * AppDimensions.numD04),
                                  child: Image.asset(
                                    "${commonImagePath}watermark.png",
                                    height: size.height / 3,
                                    width: size.width / 1.7,
                                    fit: BoxFit.cover,
                                  )))
                        ],
                      ),
                      SizedBox(
                        width: size.width * AppDimensions.numD02,
                      ),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(
                              size.width * AppDimensions.numD08),
                          child: Image.asset(
                            "${dummyImagePath}avatar.png",
                            height: size.width * AppDimensions.numD08,
                            width: size.width * AppDimensions.numD08,
                            fit: BoxFit.cover,
                          ))
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * AppDimensions.numD05,
                ),
                Row(
                  children: [
                    const Expanded(
                        child: Divider(
                      color: AppColorTheme.colorGrey1,
                      thickness: 1,
                    )),
                    Text(
                      "Pending reviews from Reuters",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * AppDimensions.numD035,
                          color: AppColorTheme.colorGrey2,
                          fontWeight: FontWeight.w600),
                    ),
                    const Expanded(
                        child: Divider(
                      color: AppColorTheme.colorGrey1,
                      thickness: 1,
                    )),
                  ],
                ),
                SizedBox(
                  height: size.width * AppDimensions.numD07,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          top: size.width * AppDimensions.numD04),
                      padding:
                          EdgeInsets.all(size.width * AppDimensions.numD01),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade300, spreadRadius: 2)
                          ]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            size.width * AppDimensions.numD04),
                        child: Image.asset(
                          "${dummyImagePath}news.png",
                          height: size.width * AppDimensions.numD09,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: size.width * AppDimensions.numD04,
                    ),
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.only(
                          top: size.width * AppDimensions.numD06),
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * AppDimensions.numD05,
                          vertical: size.width * AppDimensions.numD02),
                      width: size.width,
                      decoration: BoxDecoration(
                          color: AppColorTheme.colorLightGrey,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(
                                  size.width * AppDimensions.numD04),
                              bottomLeft: Radius.circular(
                                  size.width * AppDimensions.numD04),
                              bottomRight: Radius.circular(
                                  size.width * AppDimensions.numD04))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: size.width * AppDimensions.numD04,
                          ),
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(
                              text: "Reuters Media has offered ",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: "${currencySymbol}150 ",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: AppColorTheme.colorThemePink,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: "to buy your content",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                          ])),
                          SizedBox(
                            height: size.width * AppDimensions.numD04,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: SizedBox(
                                height: size.width * AppDimensions.numD13,
                                width: size.width,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              size.width *
                                                  AppDimensions.numD04),
                                          side: const BorderSide(
                                              color: AppColorTheme.colorGrey1,
                                              width: 2))),
                                  child: Text(
                                    AppStrings.rejectText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD04,
                                        color: AppColorTheme.colorLightGreen,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              )),
                              SizedBox(
                                width: size.width * AppDimensions.numD04,
                              ),
                              Expanded(
                                  child: SizedBox(
                                height: size.width * AppDimensions.numD13,
                                width: size.width,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppColorTheme.colorThemePink,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            size.width * AppDimensions.numD04),
                                      )),
                                  child: Text(
                                    AppStrings.acceptText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD04,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              )),
                            ],
                          ),
                          SizedBox(
                            height: size.width * AppDimensions.numD05,
                          ),
                          Row(
                            children: [
                              const Expanded(
                                  child: Divider(
                                color: AppColorTheme.colorTextFieldIcon,
                                thickness: 1,
                              )),
                              Text(
                                "or",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize:
                                        size.width * AppDimensions.numD035,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600),
                              ),
                              const Expanded(
                                  child: Divider(
                                color: AppColorTheme.colorTextFieldIcon,
                                thickness: 1,
                              )),
                            ],
                          ),
                          SizedBox(
                            height: size.width * AppDimensions.numD04,
                          ),
                          SizedBox(
                            height: size.width * AppDimensions.numD13,
                            width: size.width,
                            child: commonElevatedButton(
                                "Make a Counter Offer",
                                size,
                                commonButtonTextStyle(size),
                                commonButtonStyle(
                                    size, AppColorTheme.colorThemePink),
                                () {}),
                          ),
                          SizedBox(
                            height: size.width * AppDimensions.numD04,
                          ),
                          Text(
                            "You can make a counter offer only once",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD035,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ))
                  ],
                ),
                SizedBox(
                  height: size.width * AppDimensions.numD07,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          top: size.width * AppDimensions.numD04),
                      padding:
                          EdgeInsets.all(size.width * AppDimensions.numD03),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade300, spreadRadius: 2)
                          ]),
                      child: Image.asset(
                        "${commonImagePath}rabbitLogo.png",
                        height: size.width * AppDimensions.numD07,
                        width: size.width * AppDimensions.numD07,
                      ),
                    ),
                    SizedBox(
                      width: size.width * AppDimensions.numD04,
                    ),
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.only(
                          top: size.width * AppDimensions.numD06),
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * AppDimensions.numD05,
                          vertical: size.width * AppDimensions.numD02),
                      width: size.width,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(
                                  size.width * AppDimensions.numD04),
                              bottomLeft: Radius.circular(
                                  size.width * AppDimensions.numD04),
                              bottomRight: Radius.circular(
                                  size.width * AppDimensions.numD04))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: size.width * AppDimensions.numD04,
                          ),
                          Text(
                            "Make a counter offer to Reuters Media",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD035,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: size.width * AppDimensions.numD04,
                          ),
                          SizedBox(
                            height: size.width * AppDimensions.numD13,
                            width: size.width,
                            child: TextFormField(
                              cursorColor: AppColorTheme.colorTextFieldIcon,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true, signed: true),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                filled: false,
                                hintText: "Enter price here...",
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        size.width * AppDimensions.numD04),
                                disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        size.width * 0.03),
                                    borderSide: const BorderSide(
                                        width: 1, color: Colors.black)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        size.width * 0.03),
                                    borderSide: const BorderSide(
                                        width: 1, color: Colors.black)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        size.width * 0.03),
                                    borderSide: const BorderSide(
                                        width: 1, color: Colors.black)),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        size.width * 0.03),
                                    borderSide: const BorderSide(
                                        width: 1, color: Colors.black)),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        size.width * 0.03),
                                    borderSide: const BorderSide(
                                        width: 1, color: Colors.black)),
                              ),
                              textAlignVertical: TextAlignVertical.center,
                              validator: checkRequiredValidator,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                            ),
                          ),
                          SizedBox(
                            height: size.width * AppDimensions.numD04,
                          ),
                          SizedBox(
                            height: size.width * AppDimensions.numD13,
                            width: size.width,
                            child: commonElevatedButton(
                                "AppStrings.submitText",
                                size,
                                commonButtonTextStyle(size),
                                commonButtonStyle(
                                    size, AppColorTheme.colorThemePink),
                                () {}),
                          ),
                          SizedBox(
                            height: size.width * AppDimensions.numD04,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "${iconsPath}ic_tag.png",
                                height: size.width * AppDimensions.numD06,
                              ),
                              SizedBox(
                                width: size.width * AppDimensions.numD02,
                              ),
                              Expanded(
                                child: Text(
                                  "Check price tips, and learnings",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize:
                                          size.width * AppDimensions.numD035,
                                      color: AppColorTheme.colorThemePink,
                                      fontWeight: FontWeight.w600),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: size.width * AppDimensions.numD04,
                          ),
                          Text(
                            "You can make a counter offer only once",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD031,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ))
                  ],
                ),
                SizedBox(
                  height: size.width * AppDimensions.numD07,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          top: size.width * AppDimensions.numD04),
                      padding:
                          EdgeInsets.all(size.width * AppDimensions.numD01),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade300, spreadRadius: 2)
                          ]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            size.width * AppDimensions.numD04),
                        child: Image.asset(
                          "${dummyImagePath}news.png",
                          height: size.width * AppDimensions.numD09,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: size.width * AppDimensions.numD04,
                    ),
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.only(
                          top: size.width * AppDimensions.numD06),
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * AppDimensions.numD05,
                          vertical: size.width * AppDimensions.numD02),
                      width: size.width,
                      decoration: BoxDecoration(
                          color: AppColorTheme.colorLightGrey,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(
                                  size.width * AppDimensions.numD04),
                              bottomLeft: Radius.circular(
                                  size.width * AppDimensions.numD04),
                              bottomRight: Radius.circular(
                                  size.width * AppDimensions.numD04))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: size.width * AppDimensions.numD04,
                          ),
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(
                              text:
                                  "Reuters Media have increased their offered to ",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: "${currencySymbol}200 ",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: AppColorTheme.colorThemePink,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: "to buy your content",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                          ])),
                          SizedBox(
                            height: size.width * AppDimensions.numD04,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: SizedBox(
                                height: size.width * AppDimensions.numD13,
                                width: size.width,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              size.width *
                                                  AppDimensions.numD04),
                                          side: const BorderSide(
                                              color: AppColorTheme.colorGrey1,
                                              width: 2))),
                                  child: Text(
                                    AppStrings.rejectText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD04,
                                        color: AppColorTheme.colorLightGreen,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              )),
                              SizedBox(
                                width: size.width * AppDimensions.numD04,
                              ),
                              Expanded(
                                  child: SizedBox(
                                height: size.width * AppDimensions.numD13,
                                width: size.width,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppColorTheme.colorThemePink,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            size.width * AppDimensions.numD04),
                                      )),
                                  child: Text(
                                    AppStrings.acceptText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize:
                                            size.width * AppDimensions.numD04,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ))
                  ],
                ),
                SizedBox(
                  height: size.width * AppDimensions.numD07,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          top: size.width * AppDimensions.numD04),
                      padding:
                          EdgeInsets.all(size.width * AppDimensions.numD03),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade300, spreadRadius: 2)
                          ]),
                      child: Image.asset(
                        "${commonImagePath}rabbitLogo.png",
                        width: size.width * AppDimensions.numD07,
                      ),
                    ),
                    SizedBox(
                      width: size.width * AppDimensions.numD04,
                    ),
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.only(
                          top: size.width * AppDimensions.numD06),
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * AppDimensions.numD05,
                          vertical: size.width * AppDimensions.numD02),
                      width: size.width,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(
                                  size.width * AppDimensions.numD04),
                              bottomLeft: Radius.circular(
                                  size.width * AppDimensions.numD04),
                              bottomRight: Radius.circular(
                                  size.width * AppDimensions.numD04))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: size.width * AppDimensions.numD04,
                          ),
                          Text(
                            "Congrats, you’ve received £200 from Reuters Media ",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD035,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: size.width * AppDimensions.numD04,
                          ),
                          SizedBox(
                            height: size.width * AppDimensions.numD13,
                            width: size.width,
                            child: commonElevatedButton(
                                AppStrings.viewDetailsText,
                                size,
                                commonButtonTextStyle(size),
                                commonButtonStyle(
                                    size, AppColorTheme.colorThemePink),
                                () {}),
                          )
                        ],
                      ),
                    ))
                  ],
                ),
                SizedBox(
                  height: size.width * AppDimensions.numD07,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          top: size.width * AppDimensions.numD04),
                      padding:
                          EdgeInsets.all(size.width * AppDimensions.numD03),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade300, spreadRadius: 2)
                          ]),
                      child: Image.asset(
                        "${commonImagePath}rabbitLogo.png",
                        width: size.width * AppDimensions.numD07,
                      ),
                    ),
                    SizedBox(
                      width: size.width * AppDimensions.numD04,
                    ),
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.only(
                          top: size.width * AppDimensions.numD06),
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * AppDimensions.numD05,
                          vertical: size.width * AppDimensions.numD02),
                      width: size.width,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(
                                  size.width * AppDimensions.numD04),
                              bottomLeft: Radius.circular(
                                  size.width * AppDimensions.numD04),
                              bottomRight: Radius.circular(
                                  size.width * AppDimensions.numD04))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: size.width * AppDimensions.numD04,
                          ),
                          Text(
                            "Rate your experience with Reuters Media",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * AppDimensions.numD035,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: size.width * AppDimensions.numD04,
                          ),
                          RatingBar(
                            ratingWidget: RatingWidget(
                              empty:
                                  Image.asset("${iconsPath}ic_empty_star.png"),
                              full: Image.asset("${iconsPath}ic_full_star.png"),
                              half: Image.asset("${iconsPath}ic_half_star.png"),
                            ),
                            onRatingUpdate: (value) {},
                            itemSize: size.width * AppDimensions.numD09,
                            itemCount: 5,
                            initialRating: 0,
                            allowHalfRating: true,
                            itemPadding: EdgeInsets.only(
                                left: size.width * AppDimensions.numD03),
                          ),
                          SizedBox(
                            height: size.width * AppDimensions.numD04,
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Write your review here",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * AppDimensions.numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          SizedBox(
                            height: size.width * AppDimensions.numD04,
                          ),
                          Stack(
                            children: [
                              SizedBox(
                                height: size.width * AppDimensions.numD35,
                                child: TextFormField(
                                  cursorColor: AppColorTheme.colorTextFieldIcon,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintText:
                                        "Please share your feedback on your experience with the publication. Your feedback is very important for improving your experience, and our service. Thank you",
                                    hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize:
                                            size.width * AppDimensions.numD035),
                                    disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            size.width * 0.03),
                                        borderSide: const BorderSide(
                                            width: 1, color: Colors.black)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            size.width * 0.03),
                                        borderSide: const BorderSide(
                                            width: 1, color: Colors.black)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            size.width * 0.03),
                                        borderSide: const BorderSide(
                                            width: 1, color: Colors.black)),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            size.width * 0.03),
                                        borderSide: const BorderSide(
                                            width: 1, color: Colors.black)),
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            size.width * 0.03),
                                        borderSide: const BorderSide(
                                            width: 1, color: Colors.black)),
                                    contentPadding: EdgeInsets.only(
                                        left: size.width * AppDimensions.numD08,
                                        right:
                                            size.width * AppDimensions.numD03,
                                        top: size.width * AppDimensions.numD04,
                                        bottom:
                                            size.width * AppDimensions.numD04),
                                    alignLabelWithHint: true,
                                  ),
                                  validator: checkRequiredValidator,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: size.width * AppDimensions.numD04,
                                    left: size.width * AppDimensions.numD01),
                                child: Icon(
                                  Icons.sticky_note_2_outlined,
                                  size: size.width * AppDimensions.numD06,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: size.width * AppDimensions.numD04,
                          ),
                          SizedBox(
                            height: size.width * AppDimensions.numD13,
                            width: size.width,
                            child: commonElevatedButton(
                                AppStrings.submitText,
                                size,
                                commonButtonTextStyle(size),
                                commonButtonStyle(
                                    size, AppColorTheme.colorThemePink),
                                () {}),
                          ),
                          SizedBox(
                            height: size.width * AppDimensions.numD04,
                          ),
                        ],
                      ),
                    ))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
