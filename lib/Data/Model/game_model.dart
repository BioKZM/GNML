class GameModel {
  int? id;
  List<dynamic>? age_ratings;
  int? aggregated_rating;
  List<dynamic>? artworks;
  int? category;
  var cover;
  int? first_release_date;
  List<dynamic>? game_engines;
  List<dynamic>? genres;
  List<dynamic>? keywords;
  List<dynamic>? multiplayer_modes;
  String? name;
  List<dynamic>? platforms;
  List<dynamic>? player_perspectives;
  int? rating;
  List<dynamic>? release_dates;
  List<dynamic>? screenshots;
  String? storyline;
  String? summary;
  List<dynamic>? tags;
  List<dynamic>? themes;
  List<dynamic>? videos;
  List<dynamic>? websites;
  List<dynamic>? language;
  List<dynamic>? language_support_type;
  Map<dynamic, dynamic>? language_support;
  String? url;
  String? image_id;
  int? hypes;
  List<dynamic>? involved_companies;
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
  var first_release_date;
  if (json['first_release_date'] == null) {
    first_release_date = 0;
  } else {
    first_release_date = json['first_release_date'];
  }
  return first_release_date;
}

dynamic getCoverURL(json, cover) {
  var url;
  if (cover == null) {
    url = "images.igdb.com/igdb/image/upload/t_cover_big/null.png";
  } else {
    url = cover['url'];

    url = "images.igdb.com/igdb/image/upload/t_cover_big/${url.substring(44)}";
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
  var image_id;
  if (cover == null) {
    image_id = "0";
  } else {
    image_id = cover['image_id'];
  }
  return image_id;
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
