import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/core/utils/shared_preferences.dart';

/// Service for handling media uploads with progress tracking
class MediaUploadService {
  /// Upload media files using Dio with progress notifications
  static Future<void> uploadMedia({
    required String endUrl,
    Map<String, String>? jsonBody,
    required List filePathList,
    required String imageParams,
  }) async {
    await WakelockPlus.enable();
    
    Dio dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 120),
      ),
    );
    
    FormData formData = FormData();
    
    // Add files to form data
    if (filePathList.isNotEmpty) {
      for (var element in filePathList) {
        var mimeType = lookupMimeType(element.path) ?? "video/mp4";
        debugPrint("MediaMime: $mimeType");

        var mArray = mimeType.split("/");
        var file = await MultipartFile.fromFile(
          element.path,
          contentType: MediaType(mArray.first, mArray.last),
        );
        formData.files.add(MapEntry(imageParams, file));
      }
    }

    // Add authorization header
    if (sharedPreferences!.getString(tokenKey) != null) {
      dio.options.headers = {
        "Authorization": "Bearer ${sharedPreferences!.getString(tokenKey)!}",
      };
    }

    // Add JSON body fields
    if (jsonBody != null && jsonBody.isNotEmpty) {
      jsonBody.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });
    }

    try {
      log("Upload started: ${DateTime.now()}");
      
      Response response = await dio.post(
        baseUrl + endUrl,
        data: formData,
        onSendProgress: (int sent, int total) {
          _handleUploadProgress(sent, total, jsonBody);
        },
      );

      debugPrint("Upload completed: ${response.data}");
      
      if (response.statusCode! <= 201) {
        debugPrint("Upload successful: ${response.data}");
        localNotificationService.flutterLocalNotificationsPlugin.cancel(0);
        _showCompletionNotification(
          localNotificationService.flutterLocalNotificationsPlugin,
          isDraft: jsonBody?['is_draft'] == 'true',
        );
      } else {
        _showFailedNotification(
          localNotificationService.flutterLocalNotificationsPlugin,
        );
        debugPrint("Upload failed with status code: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Upload error: $e");
      _showFailedNotification(
        localNotificationService.flutterLocalNotificationsPlugin,
      );
    } finally {
      await WakelockPlus.disable();
    }
  }

  /// Handle upload progress and show notifications
  static void _handleUploadProgress(
    int sent,
    int total,
    Map<String, String>? jsonBody,
  ) {
    int progress = ((sent / total) * 100).toInt();
    debugPrint("Upload progress: $progress%");

    if ((progress >= 1 &&
            progress <= 10 &&
            (sharedPreferences!.getBool('notify_10') ?? true)) ||
        (progress >= 30 &&
            progress <= 40 &&
            (sharedPreferences!.getBool('notify_40') ?? true)) ||
        (progress >= 80 &&
            progress <= 90 &&
            (sharedPreferences!.getBool('notify_90') ?? true))) {
      _showProgressNotification(
        localNotificationService.flutterLocalNotificationsPlugin,
        progress,
        isDraft: jsonBody?['is_draft'] == 'true',
      );

      if (progress <= 10) sharedPreferences!.setBool('notify_10', false);
      if (progress <= 40) sharedPreferences!.setBool('notify_40', false);
      if (progress <= 90) sharedPreferences!.setBool('notify_90', false);
    } else if (progress == 100) {
      // Reset notification flags for next upload
      sharedPreferences!.remove('notify_10');
      sharedPreferences!.remove('notify_40');
      sharedPreferences!.remove('notify_90');
      _showProgressNotification(
        localNotificationService.flutterLocalNotificationsPlugin,
        progress,
        isDraft: jsonBody?['is_draft'] == 'true',
      );
    }
  }

  /// Show progress notification
  static void _showProgressNotification(
    FlutterLocalNotificationsPlugin notificationPlugin,
    int progress, {
    bool isDraft = false,
  }) {
    notificationPlugin.show(
      0,
      isDraft ? "Saving draft" : 'Uploading Content',
      'Progress: $progress%',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'upload_channel',
          'Video Upload',
          importance: Importance.max,
          priority: Priority.high,
          showProgress: true,
          maxProgress: 100,
          progress: progress,
        ),
      ),
    );
  }

  /// Show upload failed notification
  static void _showFailedNotification(
    FlutterLocalNotificationsPlugin notificationPlugin,
  ) {
    notificationPlugin.show(
      0,
      'Upload Failed',
      'There was an error uploading the video.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'upload_channel',
          'Video Upload',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  /// Show upload completion notification
  static void _showCompletionNotification(
    FlutterLocalNotificationsPlugin notificationPlugin, {
    bool isDraft = false,
  }) {
    notificationPlugin.show(
      0,
      'Upload Complete',
      isDraft
          ? "Draft saved successfully"
          : 'Your Media has been uploaded successfully.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'upload_channel',
          'Video Upload',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}
