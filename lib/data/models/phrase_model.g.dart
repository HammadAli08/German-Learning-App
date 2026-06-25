// GENERATED CODE - DO NOT MODIFY BY HAND
// Manually extended to include HiveField(11) category. If you re-run
// build_runner, the generated file will need this field added back.

part of 'phrase_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PhraseModelAdapter extends TypeAdapter<PhraseModel> {
  @override
  final int typeId = 0;

  @override
  PhraseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PhraseModel(
      englishText: fields[0] as String,
      germanInformal: fields[1] as String,
      germanFormal: fields[2] as String,
      wordGloss: (fields[3] as List).cast<WordGloss>(),
      grammarNote: fields[4] as String,
      alternatePhrasing: fields[5] as String,
      dateAdded: fields[6] as DateTime,
      lastReviewed: fields[7] as DateTime,
      intervalDays: fields[8] as int,
      easeFactor: fields[9] as double,
      cachedAudioPath: fields[10] as String?,
      // Field 11 may be absent in data written by older app versions → default 'personal'
      category: fields[11] as String? ?? 'personal',
    );
  }

  @override
  void write(BinaryWriter writer, PhraseModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.englishText)
      ..writeByte(1)
      ..write(obj.germanInformal)
      ..writeByte(2)
      ..write(obj.germanFormal)
      ..writeByte(3)
      ..write(obj.wordGloss)
      ..writeByte(4)
      ..write(obj.grammarNote)
      ..writeByte(5)
      ..write(obj.alternatePhrasing)
      ..writeByte(6)
      ..write(obj.dateAdded)
      ..writeByte(7)
      ..write(obj.lastReviewed)
      ..writeByte(8)
      ..write(obj.intervalDays)
      ..writeByte(9)
      ..write(obj.easeFactor)
      ..writeByte(10)
      ..write(obj.cachedAudioPath)
      ..writeByte(11)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhraseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
