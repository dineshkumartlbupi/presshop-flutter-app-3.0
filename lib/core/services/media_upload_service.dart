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
import 'package:presshop/features/media/domain/services/background_upload_service.dart';

/// Service for handling media uploads with progress tracking
class MediaUploadService {
  static int _lastProgress = -1;
  static final ValueNotifier<Map<String, dynamic>?> uploadStatus =
      ValueNotifier(null);

  /// Upload media files using Dio with progress notifications
  // static Future<bool> uploadMedia({
  //   required String endUrl,
  //   Map<String, String>? jsonBody,
  //   required List filePathList,
  //   required String imageParams,
  //   Map<String, String>? additionalFiles,
  // }) async {
  //   await WakelockPlus.enable();

  //   // Use ApiClient from DI
  //   final apiClient = sl<ApiClient>();

  //   FormData formData = FormData();
  //   List<String> backgroundVideos = [];

  //   // Add files to form data
  //   if (filePathList.isNotEmpty) {
  //     for (var element in filePathList) {
  //       var mimeType = lookupMimeType(element.path) ?? "video/mp4";
  //       debugPrint("MediaMime: $mimeType");

  //       var mArray = mimeType.split("/");
  //       if (mArray.first == 'video') {
  //          backgroundVideos.add(element.path);
  //       } else {
  //          var file = await MultipartFile.fromFile(
  //            element.path,
  //            contentType: MediaType(mArray.first, mArray.last),
  //          );
  //          formData.files.add(MapEntry(imageParams, file));
  //       }
  //     }
  //   }

  //   // Add additional files with custom keys
  //   if (additionalFiles != null && additionalFiles.isNotEmpty) {
  //     for (var entry in additionalFiles.entries) {
  //       var mimeType = lookupMimeType(entry.value) ?? "audio/mpeg";
  //       debugPrint("AdditionalFile Mime: $mimeType Key: ${entry.key}");

  //       var mArray = mimeType.split("/");
  //       if (mArray.first == 'video') {
  //           backgroundVideos.add(entry.value);
  //       } else {
  //           var file = await MultipartFile.fromFile(
  //             entry.value,
  //             contentType: MediaType(mArray.first, mArray.last),
  //           );
  //           formData.files.add(MapEntry(entry.key, file));
  //       }
  //     }
  //   }

  //   // Add JSON body fields
  //   if (jsonBody != null && jsonBody.isNotEmpty) {
  //     jsonBody.forEach((key, value) {
  //       formData.fields.add(MapEntry(key, value.toString()));
  //     });
  //   }

  //   try {
  //     uploadStatus.value = {
  //       'status': 'starting',
  //       'progress': 0,
  //       'taskId': jsonBody?['task_id'],
  //       'endUrl': endUrl,
  //     };
  //     AppLogger.info("Media upload started to $endUrl");
  //     log("Upload started: ${DateTime.now()}");
  //     debugPrint("Upload URL: $endUrl");

  //     // Show initial 0% notification
  //     _showProgressNotification(
  //       localNotificationService.flutterLocalNotificationsPlugin,
  //       0,
  //       isDraft: jsonBody?['is_draft'] == 'true',
  //     );

  //     // Use ApiClient.post with custom timeouts via Options if needed, though ApiClient has defaults.
  //     // If stricter timeouts needed, pass Options.
  //     final response = await apiClient.multipartPost(
  //       endUrl,
  //       formData: formData,
  //       onSendProgress: (count, total) {
  //         int progress = ((count / total) * 100).toInt();
  //         debugPrint("Upload progress: $progress%");
  //         _showProgressNotification(localNotificationService.flutterLocalNotificationsPlugin, progress);
  //       },
  //     );

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       AppLogger.info("MediaUploadService: Metadata upload successful. EndUrl: $endUrl");

  //       final responseData = response.data;
  //       String? contentId;
  //       if (responseData != null && responseData is Map && responseData['id'] != null) {
  //         contentId = responseData['id'].toString();
  //         AppLogger.info("MediaUploadService: Extracted ContentId: $contentId");
  //       }

  //       if (backgroundVideos.isNotEmpty) {
  //          AppLogger.info("MediaUploadService: Handing off ${backgroundVideos.length} videos to BackgroundUploadService");
  //          for (var videoPath in backgroundVideos) {
  //            BackgroundUploadService().createJobAndStart(videoPath, contentId: contentId);
  //          }
  //       } else {
  //          await localNotificationService.flutterLocalNotificationsPlugin.cancel(0);
  //          _showCompletionNotification(
  //            localNotificationService.flutterLocalNotificationsPlugin,
  //            isDraft: jsonBody?['is_draft'] == 'true',
  //          );
  //       }
  //       AppLogger.trackEvent(EventNames.mediaUpload, parameters: {
  //         'status': 'success',
  //         'is_draft': (jsonBody?['is_draft'] == 'true').toString(),
  //         'file_count': filePathList.length + (additionalFiles?.length ?? 0),
  //       });
  //       uploadStatus.value = {
  //         'status': 'success',
  //         'progress': 100,
  //         'taskId': jsonBody?['task_id'],
  //       };
  //       return true;
  //     } else {
  //       _showFailedNotification(
  //         localNotificationService.flutterLocalNotificationsPlugin,
  //       );
  //       debugPrint("Upload failed with status code: ${response.statusCode}");
  //       uploadStatus.value = {
  //         'status': 'failed',
  //         'progress': _lastProgress,
  //         'taskId': jsonBody?['task_id'],
  //       };
  //       return false;
  //     }
  //   } catch (e) {
  //     AppLogger.error("Media upload error: $e", trackAnalytics: true);
  //     _showFailedNotification(
  //       localNotificationService.flutterLocalNotificationsPlugin,
  //     );
  //     uploadStatus.value = {
  //       'status': 'failed',
  //       'progress': _lastProgress,
  //       'taskId': jsonBody?['task_id'],
  //       'error': e.toString(),
  //     };
  //     return false;
  //   } finally {
  //     await WakelockPlus.disable();
  //   }
  // }

