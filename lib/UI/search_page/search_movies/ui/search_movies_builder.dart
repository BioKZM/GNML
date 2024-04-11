import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Logic/moviepage_logic.dart';
import 'package:gnml/Data/movies_data.dart';
import 'package:gnml/UI/search_page/search_movies/ui/change_movie_pages.dart';
import 'package:gnml/UI/search_page/search_movies/ui/movie_cards_builder.dart';
import 'package:gnml/Widgets/circularprogressindicator.dart';

StatefulBuilder searchMoviesBuilder(
  User? user,
  List<dynamic> moviesList,
  int themeColor,
  List<dynamic> gamesList,
  List<dynamic> seriesList,
  List<dynamic> booksList,
  List<dynamic> actorsList,
  int pageIndexMovies,
  String searchText,
) {
  return StatefulBuilder(
    builder: (context, setState) {
      return FutureBuilder<int>(
          future: MoviePageLogic().getSearchResultsTotalPage(searchText),
          builder: (context, snapshot) {
            int? totalPages = snapshot.data;
            return FutureBuilder<List<dynamic>>(
              future: MoviesData().searchMovies(searchText, pageIndexMovies),
              builder: (context, snapshot) {
                var data = snapshot.data;

                if (snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.done) {
                  return PageView.builder(
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          movieCardsBuilder(data, moviesList, themeColor, user,
                              gamesList, seriesList, booksList, actorsList),
                          changeMoviePages(
                              pageIndexMovies, setState, totalPages),
                        ],
                      );
                    },
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const CustomCPI();
                } else {
                  return const Center(
                    child: Text("No result"),
                  );
                }
              },
            );
          });
    },
  );
}
