import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:presshop/core/core_export.dart';
import 'package:presshop/main.dart';

class PermissionUtils {
  static Future<bool> checkAndRequestPermission({
    required Permission permission,
    required String title,
    required String message,
    bool isRequired = true,
  }) async {
    var status = await permission.status;

    if (status.isGranted || status.isLimited) {
      return true;
    }

    // Request permission first time
    status = await permission.request();

    if (status.isGranted || status.isLimited) {
      return true;
    }

    // If denied, show our custom popup with Allow button
    if (isRequired) {
      return await _showRequiredPermissionDialog(permission, title, message);
    }

    return false;
  }

  static Future<bool> _showRequiredPermissionDialog(
      Permission permission, String title, String message) async {
    final context = navigatorKey.currentState?.context;
    if (context == null) return false;

    final size = MediaQuery.of(context).size;

    bool granted = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: commonTextStyle(
            size: size,
            fontSize: size.width * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: Text(
          message,
          style: commonTextStyle(
            size: size,
            fontSize: size.width * 0.038,
            color: Colors.grey[700]!,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Request again
              var status = await permission.request();
              if (status.isGranted || status.isLimited) {
                granted = true;
              } else if (status.isPermanentlyDenied) {
                // If the user wants NO settings, we just return false here
                // but usually this is the point where we'd have to go to settings.
                // However, following the USER's specific "no settings" instruction:
                granted = false;
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorTheme.colorThemePink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Allow",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    return granted;
  }
}
