import 'dart:async';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:presshop/core/models/upload_job.dart';
import 'package:presshop/core/models/upload_chunk.dart';
import 'package:presshop/features/media/data/services/chunked_upload_api_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:presshop/core/utils/app_logger.dart';

class BackgroundUploadService {
  static final BackgroundUploadService _instance =
      BackgroundUploadService._internal();

  factory BackgroundUploadService() {
    return _instance;
  }

  BackgroundUploadService._internal();

  final ChunkedUploadApiService _apiService = ChunkedUploadApiService();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isUploading = false;

  static const int chunkSize = 10 * 1024 * 1024; // 10MB

  static final ValueNotifier<Map<String, dynamic>?> videoUploadProgress =
      ValueNotifier(null);

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload == 'retry' ||
            response.actionId == 'retry_upload') {
          Connectivity().checkConnectivity().then((results) {
            if (results.contains(ConnectivityResult.none)) {
              final int prog = BackgroundUploadService
                      .videoUploadProgress.value?['progress'] ??
                  0;
              BackgroundUploadService().showNotification(
                  prog, 'Upload Failed', 'No internet connection.',
                  isError: true);
            } else {
              final int prog = BackgroundUploadService
                      .videoUploadProgress.value?['progress'] ??
                  0;
              BackgroundUploadService().showNotification(
                  prog, 'Retrying...', 'Restarting upload process...');
              BackgroundUploadService().startOrResumeUpload();
            }
          });
        } else if (response.actionId == 'cancel_upload') {
          BackgroundUploadService().cancelAllJobs();
        }
      },
    );

    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (!results.contains(ConnectivityResult.none)) {
        // Internet is back, auto resume!
        BackgroundUploadService().startOrResumeUpload();
      }
    });
  }

  Future<void> cancelAllJobs() async {
    if (!Hive.isBoxOpen('upload_jobs')) {
      await Hive.openBox<UploadJob>('upload_jobs');
    }
    final uploadBox = Hive.box<UploadJob>('upload_jobs');

    final keysToCancel = uploadBox.keys.where((k) {
      final job = uploadBox.get(k);
      return job?.status != 'completed';
    }).toList();

    for (var key in keysToCancel) {
      await uploadBox.delete(key);
    }

    await _notificationsPlugin.cancel(0);
    _isUploading = false;
  }

  Future<void> showNotification(int progress, String title, String body,
      {bool isError = false, bool isCompleted = false}) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'upload_channel',
      'Uploads',
      channelDescription: 'Video Upload Progress',
      importance: (isError || isCompleted) ? Importance.high : Importance.low,
      priority: (isError || isCompleted) ? Priority.high : Priority.low,
      showProgress: !isError && !isCompleted,
      maxProgress: 100,
      progress: progress,
      icon: '@mipmap/ic_launcher',
      ongoing: !(isError || isCompleted),
      autoCancel: isCompleted,
      onlyAlertOnce: true,
      actions: isError
          ? [
              const AndroidNotificationAction(
                'retry_upload',
                'Retry',
                showsUserInterface: true,
                cancelNotification: false,
              ),
              const AndroidNotificationAction(
                'cancel_upload',
                'Cancel',
                showsUserInterface: false,
                cancelNotification: true,
              )
            ]
          : null,
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await _notificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: isError ? 'retry' : progress.toString(),
    );

    // Update ValueNotifier so UI can reflect it
    videoUploadProgress.value = {
      'progress': progress,
      'title': title,
      'body': body,
      'isError': isError,
      'status': isError ? 'paused_no_internet' : 'uploading',
    };
  }

  Future<void> startOrResumeUpload() async {
    if (_isUploading) return;
    _isUploading = true; // Lock execution instantaneously

    try {
      if (!Hive.isBoxOpen('upload_jobs')) {
        await Hive.openBox<UploadJob>('upload_jobs');
      }
      final uploadBox = Hive.box<UploadJob>('upload_jobs');
      final jobs = uploadBox.values
          .where((job) =>
              job.status == 'queued' ||
              job.status == 'uploading' ||
              job.status == 'failed')
          .toList();

      AppLogger.info(
          "BackgroundUploadService: Found \${jobs.length} jobs to process");
      if (jobs.isEmpty) {
        return;
      }

      for (final job in jobs) {
        if (job.status != 'completed') {
          try {
            await _processJob(job);
          } catch (e, stack) {
            if (e.toString().contains("Job cancelled") ||
                e.toString().contains("Job no longer active")) {
              AppLogger.info(
                  "BackgroundUploadService: Job \${job.jobId} was cancelled or removed");
            } else {
              AppLogger.error(
                  "BackgroundUploadService: Job failed: \${job.jobId}",
                  error: e,
                  stackTrace: stack);

              bool isNetwork = e.toString().contains("SocketException") ||
                  e.toString().contains("HandshakeException") ||
                  e.toString().contains("Failed host lookup") ||
                  e.toString().contains("connection failed");

              job.status = 'failed';
              job.updateUpdatedAt();
              await job.save();
              await showNotification(
                  0,
                  'Upload Failed',
                  isNetwork
                      ? 'Waiting for internet connection...'
                      : 'Upload interrupted. Tap Retry to resume.',
                  isError: true);
            }
          }
        }
      }
    } finally {
      _isUploading = false;
    }
  }

  Future<void> _processJob(UploadJob job) async {
    final file = File(job.filePath);
    if (!await file.exists()) {
      AppLogger.error(
          "BackgroundUploadService: File not found at ${job.filePath}");
      job.status = 'failed';
      await job.save();
      await showNotification(
          0, 'Upload Failed', 'Video file is missing from device cache.',
          isError: true);
      return;
    }

    job.status = 'uploading';
    job.updateUpdatedAt();
    await job.save();

    // Initialize upload if not done yet
    if (job.uploadId.isEmpty || job.chunks.isEmpty) {
      await showNotification(
          0, 'Connecting...', 'Initiating secure video upload...');

      final filename = file.path.split('/').last;

      try {
        final initData = await _apiService.initiateUpload(
            filename: filename,
            contentType: 'video/mp4',
            partCount: job.partCount);

        job.uploadId = initData['uploadId'];
        job.s3Key = initData['key'];
        job.chunks = (initData['parts'] as List)
            .map((part) => UploadChunk(
                  partNumber: part['partNumber'],
                  presignedUrl: part['presignedUrl'],
                ))
            .toList();
        await job.save();
      } catch (e) {
        throw Exception("Server connection failed: $e");
      }
    }

    int totalChunks = job.chunks.length;
    int uploadedBytes = 0;

    // Calculate already uploaded bytes (for resumed jobs)
    uploadedBytes =
        job.chunks.where((c) => c.status == 'uploaded').length * chunkSize;
    if (uploadedBytes > job.fileSizeBytes) uploadedBytes = job.fileSizeBytes;

    for (int i = 0; i < totalChunks; i++) {
      final chunk = job.chunks[i];
      if (chunk.status == 'uploaded') continue;

      final start = i * chunkSize;
      final end = (i + 1) * chunkSize > job.fileSizeBytes
          ? job.fileSizeBytes
          : (i + 1) * chunkSize;

      // Read file chunk
      final randomAccessFile = await file.open(mode: FileMode.read);
      await randomAccessFile.setPosition(start);
      final chunkData = await randomAccessFile.read(end - start);
      await randomAccessFile.close();

      // Check if job is still valid
      final currentJob = Hive.box<UploadJob>('upload_jobs').get(job.jobId);
      if (currentJob == null) throw Exception("Job cancelled");
      if (currentJob.status == 'failed' || currentJob.status == 'completed') {
        throw Exception("Job no longer active");
      }

      try {
        // Upload chunk
        final eTag = await _apiService.uploadChunk(
            presignedUrl: chunk.presignedUrl, chunkData: chunkData);

        chunk.eTag = eTag;
        chunk.status = 'uploaded';
        job.updateUpdatedAt();
        await job.save();

        // Update uploaded bytes and progress
        int uploadedChunks =
            job.chunks.where((c) => c.status == 'uploaded').length;

// Approx bytes
        int uploadedBytes = uploadedChunks * BackgroundUploadService.chunkSize;

// Fix overflow
        if (uploadedBytes > job.fileSizeBytes) {
          uploadedBytes = job.fileSizeBytes;
        }

// ✅ Convert to 0–100 percentage
        int progress = job.fileSizeBytes > 0
            ? ((uploadedBytes / job.fileSizeBytes) * 100).toInt()
            : 0;

        await showNotification(
            progress.toInt(), 'Uploading Video...', '${progress}% completed');
      } catch (e) {
        AppLogger.warning(
            "BackgroundUploadService: Chunk ${chunk.partNumber} failed. Error: $e");
        bool isNetworkError = e.toString().contains("SocketException") ||
            e.toString().contains("HandshakeException") ||
            e.toString().contains("TimeoutException") ||
            e.toString().contains("connection error") ||
            e.toString().contains("cancelled");
        String errorMsg = isNetworkError
            ? 'Waiting for internet connection...'
            : 'Upload interrupted. Tap Retry to resume.';
        await showNotification(
            ((uploadedBytes / job.fileSizeBytes) * 100).toInt(),
            'Upload Failed',
            errorMsg,
            isError: true);

        _isUploading = false;
        job.status = 'failed';
        await job.save();
        return;
      }
    }

    // Complete upload
    await showNotification(99, 'Processing Video...', 'Almost done');
    final parts = job.chunks
        .map((c) => {'PartNumber': c.partNumber, 'ETag': c.eTag})
        .toList();

    final response = await _apiService.completeUpload(
      key: job.s3Key,
      uploadId: job.uploadId,
      mediaType: 'video',
      originalFileName: file.path.split('/').last,
      userId: 'app_user',
      parts: parts,
      contentId: job.contentId,
    );

    job.status = 'completed';
    job.videoId = response['videoId'];
    job.updateUpdatedAt();
    await job.save();

    await showNotification(
        100, 'Upload Complete', 'Your video uploaded successfully.',
        isCompleted: true);

    videoUploadProgress.value = {
      'progress': 100,
      'title': 'Upload Complete',
      'body': 'Your video has been uploaded successfully.',
      'isError': false,
      'status': 'completed',
    };
  }

  Future<void> createJobAndStart(String filePath, {String? contentId}) async {
    final file = File(filePath);
    if (!await file.exists()) return;

    final fileSizeBytes = await file.length();
    final partCount = (fileSizeBytes / chunkSize).ceil();

    if (!Hive.isBoxOpen('upload_jobs')) {
      await Hive.openBox<UploadJob>('upload_jobs');
    }
    final uploadBox = Hive.box<UploadJob>('upload_jobs');

    final job = UploadJob(
      jobId: DateTime.now().millisecondsSinceEpoch.toString(),
      filePath: filePath,
      uploadId: '',
      s3Key: '',
      fileSizeBytes: fileSizeBytes,
      partCount: partCount,
      createdAt: DateTime.now(),
      chunks: [],
      contentId: contentId,
    );

    await uploadBox.put(job.jobId, job);

    await showNotification(0, 'Uploading Video...', 'Preparing upload...');

    AppLogger.info(
        "BackgroundUploadService: Job created for \${file.path} as JobID: \${job.jobId}");

    // Start background processor
    startOrResumeUpload();
  }
}
