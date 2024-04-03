class BookModel {
  String? id;
  String? title;
  // String? subtitle;
  List<dynamic>? authors;
  // List<dynamic>? publisher;
  int? publish_year;
  String? description;
  int? page_count;
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
