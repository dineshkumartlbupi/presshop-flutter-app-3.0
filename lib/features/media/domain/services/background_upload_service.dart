import 'dart:async';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:presshop/core/models/upload_job.dart';
import 'package:presshop/core/models/upload_chunk.dart';
import 'package:presshop/features/media/data/services/chunked_upload_api_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:presshop/core/utils/app_logger.dart';

class BackgroundUploadService {
  static final BackgroundUploadService _instance = BackgroundUploadService._internal();

  factory BackgroundUploadService() {
    return _instance;
  }

  BackgroundUploadService._internal();

  final ChunkedUploadApiService _apiService = ChunkedUploadApiService();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  bool _isUploading = false;
  
  static const int chunkSize = 10 * 1024 * 1024; // 10MB

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload == 'retry' || response.actionId == 'retry_upload') {
          // Immediately update notification to show we're retrying
          BackgroundUploadService().showNotification(0, 'Retrying...', 'Restarting upload process...');
          BackgroundUploadService().startOrResumeUpload();
        } else if (response.actionId == 'cancel_upload') {
          BackgroundUploadService().cancelAllJobs();
        }
      },
    );
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

  Future<void> showNotification(int progress, String title, String body, {bool isError = false}) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'upload_channel',
      'Uploads',
      channelDescription: 'Video Upload Progress',
      importance: isError ? Importance.high : Importance.low,
      priority: isError ? Priority.high : Priority.low,
      showProgress: !isError,
      maxProgress: 100,
      icon: '@mipmap/ic_launcher',
      ongoing: true, // Always persistent so user can't swipe it away
      autoCancel: false, // Ensure it doesn't disappear on tap
      onlyAlertOnce: true,
      actions: isError ? [
        const AndroidNotificationAction(
          'retry_upload',
          'Retry',
          showsUserInterface: true, // Will launch app and trigger onDidReceiveNotificationResponse
        ),
        const AndroidNotificationAction(
          'cancel_upload',
          'Cancel',
          showsUserInterface: false,
        )
      ] : null,
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
  }

  Future<void> startOrResumeUpload() async {
    if (_isUploading) return;
    
    if (!Hive.isBoxOpen('upload_jobs')) {
        await Hive.openBox<UploadJob>('upload_jobs');
    }
    final uploadBox = Hive.box<UploadJob>('upload_jobs');
    final jobs = uploadBox.values.where((job) => job.status == 'queued' || job.status == 'uploading' || job.status == 'failed').toList();

    AppLogger.info("BackgroundUploadService: Found ${jobs.length} jobs to process");
    if (jobs.isEmpty) {
      _isUploading = false;
      return;
    }

    _isUploading = true;

    for (final job in jobs) {
      if (job.status != 'completed') {
        try {
          await _processJob(job);
        } catch (e, stack) {
          if (e.toString().contains("Job cancelled") || e.toString().contains("Job no longer active")) {
             AppLogger.info("BackgroundUploadService: Job ${job.jobId} was cancelled or removed");
          } else {
             AppLogger.error("BackgroundUploadService: Job failed: ${job.jobId}", error: e, stackTrace: stack);
             job.status = 'failed';
             job.updateUpdatedAt();
             await job.save();
             await showNotification(0, 'Upload Failed', 'There was an error uploading the video.', isError: true);
          }
        }
      }
    }

    _isUploading = false;
  }

  Future<void> _processJob(UploadJob job) async {
    job.status = 'uploading';
    job.updateUpdatedAt();
    await job.save();

    final file = File(job.filePath);
    if (!await file.exists()) {
      throw Exception("File does not exist: ${job.filePath}");
    }

    int uploadedChunks = job.chunks.where((c) => c.status == 'uploaded').length;
    int totalChunks = job.chunks.length;

    for (int i = 0; i < totalChunks; i++) {
        final chunk = job.chunks[i];
        if (chunk.status == 'uploaded') continue;

        final start = i * chunkSize;
        final end = (i + 1) * chunkSize > job.fileSizeBytes ? job.fileSizeBytes : (i + 1) * chunkSize;
        
        // Read file chunk
        final randomAccessFile = await file.open(mode: FileMode.read);
        await randomAccessFile.setPosition(start);
        final chunkData = await randomAccessFile.read(end - start);
        await randomAccessFile.close();

        // Upload to S3 using PUT presignedUrl
        bool chunkSuccess = false;
        while (!chunkSuccess) {
            // Check if job got cancelled 
            final currentJob = Hive.box<UploadJob>('upload_jobs').get(job.jobId);
            if (currentJob == null) {
                throw Exception("Job cancelled");
            }
            if (currentJob.status == 'failed' || currentJob.status == 'completed') {
                throw Exception("Job no longer active");
            }
        
            try {
              final eTag = await _apiService.uploadChunk(
                presignedUrl: chunk.presignedUrl, 
                chunkData: chunkData
              );
              
              chunk.eTag = eTag;
              chunk.status = 'uploaded';
              job.updateUpdatedAt();
              await job.save();
              
              uploadedChunks++;
              final progress = ((uploadedChunks / totalChunks) * 100).toInt();
              await showNotification(progress, 'Uploading Video...', '\$progress% completed');
              chunkSuccess = true;
              
            } catch (e) {
               AppLogger.warning("BackgroundUploadService: Chunk \${chunk.partNumber} failed, retrying in 10s. Error: \$e");
               await showNotification(((uploadedChunks / totalChunks) * 100).toInt(), 'Upload Paused', 'Waiting for internet connection...', isError: true);
               await Future.delayed(const Duration(seconds: 10));
            }
        }
    }

    // Complete upload
    await showNotification(99, 'Processing Video...', 'Almost done');
    final parts = job.chunks.map((c) => {
      'PartNumber': c.partNumber,
      'ETag': c.eTag
    }).toList();

    final response = await _apiService.completeUpload(
      key: job.s3Key,
      uploadId: job.uploadId,
      mediaType: 'video',
      originalFileName: file.path.split('/').last,
      userId: 'app_user', // This should be dynamic based on signed in user
      parts: parts,
      contentId: job.contentId,
    );

    job.status = 'completed';
    job.videoId = response['videoId'];
    job.updateUpdatedAt();
    await job.save();
    
    await _notificationsPlugin.cancel(0);
  }

  Future<void> createJobAndStart(String filePath, {String? contentId}) async {
    final file = File(filePath);
    if (!await file.exists()) return;

    final fileSizeBytes = await file.length();
    final partCount = (fileSizeBytes / chunkSize).ceil();
    final filename = filePath.split('/').last;

    final initData = await _apiService.initiateUpload(
      filename: filename, 
      contentType: 'video/mp4', 
      partCount: partCount
    );

    final String uploadId = initData['uploadId'];
    final String key = initData['key'];
    final List<dynamic> partsData = initData['parts'];

    final uploadBox = Hive.box<UploadJob>('upload_jobs');
    
    final chunks = partsData.map((part) => UploadChunk(
      partNumber: part['partNumber'],
      presignedUrl: part['presignedUrl'],
    )).toList();

    final job = UploadJob(
      jobId: DateTime.now().millisecondsSinceEpoch.toString(),
      filePath: filePath,
      uploadId: uploadId,
      s3Key: key,
      fileSizeBytes: fileSizeBytes,
      partCount: partCount,
      createdAt: DateTime.now(),
      chunks: chunks,
      contentId: contentId,
    );

    await uploadBox.put(job.jobId, job);
    
    AppLogger.info("BackgroundUploadService: Job created for \${file.path} as JobID: \${job.jobId}");
    
    // Start background processor
    startOrResumeUpload();
  }
}
