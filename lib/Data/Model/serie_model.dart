class SerieModel {
  int? id;
  String? overview;
  String? imageURL;
  String? first_air_date;
  String? name;
  double? vote_average;
  List<dynamic>? created_by;
  List<dynamic>? genres;
  String? homepage;
  int? number_of_episodes;
  int? number_of_seasons;
  List<dynamic>? production_companies;
  String? status;
  String? tagline;
  List<dynamic>? seasons;
  Map<String, dynamic>? credits;
  List<dynamic>? images;
  String? type;
  // List<dynamic>? genres;
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
  var image_url = json['poster_path'];

  image_url = "https://image.tmdb.org/t/p/original/${image_url?.substring(1)}";
  return image_url;
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
