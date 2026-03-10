// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serie_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SerieModelAdapter extends TypeAdapter<SerieModel> {
  @override
  final int typeId = 2;

  @override
  SerieModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SerieModel(
      id: fields[1] as int?,
      overview: fields[2] as String?,
      imageURL: fields[3] as String?,
      first_air_date: fields[4] as String?,
      name: fields[5] as String?,
      vote_average: fields[6] as double?,
      created_by: (fields[7] as List?)?.cast<dynamic>(),
      genres: (fields[8] as List?)?.cast<dynamic>(),
      homepage: fields[9] as String?,
      number_of_episodes: fields[10] as int?,
      number_of_seasons: fields[11] as int?,
      production_companies: (fields[12] as List?)?.cast<dynamic>(),
      status: fields[13] as String?,
      tagline: fields[14] as String?,
      seasons: (fields[15] as List?)?.cast<dynamic>(),
      credits: (fields[16] as Map?)?.cast<String, dynamic>(),
      images: (fields[17] as List?)?.cast<dynamic>(),
      type: fields[18] as String?,
      providers: fields[19] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, SerieModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.overview)
      ..writeByte(3)
      ..write(obj.imageURL)
      ..writeByte(4)
      ..write(obj.first_air_date)
      ..writeByte(5)
      ..write(obj.name)
      ..writeByte(6)
      ..write(obj.vote_average)
      ..writeByte(7)
      ..write(obj.created_by)
      ..writeByte(8)
      ..write(obj.genres)
      ..writeByte(9)
      ..write(obj.homepage)
      ..writeByte(10)
      ..write(obj.number_of_episodes)
      ..writeByte(11)
      ..write(obj.number_of_seasons)
      ..writeByte(12)
      ..write(obj.production_companies)
      ..writeByte(13)
      ..write(obj.status)
      ..writeByte(14)
      ..write(obj.tagline)
      ..writeByte(15)
      ..write(obj.seasons)
      ..writeByte(16)
      ..write(obj.credits)
      ..writeByte(17)
      ..write(obj.images)
      ..writeByte(18)
      ..write(obj.type)
      ..writeByte(19)
      ..write(obj.providers)
      ..writeByte(0)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SerieModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
