import 'dart:convert';
import 'package:gnml/Data/Model/book_model.dart';
import 'package:http/http.dart' as http;

class BooksPageLogic {
  Future<BookModel> getBook(String id) async {
    BookModel bookModel = BookModel();

    var response = await http.get(
      Uri.parse(
        "https://openlibrary.org/works/$id.json",
      ),
    );
    var responseBody = jsonDecode(response.body);
    bookModel = BookModel.fromJson(responseBody);
    return bookModel;
  }

  Future<List<BookModel>> searchBooks(String query) async {
    List<BookModel> bookModelList = [];
    var response = await http.get(
      Uri.parse(
        "https://openlibrary.org/search.json?q=$query",
      ),
    );
    var responseBody = jsonDecode(response.body);
    for (Map<String, dynamic> x in responseBody['docs']) {
      BookModel bookModel = BookModel.fromJson(x);
      bookModelList.add(bookModel);
    }
    return bookModelList;
  }
}
