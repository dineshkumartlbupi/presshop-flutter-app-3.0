import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:presshop/main.dart';

class GlobalLoader {
  static int _requestCount = 0;
  static OverlayEntry? _overlayEntry;

  static void show() {
    debugPrint(
        "🐰 GlobalLoader.show() called from:\n${StackTrace.current.toString().split('\n').take(3).join('\n')}");
    _requestCount++;
    if (_overlayEntry == null) {
      final overlay = navigatorKey.currentState?.overlay;
      if (overlay != null) {
        _overlayEntry = OverlayEntry(
          builder: (context) => Material(
            color: Colors.black.withOpacity(0.5),
            child: WillPopScope(
              onWillPop: () async => false,
              child: Center(
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Lottie.asset("assets/lottieFiles/emily_loader.json"),
                ),
              ),
            ),
          ),
        );
        overlay.insert(_overlayEntry!);
      } else {
        debugPrint("GlobalLoader.show() failed: No overlay available");
      }
    }
  }

  static void hide() {
    if (_requestCount > 0) {
      _requestCount--;
    }

    if (_requestCount == 0 && _overlayEntry != null) {
      final entryToRemove = _overlayEntry;
      _overlayEntry =
          null; // Clear reference before removal to avoid re-entry issues
      try {
        // OverlayEntry doesn't have a public 'mounted' property but 'remove'
        // will throw if it's not currently in an overlay.
        entryToRemove?.remove();
      } catch (e) {
        debugPrint("GlobalLoader.hide() safeguard: ${e.toString()}");
      }
    }
  }

  /// Force hide in case of errors/resets
  static void forceHide() {
    _requestCount = 0;
    if (_overlayEntry != null) {
      final entryToRemove = _overlayEntry;
      _overlayEntry = null;
      try {
        entryToRemove?.remove();
      } catch (e) {
        debugPrint("GlobalLoader.forceHide() safeguard: ${e.toString()}");
      }
    }
  }
}
