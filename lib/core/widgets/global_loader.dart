import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:presshop/main.dart';

class GlobalLoader {
  static int _requestCount = 0;
  static bool _isLoading = false;

  static void show() {
    debugPrint(
        "🐰 GlobalLoader.show() called from:\n${StackTrace.current.toString().split('\n').take(3).join('\n')}");
    _requestCount++;
    if (!_isLoading) {
      _isLoading = true;
      if (navigatorKey.currentContext != null) {
        showDialog(
          context: navigatorKey.currentContext!,
          barrierDismissible: false,
          useRootNavigator: true,
          barrierColor: Colors.black.withOpacity(0.5),
          builder: (context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: Center(
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Lottie.asset("assets/lottieFiles/emily_loader.json"),
                ),
              ),
            );
          },
        );
      }
    }
  }

  static void hide() {
    if (_requestCount > 0) {
      _requestCount--;
    }

    if (_requestCount == 0 && _isLoading) {
      _isLoading = false;
      if (navigatorKey.currentContext != null) {
        // Use root navigator to ensure we pop the dialog
        Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
        // Note: checking if canPop or just pop might be safer.
        // But popDialog isn't a standard method. It should be pop().
        // However, standard pop() might pop the screen if dialog is already gone?
        // We track _isLoading so we believe dialog is there.
      }
    }
  }

  /// Force hide in case of errors/resets
  static void forceHide() {
    _requestCount = 0;
    if (_isLoading) {
      _isLoading = false;
      if (navigatorKey.currentContext != null) {
        Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
      }
    }
  }
}

// Extension to safely pop dialogs if needed?
// Actually standard pop() is fine if we are sure it's the top. Use rootNavigator: true.
