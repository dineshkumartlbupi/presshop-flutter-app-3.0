import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/core/api/api_client.dart';
import 'package:presshop/core/utils/app_logger.dart';
import 'package:presshop/core/analytics/analytics_constants.dart';

/// Service for handling media uploads with progress tracking
class MediaUploadService {
  static int _lastProgress = -1;
  static final ValueNotifier<Map<String, dynamic>?> uploadStatus =
      ValueNotifier(null);

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
      uploadStatus.value = {
        'status': 'starting',
        'progress': 0,
        'taskId': jsonBody?['task_id'],
        'endUrl': endUrl,
      };
      AppLogger.info("Media upload started to $endUrl");
      log("Upload started: ${DateTime.now()}");
      debugPrint("Upload URL: $endUrl");

      // Show initial 0% notification
      _showProgressNotification(
        localNotificationService.flutterLocalNotificationsPlugin,
        0,
        isDraft: jsonBody?['is_draft'] == 'true',
      );

      // Transition to processing state after upload completes but before response
      _showProcessingNotification(
        localNotificationService.flutterLocalNotificationsPlugin,
        isDraft: jsonBody?['is_draft'] == 'true',
      );
      uploadStatus.value = {
        'status': 'processing',
        'progress': 100,
        'taskId': jsonBody?['task_id'],
      };

      // Use ApiClient.post with custom timeouts via Options if needed, though ApiClient has defaults.
      // If stricter timeouts needed, pass Options.
      Response response = await apiClient.post(
        endUrl,
        data: formData,
        onSendProgress: (sent, total) {
          _handleUploadProgress(sent, total, jsonBody);
        },
        options: Options(
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
        showLoader: false,
      );

      debugPrint("Upload completed: ${response.data}");

      if (response.statusCode! <= 201) {
        debugPrint("Upload successful: ${response.data}");
        await localNotificationService.flutterLocalNotificationsPlugin
            .cancel(0);
        _showCompletionNotification(
          localNotificationService.flutterLocalNotificationsPlugin,
          isDraft: jsonBody?['is_draft'] == 'true',
        );
        AppLogger.trackEvent(EventNames.mediaUpload, parameters: {
          'status': 'success',
          'is_draft': (jsonBody?['is_draft'] == 'true').toString(),
          'file_count': filePathList.length + (additionalFiles?.length ?? 0),
        });
        uploadStatus.value = {
          'status': 'success',
          'progress': 100,
          'taskId': jsonBody?['task_id'],
        };
        return true;
      } else {
        _showFailedNotification(
          localNotificationService.flutterLocalNotificationsPlugin,
        );
        debugPrint("Upload failed with status code: ${response.statusCode}");
        uploadStatus.value = {
          'status': 'failed',
          'progress': _lastProgress,
          'taskId': jsonBody?['task_id'],
        };
        return false;
      }
    } catch (e) {
      AppLogger.error("Media upload error: $e", trackAnalytics: true);
      _showFailedNotification(
        localNotificationService.flutterLocalNotificationsPlugin,
      );
      uploadStatus.value = {
        'status': 'failed',
        'progress': _lastProgress,
        'taskId': jsonBody?['task_id'],
        'error': e.toString(),
      };
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
    if (total <= 0) return;
    int progress = ((sent / total) * 100).toInt();

    if (progress > _lastProgress) {
      _lastProgress = progress;
      debugPrint("Upload progress: $progress%");

      _showProgressNotification(
        localNotificationService.flutterLocalNotificationsPlugin,
        progress,
        isDraft: jsonBody?['is_draft'] == 'true',
      );

      uploadStatus.value = {
        'status': 'uploading',
        'progress': progress,
        'taskId': jsonBody?['task_id'],
      };
    }

    if (progress == 100) {
      _lastProgress = -1; // Reset for next upload
    }
  }

  static void _showProgressNotification(
    FlutterLocalNotificationsPlugin notificationPlugin,
    int progress, {
    bool isDraft = false,
  }) {
    String title = isDraft ? "Saving draft" : 'Uploading Content';
    String body = 'Uploading ($progress%)';

    notificationPlugin.show(
      0,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'upload_channel',
          'Video Upload',
          importance: Importance.max,
          priority: Priority.high,
          showProgress: true,
          maxProgress: 100,
          progress: progress,
          onlyAlertOnce: true,
          ongoing: true,
        ),
      ),
    );
  }

  /// Show processing notification
  static void _showProcessingNotification(
    FlutterLocalNotificationsPlugin notificationPlugin, {
    bool isDraft = false,
  }) {
    String title = isDraft ? "Saving draft" : 'Processing Content';
    String body = 'Processing - Finalizing upload...';

    notificationPlugin.show(
      0,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'upload_channel',
          'Video Upload',
          importance: Importance.max,
          priority: Priority.high,
          showProgress: false,
          indeterminate: true,
          onlyAlertOnce: true,
          ongoing: true,
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
