// ignore_for_file: non_constant_identifier_names
import 'package:hive/hive.dart';
import 'package:vault/Data/Model/base_content_model.dart';

part 'book_model.g.dart';

@HiveType(typeId: 3)
class BookModel implements BaseContentModel {
  @override
  @HiveField(0)
  String? id;
  @override
  @HiveField(1)
  String? title;
  // String? subtitle;
  @HiveField(2)
  List<dynamic>? authors;
  // List<dynamic>? publisher;
  @HiveField(3)
  int? publish_year;
  @HiveField(4)
  String? description;
  @HiveField(5)
  int? page_count;
  @override
  @HiveField(6)
  String? imageURL;

  BookModel({
    this.id,
    this.title,
    this.authors,
    this.publish_year,
    this.description,
    this.page_count,
    this.imageURL,
  });

  BookModel.fromJson(Map<String, dynamic> json) {
    id = json['key'];
    title = json['title'];
    authors = json['author_name'];
    description = json['description'];
    description ??= "";
    publish_year = json['first_publish_year'];
    page_count = json['number_of_pages_median'];
    if (json['seed'] != null) {
      imageURL = getCover(json['seed'][0]);
    } else {
      imageURL = getCover(json['covers'][0].toString());
    }
  }
}

String getCover(id) {
  return "https://covers.openlibrary.org/b/olid/${id.substring(7)}-L.jpg";
}
