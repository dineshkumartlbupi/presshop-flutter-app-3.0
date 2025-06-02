import 'dart:async';
import 'package:flutter/material.dart';
import 'package:presshop/utils/CommonAppBar.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../main.dart';
import 'Common.dart';
import 'CommonWigdets.dart';

class CommonWebView extends StatefulWidget {
  final String webUrl;
  final String title;
  final String accountId;
  final String type;

  const CommonWebView({
    Key? key,
    required this.webUrl,
    required this.title,
    required this.accountId,
    required this.type,
  }) : super(key: key);

  @override
  _CommonWebViewState createState() => _CommonWebViewState();
}

bool isPageLoad = false;

class _CommonWebViewState extends State<CommonWebView> {
  late final WebViewController controller;

  @override
  void initState() {
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
            if (request.url.contains("status=1")) {
              showToast(
                "Your request has been submitted successfully.",
              );
              navigatorKey.currentState!.pop(true);
            } else if (request.url.contains("status=0")) {
              navigatorKey.currentState!.pop(false);
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
            appBar: CommonAppBar(
              elevation: 0,
              hideLeading: false,
              title: Text(
                widget.title,
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
                _exitApp(navigatorKey.currentState!.context);
              },
              actionWidget: [],
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
              ],
            )),
      ),
    );
  }

  Future<bool> _exitApp(BuildContext context) async {
    if (await controller.canGoBack()) {
      debugPrint("onWillGoBack");
      controller.goBack();
    } else {
      // showToast(message: "No back history item");
      navigatorKey.currentState!.pop(false);
    }
    return false;
  }
}
