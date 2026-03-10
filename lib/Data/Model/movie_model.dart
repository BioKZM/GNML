// ignore_for_file: non_constant_identifier_names
import 'package:hive/hive.dart';
import 'package:vault/Data/Model/base_content_model.dart';

part 'movie_model.g.dart';

@HiveType(typeId: 1)
class MovieModel implements BaseContentModel {
  @HiveField(0)
  bool? adult;
  @HiveField(1)
  String? background_image_url;
  // List<int?>? genreids;
  @override
  @HiveField(2)
  int? id;
  @HiveField(3)
  int? budget;
  @HiveField(4)
  List<dynamic>? genres;
  @HiveField(5)
  String? original_language;
  // String? originaltitle;
  @HiveField(6)
  String? overview;
  @HiveField(7)
  double? popularity;
  @HiveField(8)
  List<dynamic>? production_companies;
  @override
  @HiveField(9)
  String? imageURL;
  @HiveField(10)
  String? release_date;
  @HiveField(11)
  int? revenue;
  @override
  @HiveField(12)
  String? title;
  @HiveField(13)
  String? status;
  @HiveField(14)
  String? tagline;
  @HiveField(15)
  bool? video;
  @HiveField(16)
  double? vote_average;
  @HiveField(17)
  int? votecount;
  // List<dynamic>? spoken_languages;
  @HiveField(18)
  Map<String, dynamic>? credits;
  @HiveField(19)
  List<dynamic>? cast;
  @HiveField(20)
  List<dynamic>? crew;
  @HiveField(21)
  int? total_pages;
  @HiveField(22)
  List<dynamic>? images;
  @HiveField(23)
  dynamic providers;

  MovieModel({
    this.adult,
    this.background_image_url,
    // this.genreids,
    this.id,
    this.budget,
    this.genres,
    this.original_language,
    // this.originaltitle,
    this.overview,
    this.popularity,
    this.production_companies,
    this.imageURL,
    this.release_date,
    this.revenue,
    this.title,
    this.status,
    this.tagline,
    this.video,
    this.vote_average,
    this.votecount,
    // this.spoken_languages,
    this.credits,
    this.cast,
    this.crew,
    this.total_pages,
    this.images,
    this.providers,
  });

  MovieModel.fromJson(Map<String, dynamic> json) {
    adult = json['adult'];
    background_image_url = getBackgroundImageURL(json);
    overview = json['overview'];
    imageURL = getImageURL(json);
    release_date = json['release_date'];
    title = json['title'];
    budget = json['budget'];
    genres = json['genres'];
    id = json['id'];
    popularity = json['popularity'];
    production_companies = json['production_companies'];
    release_date = json['release_date'];
    revenue = json['revenue'];
    status = json['status'];
    tagline = json['tagline'];
    vote_average = json['vote_average'];
    // spoken_languages = json['spoken_languages'];
    credits = json['credits'];
    original_language = json['original_language'];
    images = getImages(json);
    providers = getProviders(json);
  }
}

String getBackgroundImageURL(json) {
  var backgroundImageUrl = json['backdrop_path'];
  backgroundImageUrl =
      "https://image.tmdb.org/t/p/original/${backgroundImageUrl?.substring(1)}";
  return backgroundImageUrl;
}

String getImageURL(json) {
  var imageUrl = json['poster_path'];
  imageUrl = "https://image.tmdb.org/t/p/original/${imageUrl?.substring(1)}";
  return imageUrl;
}

List<dynamic> getImages(json) {
  if (json['images'] == null) {
    return [];
  } else {
    return json['images']['backdrops'];
  }
}

dynamic getProviders(json) {
  if (json['watch/providers'] == null) {
    return <Set>{};
  } else {
    return json['watch/providers']['results'];
  }
}
