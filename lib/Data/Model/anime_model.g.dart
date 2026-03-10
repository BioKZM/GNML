// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anime_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnimeModelAdapter extends TypeAdapter<AnimeModel> {
  @override
  final int typeId = 5;

  @override
  AnimeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnimeModel(
      id: fields[0] as int?,
      title: fields[1] as String?,
      imageURL: fields[2] as String?,
      synopsis: fields[3] as String?,
      score: fields[4] as double?,
      status: fields[5] as String?,
      episodes: fields[6] as int?,
      type: fields[7] as String?,
      genres: (fields[8] as List?)?.cast<dynamic>(),
      aired_string: fields[9] as String?,
      rating: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AnimeModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.imageURL)
      ..writeByte(3)
      ..write(obj.synopsis)
      ..writeByte(4)
      ..write(obj.score)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.episodes)
      ..writeByte(7)
      ..write(obj.type)
      ..writeByte(8)
      ..write(obj.genres)
      ..writeByte(9)
      ..write(obj.aired_string)
      ..writeByte(10)
      ..write(obj.rating);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
