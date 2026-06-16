// ignore_for_file: non_constant_identifier_names
import 'package:hive/hive.dart';
import 'package:vault/data/model/base_content_model.dart';

part 'auto_generated/anime_model.g.dart';

String? normalizeAnimeImageUrl(String? url) {
  if (url == null || url.trim().isEmpty) return null;
  var normalized = Uri.encodeFull(url.trim());
  if (normalized.contains('myanimelist.net/images/')) {
    normalized = normalized.replaceFirst(
      'https://myanimelist.net/images/',
      'https://cdn.myanimelist.net/images/',
    );
    normalized = normalized.replaceFirst(
      'http://myanimelist.net/images/',
      'https://cdn.myanimelist.net/images/',
    );
  }
  return normalized;
}

@HiveType(typeId: 5)
class AnimeModel implements BaseContentModel {
  @override
  @HiveField(0)
  int? id;
  @override
  @HiveField(1)
  String? title;
  @override
  @HiveField(2)
  String? imageURL;
  @HiveField(3)
  String? synopsis;
  @HiveField(4)
  double? score;
  @HiveField(5)
  String? status;
  @HiveField(6)
  int? episodes;
  @HiveField(7)
  String? type;
  @HiveField(8)
  List<dynamic>? genres;
  @HiveField(9)
  String? aired_string;
  @HiveField(10)
  String? rating;

  AnimeModel({
    this.id,
    this.title,
    this.imageURL,
    this.synopsis,
    this.score,
    this.status,
    this.episodes,
    this.type,
    this.genres,
    this.aired_string,
    this.rating,
  });

  AnimeModel.fromJson(Map<String, dynamic> json) {
    id = json['mal_id'];
    title = json['title'];
    if (json['images'] != null) {
      final jpg = json['images']['jpg'];
      final webp = json['images']['webp'];
      imageURL = normalizeAnimeImageUrl(
        webp?['large_image_url'] ??
            webp?['image_url'] ??
            webp?['small_image_url'] ??
            jpg?['large_image_url'] ??
            jpg?['image_url'] ??
            jpg?['small_image_url'],
      );
    }
    synopsis = json['synopsis'];
    score = json['score']?.toDouble();
    status = json['status'];
    episodes = json['episodes'];
    type = json['type'];
    if (json['genres'] != null) {
      genres = json['genres'].map((g) => g['name']).toList();
    }
    if (json['aired'] != null) {
      aired_string = json['aired']['string'];
    }
    rating = json['rating'];
  }
}
