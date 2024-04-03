class MusicModel {
  // List<dynamic>? items;
  String? id;
  String? album_type;
  List<dynamic>? artists;
  Map<String, dynamic>? external_urls;
  String? href;
  List<dynamic>? images;
  String? name;
  String? release_date;
  int? total_tracks;
  String? image_url;
  bool? explicit;

  MusicModel({
    this.id,
    this.album_type,
    this.artists,
    this.external_urls,
    this.href,
    this.images,
    this.name,
    this.release_date,
    this.total_tracks,
    this.image_url,
    this.explicit,
  });
  MusicModel.fromJson(Map<String, dynamic> json) {
    // json = json['albums']['items'];
    // varalbumJson = json['albums']['items'];
    id = json["id"];
    album_type = json['album_type'];
    artists = json['artists'];
    external_urls = json['external_urls'];
    href = json['href'];
    images = json['images'];
    // image_url = images[0]['url'];
    image_url = getImages(json);
    name = json['name'];
    release_date = json['release_date'];
    total_tracks = json['total_tracks'];
    explicit = json['explicit'];
  }
}

String getImages(json) {
  // return json[]
  if (json['images'] != null) {
    return json['images'][0]['url'];
  } else {
    return "";
  }
}
// IconButton(
//                                               splashColor: Colors.transparent,
//                                               highlightColor:
//                                                   Colors.transparent,
//                                               hoverColor: Colors.transparent,
//                                               padding: EdgeInsets.zero,
//                                               alignment: AlignmentDirectional
//                                                   .centerStart,
//                                               // ignore: dead_code
//                                               icon: isOpen
//                                                   ? const Icon(Icons
//                                                       .keyboard_arrow_up_rounded)
//                                                   : const Icon(Icons
//                                                       .keyboard_arrow_down_rounded),
//                                               onPressed: () {
//                                                 setState(
//                                                   () {
//                                                     isOpen = !isOpen;
//                                                   },
//                                                 );
//                                               },
//                                             ),