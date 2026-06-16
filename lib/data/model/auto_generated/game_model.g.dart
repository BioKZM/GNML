// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../game_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameModelAdapter extends TypeAdapter<GameModel> {
  @override
  final int typeId = 0;

  @override
  GameModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameModel(
      id: fields[2] as int?,
      age_ratings: (fields[3] as List?)?.cast<dynamic>(),
      aggregated_rating: fields[4] as int?,
      artworks: (fields[5] as List?)?.cast<dynamic>(),
      category: fields[6] as int?,
      cover: fields[7] as dynamic,
      first_release_date: fields[8] as int?,
      game_engines: (fields[9] as List?)?.cast<dynamic>(),
      genres: (fields[10] as List?)?.cast<dynamic>(),
      keywords: (fields[11] as List?)?.cast<dynamic>(),
      multiplayer_modes: (fields[12] as List?)?.cast<dynamic>(),
      name: fields[13] as String?,
      platforms: (fields[14] as List?)?.cast<dynamic>(),
      player_perspectives: (fields[15] as List?)?.cast<dynamic>(),
      rating: fields[16] as int?,
      release_dates: (fields[17] as List?)?.cast<dynamic>(),
      screenshots: (fields[18] as List?)?.cast<dynamic>(),
      storyline: fields[19] as String?,
      summary: fields[20] as String?,
      tags: (fields[21] as List?)?.cast<dynamic>(),
      themes: (fields[22] as List?)?.cast<dynamic>(),
      videos: (fields[23] as List?)?.cast<dynamic>(),
      language: (fields[25] as List?)?.cast<dynamic>(),
      language_support_type: (fields[26] as List?)?.cast<dynamic>(),
      url: fields[28] as String?,
      image_id: fields[29] as String?,
      hypes: fields[30] as int?,
      involved_companies: (fields[31] as List?)?.cast<dynamic>(),
      language_support: (fields[27] as Map?)?.cast<dynamic, dynamic>(),
      screenshots_list: (fields[32] as List?)?.cast<dynamic>(),
    )..websites = (fields[24] as List?)?.cast<dynamic>();
  }

  @override
  void write(BinaryWriter writer, GameModel obj) {
    writer
      ..writeByte(33)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.age_ratings)
      ..writeByte(4)
      ..write(obj.aggregated_rating)
      ..writeByte(5)
      ..write(obj.artworks)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.cover)
      ..writeByte(8)
      ..write(obj.first_release_date)
      ..writeByte(9)
      ..write(obj.game_engines)
      ..writeByte(10)
      ..write(obj.genres)
      ..writeByte(11)
      ..write(obj.keywords)
      ..writeByte(12)
      ..write(obj.multiplayer_modes)
      ..writeByte(13)
      ..write(obj.name)
      ..writeByte(14)
      ..write(obj.platforms)
      ..writeByte(15)
      ..write(obj.player_perspectives)
      ..writeByte(16)
      ..write(obj.rating)
      ..writeByte(17)
      ..write(obj.release_dates)
      ..writeByte(18)
      ..write(obj.screenshots)
      ..writeByte(19)
      ..write(obj.storyline)
      ..writeByte(20)
      ..write(obj.summary)
      ..writeByte(21)
      ..write(obj.tags)
      ..writeByte(22)
      ..write(obj.themes)
      ..writeByte(23)
      ..write(obj.videos)
      ..writeByte(24)
      ..write(obj.websites)
      ..writeByte(25)
      ..write(obj.language)
      ..writeByte(26)
      ..write(obj.language_support_type)
      ..writeByte(27)
      ..write(obj.language_support)
      ..writeByte(28)
      ..write(obj.url)
      ..writeByte(29)
      ..write(obj.image_id)
      ..writeByte(30)
      ..write(obj.hypes)
      ..writeByte(31)
      ..write(obj.involved_companies)
      ..writeByte(32)
      ..write(obj.screenshots_list)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.imageURL);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
