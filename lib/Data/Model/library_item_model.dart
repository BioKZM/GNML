import 'package:vault/Data/Model/base_content_model.dart';

class LibraryItemModel implements BaseContentModel {
  @override
  final dynamic id;
  @override
  final String? title;
  @override
  final String? imageURL;

  LibraryItemModel({
    required this.id,
    required this.title,
    required this.imageURL,
  });

  factory LibraryItemModel.fromMap(Map<String, dynamic> map, String type) {
    switch (type) {
      case 'games':
        return LibraryItemModel(
          id: map['gameID'],
          title: map['gameName'],
          imageURL: map['imageURL'],
        );
      case 'movies':
        return LibraryItemModel(
          id: map['movieID'],
          title: map['movieName'],
          imageURL: map['imageURL'],
        );
      case 'series':
        return LibraryItemModel(
          id: map['serieID'],
          title: map['serieName'],
          imageURL: map['imageURL'],
        );
      case 'books':
        return LibraryItemModel(
          id: map['bookID'],
          title: map['bookName'],
          imageURL: map['imageURL'],
        );
      case 'actors':
        return LibraryItemModel(
          id: map['actorID'],
          title: map['actorName'],
          imageURL: map['imageURL'],
        );
      case 'animes':
        return LibraryItemModel(
          id: map['animeID'],
          title: map['title'],
          imageURL: map['imageURL'],
        );
      default:
        throw Exception("Unknown library item type: $type");
    }
  }
}
