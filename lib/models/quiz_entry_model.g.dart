// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_entry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuizEntryModelAdapter extends TypeAdapter<QuizEntryModel> {
  @override
  final int typeId = 1;

  @override
  QuizEntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizEntryModel(
      question: fields[0] as String,
      answer: fields[1] as String,
      number: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, QuizEntryModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.question)
      ..writeByte(1)
      ..write(obj.answer)
      ..writeByte(2)
      ..write(obj.number);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizEntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
