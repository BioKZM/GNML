// ignore_for_file: non_constant_identifier_names
import 'package:hive/hive.dart';
import 'package:vault/Data/Model/base_content_model.dart';

part 'serie_model.g.dart';

@HiveType(typeId: 2)
class SerieModel implements BaseContentModel {
  @override
  @HiveField(0)
  String? get title => name;
  @override
  @HiveField(1)
  int? id;
  @HiveField(2)
  String? overview;
  @override
  @HiveField(3)
  String? imageURL;
  @HiveField(4)
  String? first_air_date;
  @HiveField(5)
  String? name;
  @HiveField(6)
  double? vote_average;
  @HiveField(7)
  List<dynamic>? created_by;
  @HiveField(8)
  List<dynamic>? genres;
  @HiveField(9)
  String? homepage;
  @HiveField(10)
  int? number_of_episodes;
  @HiveField(11)
  int? number_of_seasons;
  @HiveField(12)
  List<dynamic>? production_companies;
  @HiveField(13)
  String? status;
  @HiveField(14)
  String? tagline;
  @HiveField(15)
  List<dynamic>? seasons;
  @HiveField(16)
  Map<String, dynamic>? credits;
  @HiveField(17)
  List<dynamic>? images;
  @HiveField(18)
  String? type;
  // List<dynamic>? genres;
  @HiveField(19)
  dynamic providers;

  SerieModel({
    this.id,
    this.overview,
    this.imageURL,
    this.first_air_date,
    this.name,
    this.vote_average,
    this.created_by,
    this.genres,
    this.homepage,
    this.number_of_episodes,
    this.number_of_seasons,
    this.production_companies,
    this.status,
    this.tagline,
    this.seasons,
    this.credits,
    this.images,
    this.type,
    this.providers,
  });

  SerieModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    overview = json['overview'];
    imageURL = getImageURL(json);
    first_air_date = json['first_air_date'];
    name = json['name'];
    vote_average = json['vote_average'];
    created_by = json['created_by'];
    genres = json['genres'];
    homepage = json['homepage'];
    number_of_episodes = json['number_of_episodes'];
    number_of_seasons = json['number_of_seasons'];
    production_companies = json['production_companies'];
    status = json['status'];
    tagline = json['tagline'];
    // seasons = json['seasons'];
    credits = json['credits'];
    images = getImages(json);
    status = json['status'];
    type = json['type'];
    providers = getProviders(json);
  }
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
