// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'actor_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActorModelAdapter extends TypeAdapter<ActorModel> {
  @override
  final int typeId = 4;

  @override
  ActorModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActorModel(
      id: fields[1] as int?,
      biography: fields[2] as String?,
      deathday: fields[4] as String?,
      homepage: fields[5] as String?,
      name: fields[6] as String?,
      place_of_birth: fields[7] as String?,
      imageURL: fields[8] as String?,
      movie_credits: (fields[9] as Map?)?.cast<String, dynamic>(),
      tv_credits: (fields[10] as Map?)?.cast<String, dynamic>(),
      images: (fields[11] as List?)?.cast<dynamic>(),
    )..birthday = fields[3] as String?;
  }

  @override
  void write(BinaryWriter writer, ActorModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.biography)
      ..writeByte(3)
      ..write(obj.birthday)
      ..writeByte(4)
      ..write(obj.deathday)
      ..writeByte(5)
      ..write(obj.homepage)
      ..writeByte(6)
      ..write(obj.name)
      ..writeByte(7)
      ..write(obj.place_of_birth)
      ..writeByte(8)
      ..write(obj.imageURL)
      ..writeByte(9)
      ..write(obj.movie_credits)
      ..writeByte(10)
      ..write(obj.tv_credits)
      ..writeByte(11)
      ..write(obj.images)
      ..writeByte(0)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActorModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
