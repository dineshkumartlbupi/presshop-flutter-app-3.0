import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/utils/commonWebView.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';

import '../../main.dart';
import '../../utils/CommonAppBar.dart';
import '../../utils/CommonSharedPrefrence.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../dashboard/Dashboard.dart';

class MyBanksScreen extends StatefulWidget {
  const MyBanksScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return MyBanksScreenState();
  }
}

class MyBanksScreenState extends State<MyBanksScreen>
    implements NetworkResponse {
  List<MyBankListData> myBankList = [];
  String deleteBankId = '';
  bool isLoading = false;
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      bankListApi();
    });
  }

  void selectDefault(int index) {
    if (selectedIndex == index) {
      selectedIndex = -1;
      myBankList[index].isDefault = false;
    } else {
      if (selectedIndex != -1) {
        myBankList[selectedIndex].isDefault = false;
      }
      myBankList[index].isDefault = true;
      selectedIndex = index;
      setState(() {});
      Future.delayed(Duration(seconds: 1), () {
        var selectedBank = myBankList.removeAt(index);
        myBankList.insert(0, selectedBank);
        setAsDefaultAPi(true, myBankList[index].stripeBankId);
        selectedIndex = -1;
        setState(() {});
      });
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(

        /// app-bar
        appBar: CommonAppBar(
          elevation: 0,
          hideLeading: false,
          title: Text(
            paymentMethods,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: size.width * appBarHeadingFontSize),
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

        /// body
        body: isLoading
            ? SafeArea(
                child: myBankList.isNotEmpty
                    ? upliftAccountsPaymentDesign(size)
                    : upliftNoAccountsPaymentDesign(size))
            : showLoader());
  }

  Widget upliftAccountsPaymentDesign(Size size) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(size.width * numD05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hi ${sharedPreferences!.getString(userNameKey)}",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: size.width * numD05,
                    fontWeight: FontWeight.bold)),
            SizedBox(
              height: size.height * numD03,
            ),
            Center(
              child: Image.asset(
                "${iconsPath}payment_page_icon_2.png",
              ),
            ),
            SizedBox(
              height: size.width * numD02,
            ),
            Container(
              decoration: BoxDecoration(
                color: colorLightWhite,
                borderRadius: BorderRadius.circular(size.width * numD03),
                border: Border.all(color: Colors.black),
              ),
              padding: EdgeInsets.all(size.width * numD04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Manage your bank account on Stripe",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: size.width * numD033,
                          fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: size.width * numD02,
                  ),
                  Container(
                      decoration: BoxDecoration(
                        color: colorLightWhite,
                        borderRadius:
                            BorderRadius.circular(size.width * numD03),
                        border: Border.all(color: Colors.black),
                      ),
                      padding: EdgeInsets.all(size.width * numD02),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(size.width * numD02),
                                child: Image.network(
                                  myBankList[0].bankImage,
                                  height: size.width * numD11,
                                  width: size.width * numD11,
                                  fit: BoxFit.contain,
                                  errorBuilder: (c, s, o) {
                                    return Container(
                                      height: size.width * numD11,
                                      width: size.width * numD11,
                                      decoration: BoxDecoration(
                                        color: colorLightGrey,
                                        borderRadius: BorderRadius.circular(
                                            size.width * numD02),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(
                                width: size.width * numD02,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        myBankList[0].bankName,
                                        maxLines: 1,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: size.width * numD028,
                                            fontFamily: "AirbnbCereal",
                                            overflow: TextOverflow.ellipsis,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      SizedBox(
                                        width: size.width * numD01,
                                      ),
                                      Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical:
                                                  2), // Adjust padding for tag size
                                          decoration: BoxDecoration(
                                            color: Colors.blueGrey[
                                                100], // Background color of the tag
                                            borderRadius: BorderRadius.circular(
                                                5), // Rounded corners
                                          ),
                                          child: Text(
                                            myBankList[0].curreny.toUpperCase(),
                                            maxLines: 1,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: size.width * numD028,
                                                fontFamily: "AirbnbCereal",
                                                overflow: TextOverflow.ellipsis,
                                                fontWeight: FontWeight.normal),
                                          ))
                                    ],
                                  ),
                                  SizedBox(
                                    height: size.width * numD015,
                                  ),
                                  Text(
                                    "********${myBankList[0].accountNumber}",
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD025,
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * numD028,
                                    vertical: size.width * numD01),
                                decoration: BoxDecoration(
                                    color: colorThemePink,
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD03)),
                                child: Text(
                                  defaultText,
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD028,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Container(
                                margin:
                                    EdgeInsets.only(top: size.width * 0.014),
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * numD028,
                                    vertical: size.width * 0.008),
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(
                                        size.width * numD03)),
                                child: Text(
                                  "Verified",
                                  style: commonTextStyle(
                                      size: size,
                                      fontSize: size.width * numD028,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                              )
                            ],
                          )
                        ],
                      )),
                  SizedBox(
                    height: size.width * numD02,
                  ),
                  RichText(
                      text: TextSpan(
                    children: [
                      TextSpan(
                          text:
                              "This is your connected bank account on Stripe — where your payments will be sent.\n\n",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * numD032,
                              fontWeight: FontWeight.normal)),
                      TextSpan(
                          text:
                              "Need to update your details or switch to a different account? Simply click below to log into Stripe and make any changes you need.",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * numD032,
                              fontWeight: FontWeight.normal)),
                    ],
                  )),
                ],
              ),
            ),
            SizedBox(
              height: size.height * numD06,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: size.width * numD06,
              children: [
                Expanded(
                  child: SizedBox(
                    height: size.width * numD13,
                    child: commonElevatedButton(
                        "Update Your Details",
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, Colors.black), () {
                      generateAddBankApi();
                    }),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: size.width * numD13,
                    child: commonElevatedButton(
                        "Change Bank Account",
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, colorThemePink), () {
                      generateAddBankApi();
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget upliftNoAccountsPaymentDesign(Size size) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(size.width * numD05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hi ${sharedPreferences!.getString(userNameKey)}",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: size.width * numD06,
                    fontWeight: FontWeight.bold)),
            SizedBox(
              height: size.height * numD04,
            ),
            Image.asset(
              "${iconsPath}payment_page_icon.png",
            ),
            SizedBox(
              height: size.width * numD02,
            ),
            Container(
              decoration: BoxDecoration(
                color: colorLightWhite,
                borderRadius: BorderRadius.circular(size.width * numD03),
                border: Border.all(color: Colors.black),
              ),
              padding: EdgeInsets.all(size.width * numD04),
              child: RichText(
                  text: TextSpan(
                text: "Ready to get paid?\n\n",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: size.width * numD03,
                    fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                      text:
                          "Set up your Stripe account now to receive payments within 2-7 days when your content is purchased.\n\n",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: size.width * numD032,
                          fontWeight: FontWeight.normal)),
                  TextSpan(
                      text:
                          "Just tap the CTA below to get started - it takes less than a minute.\n\n",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: size.width * numD032,
                          fontWeight: FontWeight.normal)),
                ],
              )),
            ),
            SizedBox(
              height: size.height * numD06,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: size.width * numD06,
              children: [
                Expanded(
                  child: SizedBox(
                    height: size.width * numD13,
                    child: commonElevatedButton(
                        "Camera",
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, Colors.black), () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Dashboard(initialPosition: 2)));
                    }),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: size.width * numD13,
                    child: commonElevatedButton(
                        "Sign Up With Stripe",
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, colorThemePink), () {
                      generateAddBankApi();
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget legecyDesign(Size size) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: Container(
            padding: EdgeInsets.only(
                right: size.width * numD04, top: size.width * numD02),
            height: size.width * numD11,
            child: ElevatedButton.icon(
                onPressed: () {
                  generateAddBankApi();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: colorThemePink,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(size.width * numD03))),
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: size.width * numD06,
                ),
                label: Text("Add new bank",
                    style: commonTextStyle(
                        size: size,
                        fontSize: size.width * numD033,
                        color: Colors.white,
                        fontWeight: FontWeight.normal))),
          ),
        ),
        Expanded(
            child: ListView.separated(
                padding: EdgeInsets.symmetric(
                  vertical: size.width * numD035,
                  horizontal: size.width * numD03,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                        color: index == 0 ? colorGreyChat : Colors.white,
                        borderRadius:
                            BorderRadius.circular(size.width * numD03),
                        border: Border.all(color: Colors.grey.shade300)),
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * numD025,
                        vertical: size.width * numD02),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(size.width * numD02),
                          child: Image.network(
                            myBankList[index].bankImage,
                            height: size.width * numD11,
                            width: size.width * numD11,
                            fit: BoxFit.contain,
                            errorBuilder: (c, s, o) {
                              return Container(
                                height: size.width * numD11,
                                width: size.width * numD11,
                                decoration: BoxDecoration(
                                  color: colorLightGrey,
                                  borderRadius: BorderRadius.circular(
                                      size.width * numD02),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: size.width * numD02,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  myBankList[index].bankName,
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: size.width * numD035,
                                      fontFamily: "AirbnbCereal",
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.normal),
                                ),
                                SizedBox(
                                  width: size.width * numD01,
                                ),
                                Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical:
                                            2), // Adjust padding for tag size
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey[
                                          100], // Background color of the tag
                                      borderRadius: BorderRadius.circular(
                                          5), // Rounded corners
                                    ),
                                    child: Text(
                                      myBankList[index].curreny.toUpperCase(),
                                      maxLines: 1,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: size.width * numD03,
                                          fontFamily: "AirbnbCereal",
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.normal),
                                    ))
                              ],
                            ),
                            SizedBox(
                              height: size.width * numD015,
                            ),
                            Text(
                              "********${myBankList[index].accountNumber}",
                              style: commonTextStyle(
                                  size: size,
                                  fontSize: size.width * numD03,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Visibility(
                              visible: index > 0,
                              child: InkWell(
                                onTap: () {
                                  generateAddBankApi();
                                },
                                child: Icon(Icons.edit,
                                    color: Colors.black,
                                    size: size.width * numD055),
                              ),
                            ),
                            SizedBox(
                              height: size.width * numD018,
                            ),
                            Visibility(
                              visible: index == 0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: size.width * numD028,
                                        vertical: size.width * numD01),
                                    decoration: BoxDecoration(
                                        color: colorThemePink,
                                        borderRadius: BorderRadius.circular(
                                            size.width * numD03)),
                                    child: Text(
                                      defaultText,
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD028,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: size.width * 0.014),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: size.width * numD028,
                                        vertical: size.width * 0.008),
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(
                                            size.width * numD03)),
                                    child: Text(
                                      "Verified",
                                      style: commonTextStyle(
                                          size: size,
                                          fontSize: size.width * numD028,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Visibility(
                              visible: index > 0,
                              child: Container(
                                color: Colors.transparent,
                                margin: EdgeInsets.only(
                                    right: size.width * numD006),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                    selectDefault(index);
                                  },
                                  child: Text(
                                    myBankList[index]
                                        .available_payout_methods
                                        .first
                                        .toCapitalized(),
                                    style: commonTextStyle(
                                        size: size,
                                        fontSize: size.width * numD035,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  //  Row(
                                  //   children: [
                                  //     Text(
                                  //       "Set as default",
                                  //       style: commonTextStyle(
                                  //           size: size,
                                  //           fontSize: size.width *
                                  //               numD035,
                                  //           color: Colors.black,
                                  //           fontWeight:
                                  //               FontWeight.w400),
                                  //     ),
                                  //     SizedBox(
                                  //       width: size.width * numD01,
                                  //     ),
                                  //     Image.asset(
                                  //         selectedIndex == index
                                  //             ? "${iconsPath}ic_checkbox_filled.png"
                                  //             : "${iconsPath}ic_checkbox_empty.png",
                                  //         height:
                                  //             size.width * numD055),
                                  //   ],
                                  // ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: size.width * numD04,
                  );
                },
                itemCount: myBankList.length)),
      ],
    );
  }

  void deleteBankDialog(Size size, BuildContext context, int index) {
    showDialog(
        context: navigatorKey.currentState!.context,
        barrierDismissible: false,
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
                        SizedBox(
                          height: size.width * numD02,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: size.width * numD04),
                          child: Row(
                            children: [
                              Text(
                                "Delete bank?",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: size.width * numD05,
                                    fontFamily: "AirbnbCereal",
                                    fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Image.asset(
                                    "${iconsPath}cross.png",
                                    width: size.width * numD065,
                                    height: size.width * numD065,
                                    color: Colors.black,
                                  ))
                            ],
                          ),
                        ),
                        const Divider(
                          color: Colors.black,
                          thickness: 0.5,
                        ),
                        SizedBox(
                          height: size.width * numD02,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: size.width * numD035,
                              right: size.width * numD035),
                          child: Text(
                            "Are you sure you wish to delete this bank account?",
                            style: TextStyle(
                                fontSize: size.width * numD038,
                                color: Colors.black,
                                fontFamily: "AirbnbCereal",
                                fontWeight: FontWeight.w400,
                                height: 1.5),
                          ),
                        ),
                        SizedBox(
                          height: size.width * numD05,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: size.width * numD035,
                              right: size.width * numD035),
                          child: Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: size.width * numD13,
                                  child: commonElevatedButton(
                                      "Cancel",
                                      size,
                                      commonButtonTextStyle(size),
                                      commonButtonStyle(size, Colors.black),
                                      () {
                                    Navigator.pop(context);
                                  }),
                                ),
                              ),
                              SizedBox(
                                width: size.width * numD04,
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: size.width * numD13,
                                  child: commonElevatedButton(
                                      "Delete",
                                      size,
                                      commonButtonTextStyle(size),
                                      commonButtonStyle(size, colorThemePink),
                                      () {
                                    Navigator.pop(context);
                                    deleteBankApi(myBankList[index].id,
                                        myBankList[index].stripeBankId);
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: size.width * numD05,
                        ),
                      ],
                    ),
                  );
                },
              ));
        });
  }

  ///ApisSection------------

  void bankListApi() {
    try {
      NetworkClass(bankListUrl, this, bankListUrlRequest)
          .callRequestServiceHeader(false, "get", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  void generateAddBankApi() {
    try {
      NetworkClass(generateStripeBankApi, this, generateStripeBankUrlRequest)
          .callRequestServiceHeader(true, "get", null);
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  void deleteBankApi(String id, String stripeBankId) {
    debugPrint("id:::::::$id/$stripeBankId");
    NetworkClass("$deleteBankUrl$id/$stripeBankId", this, deleteBankUrlRequest)
        .callRequestServiceHeader(false, "delete", null);
  }

  void setAsDefaultAPi(bool isDefault, String stripBankId) {
    Map<String, String> map = {
      "is_default": isDefault.toString(),
      "stripe_bank_id": stripBankId,
    };
    debugPrint("map:::::::::: $map");
    NetworkClass.fromNetworkClass(editBankUrl, this, editBankUrlRequest, map)
        .callRequestServiceHeader(false, "patch", null);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case bankListUrlRequest:
          var map = jsonDecode(response);
          debugPrint("BankListError:$map");
          isLoading = false;
          break;

        case generateStripeBankUrlRequest:
          var map = jsonDecode(response);
          debugPrint("generateStripeBankUrlRequest:$map");
          showToast(map['error'] ?? "Something went wrong");
          break;

        case deleteBankUrlRequest:
          var map = jsonDecode(response);
          debugPrint("deleteBankUrlRequest:::::$map");
          break;

        case editBankUrlRequest:
          var map = jsonDecode(response);
          debugPrint("editBankUrlRequest::::::::$map");

          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  @override
  void onResponse({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case bankListUrlRequest:
          var map = jsonDecode(response);
          log("bankListUrlRequest::::::::::::::::::::::::::::::$map");
          if (map["code"] == 200) {
            var list = map["bankList"] as List;
            myBankList = list.map((e) => MyBankListData.fromJson(e)).toList();
          }

          isLoading = true;
          debugPrint("bankListUrlRequest length::::${myBankList.length}");
          setState(() {});
          break;

        case generateStripeBankUrlRequest:
          var data = jsonDecode(response);
          debugPrint("generateStripeBankUrlRequest::::::::::::$data");
          Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (context) => CommonWebView(
                        webUrl: data['accountLink'],
                        title: "Add Bank",
                        accountId: "",
                        type: "",
                      )))
              .then((value) {
            if (value == true) {
              bankListApi();
            }
          });
          break;
        case deleteBankUrlRequest:
          var map = jsonDecode(response);
          log("deleteBankUrlRequest::::::::::::::::$map");
          bankListApi();

          break;

        case editBankUrlRequest:
          var map = jsonDecode(response);
          debugPrint(" success::::::::$map");

          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  ///
}

class MyBankListData {
  String id = "";
  String bankName = "";
  String bankImage = "";
  String bankLocation = "";
  String curreny = "";
  bool isDefault = false;
  bool isSelected = false;
  String accountHolderName = "";
  String sortCode = "";
  String accountNumber = "";
  String stripeBankId = "";
  List<String> available_payout_methods = [];

  MyBankListData.fromJson(json) {
    id = json["bank_detail"] != null ? json['bank_detail']["_id"] : "";
    bankName = json["bank_name"] ?? "";
    isDefault = json["is_default"] ?? false;
    bankImage = json["bank_info"] != null
        ? json["bank_info"]["logoUrl"]
        : "https://logo.clearbit.com/stripe.com";
    bankLocation = "Mayfair, London";
    accountHolderName = json["bank_detail"] != null
        ? json["bank_detail"]["acc_holder_name"].toString()
        : "";
    sortCode = json["sort_code"] != null ? json["sort_code"].toString() : "";
    accountNumber =
        json["acc_number"] != null ? json['acc_number'].toString() : "";
    stripeBankId = json["bank_detail"] != null
        ? json["bank_detail"]["stripe_bank_id"].toString()
        : "";
    available_payout_methods = json["available_payout_methods"] != null
        ? List<String>.from(json["available_payout_methods"])
        : [];
    curreny = json["currency"] ?? "GBP";
    isSelected = false;
  }
}

class MyBankData {
  String id = "";
  String bankName = "";
  String bankImage = "";
  bool isSelected = false;

  MyBankData.fromJson(json) {
    id = json["_id"] ?? "";
    bankName = json["bank_name"] ?? "";
    bankImage = json["logoUrl"] ?? "";
    isSelected = false;
  }
}
