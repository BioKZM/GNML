class ActorModel {
  int? id;
  String? biography;
  String? birthday;
  String? deathday;
  String? homepage;
  String? name;
  String? place_of_birth;
  String? imageURL;
  Map<String, dynamic>? movie_credits;
  Map<String, dynamic>? tv_credits;
  List<dynamic>? images;

  ActorModel({
    this.id,
    this.biography,
    this.deathday,
    this.homepage,
    this.name,
    this.place_of_birth,
    this.imageURL,
    this.movie_credits,
    this.tv_credits,
    this.images,
  });

  ActorModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    biography = json['biography'];
    birthday = json['birthday'];
    deathday = getDeathday(json);
    homepage = json['homepage'];
    name = json['name'];
    place_of_birth = json['place_of_birth'];
    imageURL = getImageURL(json);
    movie_credits = json['movie_credits'];
    tv_credits = json['tv_credits'];
    images = getImages(json);
  }
}

String getImageURL(json) {
  var image_url = json['profile_path'];
  if (image_url == null) {
    image_url ??=
        "https://firebasestorage.googleapis.com/v0/b/scheduleme-adde6.appspot.com/o/placeholder.jpg?alt=media&token=9cfa9b9d-eb60-409b-8a5f-b3b54a5c1b10";
  } else {
    image_url =
        "https://image.tmdb.org/t/p/original/${image_url?.substring(1)}";
  }
  return image_url;
}

dynamic getDeathday(json) {
  var deathday = json['deathday'];
  if (deathday == null) {
    return "";
  } else {
    return "- $deathday";
  }
}

dynamic getAKA(json) {
  var aka = json['also_known_as'];
  if (aka == null) {
    return "";
  } else {
    return aka;
  }
}

List<dynamic> getImages(json) {
  if (json['images'] == null) {
    return [];
  } else {
    return json['images']['profiles'];
  }
}
