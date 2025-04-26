import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/view/authentication/LoginScreen.dart';

import '../../main.dart';
import '../../utils/Common.dart';
import '../../utils/networkOperations/NetworkClass.dart';
import '../../utils/networkOperations/NetworkResponse.dart';

class AccountDeleteScreen extends StatefulWidget {
  const AccountDeleteScreen({super.key});

  @override
  State<AccountDeleteScreen> createState() => _AccountDeleteScreenState();
}

class _AccountDeleteScreenState extends State<AccountDeleteScreen>
    implements NetworkResponse {
  List<dynamic> purposeData = [...purposeForDeleteAccount];
  Map<String, String> selectReason = {};

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: CommonAppBar(
        elevation: 0,
        hideLeading: false,
        title: Text(
          "Delete Account",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: size.width * appBarHeadingFontSize),
        ),
        centerTitle: false,
        titleSpacing: 0,
        size: size,
        showActions: true,
        leadingFxn: () {
          /*  if (widget.editProfileScreen) {
              widget.editProfileScreen = false;
            }*/
          Navigator.pop(context);
        },
        actionWidget: [],
      ),
      body: Padding(
        padding: EdgeInsets.all(size.width * numD045),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              deleteAccountText,
              style: commonTextStyle(
                  size: size,
                  fontSize: size.width * numD035,
                  color: Colors.red,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: size.height * numD02,
            ),
            Text(
              "Select delete reason:- ",
              style: commonTextStyle(
                  size: size,
                  fontSize: size.width * numD04,
                  color: Colors.black,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: size.height * numD01,
            ),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: Colors.grey),
                padding: isIpad
                    ? EdgeInsets.symmetric(vertical: size.width * numD012)
                    : EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                itemCount: purposeData.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (ctx, int) {
                  return ListTile(
                    contentPadding: isIpad
                        ? EdgeInsets.symmetric(vertical: size.width * numD02)
                        : EdgeInsets.zero,
                    leading: Transform.scale(
                      scale: isIpad ? 1.8 : 1,
                      child: Checkbox(
                        visualDensity: VisualDensity.compact,
                        value: selectReason == purposeData[int],
                        onChanged: (value) {
                          selectReason = purposeData[int];
                          setState(() {});
                        },
                        activeColor: colorThemePink,
                        checkColor: Colors.white,
                      ),
                    ),
                    title: Text(
                      purposeData[int]['title'],
                      style: commonTextStyle(
                          size: size,
                          fontSize: size.width * numD034,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              height: size.height * (isIpad ? numD1 : numD08),
              padding: EdgeInsets.symmetric(vertical: size.height * numD015),
              child: commonElevatedButton(
                'Permanent Delete',
                size,
                commonTextStyle(
                    size: size,
                    fontSize: size.width * (isIpad ? numD032 : numD038),
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
                commonButtonStyle(size, colorThemePink),
                () {
                  if (selectReason.isNotEmpty) {
                    showDeleteDialog(size);
                  } else {
                    showToast("Please select reason...");
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void showDeleteDialog(Size size) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            contentPadding: EdgeInsets.zero,
            insetPadding: EdgeInsets.symmetric(horizontal: size.width * numD02),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Container(
                width: size.width * num1,
                height: size.height * numD18,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size.width * numD025),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      "Do you want to proceed this?",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.width * numD045,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: size.height * 0.04,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: size.width * numD40,
                          height: size.height * numD055,
                          child: commonElevatedButton(
                              "Proceed",
                              size,
                              commonButtonTextStyle(size),
                              commonButtonStyle(size, Colors.grey), () {
                            Navigator.pop(context);
                            NetworkClass.fromNetworkClass(deleteAccountUrl,
                                    this, deleteAccountUrlReq, selectReason)
                                .callRequestServiceHeader(true, "post", null);
                          }),
                        ),
                        SizedBox(
                          width: size.width * 0.02,
                        ),
                        SizedBox(
                          width: size.width * numD40,
                          height: size.height * numD055,
                          child: commonElevatedButton(
                              "Cancel",
                              size,
                              commonButtonTextStyle(size),
                              commonButtonStyle(size, colorThemePink), () {
                            Navigator.pop(context);
                          }),
                        )
                      ],
                    )
                  ],
                ),
              );
            }),
          );
        });
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case deleteAccountUrlReq:
          debugPrint("deleteAccount error: $response");
          var map = jsonDecode(response);
          showSnackBar(
              "Error",
              map["body"].toString().replaceAll("_", " ").toCapitalized(),
              Colors.red);
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
        case deleteAccountUrlReq:
          var map = jsonDecode(response);
          debugPrint("deleteAccount response: $response");
          if (map["code"] == 200) {
            sharedPreferences!.clear();
            googleSignIn.signOut();
            showToast(map['message']);
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false);
          }
          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }
}
