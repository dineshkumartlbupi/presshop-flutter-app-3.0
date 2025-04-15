import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:presshop/utils/networkOperations/NetworkResponse.dart';
import 'package:presshop/view/authentication/WelcomeScreen.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../main.dart';
import 'Common.dart';
import 'CommonWigdets.dart';
import 'networkOperations/NetworkClass.dart';

class CommonWebView extends StatefulWidget {
  final String webUrl;
  final String title;
  final String accountId;
  final String type;

  const CommonWebView(
      {Key? key,
      required this.webUrl,
      required this.title,
      required this.accountId,
      required this.type,
      })
      : super(key: key);

  @override
  _CommonWebViewState createState() => _CommonWebViewState();
}

late WebViewController controllerGlobal;
bool isPageLoad = false;

Future<bool> _exitApp(BuildContext context) async {
  if (await controllerGlobal.canGoBack()) {
    debugPrint("onWillGoBack");
    controllerGlobal.goBack();
  } else {
    // showToast(message: "No back history item");
    return Future.value(false);
  }
  return false;
}

class _CommonWebViewState extends State<CommonWebView>
    implements NetworkResponse {
  late final WebViewController controller;

  @override
  void initState() {
    debugPrint("type::::::${widget.type}");
    super.initState();
    isPageLoad = true;

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint("onProgress :: $progress");
          },
          onPageStarted: (String url) {
            debugPrint("onPageStarted :: $url");
          },
          onPageFinished: (String url) {
            debugPrint("onPageFinished :: $url");
            isPageLoad = false;
            if (mounted) {
              setState(() {});
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("onWebResourceError :: $error");
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint("onNavigationRequest :: ${request.url}");
            if (request.url.contains("status=1")) {
              updateStripeAccountApi();
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.webUrl));
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return WillPopScope(
      onWillPop: () => _exitApp(navigatorKey.currentState!.context),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
            body: Stack(
          alignment: Alignment.topLeft,
          children: [
            isPageLoad
                ? showLoader()
                : Builder(builder: (BuildContext context) {
                    return WebViewWidget(
                      controller: controller,
                    );
                  }),
            /* InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: EdgeInsets.all(size.width*numD01),
                    padding: EdgeInsets.all(size.width * numD025),
                    decoration:  BoxDecoration(
                        color: Colors.grey.shade200, shape: BoxShape.circle),
                    child: Image.asset(
                      "${iconsPath}ic_arrow_left.png",
                      height: size.width * numD065,
                      width: size.width * numD065,
                    ),
                  ),
                ),*/
          ],
        )
            //floatingActionButton: favoriteButton(),
            ),
      ),
    );
  }

  updateStripeAccountApi() {
    NetworkClass(
            "${updateStripeBankUrl}id=${widget.accountId}&is_stripe_registered=true",
            this,
            updateStripeBankReq)
        .callRequestServiceHeader(true, "get", null);
  }

  @override
  void onError({required int requestCode, required String response}) {
    try {
      switch (requestCode) {
        case updateStripeBankReq:
          debugPrint("updateStripeBankReq:::::: error:::::::::$response");
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
        case updateStripeBankReq:
          debugPrint("updateStripeBankReq success:::::${widget.type}::::$response");

          if(widget.type=="myBank"){
            Navigator.pop(context);
          }else{
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => WelcomeScreen(hideLeading: false, screenType: '',)),
                    (route) => false);
          }
          break;

      }
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }
}
