// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovieModelAdapter extends TypeAdapter<MovieModel> {
  @override
  final int typeId = 1;

  @override
  MovieModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MovieModel(
      adult: fields[0] as bool?,
      background_image_url: fields[1] as String?,
      id: fields[2] as int?,
      budget: fields[3] as int?,
      genres: (fields[4] as List?)?.cast<dynamic>(),
      original_language: fields[5] as String?,
      overview: fields[6] as String?,
      popularity: fields[7] as double?,
      production_companies: (fields[8] as List?)?.cast<dynamic>(),
      imageURL: fields[9] as String?,
      release_date: fields[10] as String?,
      revenue: fields[11] as int?,
      title: fields[12] as String?,
      status: fields[13] as String?,
      tagline: fields[14] as String?,
      video: fields[15] as bool?,
      vote_average: fields[16] as double?,
      votecount: fields[17] as int?,
      credits: (fields[18] as Map?)?.cast<String, dynamic>(),
      cast: (fields[19] as List?)?.cast<dynamic>(),
      crew: (fields[20] as List?)?.cast<dynamic>(),
      total_pages: fields[21] as int?,
      images: (fields[22] as List?)?.cast<dynamic>(),
      providers: fields[23] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, MovieModel obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.adult)
      ..writeByte(1)
      ..write(obj.background_image_url)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.budget)
      ..writeByte(4)
      ..write(obj.genres)
      ..writeByte(5)
      ..write(obj.original_language)
      ..writeByte(6)
      ..write(obj.overview)
      ..writeByte(7)
      ..write(obj.popularity)
      ..writeByte(8)
      ..write(obj.production_companies)
      ..writeByte(9)
      ..write(obj.imageURL)
      ..writeByte(10)
      ..write(obj.release_date)
      ..writeByte(11)
      ..write(obj.revenue)
      ..writeByte(12)
      ..write(obj.title)
      ..writeByte(13)
      ..write(obj.status)
      ..writeByte(14)
      ..write(obj.tagline)
      ..writeByte(15)
      ..write(obj.video)
      ..writeByte(16)
      ..write(obj.vote_average)
      ..writeByte(17)
      ..write(obj.votecount)
      ..writeByte(18)
      ..write(obj.credits)
      ..writeByte(19)
      ..write(obj.cast)
      ..writeByte(20)
      ..write(obj.crew)
      ..writeByte(21)
      ..write(obj.total_pages)
      ..writeByte(22)
      ..write(obj.images)
      ..writeByte(23)
      ..write(obj.providers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
