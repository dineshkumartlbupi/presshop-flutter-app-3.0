import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../utils/Common.dart';
import '../../utils/CommonAppBar.dart';
import '../../utils/CommonWigdets.dart';

class ManageContentScreen extends StatefulWidget {
  String taskStatus = "";

  ManageContentScreen({super.key, required this.taskStatus});

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
          manageContentText,
          style: TextStyle(
              color: Colors.black, fontSize: size.width * headerFontSize),
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
            padding: EdgeInsets.symmetric(horizontal: size.width * numD04),
            child: Column(
              children: [
                SizedBox(
                  height: size.width * numD08,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(size.width * numD04),
                  child: Stack(
                    children: [
                      Image.asset(
                        "${dummyImagePath}dummy_content.png",
                        height: size.width * numD50,
                        width: size.width,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        right: size.width * numD02,
                        top: size.width * numD02,
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * numD01,
                                vertical: size.width * 0.002),
                            decoration: BoxDecoration(
                                color: colorLightGreen.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(
                                    size.width * numD015)),
                            child: Icon(
                              Icons.videocam_outlined,
                              size: size.width * numD06,
                              color: Colors.white,
                            )),
                      ),
                      Positioned(
                        right: size.width * numD02,
                        bottom: size.width * numD02,
                        child: Text(
                          "+2",
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD04,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Image.asset(
                        "${commonImagePath}watermark.png",
                        height: size.width * numD50,
                        width: size.width,
                        fit: BoxFit.cover,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * numD02,
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
                            fontSize: size.width * numD045,
                            color: Colors.black,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "${iconsPath}ic_exclusive.png",
                          height: size.width * numD05,
                        ),
                        SizedBox(
                          width: size.width * numD02,
                        ),
                        Text(
                          exclusiveText,
                          style: commonTextStyle(
                              size: size,
                              fontSize: size.width * numD04,
                              color: Colors.black,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: size.width * numD04,
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
                                height: size.width * numD05,
                                color: colorTextFieldIcon,
                              ),
                              SizedBox(
                                width: size.width * numD02,
                              ),
                              Text(
                                "12:36, 10:12:2021",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD035,
                                    color: colorHint,
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                          SizedBox(
                            height: size.width * numD02,
                          ),
                          Row(
                            children: [
                              Image.asset(
                                "${iconsPath}ic_location.png",
                                height: size.width * numD06,
                                color: colorTextFieldIcon,
                              ),
                              SizedBox(
                                width: size.width * numD02,
                              ),
                              Text(
                                "Grenfell Tower, London",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD035,
                                    color: colorHint,
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                          SizedBox(
                            height: size.width * numD02,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * numD06,
                          vertical: size.width * numD01),
                      decoration: BoxDecoration(
                          color: colorThemePink,
                          borderRadius:
                              BorderRadius.circular(size.width * numD03)),
                      child: Column(
                        children: [
                          Text(
                            priceQuotedText,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD035,
                                color: Colors.white,
                                fontWeight: FontWeight.normal),
                          ),
                          Text(
                            "${euroUniqueCode}350",
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD06,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: size.width * numD04,
                ),
                const Divider(
                  color: colorTextFieldIcon,
                ),
                SizedBox(
                  height: size.width * numD04,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: size.width * numD04),
                      padding: EdgeInsets.all(size.width * numD03),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade300, spreadRadius: 2)
                          ]),
                      child: Image.asset(
                        "${commonImagePath}rabbitLogo.png",
                        height: size.width * numD07,
                        width: size.width * numD07,
                      ),
                    ),
                    SizedBox(
                      width: size.width * numD04,
                    ),
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.only(top: size.width * numD06),
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * numD05,
                          vertical: size.width * numD02),
                      width: size.width,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(size.width * numD04),
                              bottomLeft: Radius.circular(size.width * numD04),
                              bottomRight:
                                  Radius.circular(size.width * numD04))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: size.width * numD04,
                          ),
                          Text(
                            "Congrats, you’ve received £200 from Reuters Media ",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD035,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: size.width * numD04,
                          ),
                          SizedBox(
                            height: size.width * numD13,
                            width: size.width,
                            child: commonElevatedButton(
                                viewDetailsText,
                                size,
                                commonButtonTextStyle(size),
                                commonButtonStyle(size, colorThemePink),
                                () {}),
                          )
                        ],
                      ),
                    ))
                  ],
                ),
                SizedBox(
                  height: size.width * numD07,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: size.width * numD04),
                      padding: EdgeInsets.all(size.width * numD01),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade300, spreadRadius: 2)
                          ]),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(size.width * numD04),
                        child: Image.asset(
                          "${dummyImagePath}news.png",
                          height: size.width * numD09,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: size.width * numD04,
                    ),
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.only(top: size.width * numD06),
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * numD05,
                          vertical: size.width * numD02),
                      width: size.width,
                      decoration: BoxDecoration(
                          color: colorLightGrey,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(size.width * numD04),
                              bottomLeft: Radius.circular(size.width * numD04),
                              bottomRight:
                                  Radius.circular(size.width * numD04))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: size.width * numD04,
                          ),
                          Text(
                            "Do you have additional pictures related to the task?",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD035,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: size.width * numD04,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: SizedBox(
                                height: size.width * numD13,
                                width: size.width,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              size.width * numD04),
                                          side: const BorderSide(
                                              color: colorGrey1, width: 2))),
                                  child: Text(
                                    noText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD04,
                                        color: colorLightGreen,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              )),
                              SizedBox(
                                width: size.width * numD04,
                              ),
                              Expanded(
                                  child: SizedBox(
                                height: size.width * numD13,
                                width: size.width,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: colorThemePink,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            size.width * numD04),
                                      )),
                                  child: Text(
                                    viewDetailsText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD04,
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
                  height: size.width * numD07,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: size.width * numD04),
                      padding: EdgeInsets.all(size.width * numD03),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade300, spreadRadius: 2)
                          ]),
                      child: Image.asset(
                        "${commonImagePath}rabbitLogo.png",
                        height: size.width * numD07,
                        width: size.width * numD07,
                      ),
                    ),
                    SizedBox(
                      width: size.width * numD04,
                    ),
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.only(top: size.width * numD06),
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * numD05,
                          vertical: size.width * numD02),
                      width: size.width,
                      decoration: BoxDecoration(
                          color: colorLightGrey,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(size.width * numD04),
                              bottomLeft: Radius.circular(size.width * numD04),
                              bottomRight:
                                  Radius.circular(size.width * numD04))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: size.width * numD04,
                          ),
                          Text(
                            "Send the content for approval",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD035,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: size.width * numD04,
                          ),
                          SizedBox(
                            height: size.width * numD13,
                            width: size.width,
                            child: commonElevatedButton(
                                uploadText,
                                size,
                                commonButtonTextStyle(size),
                                commonButtonStyle(size, colorThemePink),
                                () {}),
                          )
                        ],
                      ),
                    ))
                  ],
                ),
                SizedBox(
                  height: size.width * numD07,
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
                              borderRadius:
                                  BorderRadius.circular(size.width * numD04),
                              child: Image.asset(
                                "${dummyImagePath}walk6.png",
                                height: size.height / 3,
                                width: size.width / 1.7,
                                fit: BoxFit.cover,
                              )),
                          Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius:
                                    BorderRadius.circular(size.width * numD04),
                              ),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD04),
                                  child: Image.asset(
                                    "${commonImagePath}watermark.png",
                                    height: size.height / 3,
                                    width: size.width / 1.7,
                                    fit: BoxFit.cover,
                                  )))
                        ],
                      ),
                      SizedBox(
                        width: size.width * numD02,
                      ),
                      ClipRRect(
                          borderRadius:
                              BorderRadius.circular(size.width * numD08),
                          child: Image.asset(
                            "${dummyImagePath}avatar.png",
                            height: size.width * numD08,
                            width: size.width * numD08,
                            fit: BoxFit.cover,
                          ))
                    ],
                  ),
                ),
                SizedBox(
                  height: size.width * numD05,
                ),
                Row(
                  children: [
                    const Expanded(
                        child: Divider(
                      color: colorGrey1,
                      thickness: 1,
                    )),
                    Text(
                      "Pending reviews from Reuters",
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD035,
                          color: colorGrey2,
                          fontWeight: FontWeight.w600),
                    ),
                    const Expanded(
                        child: Divider(
                      color: colorGrey1,
                      thickness: 1,
                    )),
                  ],
                ),
                SizedBox(
                  height: size.width * numD07,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: size.width * numD04),
                      padding: EdgeInsets.all(size.width * numD01),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade300, spreadRadius: 2)
                          ]),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(size.width * numD04),
                        child: Image.asset(
                          "${dummyImagePath}news.png",
                          height: size.width * numD09,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: size.width * numD04,
                    ),
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.only(top: size.width * numD06),
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * numD05,
                          vertical: size.width * numD02),
                      width: size.width,
                      decoration: BoxDecoration(
                          color: colorLightGrey,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(size.width * numD04),
                              bottomLeft: Radius.circular(size.width * numD04),
                              bottomRight:
                                  Radius.circular(size.width * numD04))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: size.width * numD04,
                          ),
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(
                              text: "Reuters Media has offered ",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: "${euroUniqueCode}150 ",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: colorThemePink,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: "to buy your content",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                          ])),
                          SizedBox(
                            height: size.width * numD04,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: SizedBox(
                                height: size.width * numD13,
                                width: size.width,
                                child: ElevatedButton(
                                  onPressed: () {

                                  },
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              size.width * numD04),
                                          side: const BorderSide(
                                              color: colorGrey1, width: 2))),
                                  child: Text(
                                    rejectText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD04,
                                        color: colorLightGreen,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              )),
                              SizedBox(
                                width: size.width * numD04,
                              ),
                              Expanded(
                                  child: SizedBox(
                                height: size.width * numD13,
                                width: size.width,
                                child: ElevatedButton(
                                  onPressed: () {

                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: colorThemePink,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            size.width * numD04),
                                      )),
                                  child: Text(
                                    acceptText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD04,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              )),
                            ],
                          ),
                          SizedBox(
                            height: size.width * numD05,
                          ),
                          Row(
                            children: [
                              const Expanded(
                                  child: Divider(
                                color: colorTextFieldIcon,
                                thickness: 1,
                              )),
                              Text(
                                "or",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD035,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600),
                              ),
                              const Expanded(
                                  child: Divider(
                                color: colorTextFieldIcon,
                                thickness: 1,
                              )),
                            ],
                          ),
                          SizedBox(
                            height: size.width * numD04,
                          ),
                          SizedBox(
                            height: size.width * numD13,
                            width: size.width,
                            child: commonElevatedButton(
                                "Make a Counter Offer",
                                size,
                                commonButtonTextStyle(size),
                                commonButtonStyle(size, colorThemePink),
                                () {}),
                          ),
                          SizedBox(
                            height: size.width * numD04,
                          ),
                          Text(
                            "You can make a counter offer only once",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD035,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ))
                  ],
                ),
                SizedBox(
                  height: size.width * numD07,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: size.width * numD04),
                      padding: EdgeInsets.all(size.width * numD03),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade300, spreadRadius: 2)
                          ]),
                      child: Image.asset(
                        "${commonImagePath}rabbitLogo.png",
                        height: size.width * numD07,
                        width: size.width * numD07,
                      ),
                    ),
                    SizedBox(
                      width: size.width * numD04,
                    ),
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.only(top: size.width * numD06),
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * numD05,
                          vertical: size.width * numD02),
                      width: size.width,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(size.width * numD04),
                              bottomLeft: Radius.circular(size.width * numD04),
                              bottomRight:
                                  Radius.circular(size.width * numD04))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: size.width * numD04,
                          ),
                          Text(
                            "Make a counter offer to Reuters Media",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD035,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: size.width * numD04,
                          ),
                          SizedBox(
                            height: size.width * numD13,
                            width: size.width,
                            child: TextFormField(
                              cursorColor: colorTextFieldIcon,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true, signed: true),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                filled: false,
                                hintText: "Enter price here...",
                                hintStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: size.width * numD04),
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
                            height: size.width * numD04,
                          ),
                          SizedBox(
                            height: size.width * numD13,
                            width: size.width,
                            child: commonElevatedButton(
                                "submitText",
                                size,
                                commonButtonTextStyle(size),
                                commonButtonStyle(size, colorThemePink),
                                () {}),
                          ),
                          SizedBox(
                            height: size.width * numD04,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "${iconsPath}ic_tag.png",
                                height: size.width * numD06,
                              ),
                              SizedBox(
                                width: size.width * numD02,
                              ),
                              Expanded(
                                child: Text(
                                  "Check price tips, and learnings",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD035,
                                      color: colorThemePink,
                                      fontWeight: FontWeight.w600),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: size.width * numD04,
                          ),
                          Text(
                            "You can make a counter offer only once",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD031,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ))
                  ],
                ),
                SizedBox(
                  height: size.width * numD07,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: size.width * numD04),
                      padding: EdgeInsets.all(size.width * numD01),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade300, spreadRadius: 2)
                          ]),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(size.width * numD04),
                        child: Image.asset(
                          "${dummyImagePath}news.png",
                          height: size.width * numD09,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: size.width * numD04,
                    ),
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.only(top: size.width * numD06),
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * numD05,
                          vertical: size.width * numD02),
                      width: size.width,
                      decoration: BoxDecoration(
                          color: colorLightGrey,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(size.width * numD04),
                              bottomLeft: Radius.circular(size.width * numD04),
                              bottomRight:
                                  Radius.circular(size.width * numD04))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: size.width * numD04,
                          ),
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(
                              text:
                                  "Reuters Media have increased their offered to ",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: "${euroUniqueCode}200 ",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: colorThemePink,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: "to buy your content",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                          ])),
                          SizedBox(
                            height: size.width * numD04,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: SizedBox(
                                height: size.width * numD13,
                                width: size.width,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              size.width * numD04),
                                          side: const BorderSide(
                                              color: colorGrey1, width: 2))),
                                  child: Text(
                                    rejectText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD04,
                                        color: colorLightGreen,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              )),
                              SizedBox(
                                width: size.width * numD04,
                              ),
                              Expanded(
                                  child: SizedBox(
                                height: size.width * numD13,
                                width: size.width,
                                child: ElevatedButton(
                                  onPressed: () {

                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: colorThemePink,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            size.width * numD04),
                                      )),
                                  child: Text(
                                    acceptText,
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD04,
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
                  height: size.width * numD07,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: size.width * numD04),
                      padding: EdgeInsets.all(size.width * numD03),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade300, spreadRadius: 2)
                          ]),
                      child: Image.asset(
                        "${commonImagePath}rabbitLogo.png",
                        width: size.width * numD07,
                      ),
                    ),
                    SizedBox(
                      width: size.width * numD04,
                    ),
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.only(top: size.width * numD06),
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * numD05,
                          vertical: size.width * numD02),
                      width: size.width,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(size.width * numD04),
                              bottomLeft: Radius.circular(size.width * numD04),
                              bottomRight:
                                  Radius.circular(size.width * numD04))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: size.width * numD04,
                          ),
                          Text(
                            "Congrats, you’ve received £200 from Reuters Media ",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD035,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: size.width * numD04,
                          ),
                          SizedBox(
                            height: size.width * numD13,
                            width: size.width,
                            child: commonElevatedButton(
                                viewDetailsText,
                                size,
                                commonButtonTextStyle(size),
                                commonButtonStyle(size, colorThemePink),
                                () {}),
                          )
                        ],
                      ),
                    ))
                  ],
                ),
                SizedBox(
                  height: size.width * numD07,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: size.width * numD04),
                      padding: EdgeInsets.all(size.width * numD03),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade300, spreadRadius: 2)
                          ]),
                      child: Image.asset(
                        "${commonImagePath}rabbitLogo.png",
                        width: size.width * numD07,
                      ),
                    ),
                    SizedBox(
                      width: size.width * numD04,
                    ),
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.only(top: size.width * numD06),
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * numD05,
                          vertical: size.width * numD02),
                      width: size.width,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(size.width * numD04),
                              bottomLeft: Radius.circular(size.width * numD04),
                              bottomRight:
                                  Radius.circular(size.width * numD04))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: size.width * numD04,
                          ),
                          Text(
                            "Rate your experience with Reuters Media",
                            style: commonTextStyle(
                                size: size,
                                fontSize: size.width * numD035,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: size.width * numD04,
                          ),
                          RatingBar(
                            ratingWidget: RatingWidget(
                              empty:
                                  Image.asset("${iconsPath}ic_empty_star.png"),
                              full: Image.asset("${iconsPath}ic_full_star.png"),
                              half: Image.asset("${iconsPath}ic_half_star.png"),
                            ),
                            onRatingUpdate: (value) {},
                            itemSize: size.width * numD09,
                            itemCount: 5,
                            initialRating: 0,
                            allowHalfRating: true,
                            itemPadding:
                                EdgeInsets.only(left: size.width * numD03),
                          ),
                          SizedBox(
                            height: size.width * numD04,
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Write your review here",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD035,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          SizedBox(
                            height: size.width * numD04,
                          ),
                          Stack(
                            children: [
                              SizedBox(
                                height: size.width * numD35,
                                child: TextFormField(
                                  cursorColor: colorTextFieldIcon,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintText:
                                        "Please share your feedback on your experience with the publication. Your feedback is very important for improving your experience, and our service. Thank you",
                                    hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: size.width * numD035),
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
                                        left: size.width * numD08,
                                        right: size.width * numD03,
                                        top: size.width * numD04,
                                        bottom: size.width * numD04),
                                    alignLabelWithHint: true,
                                  ),
                                  validator: checkRequiredValidator,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: size.width * numD04,
                                    left: size.width * numD01),
                                child: Icon(
                                  Icons.sticky_note_2_outlined,
                                  size: size.width * numD06,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: size.width * numD04,
                          ),
                          SizedBox(
                            height: size.width * numD13,
                            width: size.width,
                            child: commonElevatedButton(
                                submitText,
                                size,
                                commonButtonTextStyle(size),
                                commonButtonStyle(size, colorThemePink),
                                () {

                                }),
                          ),
                          SizedBox(
                            height: size.width * numD04,
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
