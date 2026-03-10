// ignore_for_file: non_constant_identifier_names
import 'package:hive/hive.dart';
import 'package:vault/Data/Model/base_content_model.dart';

part 'game_model.g.dart';

@HiveType(typeId: 0)
class GameModel implements BaseContentModel {
  @override
  @HiveField(0)
  String? get title => name;
  @override
  @HiveField(1)
  String? get imageURL => url != null ? "https://$url" : null;

  @override
  @HiveField(2)
  int? id;
  @HiveField(3)
  List<dynamic>? age_ratings;
  @HiveField(4)
  int? aggregated_rating;
  @HiveField(5)
  List<dynamic>? artworks;
  @HiveField(6)
  int? category;
  @HiveField(7)
  dynamic cover;
  @HiveField(8)
  int? first_release_date;
  @HiveField(9)
  List<dynamic>? game_engines;
  @HiveField(10)
  List<dynamic>? genres;
  @HiveField(11)
  List<dynamic>? keywords;
  @HiveField(12)
  List<dynamic>? multiplayer_modes;
  @HiveField(13)
  String? name;
  @HiveField(14)
  List<dynamic>? platforms;
  @HiveField(15)
  List<dynamic>? player_perspectives;
  @HiveField(16)
  int? rating;
  @HiveField(17)
  List<dynamic>? release_dates;
  @HiveField(18)
  List<dynamic>? screenshots;
  @HiveField(19)
  String? storyline;
  @HiveField(20)
  String? summary;
  @HiveField(21)
  List<dynamic>? tags;
  @HiveField(22)
  List<dynamic>? themes;
  @HiveField(23)
  List<dynamic>? videos;
  @HiveField(24)
  List<dynamic>? websites;
  @HiveField(25)
  List<dynamic>? language;
  @HiveField(26)
  List<dynamic>? language_support_type;
  @HiveField(27)
  Map<dynamic, dynamic>? language_support;
  @HiveField(28)
  String? url;
  @HiveField(29)
  String? image_id;
  @HiveField(30)
  int? hypes;
  @HiveField(31)
  List<dynamic>? involved_companies;
  @HiveField(32)
  List<dynamic>? screenshots_list;

  GameModel({
    this.id,
    this.age_ratings,
    this.aggregated_rating,
    this.artworks,
    this.category,
    this.cover,
    this.first_release_date,
    this.game_engines,
    this.genres,
    this.keywords,
    this.multiplayer_modes,
    this.name,
    this.platforms,
    this.player_perspectives,
    this.rating,
    this.release_dates,
    this.screenshots,
    this.storyline,
    this.summary,
    this.tags,
    this.themes,
    this.videos,
    this.language,
    this.language_support_type,
    this.url,
    this.image_id,
    this.hypes,
    this.involved_companies,
    this.language_support,
    this.screenshots_list,
  });

  GameModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cover = json['cover'];
    genres = json['genres'];
    name = json['name'];
    platforms = json['platforms'];
    hypes = json['hypes'];
    category = json['category'];
    involved_companies = json['involved_companies'];
    if (json['summary'] == null) {
      summary = " ";
    } else {
      summary = json['summary'].replaceAll("", "'");
    }
    if (json['storyline'] == null) {
      storyline = "Nothing here.";
    } else {
      storyline = json['storyline'].replaceAll("", "'");
    }
    themes = json['themes'];
    tags = json["tags"];
    first_release_date = getFirstReleaseDate(json);
    url = getCoverURL(json, cover);
    image_id = getImageID(json, cover);
    language_support = getLanguageSupport(json);
    screenshots_list = getScreenshotIDList(json);
    websites = json['websites'];
    if (json['aggregated_rating'] != null && json['rating'] != null) {
      aggregated_rating = json['aggregated_rating'].toInt();
      rating = json['rating'].toInt();
    }
  }
}

dynamic getFirstReleaseDate(json) {
  dynamic firstReleaseDate;
  if (json['first_release_date'] == null) {
    firstReleaseDate = 0;
  } else {
    firstReleaseDate = json['first_release_date'];
  }
  return firstReleaseDate;
}

dynamic getCoverURL(json, cover) {
  dynamic url;
  if (cover == null) {
    url = "images.igdb.com/igdb/image/upload/t_720p/null.png";
  } else {
    url = cover['url'];

    url = "images.igdb.com/igdb/image/upload/t_720p/${url.substring(44)}";
  }
  return url;
}

List<dynamic> getScreenshotIDList(json) {
  List<dynamic> idList = [];
  if (json['screenshots'] != null) {
    for (var x in json['screenshots']) {
      idList.add(x['image_id']);
    }
  }

  return idList;
}

dynamic getImageID(json, cover) {
  dynamic imageId;
  if (cover == null) {
    imageId = "0";
  } else {
    imageId = cover['image_id'];
  }
  return imageId;
}

dynamic getLanguageSupport(json) {
  var languageSupportDict = {};
  if (json['language_supports'] != null) {
    for (var x in json['language_supports']) {
      languageSupportDict[x['language']['name']] = [];
    }
    for (var y in json['language_supports']) {
      languageSupportDict[y['language']['name']]
          .add(y['language_support_type']['name']);
    }
  }

  return languageSupportDict;
}
