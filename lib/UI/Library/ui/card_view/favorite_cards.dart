import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/UI/Library/ui/card_view/widget/favorites/get_favorite_actors_from_library.dart';
import 'package:gnml/UI/Library/ui/card_view/widget/favorites/get_favorite_books_from_library.dart';
import 'package:gnml/UI/Library/ui/card_view/widget/favorites/get_favorite_games_from_library.dart';
import 'package:gnml/UI/Library/ui/card_view/widget/favorites/get_favorite_movies_from_library.dart';
import 'package:gnml/UI/Library/ui/card_view/widget/favorites/get_favorite_series_from_library.dart';

Card favoriteCardsTile(
  User? user,
  Map<String, dynamic>? favoritesList,
  int supportedLength,
  BuildContext context,
  int themeColor,
) {
  List<dynamic> gamesList = favoritesList?['games'];
  List<dynamic> moviesList = favoritesList?['movies'];
  List<dynamic> seriesList = favoritesList?['series'];
  List<dynamic> booksList = favoritesList?['books'];
  List<dynamic> actorsList = favoritesList?['actors'];
  int totalLength = gamesList.length +
      moviesList.length +
      seriesList.length +
      booksList.length +
      actorsList.length;
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
        title: const Row(
          children: [
            Text(
              "Favorites",
              style: TextStyle(
                color: Colors.white,
                fontFamily: "RobotoBold",
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 4.0),
              child: Icon(Icons.star),
            ),
          ],
        ),
        children: List.generate(
          (totalLength / supportedLength).ceil(),
          (rowIndex) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                supportedLength,
                (colIndex) {
                  var index = rowIndex * supportedLength + colIndex;
                  if (index < gamesList.length) {
                    return getFavoriteGamesFromLibrary(
                      gamesList,
                      index,
                      context,
                      themeColor,
                      user,
                      moviesList,
                      seriesList,
                      booksList,
                      actorsList,
                    );
                  } else if (index >= gamesList.length &&
                      index < (gamesList.length + moviesList.length)) {
                    index -= gamesList.length;
                    return getFavoriteMoviesFromLibrary(
                        moviesList,
                        index,
                        context,
                        themeColor,
                        user,
                        gamesList,
                        seriesList,
                        booksList,
                        actorsList);
                  } else if (index >
                          (gamesList.length + moviesList.length) - 1 &&
                      index <
                          (gamesList.length +
                              moviesList.length +
                              seriesList.length)) {
                    index -= gamesList.length + moviesList.length;

                    return getFavoriteSeriesFromLibrary(
                        seriesList,
                        index,
                        context,
                        themeColor,
                        user,
                        gamesList,
                        moviesList,
                        booksList,
                        actorsList);
                  } else if (index >
                          (gamesList.length +
                                  moviesList.length +
                                  seriesList.length) -
                              1 &&
                      index <
                          (gamesList.length +
                              moviesList.length +
                              seriesList.length +
                              booksList.length)) {
                    index -= gamesList.length +
                        moviesList.length +
                        seriesList.length;
                    return getFavoriteBooksFromLibrary(
                        booksList,
                        index,
                        context,
                        themeColor,
                        user,
                        gamesList,
                        moviesList,
                        seriesList,
                        actorsList);
                  } else if (index >
                          (gamesList.length +
                                  moviesList.length +
                                  seriesList.length +
                                  booksList.length) -
                              1 &&
                      index <
                          (gamesList.length +
                              moviesList.length +
                              seriesList.length +
                              booksList.length +
                              actorsList.length)) {
                    index -= (gamesList.length +
                        moviesList.length +
                        seriesList.length +
                        booksList.length);
                    return getFavoriteActorsFromLibrary(
                        actorsList,
                        index,
                        context,
                        themeColor,
                        user,
                        gamesList,
                        moviesList,
                        seriesList,
                        booksList);
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