  static Future<bool> uploadMedia({
    required String endUrl,
    Map<String, String>? jsonBody,
    required List filePathList,
    required String imageParams,
    Map<String, String>? additionalFiles,
  }) async {
    await WakelockPlus.enable();

    final apiClient = sl<ApiClient>();
    FormData formData = FormData();

    try {
      // ✅ ADD MEDIA FILES (IMAGE + VIDEO BOTH)
      if (filePathList.isNotEmpty) {
        for (var element in filePathList) {
          var mimeType =
              lookupMimeType(element.path) ?? "application/octet-stream";
          debugPrint("MediaMime: $mimeType");

          var mArray = mimeType.split("/");

          var file = await MultipartFile.fromFile(
            element.path,
            filename: element.path.split('/').last,
            contentType: MediaType(mArray.first, mArray.last),
          );

          // 🔥 IMPORTANT: separate param for video
          // if (mArray.first == 'video') {
          //   formData.files
          //       .add(MapEntry("videos", file)); // 👈 CHANGE if API key differs
          // } else {
          //   formData.files.add(MapEntry(imageParams, file));
          // }
          if (mArray.first == 'video') {
            var file = await MultipartFile.fromFile(
              element.path,
              filename: element.path.split('/').last,
              contentType: MediaType(mArray.first, mArray.last),
            );

            formData.files.add(MapEntry("videos", file)); // ✅ THIS IS THE PLACE
          } else {
            var file = await MultipartFile.fromFile(
              element.path,
              filename: element.path.split('/').last,
              contentType: MediaType(mArray.first, mArray.last),
            );

            formData.files.add(MapEntry(imageParams, file));
          }
        }
      }

      // ✅ ADD ADDITIONAL FILES (audio etc.)
      if (additionalFiles != null && additionalFiles.isNotEmpty) {
        for (var entry in additionalFiles.entries) {
          var mimeType = lookupMimeType(entry.value) ?? "audio/mpeg";
          var mArray = mimeType.split("/");

          var file = await MultipartFile.fromFile(
            entry.value,
            filename: entry.value.split('/').last,
            contentType: MediaType(mArray.first, mArray.last),
          );

          formData.files.add(MapEntry(entry.key, file));
        }
      }

      // ✅ ADD BODY PARAMS
      if (jsonBody != null && jsonBody.isNotEmpty) {
        jsonBody.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      debugPrint("🚀 Uploading to: $endUrl");

      final response = await apiClient.multipartPost(
        endUrl,
        formData: formData,
        onSendProgress: (count, total) {
          int progress = 0;
          if (total > 0) {
            progress = ((count / total) * 100).toInt();
          }

          debugPrint("Upload progress: $progress%");

          // ✅ ADD THIS LINE (YOU MISSED THIS)
          _showProgressNotification(
            localNotificationService.flutterLocalNotificationsPlugin,
            progress,
            isDraft: jsonBody?['is_draft'] == 'true',
          );
        },
      );

      debugPrint("Response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Upload Success");

        // ✅ REMOVE old background logic completely

        // ✅ Cancel progress notification
        await localNotificationService.flutterLocalNotificationsPlugin
            .cancel(0);

        // ✅ SHOW SUCCESS NOTIFICATION (ALWAYS)
        _showCompletionNotification(
          localNotificationService.flutterLocalNotificationsPlugin,
          isDraft: jsonBody?['is_draft'] == 'true',
        );

        return true;
      } else {
        debugPrint("❌ Upload Failed: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Upload Error: $e");
      return false;
    } finally {
      await WakelockPlus.disable();
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

  /// Show upload failed notification
  static void _showFailedNotification(
    FlutterLocalNotificationsPlugin notificationPlugin,
  ) {
    notificationPlugin.show(
      0,
      'Upload Failed',
      'There was an error uploading the video.',
      const NotificationDetails(
        android: AndroidNotificationDetails('upload_channel', 'Video Upload',
            importance: Importance.max,
            priority: Priority.high,
            actions: [
              AndroidNotificationAction(
                'retry_upload',
                'Retry',
                showsUserInterface: true,
              ),
              AndroidNotificationAction(
                'cancel_upload',
                'Cancel',
                showsUserInterface: false,
              )
            ]),
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
