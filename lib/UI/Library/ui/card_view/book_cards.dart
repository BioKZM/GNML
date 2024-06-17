import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/UI/Library/ui/card_view/widget/get_books_from_library.dart';

Card bookCardsTile(
    User? user,
    Map<String, dynamic> favoritesList,
    List<dynamic> booksList,
    int supportedLength,
    BuildContext context,
    int themeColor,
    List<dynamic> gamesList,
    List<dynamic> moviesList,
    List<dynamic> seriesList,
    List<dynamic> actorsList) {
  return Card(
    color: Colors.grey.withOpacity(0.2),
    child: Theme(
      data: ThemeData(
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        textColor: Colors.white,
        collapsedTextColor: Colors.white,
        collapsedIconColor: Colors.white,
        iconColor: Colors.white,
        title: const Text(
          "Books",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "RobotoBold",
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        children: List.generate(
          (booksList.length / supportedLength).ceil(),
          (rowIndex) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                supportedLength,
                (colIndex) {
                  final index = rowIndex * supportedLength + colIndex;

                  if (index < booksList.length) {
                    return getBooksFromLibrary(
                        booksList,
                        favoritesList,
                        index,
                        context,
                        themeColor,
                        user,
                        gamesList,
                        moviesList,
                        seriesList,
                        actorsList);
                  } else {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: GridTile(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 225,
                              width: 150,
                            )
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
    ),
  );
}
