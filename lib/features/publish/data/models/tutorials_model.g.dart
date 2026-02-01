// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutorials_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TutorialsModelAdapter extends TypeAdapter<TutorialsModel> {
  @override
  final int typeId = 0;

  @override
  TutorialsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TutorialsModel(
      id: fields[0] as String,
      video: fields[1] as String,
      description: fields[3] as String,
      category: fields[4] as String,
      duration: fields[5] as String,
      view: fields[6] as int,
      thumbnail: fields[2] as String,
      showVideo: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TutorialsModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.video)
      ..writeByte(2)
      ..write(obj.thumbnail)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.duration)
      ..writeByte(6)
      ..write(obj.view)
      ..writeByte(7)
      ..write(obj.showVideo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TutorialsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
