// ignore_for_file: non_constant_identifier_names
import 'package:hive/hive.dart';
import 'package:vault/Data/Model/base_content_model.dart';

part 'actor_model.g.dart';

@HiveType(typeId: 4)
class ActorModel implements BaseContentModel {
  @override
  @HiveField(0)
  String? get title => name;
  @override
  @HiveField(1)
  int? id;
  @HiveField(2)
  String? biography;
  @HiveField(3)
  String? birthday;
  @HiveField(4)
  String? deathday;
  @HiveField(5)
  String? homepage;
  @HiveField(6)
  String? name;
  @HiveField(7)
  String? place_of_birth;
  @override
  @HiveField(8)
  String? imageURL;
  @HiveField(9)
  Map<String, dynamic>? movie_credits;
  @HiveField(10)
  Map<String, dynamic>? tv_credits;
  @HiveField(11)
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
  var imageUrl = json['profile_path'];
  if (imageUrl == null) {
    imageUrl ??=
        "https://firebasestorage.googleapis.com/v0/b/scheduleme-adde6.appspot.com/o/placeholder.jpg?alt=media&token=9cfa9b9d-eb60-409b-8a5f-b3b54a5c1b10";
  } else {
    imageUrl = "https://image.tmdb.org/t/p/original/${imageUrl?.substring(1)}";
  }
  return imageUrl;
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
