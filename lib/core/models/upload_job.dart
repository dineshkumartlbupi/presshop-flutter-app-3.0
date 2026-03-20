import 'package:hive/hive.dart';
import 'upload_chunk.dart';

class UploadJob extends HiveObject {
  final String jobId;
  final String filePath;
  final String uploadId;
  final String s3Key;
  final int fileSizeBytes;
  final int partCount;
  final DateTime createdAt;
  DateTime updatedAt;
  String status; // 'queued', 'uploading', 'paused', 'completed', 'failed'
  String? videoId;
  String? contentId;
  List<UploadChunk> chunks;

  UploadJob({
    required this.jobId,
    required this.filePath,
    required this.uploadId,
    required this.s3Key,
    required this.fileSizeBytes,
    required this.partCount,
    required this.createdAt,
    DateTime? updatedAt,
    this.status = 'queued',
    this.videoId,
    this.contentId,
    List<UploadChunk>? chunks,
  })  : chunks = chunks ?? [],
        updatedAt = updatedAt ?? DateTime.now();
        
  void updateUpdatedAt() {
    updatedAt = DateTime.now();
  }
}

class UploadJobAdapter extends TypeAdapter<UploadJob> {
  @override
  final int typeId = 101;

  @override
  UploadJob read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return UploadJob(
      jobId: fields[0] as String,
      filePath: fields[1] as String,
      uploadId: fields[2] as String,
      s3Key: fields[3] as String,
      fileSizeBytes: fields[4] as int,
      partCount: fields[5] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(fields[6] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(fields[7] as int),
      status: fields[8] as String,
      videoId: fields[9] as String?,
      chunks: (fields[10] as List?)?.cast<UploadChunk>() ?? [],
      contentId: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UploadJob obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.jobId)
      ..writeByte(1)
      ..write(obj.filePath)
      ..writeByte(2)
      ..write(obj.uploadId)
      ..writeByte(3)
      ..write(obj.s3Key)
      ..writeByte(4)
      ..write(obj.fileSizeBytes)
      ..writeByte(5)
      ..write(obj.partCount)
      ..writeByte(6)
      ..write(obj.createdAt.millisecondsSinceEpoch)
      ..writeByte(7)
      ..write(obj.updatedAt.millisecondsSinceEpoch)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.videoId)
      ..writeByte(10)
      ..write(obj.chunks)
      ..writeByte(11)
      ..write(obj.contentId);
  }
}
