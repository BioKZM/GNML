import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/movies_data.dart';
import 'package:gnml/UI/Desktop/Details/movie_detail_page.dart';
import 'package:gnml/UI/Desktop/Movies/widget/FavoritesWidget.dart';
import 'package:gnml/UI/Desktop/Movies/widget/InfoWidget.dart';
import 'package:gnml/UI/Desktop/Movies/widget/LikeWidget.dart';

PageView topRatedMoviesCards(
  User? user,
  List<dynamic>? data,
  List<dynamic> moviesList,
  Map<String, dynamic> favoritesList,
  int themeColor,
  List<dynamic> gamesList,
  List<dynamic> seriesList,
  List<dynamic> booksList,
  List<dynamic> actorsList,
  StateSetter setState,
  int? totalPages,
  int pageIndexTopRated,
) {
  return PageView.builder(
    itemBuilder: (context, index) {
      List<dynamic> favoriteGames = favoritesList['games'];
      List<dynamic> favoriteMovies = favoritesList['movies'];
      List<dynamic> favoriteSeries = favoritesList['series'];
      List<dynamic> favoriteBooks = favoritesList['books'];
      List<dynamic> favoriteActors = favoritesList['actors'];
      return Column(
        children: [
          SizedBox(
            height: 1500,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
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
                          builder: (context) =>
                              MovieDetailPage(movieID: movieID),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: double.infinity,
                              width: 400,
                              child: GridTile(
                                child: Stack(
                                  children: [
                                    Card(
                                      elevation: 0,
                                      shape: const RoundedRectangleBorder(
                                        side: BorderSide(
                                          color: Colors.transparent,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(0),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              // height: 240,
                                              width: 400,
                                              child: Image(
                                                fit: BoxFit.fill,
                                                image:
                                                    CachedNetworkImageProvider(
                                                        data![innerIndex]
                                                            .imageURL
                                                            .toString()),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    LikeWidget(
                                      isHovering: isHovering,
                                      isLiked: isLiked,
                                      data: data,
                                      innerIndex: innerIndex,
                                      gamesList: gamesList,
                                      moviesList: moviesList,
                                      seriesList: seriesList,
                                      booksList: booksList,
                                      actorsList: actorsList,
                                      themeColor: themeColor,
                                      user: user,
                                    ),
                                    FavoritesWidget(
                                      isHovering: isHovering,
                                      isFavorited: isFavorited,
                                      favoriteMovies: favoriteMovies,
                                      favoriteGames: favoriteGames,
                                      favoriteSeries: favoriteSeries,
                                      favoriteBooks: favoriteBooks,
                                      favoriteActors: favoriteActors,
                                      data: data,
                                      innerIndex: innerIndex,
                                      user: user,
                                    ),
                                    InfoWidget(
                                      isHovering: isHovering,
                                      data: data,
                                      innerIndex: innerIndex,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    },
  );
}
