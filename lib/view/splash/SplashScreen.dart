import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:presshop/main.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/networkOperations/NetworkClass.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:presshop/view/authentication/UploadDocumnetsScreen.dart';
import 'package:presshop/view/dashboard/Dashboard.dart';
import 'package:presshop/view/walkThrough/WalkThrough.dart';
import '../../utils/CommonSharedPrefrence.dart';
import '../../utils/CommonWigdets.dart';
import '../authentication/LoginScreen.dart';
import '../bankScreens/AddBankScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    implements NetworkResponse {
  @override
  void initState() {
    super.initState();
    debugPrint("rememberMe: $rememberMe");
    if (rememberMe) {
      Future.delayed(Duration.zero, () {
        myProfileApi();
      });
    } else {
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Walkthrough()),
            (route) => false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * numD15),
        child: Image.asset(
          '${commonImagePath}ic_splash.png',
        ),
      ),
    );
  }

  ///-------ApisSection-----------
  void myProfileApi() {
    NetworkClass(myProfileUrl, this, myProfileUrlRequest)
        .callRequestServiceHeader(false, "get", null);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case myProfileUrlRequest:
          var map = jsonDecode(response);
          debugPrint("MyProfileError:$map");
          if (map == "Unauthorized") {
            rememberMe = false;
            sharedPreferences!.clear();
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false);
          }
          else {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Walkthrough()),
                (route) => false);
          }
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
        case myProfileUrlRequest:
          var map = jsonDecode(response);
          debugPrint("MyProfileSuccess:$map");

          if (map["code"] == 200) {
            // if(map["userData"]["verified"]){
            if (map["userData"]["bank_detail"] != null) {
              var bankList = map["userData"]["bank_detail"] as List;
             /* if (bankList.isEmpty) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen(
                        )),
                        (route) => false);
               */

              if (bankList.isEmpty) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) =>  const LoginScreen(
                        )),
                        (route) => false);
                /* onBoardingCompleteDialog(size:MediaQuery.of(context).size,func: (){
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => AddBankScreen(
                            showPageNumber: true,
                            hideLeading: true,
                            editBank: false,
                            myBankList: [],
                          )),
                          (route) => false);
                });*/
              }else{
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) =>  Dashboard(initialPosition:2,
                        )),
                        (route) => false);
              }

            }




          }

          break;
      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }
}
