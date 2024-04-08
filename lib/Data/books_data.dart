import 'package:flutter/material.dart';
import 'package:gnml/Data/Model/book_model.dart';
import 'package:gnml/Logic/bookspage_logic.dart';

class BooksData {
  Future<List<dynamic>> searchBooks(String query, int page) async {
    return await BooksPageLogic().searchBooks(query);
  }

  Widget getBookReleaseDate(data) {
    if (data.publish_year == null) {
      return const Text(
        "Unknown",
        style: TextStyle(color: Colors.grey, fontSize: 12),
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      );
    } else {
      return Text(
        data.publish_year.toString(),
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12),
      );
    }
  }

  void addToBooksList(List<dynamic> booksList, Map<String, dynamic> bookMap) {
    booksList.add(bookMap);
  }

  void removeFromBooksList(List<dynamic> booksList, String bookID) {
    booksList.removeWhere((element) => element['bookID'] == bookID);
  }

  void addBooksToFavorites(
      List<dynamic> booksList, String bookID, ValueNotifier<bool> isFavorite) {
    for (var x in booksList) {
      if (x['bookID'] == bookID) {
        isFavorite.value = true;
      }
    }
  }

  Map<String, dynamic> getBookMap(
      String bookID, List<BookModel> data, int index) {
    Map<String, dynamic> bookMap = {
      "bookID": bookID,
      "imageURL": data[index].imageURL.toString(),
      "bookName": data[index].title,
    };
    return bookMap;
  }

  Map<String, dynamic> getBookMapLibrary(List<dynamic> booksList, int index) {
    Map<String, dynamic> bookMap = {
      "bookID": booksList[index]['bookID'],
      "imageURL": booksList[index]['imageURL'],
      "bookName": booksList[index]['bookName'],
    };
    return bookMap;
  }
}
