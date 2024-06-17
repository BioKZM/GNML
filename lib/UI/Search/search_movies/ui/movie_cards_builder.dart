import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/UI/Details/movie_detail_page.dart';
import 'package:gnml/Data/movies_data.dart';
import 'package:gnml/UI/Search/search_movies/ui/widget/movie_cards.dart';

Expanded movieCardsBuilder(
  List<dynamic>? data,
  List<dynamic> moviesList,
  int themeColor,
  User? user,
  List<dynamic> gamesList,
  List<dynamic> seriesList,
  List<dynamic> booksList,
  List<dynamic> actorsList,
  Map<String, dynamic> favoritesList,
) {
  return Expanded(
    child: SizedBox(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 350,
        ),
        itemCount: data?.length,
        itemBuilder: (context, innerIndex) {
          ValueNotifier<bool> isHovering = ValueNotifier<bool>(false);
          ValueNotifier<bool> isLiked = ValueNotifier<bool>(false);
          ValueNotifier<bool> isFavorited = ValueNotifier<bool>(false);
          int movieID = MoviesData().getMovieID(data, innerIndex);
          return MouseRegion(
            onEnter: (event) => isHovering.value = true,
            onExit: (event) => isHovering.value = false,
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieDetailPage(movieID: movieID),
                  ),
                );
              },
              child: movieCards(
                data!,
                innerIndex,
                isHovering,
                isLiked,
                isFavorited,
                moviesList,
                themeColor,
                user,
                gamesList,
                seriesList,
                booksList,
                actorsList,
                favoritesList,
              ),
            ),
          );
        },
      ),
    ),
  );
}
