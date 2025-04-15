import 'package:flutter/material.dart';
import 'package:presshop/main.dart';
import 'package:presshop/utils/Common.dart';
import 'package:presshop/utils/CommonExtensions.dart';
import 'package:presshop/utils/CommonSharedPrefrence.dart';
import 'package:presshop/utils/CommonWigdets.dart';
import 'package:presshop/view/menuScreen/MyDraftScreen.dart';
import '../../utils/CommonAppBar.dart';
import '../dashboard/Dashboard.dart';

class WelcomeScreen extends StatefulWidget {
  bool hideLeading = false;
  String screenType = "";

  WelcomeScreen({super.key, required this.hideLeading,required this.screenType});

  @override
  State<StatefulWidget> createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  String userName = sharedPreferences!.getString(userNameKey) ?? '';

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Form(
          child: ListView(
            padding: EdgeInsets.symmetric(
                horizontal: size.width * numD06, vertical: size.width * numD05),
            children: [
              Text('${greeting()} $userName,',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontFamily: "AirbnbCereal",
                    fontSize: size.width * numD07),
              ),
              Row(
                children: [
                  Text("welcome to PRESS",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontFamily: "AirbnbCereal",
                        fontSize: size.width * numD07),
                  ),
                  Text("HOP",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        fontFamily: "AirbnbCereal",
                        fontSize: size.width * numD07),
                  ),
                ],
              ),



              SizedBox(
                height: size.width * numD02,
              ),
              Text(
                welcomeSubTitleText,
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: "AirbnbCereal",
                    fontSize: size.width * numD035),
              ),
              SizedBox(
                height: size.width * numD08,
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(size.width * numD03)),
                padding: EdgeInsets.all(size.width * numD04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(welcomeSubTitle1Text,
                        style: commonTextStyle(
                            size: size,
                            fontSize: size.width * numD035,
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: size.width * numD04,
                    ),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: colorThemePink,
                            size: size.width * numD06,
                          ),
                          SizedBox(
                            width: size.width * numD02,
                          ),
                          Expanded(
                            child: Text(acceptedTermsText,
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD035,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400)),
                          ),
                        ]),
                    SizedBox(
                      height: size.width * numD03,
                    ),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: colorThemePink,
                            size: size.width * numD06,
                          ),
                          SizedBox(
                            width: size.width * numD02,
                          ),
                          Expanded(
                            child: Text("Verified your mobile number",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD035,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400)),
                          ),
                        ]),
                    SizedBox(
                      height: size.width * numD03,
                    ),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: colorThemePink,
                            size: size.width * numD06,
                          ),
                          SizedBox(
                            width: size.width * numD02,
                          ),
                          Expanded(
                            child: Text("Added your bank details to start receiving money",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD035,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400)),
                          ),
                        ]),
                    SizedBox(
                      height: size.width * numD03,
                    ),
                   Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                                  Icons.check_circle,
                                  color: colorThemePink,
                                  size: size.width * numD06,
                                ),

                          SizedBox(
                            width: size.width * numD02,
                          ),
                          Expanded(
                            child: Text("Uploaded documents for your bank verification*",
                                style: commonTextStyle(
                                    size: size,
                                    fontSize: size.width * numD035,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400)),
                          ),
                        ]),
                    SizedBox(height: size.width * numD04),
                    Text(
                      "* Your documents are in, and Stripe is now reviewing them. This process usually takes 2-3 days. Sit tight – we'll notify you once the verification is complete, and you'll be ready to receive your funds.",
                   textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: "AirbnbCereal",
                          fontSize: size.width * numD032),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: size.width * numD15,
              ),
         /*     Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                      child: SizedBox(
                    height: size.width * numD15,
                    child: commonElevatedButton(
                        myAccountText,
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, Colors.black), () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => Dashboard(
                                    initialPosition: 4,
                                  )),
                          (route) => false);
                    }),
                  )),
                  SizedBox(
                    width: size.width * numD04,
                  ),
                  Expanded(
                      child: SizedBox(
                    height: size.width * numD15,
                    child: commonElevatedButton(
                        cameraText,
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, colorThemePink), () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Dashboard(initialPosition: 2)));
                    }),
                  )),
                ],
              ),*/
              SizedBox(
                height: size.width * numD13,
                child: commonElevatedButton(
                   widget.screenType=="publish"?"Submit Your Content":"Finish",
                    size,
                    commonButtonTextStyle(size),
                    commonButtonStyle(size, colorThemePink), () {
                     
                     if(widget.screenType=="publish"){
                       Navigator.push(
                           context,
                           MaterialPageRoute(
                               builder: (context) =>
                                   MyDraftScreen(publishedContent: false,screenType:"welcome")));
                     }else{
                       Navigator.push(
                           context,
                           MaterialPageRoute(
                               builder: (context) =>
                                   Dashboard(initialPosition: 2)));
                     }
                
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
