import 'dart:async';
import 'package:flutter/material.dart';
import 'package:presshop/core/widgets/common_app_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/widgets/common_widgets.dart';

class CommonWebView extends StatefulWidget {
  const CommonWebView({
    super.key,
    required this.webUrl,
    required this.title,
    required this.accountId,
    required this.type,
  });
  final String webUrl;
  final String title;
  final String accountId;
  final String type;

  @override
  _CommonWebViewState createState() => _CommonWebViewState();
}

class _CommonWebViewState extends State<CommonWebView> {
  late final WebViewController controller;
  bool _isLoading = true;
  int _loadingProgress = 0;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            debugPrint("onProgress :: $progress");
            if (mounted) {
              setState(() {
                _loadingProgress = progress;
              });
            }
          },
          onPageStarted: (url) {
            debugPrint("onPageStarted :: $url");
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (url) {
            debugPrint("onPageFinished :: $url");
            _timeoutTimer?.cancel();
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (error) {
            debugPrint("onWebResourceError :: $error");
            _timeoutTimer?.cancel();
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onNavigationRequest: (request) {
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

    // Auto-hide loader after 4 seconds even if page hasn't fully loaded
    _timeoutTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
        debugPrint("WebView: Loading timeout - showing page after 4s");
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
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
                    fontSize: size.width * AppDimensions.appBarHeadingFontSize),
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
              children: [
                // Always show the WebView (loads in background)
                WebViewWidget(
                  controller: controller,
                ),
                // Show loading overlay on top while page loads
                if (_isLoading)
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: _loadingProgress > 0
                              ? _loadingProgress / 100.0
                              : null,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.redAccent,
                          ),
                          minHeight: 3,
                        ),
                        const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
      navigatorKey.currentState!.pop(false);
    }
    return false;
  }
}
