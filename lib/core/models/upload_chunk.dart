import 'package:hive/hive.dart';

class UploadChunk { // 'pending', 'uploaded', 'failed'

  UploadChunk({
    required this.partNumber,
    required this.presignedUrl,
    this.eTag,
    this.status = 'pending',
  });
  final int partNumber;
  final String presignedUrl;
  String? eTag;
  String status;
}

class UploadChunkAdapter extends TypeAdapter<UploadChunk> {
  @override
  final int typeId = 100;

  @override
  UploadChunk read(BinaryReader reader) {
    return UploadChunk(
      partNumber: reader.readInt(),
      presignedUrl: reader.readString(),
      eTag: reader.readString(),
      status: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, UploadChunk obj) {
    writer.writeInt(obj.partNumber);
    writer.writeString(obj.presignedUrl);
    writer.writeString(obj.eTag ?? '');
    writer.writeString(obj.status);
  }
}
