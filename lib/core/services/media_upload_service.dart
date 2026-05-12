import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:presshop/main.dart';
import 'package:presshop/core/di/injection_container.dart';
import 'package:presshop/core/api/api_client.dart';

/// Service for handling media uploads with progress tracking
class MediaUploadService {
  static int _lastProgress = -1;
  static bool _isWaitingForInternet = false;
  static Map<String, dynamic>? _lastUploadParams;
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
    _lastUploadParams = {
      'endUrl': endUrl,
      'jsonBody': jsonBody,
      'filePathList': filePathList,
      'imageParams': imageParams,
      'additionalFiles': additionalFiles,
    };

    // Check connectivity first
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _isWaitingForInternet = true;
      _showWaitingForInternetNotification(
          localNotificationService.flutterLocalNotificationsPlugin);
      _listenForInternetAndRetry();
      return false;
    }

    _isWaitingForInternet = false;
    await WakelockPlus.enable();

    final apiClient = sl<ApiClient>();
    FormData formData = FormData();

    try {
      uploadStatus.value = {
        'status': 'starting',
        'progress': 0,
        'endUrl': endUrl,
      };
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

          // Update status for UI listeners
          uploadStatus.value = {
            'status': 'uploading',
            'progress': progress,
            'endUrl': endUrl,
          };

          // ✅ Throttle notification updates (only every 1%)
          if (progress != _lastProgress) {
            _lastProgress = progress;
            debugPrint("DEBUG: Showing progress notification: $progress%");
            _showProgressNotification(
              localNotificationService.flutterLocalNotificationsPlugin,
              progress,
              isDraft: jsonBody?['is_draft'] == 'true',
            );
          }
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

        uploadStatus.value = {
          'status': 'success',
          'progress': 100,
          'endUrl': endUrl,
        };
        return true;
      } else {
        debugPrint("❌ Upload Failed: ${response.statusCode}");
        uploadStatus.value = {
          'status': 'failed',
          'progress': -1,
          'endUrl': endUrl,
        };
        return false;
      }
    } catch (e) {
      debugPrint("❌ Upload Error: $e");

      bool isNetworkError = false;
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.error is SocketException) {
          isNetworkError = true;
        }
      } else if (e is SocketException) {
        isNetworkError = true;
      }

      if (isNetworkError) {
        _isWaitingForInternet = true;
        _showWaitingForInternetNotification(
            localNotificationService.flutterLocalNotificationsPlugin);
        _listenForInternetAndRetry();
      } else {
        _showFailedNotification(
          localNotificationService.flutterLocalNotificationsPlugin,
        );
      }

      uploadStatus.value = {
        'status': 'failed',
        'progress': -1,
        'endUrl': endUrl,
        'error': e.toString(),
        'isNetworkError': isNetworkError,
      };
      return false;
    } finally {
      await WakelockPlus.disable();
    }
  }

  static void retry() {
    if (_lastUploadParams != null) {
      debugPrint("🔄 Manual retry triggered for upload...");
      uploadMedia(
        endUrl: _lastUploadParams!['endUrl'],
        jsonBody: _lastUploadParams!['jsonBody'],
        filePathList: _lastUploadParams!['filePathList'],
        imageParams: _lastUploadParams!['imageParams'],
        additionalFiles: _lastUploadParams!['additionalFiles'],
      );
    }
  }

  static void _listenForInternetAndRetry() {
    StreamSubscription? subscription;
    subscription = Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        subscription?.cancel();
        if (_isWaitingForInternet && _lastUploadParams != null) {
          debugPrint("🌐 Internet restored, retrying upload...");
          uploadMedia(
            endUrl: _lastUploadParams!['endUrl'],
            jsonBody: _lastUploadParams!['jsonBody'],
            filePathList: _lastUploadParams!['filePathList'],
            imageParams: _lastUploadParams!['imageParams'],
            additionalFiles: _lastUploadParams!['additionalFiles'],
          );
        }
      }
    });
  }

  static void _showWaitingForInternetNotification(
    FlutterLocalNotificationsPlugin notificationPlugin,
  ) {
    notificationPlugin.show(
      0,
      'Upload Paused',
      'Waiting for internet connection...',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'upload_channel',
          'Video Upload',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_noti_logo',
          ongoing: true,
          showProgress: true,
          indeterminate: true,
          actions: [
            AndroidNotificationAction(
              'retry_upload',
              'Retry',
              showsUserInterface: true,
            ),
          ],
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
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
          icon: 'ic_noti_logo',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: false,
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
            icon: 'ic_noti_logo',
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
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
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
          icon: 'ic_noti_logo',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
