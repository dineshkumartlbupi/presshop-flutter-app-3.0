import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:presshop/core/core_export.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class ConnectionErrorOverlay extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ConnectionErrorOverlay({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async => false,
      child: Material(
        color: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: 0.8 + (value * 0.2),
                child: child,
              ),
            );
          },
          child: Stack(
            children: [
              // Blur Background
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: size.width * 0.85,
                  padding: EdgeInsets.all(size.width * 0.06),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(size.width * 0.06),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(size.width * 0.04),
                        decoration: BoxDecoration(
                          color: colorThemePink.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.wifi_off,
                          color: colorThemePink,
                          size: size.width * 0.1,
                        ),
                      ),
                      SizedBox(height: size.width * 0.05),
                      Text(
                        "Whoops! No Connection",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: size.width * 0.055,
                          fontWeight: FontWeight.bold,
                          fontFamily: "AirbnbCereal",
                        ),
                      ),
                      SizedBox(height: size.width * 0.03),
                      Text(
                        message.isNotEmpty
                            ? message
                            : "Please check your internet settings and try again.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: size.width * 0.038,
                          fontWeight: FontWeight.normal,
                          fontFamily: "AirbnbCereal",
                        ),
                      ),
                      SizedBox(height: size.width * 0.08),
                      SizedBox(
                        width: double.infinity,
                        height: size.width * 0.13,
                        child: commonElevatedButton(
                          "Try Again",
                          size,
                          commonButtonTextStyle(size).copyWith(
                            fontSize: size.width * 0.042,
                          ),
                          commonButtonStyle(size, colorThemePink).copyWith(
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(size.width * 0.03),
                              ),
                            ),
                          ),
                          onRetry,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
