import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/api/api_constant.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/core/api/api_client.dart';

/// Service for handling media uploads with progress tracking
class MediaUploadService {
  /// Upload media files using Dio with progress notifications
  static Future<bool> uploadMedia({
    required String endUrl,
    Map<String, String>? jsonBody,
    required List filePathList,
    required String imageParams,
    Map<String, String>? additionalFiles,
  }) async {
    await WakelockPlus.enable();

    // Use ApiClient from DI
    final apiClient = sl<ApiClient>();

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

    // Add additional files with custom keys
    if (additionalFiles != null && additionalFiles.isNotEmpty) {
      for (var entry in additionalFiles.entries) {
        var mimeType = lookupMimeType(entry.value) ?? "audio/mpeg";
        debugPrint("AdditionalFile Mime: $mimeType Key: ${entry.key}");

        var mArray = mimeType.split("/");
        var file = await MultipartFile.fromFile(
          entry.value,
          contentType: MediaType(mArray.first, mArray.last),
        );
        formData.files.add(MapEntry(entry.key, file));
      }
    }

    // Add JSON body fields
    if (jsonBody != null && jsonBody.isNotEmpty) {
      jsonBody.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });
    }

    try {
      log("Upload started: ${DateTime.now()}");
      debugPrint("Upload URL: ${baseUrl + endUrl}");
      // debugPrint("Upload Headers: ${dio.options.headers}"); // Headers handled by ApiClient
      debugPrint(
          "Upload Files: ${formData.files.map((e) => "${e.key}: ${e.value.filename}").toList()}");

      // Use ApiClient.post with custom timeouts via Options if needed, though ApiClient has defaults.
      // If stricter timeouts needed, pass Options.
      Response response = await apiClient.post(
        endUrl,
        data: formData,
        onSendProgress: (sent, total) {
          _handleUploadProgress(sent, total, jsonBody);
        },
        options: Options(
          sendTimeout: const Duration(minutes: 5), // Extended timeout for media
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      debugPrint("Upload completed: ${response.data}");

      if (response.statusCode! <= 201) {
        debugPrint("Upload successful: ${response.data}");
        localNotificationService.flutterLocalNotificationsPlugin.cancel(0);
        _showCompletionNotification(
          localNotificationService.flutterLocalNotificationsPlugin,
          isDraft: jsonBody?['is_draft'] == 'true',
        );
        return true;
      } else {
        _showFailedNotification(
          localNotificationService.flutterLocalNotificationsPlugin,
        );
        debugPrint("Upload failed with status code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("Upload error: $e");
      if (e is DioException) {
        debugPrint("DioError Message: ${e.message}");
        debugPrint("DioError Response: ${e.response?.data}");
        debugPrint("DioError Status: ${e.response?.statusCode}");
      }
      _showFailedNotification(
        localNotificationService.flutterLocalNotificationsPlugin,
      );
      return false;
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
