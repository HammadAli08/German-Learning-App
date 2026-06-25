// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_gloss.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WordGlossAdapter extends TypeAdapter<WordGloss> {
  @override
  final int typeId = 1;

  @override
  WordGloss read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WordGloss(
      de: fields[0] as String,
      en: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WordGloss obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.de)
      ..writeByte(1)
      ..write(obj.en);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordGlossAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
