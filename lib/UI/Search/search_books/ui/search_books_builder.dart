import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/Model/book_model.dart';
import 'package:gnml/Logic/bookspage_logic.dart';
import 'package:gnml/UI/Details/books_detail_page.dart';
import 'package:gnml/UI/Search/search_books/ui/widget/books_cards.dart';
import 'package:gnml/Widgets/circularprogressindicator.dart';

FutureBuilder<List<BookModel>> searchBooksBuilder(
  User? user,
  List<dynamic> booksList,
  int themeColor,
  List<dynamic> gamesList,
  List<dynamic> moviesList,
  List<dynamic> seriesList,
  List<dynamic> actorsList,
  Map<String, dynamic> favoritesList,
  String searchText,
) {
  return FutureBuilder<List<BookModel>>(
    future: BooksPageLogic().searchBooks(searchText),
    builder: (context, snapshot) {
      var data = snapshot.data;

      if (snapshot.hasData &&
          snapshot.connectionState == ConnectionState.done) {
        return GridView.builder(
          itemCount: data?.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300,
          ),
          itemBuilder: (context, index) {
            ValueNotifier<bool> isHovering = ValueNotifier<bool>(false);
            ValueNotifier<bool> isLiked = ValueNotifier<bool>(false);
            ValueNotifier<bool> isFavorited = ValueNotifier<bool>(false);
            String bookID = data![index].id.toString().substring(7);
            log("booksList: $booksList");
            return MouseRegion(
              onEnter: (event) => isHovering.value = true,
              onExit: (event) => isHovering.value = false,
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BooksDetailPage(bookID: bookID),
                    ),
                  );
                },
                child: booksCards(
                  data,
                  index,
                  isHovering,
                  isLiked,
                  isFavorited,
                  bookID,
                  booksList,
                  themeColor,
                  user,
                  gamesList,
                  moviesList,
                  seriesList,
                  actorsList,
                  favoritesList,
                ),
              ),
            );
          },
        );
      } else if (snapshot.connectionState == ConnectionState.waiting) {
        return const CustomCPI();
      } else {
        return const Center(
          child: Text("No result"),
        );
      }
    },
  );
}
