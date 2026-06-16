import 'package:flutter/material.dart';
import 'package:vault/Logic/bookspage_logic.dart';

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
}
