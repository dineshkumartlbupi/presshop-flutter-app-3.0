import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:presshop/core/models/upload_job.dart';
import 'package:presshop/core/models/upload_chunk.dart';
import 'package:presshop/core/services/app_initialization_service.dart';
import 'package:presshop/features/media/domain/services/background_upload_service.dart';
import 'package:presshop/core/utils/http_overrides.dart';
import 'package:presshop/core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  // Initialize essential services
  await AppInitializationService.loadEnvironment();
  await di.init(); // Initialize DI
  
  // Initialize Hive and register adapters
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(101)) {
    Hive.registerAdapter(UploadJobAdapter());
  }
  if (!Hive.isAdapterRegistered(102)) {
    Hive.registerAdapter(UploadChunkAdapter());
  }
  await Hive.openBox<UploadJob>('upload_jobs');

  // Initialize Background Upload Service (Notifications, etc.)
  await BackgroundUploadService().initialize();

  runApp(const MaterialApp(
    home: UploadTestScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class UploadTestScreen extends StatefulWidget {
  const UploadTestScreen({super.key});

  @override
  State<UploadTestScreen> createState() => _UploadTestScreenState();
}

class _UploadTestScreenState extends State<UploadTestScreen> {
  final ImagePicker _picker = ImagePicker();
  List<UploadJob> _jobs = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _refreshJobs();
    // Poll Hive every second to update UI
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _refreshJobs();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _refreshJobs() {
    final box = Hive.box<UploadJob>('upload_jobs');
    setState(() {
      _jobs = box.values.toList().reversed.toList();
    });
  }

  Future<void> _pickAndUpload() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      debugPrint("Selected video: ${video.path}");
      await BackgroundUploadService().createJobAndStart(video.path);
      _refreshJobs();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload Job Created!")),
      );
    }
  }

  Future<void> _clearJobs() async {
    final box = Hive.box<UploadJob>('upload_jobs');
    await box.clear();
    _refreshJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Background Upload Tester"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearJobs,
            tooltip: "Clear Jobs",
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Testing Ground for S3 Chunked Uploads",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _pickAndUpload,
            icon: const Icon(Icons.video_collection),
            label: const Text("Pick Video & Start Background Upload"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          const Divider(height: 32),
          const Text("Recent Upload Jobs (Live from Hive)"),
          Expanded(
            child: _jobs.isEmpty
                ? const Center(child: Text("No jobs found in Hive"))
                : ListView.builder(
                    itemCount: _jobs.length,
                    itemBuilder: (context, index) {
                      final job = _jobs[index];
                      int uploaded = job.chunks.where((c) => c.status == 'uploaded').length;
                      double progress = job.partCount > 0 ? uploaded / job.partCount : 0;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text("Job ID: ${job.jobId}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Status: ${job.status}"),
                              Text("File: ${job.filePath.split('/').last}"),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(value: progress),
                              Text("${(progress * 100).toInt()}% (${uploaded}/${job.partCount} chunks)"),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Simple Timer import since I used it manually
import 'dart:async';
