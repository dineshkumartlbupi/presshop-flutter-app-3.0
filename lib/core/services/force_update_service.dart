import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/core/widgets/common_widgets.dart';

/// Service for handling force update functionality
class ForceUpdateService {
  /// Open app store for update
  static Future<void> openStore() async {
    FirebaseCrashlytics.instance.log("User clicked Update Now");
    FirebaseAnalytics.instance.logEvent(name: "user_update_now_click");

    final url = Platform.isAndroid
        ? 'https://play.google.com/store/apps/details?id=com.presshop.app'
        : 'https://apps.apple.com/app/id6744651614';

    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      FirebaseAnalytics.instance.logEvent(
        name: "store_launch_error",
        parameters: {"error": e.toString()},
      );
      showSnackBar("Error", "Could not open store", Colors.red);
    }
  }

  /// Show force update dialog
  static Future<bool?> showForceUpdateDialog(
    BuildContext context,
    bool allowCancel,
  ) {
    final size = MediaQuery.of(context).size;
    
    return showDialog(
      context: context,
      barrierDismissible: allowCancel,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.symmetric(horizontal: size.width * numD04),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size.width * numD045),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Padding(
                      padding: EdgeInsets.only(
                        left: size.width * numD04,
                        top: size.width * numD02,
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Update Required",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: size.width * numD04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    
                    // Divider
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * numD04,
                      ),
                      child: const Divider(
                        color: Colors.black,
                        thickness: 0.5,
                      ),
                    ),
                    
                    SizedBox(height: size.width * numD02),
                    
                    // Content
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * numD04,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Rabbit image
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                size.width * numD04,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                size.width * numD04,
                              ),
                              child: Image.asset(
                                "assets/rabbits/update_rabbit.png",
                                height: size.width * numD25,
                                width: size.width * numD35,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          
                          SizedBox(width: size.width * numD04),
                          
                          // Message
                          Expanded(
                            child: Text(
                              "A newer version of PressHop is available. Please update the app to continue using all features smoothly.",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: size.width * numD035,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: size.width * numD08),
                    
                    // Update button
                    SizedBox(
                      height: size.width * numD12,
                      width: size.width * numD35,
                      child: commonElevatedButton(
                        "Update Now",
                        size,
                        commonButtonTextStyle(size),
                        commonButtonStyle(size, colorThemePink),
                        openStore,
                      ),
                    ),
                    
                    SizedBox(height: size.width * numD05),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
