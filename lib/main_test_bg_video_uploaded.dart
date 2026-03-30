import 'dart:async';
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
  if (!Hive.isAdapterRegistered(100)) {
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
  final List<String> _logs = [];
  Timer? _timer;
  final ScrollController _logScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _refreshJobs();
    _addLog("Test Playground Initialized");

    // Poll Hive every second to update UI
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _refreshJobs();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _logScrollController.dispose();
    super.dispose();
  }

  void _addLog(String msg) {
    debugPrint("TesterLog: $msg");
    if (!mounted) return;
    setState(() {
      final timestamp =
          DateTime.now().toString().split('.').first.split(' ').last;
      _logs.add("[$timestamp] $msg");
      if (_logs.length > 50) _logs.removeAt(0);
    });
    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logScrollController.hasClients) {
        _logScrollController.animateTo(
          _logScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _refreshJobs() {
    if (!Hive.isBoxOpen('upload_jobs')) return;
    final box = Hive.box<UploadJob>('upload_jobs');
    final newJobs = box.values.toList().reversed.toList();

    // Simple logic to detect status changes for logging
    if (_jobs.isNotEmpty && newJobs.isNotEmpty) {
      for (var newJob in newJobs) {
        final oldJob = _jobs.firstWhere((j) => j.jobId == newJob.jobId,
            orElse: () => newJob);
        if (oldJob.status != newJob.status) {
          _addLog(
              "Job ${newJob.jobId} status: ${oldJob.status} -> ${newJob.status}");
        }
      }
    }

    setState(() {
      _jobs = newJobs;
    });
  }

  Future<void> _pickAndUpload() async {
    _addLog("Opening video picker (multiple selection)...");
    List<XFile>? videos;
    try {
      videos = await _picker.pickMultiVideo();
    } catch (e) {
      _addLog("ERROR: $e");
      return;
    }
    if (videos != null && videos.isNotEmpty) {
      _addLog("Selected: ${videos.length} video(s)");
      for (final video in videos) {
        _addLog("Selected: ${video.name} (${video.path})");
        try {
          await BackgroundUploadService().createJobAndStart(video.path);
          _addLog("Job successfully created and started for ${video.name}.");
        } catch (e) {
          _addLog("ERROR: $e");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("Error creating job for ${video.name}: $e")),
            );
          }
        }
      }
      _refreshJobs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${videos.length} Upload Job(s) Created!")),
        );
      }
    } else {
      _addLog("Video picking cancelled or no videos selected.");
    }
  }

  Future<void> _clearJobs() async {
    _addLog("Clearing all jobs from Hive...");
    final box = Hive.box<UploadJob>('upload_jobs');
    await box.clear();
    _refreshJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Background Upload Tester"),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
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
          // Action Panel
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.blueGrey[50],
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickAndUpload,
                  icon: const Icon(Icons.video_collection),
                  label: const Text("Pick Video & Start Upload"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Jobs List (Middle)
          Expanded(
            flex: 2,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("Active Jobs",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: _jobs.isEmpty
                      ? const Center(child: Text("No jobs found"))
                      : ListView.builder(
                          itemCount: _jobs.length,
                          itemBuilder: (context, index) {
                            final job = _jobs[index];
                            int uploaded = job.chunks
                                .where((c) => c.status == 'uploaded')
                                .length;
                            double progress = job.partCount > 0
                                ? uploaded / job.partCount
                                : 0;

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              child: ListTile(
                                dense: true,
                                title: Text(job.filePath.split('/').last,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Status: ${job.status}",
                                        style: const TextStyle(fontSize: 10)),
                                    const SizedBox(height: 4),
                                    LinearProgressIndicator(
                                        value: progress, minHeight: 4),
                                  ],
                                ),
                                trailing: Text("${(progress * 100).toInt()}%",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 2),

          // Log Console (Bottom)
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.black87,
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("LOG CONSOLE",
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 10)),
                      GestureDetector(
                        onTap: () => setState(() => _logs.clear()),
                        child: const Text("CLEAR",
                            style:
                                TextStyle(color: Colors.white54, fontSize: 10)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: ListView.builder(
                      controller: _logScrollController,
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        final isError = log.contains("ERROR");
                        return Text(
                          log,
                          style: TextStyle(
                            color: isError ? Colors.redAccent : Colors.white,
                            fontFamily: 'monospace',
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
