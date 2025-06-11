// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EntryModelAdapter extends TypeAdapter<EntryModel> {
  @override
  final int typeId = 0;

  @override
  EntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EntryModel(
      text: fields[0] as String,
      image: fields[1] as Uint8List?,
      audio: fields[2] as Uint8List?,
      video: fields[3] as Uint8List?,
      audioName: fields[4] as String?,
      videoName: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EntryModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.image)
      ..writeByte(2)
      ..write(obj.audio)
      ..writeByte(3)
      ..write(obj.video)
      ..writeByte(4)
      ..write(obj.audioName)
      ..writeByte(5)
      ..write(obj.videoName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
