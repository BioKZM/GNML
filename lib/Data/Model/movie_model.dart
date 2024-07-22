class MovieModel {
  bool? adult;
  String? background_image_url;
  // List<int?>? genreids;
  int? id;
  int? budget;
  List<dynamic>? genres;
  String? original_language;
  // String? originaltitle;
  String? overview;
  double? popularity;
  List<dynamic>? production_companies;
  String? imageURL;
  String? release_date;
  int? revenue;
  String? title;
  String? status;
  String? tagline;
  bool? video;
  double? vote_average;
  int? votecount;
  // List<dynamic>? spoken_languages;
  Map<String, dynamic>? credits;
  List<dynamic>? cast;
  List<dynamic>? crew;
  int? total_pages;
  List<dynamic>? images;
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
  var background_image_url = json['backdrop_path'];
  background_image_url =
      "https://image.tmdb.org/t/p/original/${background_image_url?.substring(1)}";
  return background_image_url;
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
